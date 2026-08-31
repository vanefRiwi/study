-- =============================================================================
-- EVIDENCIA Y VALIDACIÓN DE LA CARGA EN POSTGRESQL
-- Proyecto: Cruise Revenue & Booking Analytics
-- Base de datos: cruises
--
-- Ejecutar tras correr `python analisis_cruiseship.py`.
-- Cada bloque genera una captura para el entregable de la Etapa 3.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. CONTEO DE FILAS POR TABLA
-- Esperado: 8 / 8 / 4 / 4 / 3 / 77040
-- -----------------------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM ships_dim)           AS ships,
    (SELECT COUNT(*) FROM countries_dim)       AS countries,
    (SELECT COUNT(*) FROM suites_dim)          AS suites,
    (SELECT COUNT(*) FROM packages_dim)        AS packages,
    (SELECT COUNT(*) FROM booking_sources_dim) AS sources,
    (SELECT COUNT(*) FROM bookings_fact)       AS facts;


-- -----------------------------------------------------------------------------
-- 2. VISTA PREVIA DE LA TABLA DE HECHOS
-- -----------------------------------------------------------------------------
SELECT *
FROM bookings_fact
ORDER BY booking_id
LIMIT 10;


-- -----------------------------------------------------------------------------
-- 3. VISTA PREVIA DE LAS DIMENSIONES
-- -----------------------------------------------------------------------------
SELECT * FROM ships_dim           ORDER BY id_ship;
SELECT * FROM countries_dim       ORDER BY id_country;
SELECT * FROM suites_dim          ORDER BY id_suite;
SELECT * FROM packages_dim        ORDER BY id_package;
SELECT * FROM booking_sources_dim ORDER BY id_booking_source;


-- -----------------------------------------------------------------------------
-- 4. AUSENCIA DE NULOS EN COLUMNAS CRÍTICAS
-- Esperado: todos los contadores en 0
-- -----------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE travel_date IS NOT NULL)                  AS travel_date_ok,
    COUNT(*) FILTER (WHERE travel_date IS NULL)                      AS travel_date_nulos,
    COUNT(*) FILTER (WHERE total_reservation_income_usd IS NULL)     AS ingreso_nulos,
    COUNT(*) FILTER (WHERE satisfaction_score IS NULL)               AS satisfaccion_nulos,
    COUNT(*) FILTER (WHERE price_category IS NULL)                   AS categoria_nulos,
    COUNT(*) FILTER (WHERE total_guest_spending_usd IS NULL)         AS gasto_nulos
FROM bookings_fact;


-- -----------------------------------------------------------------------------
-- 5. AUSENCIA DE DUPLICADOS EN LA LLAVE PRIMARIA
-- Esperado: 0 filas
-- -----------------------------------------------------------------------------
SELECT booking_id, COUNT(*) AS repeticiones
FROM bookings_fact
GROUP BY booking_id
HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- 6. INTEGRIDAD REFERENCIAL
-- Ninguna fila de hechos debe quedar huérfana. Esperado: 0 en las cinco columnas
-- -----------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE s.id_ship            IS NULL) AS huerfanos_ship,
    COUNT(*) FILTER (WHERE c.id_country         IS NULL) AS huerfanos_country,
    COUNT(*) FILTER (WHERE su.id_suite          IS NULL) AS huerfanos_suite,
    COUNT(*) FILTER (WHERE p.id_package         IS NULL) AS huerfanos_package,
    COUNT(*) FILTER (WHERE b.id_booking_source  IS NULL) AS huerfanos_source
FROM bookings_fact f
LEFT JOIN ships_dim           s  ON f.id_ship            = s.id_ship
LEFT JOIN countries_dim       c  ON f.id_country         = c.id_country
LEFT JOIN suites_dim          su ON f.id_suite           = su.id_suite
LEFT JOIN packages_dim        p  ON f.id_package         = p.id_package
LEFT JOIN booking_sources_dim b  ON f.id_booking_source  = b.id_booking_source;


-- -----------------------------------------------------------------------------
-- 7. RANGOS VÁLIDOS DE LAS MEDIDAS
-- Verifica que los CHECK constraints se cumplen en los datos reales
-- -----------------------------------------------------------------------------
SELECT
    MIN(satisfaction_score)               AS sat_min,
    MAX(satisfaction_score)               AS sat_max,
    MIN(nights_of_stay)                   AS noches_min,
    MAX(nights_of_stay)                   AS noches_max,
    MIN(lead_time_days)                   AS antelacion_min,
    MAX(lead_time_days)                   AS antelacion_max,
    MIN(total_reservation_income_usd)     AS ingreso_min,
    MAX(total_reservation_income_usd)     AS ingreso_max,
    MIN(cycle_occupancy_percentage)       AS ocupacion_min,
    MAX(cycle_occupancy_percentage)       AS ocupacion_max
FROM bookings_fact;


-- -----------------------------------------------------------------------------
-- 8. COBERTURA TEMPORAL
-- Documenta el año 2022 parcial que se excluye en Power BI
-- -----------------------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM travel_date)::INT       AS anio,
    COUNT(*)                                  AS reservas,
    MIN(travel_date)                          AS primera_fecha,
    MAX(travel_date)                          AS ultima_fecha,
    ROUND(SUM(total_reservation_income_usd), 2) AS ingreso_total
FROM bookings_fact
GROUP BY 1
ORDER BY 1;


-- -----------------------------------------------------------------------------
-- 9. VALIDACIÓN DE LAS COLUMNAS DERIVADAS
-- 9a. price_category debe repartir las reservas en tres tercios iguales
-- -----------------------------------------------------------------------------
SELECT
    price_category,
    COUNT(*)                                     AS reservas,
    ROUND(AVG(total_reservation_income_usd), 2)  AS ingreso_promedio,
    ROUND(MIN(total_reservation_income_usd), 2)  AS ingreso_min,
    ROUND(MAX(total_reservation_income_usd), 2)  AS ingreso_max
FROM bookings_fact
GROUP BY price_category
ORDER BY ingreso_promedio;

-- 9b. total_guest_spending_usd es determinística: debe reproducirse exactamente.
--     Esperado: 0 discrepancias
SELECT COUNT(*) AS discrepancias
FROM bookings_fact
WHERE ABS(
        total_guest_spending_usd
        - (average_daily_guest_spending_usd * nights_of_stay * passengers_on_booking)
      ) > 0.01;


-- -----------------------------------------------------------------------------
-- 10. CONTRASTE CONTRA LAS MEDIDAS DEL TABLERO
-- Reproduce en SQL los números que Power BI debe mostrar (alcance 2018-2021).
-- Sirve para verificar que el DAX está bien filtrado.
-- -----------------------------------------------------------------------------

-- 10a. KPIs generales
SELECT
    COUNT(*)                                        AS reservas,
    ROUND(SUM(total_reservation_income_usd), 2)     AS ingreso_total,
    ROUND(AVG(total_reservation_income_usd), 2)     AS ticket_promedio,
    ROUND(AVG(satisfaction_score), 2)               AS satisfaccion_promedio
FROM bookings_fact
WHERE travel_date < DATE '2022-01-01';

-- 10b. Q2 — Ranking de navieras (nótese el volumen idéntico)
SELECT
    s.company,
    COUNT(*)                                                   AS reservas,
    ROUND(SUM(f.total_reservation_income_usd), 2)              AS ingreso,
    ROUND(AVG(f.total_reservation_income_usd), 2)              AS ticket_promedio,
    ROUND(SUM(f.total_reservation_income_usd)
          / SUM(f.nights_of_stay), 2)                          AS ingreso_por_noche
FROM bookings_fact f
JOIN ships_dim s ON f.id_ship = s.id_ship
WHERE f.travel_date < DATE '2022-01-01'
GROUP BY s.company
ORDER BY ingreso DESC;

-- 10c. Q3 — Concentración por país con acumulado (Pareto)
WITH por_pais AS (
    SELECT
        c.guest_country,
        SUM(f.total_reservation_income_usd) AS ingreso
    FROM bookings_fact f
    JOIN countries_dim c ON f.id_country = c.id_country
    WHERE f.travel_date < DATE '2022-01-01'
    GROUP BY c.guest_country
)
SELECT
    guest_country,
    ROUND(ingreso, 2)                                                   AS ingreso,
    ROUND(100 * ingreso / SUM(ingreso) OVER (), 1)                      AS pct,
    ROUND(100 * SUM(ingreso) OVER (ORDER BY ingreso DESC)
              / SUM(ingreso) OVER (), 1)                                AS pct_acumulado
FROM por_pais
ORDER BY ingreso DESC;

-- 10d. Q4 — Variación trimestre contra trimestre
WITH por_trimestre AS (
    SELECT
        EXTRACT(YEAR    FROM travel_date)::INT AS anio,
        EXTRACT(QUARTER FROM travel_date)::INT AS trimestre,
        SUM(total_reservation_income_usd)      AS ingreso
    FROM bookings_fact
    WHERE travel_date < DATE '2022-01-01'
    GROUP BY 1, 2
)
SELECT
    anio || '-Q' || trimestre                                     AS periodo,
    ROUND(ingreso, 2)                                             AS ingreso,
    ROUND(100 * (ingreso - LAG(ingreso) OVER (ORDER BY anio, trimestre))
              / LAG(ingreso) OVER (ORDER BY anio, trimestre), 1)  AS variacion_qoq_pct
FROM por_trimestre
ORDER BY anio, trimestre;

-- 10e. Q5 — Satisfacción contra gasto diario (base del scatter)
SELECT
    ROUND(satisfaction_score, 1)                        AS rango_satisfaccion,
    COUNT(*)                                            AS reservas,
    ROUND(AVG(average_daily_guest_spending_usd), 2)     AS gasto_diario_promedio
FROM bookings_fact
WHERE travel_date < DATE '2022-01-01'
GROUP BY 1
ORDER BY 1;

-- 10f. Q5 — Coeficiente de correlación de Pearson calculado en el motor
SELECT ROUND(
           CORR(satisfaction_score, average_daily_guest_spending_usd)::NUMERIC,
           3
       ) AS r_satisfaccion_gasto
FROM bookings_fact
WHERE travel_date < DATE '2022-01-01';
