# Cruise Revenue & Booking Analytics

Pipeline de datos de extremo a extremo: extracción de un dataset de reservas de cruceros desde Kaggle, transformación y normalización con pandas, persistencia en PostgreSQL bajo un modelo estrella y consumo desde Power BI mediante el conector nativo.

**Autora:** Vane · Ingeniera de Sistemas y Computación
**Módulo:** Ingeniería de Datos — ETL, Bases de Datos y BI

---

## 1. Ficha del dataset

| Atributo | Valor |
|---|---|
| Origen | Kaggle — dataset de reservas de cruceros |
| Archivo fuente | `cruises_unclean.csv` |
| Registros | 77.040 reservas |
| Columnas originales | 20 |
| Columnas tras enriquecimiento | 22 |
| Rango temporal | 5 de enero de 2018 a 6 de febrero de 2022 |
| Granularidad | Una fila = una reserva individual |

**Por qué se eligió.** El dataset cumple con holgura los mínimos exigidos (5 columnas, 1.000 filas) y ofrece una combinación poco común de variables que habilita análisis de negocio reales:

- **Dos columnas de fecha** (`travel_date` y `booking_date`), lo que permite construir métricas de antelación de reserva además de la serie temporal.
- **Seis dimensiones categóricas** (naviera, barco, ruta, tipo de suite, canal de venta, país de origen) que soportan agregaciones y segmentación.
- **Ocho variables numéricas continuas**, incluyendo ingreso por reserva, gasto diario a bordo, ocupación del ciclo y puntaje de satisfacción.

Esa estructura permite formular preguntas de negocio de distinto tipo: evolución temporal, ranking competitivo, concentración de mercado, comparación entre periodos y correlación entre variables de experiencia y monetización.

### Diccionario de datos

| Columna | Tipo | Descripción |
|---|---|---|
| `booking_id` | int | Identificador único de la reserva |
| `travel_date` | date | Fecha de zarpe |
| `booking_date` | date | Fecha en que se realizó la reserva |
| `lead_time_days` | int | Días de antelación entre reserva y viaje (5 a 267) |
| `nights_of_stay` | int | Duración del crucero en noches |
| `ship_name` | str | Nombre del barco (8 valores) |
| `company` | str | Naviera operadora (8 valores) |
| `route_type` | str | Itinerario (7 valores) |
| `suite_type` | str | Categoría de camarote |
| `booking_source` | str | Canal de venta (Direct, B2B, Web) |
| `package` | str | Régimen contratado (4 valores) |
| `guest_country` | str | País de origen del huésped (8 valores) |
| `total_cabins` | int | Capacidad total del barco *(atributo del barco, no de la reserva)* |
| `booked_cabins` | int | Camarotes incluidos en la reserva |
| `cycle_occupancy_percentage` | float | Ocupación del ciclo de navegación |
| `passengers_on_booking` | int | Pasajeros en la reserva |
| `total_crew` | int | Tripulación del barco *(atributo del barco, no de la reserva)* |
| `total_reservation_income_usd` | float | **Métrica principal.** Ingreso generado por la reserva |
| `average_daily_guest_spending_usd` | float | Gasto diario a bordo por huésped |
| `satisfaction_score` | float | Puntaje de satisfacción (escala 0-5) |
| `total_guest_spending_usd` | float | **Derivada.** Gasto total estimado del huésped |
| `price_category` | str | **Derivada.** Tercil de precio (Low / Medium / High) |

> **Advertencia de modelado.** `total_cabins` y `total_crew` describen al barco, no a la reserva, y se repiten en cada fila del dataset original. Por eso viven en `ships_dim` y **nunca deben agregarse con `SUM`** — solo con promedio o máximo por barco.

---

## 2. Diagrama del pipeline

Ver `pipeline_etl.drawio` (editable en [draw.io](https://app.diagrams.net)) y su exportación `pipeline_etl.png`.

```
Kaggle CSV → pandas (Extract) → limpieza + tipado + derivadas (Transform)
           → normalización a esquema estrella
           → SQLAlchemy + psycopg2 (Load) → PostgreSQL `cruises`
           → conector nativo PostgreSQL → Power BI (Consumo)
```

---

## 3. Proceso ETL

### Extract

`analisis_cruiseship.py` lee `cruises_unclean.csv` con `pandas.read_csv()` y homologa los nombres de columna del español original al inglés mediante un diccionario de mapeo (`columnas_map`), estableciendo `snake_case` como convención. También se homologan los valores de `route_type`, que venían mezclados en dos idiomas (`Mediterráneo` → `Mediterranean`).

### Transform

| Operación | Implementación |
|---|---|
| Normalización de nombres | `df.rename(columns=columnas_map)` — 20 columnas a `snake_case` en inglés |
| Homologación de valores | `route_type.replace()` para unificar el idioma de los itinerarios |
| Corrección de tipos | `pd.to_datetime()` sobre `travel_date` y `booking_date` |
| Auditoría de nulos | `df.isnull().sum()` antes y después de la limpieza |
| Eliminación de duplicados | `df.drop_duplicates()` con reporte del delta de filas |
| Columna derivada 1 | `total_guest_spending_usd = gasto_diario × noches × pasajeros` |
| Columna derivada 2 | `price_category` mediante `pd.qcut(q=3)` sobre el ingreso |

**Sobre las columnas derivadas.** `price_category` segmenta las reservas en terciles de ingreso, generando tres grupos de 25.680 registros cada uno con ingreso promedio de 1.994 USD (Low), 3.236 USD (Medium) y 6.517 USD (High). Es la variable que habilita segmentación cruzada en el tablero.

`total_guest_spending_usd` estima el gasto total a bordo. **Es una columna determinística**: se calcula íntegramente a partir de otras tres del dataset. Esto tiene una consecuencia analítica importante que se documenta en `CONCLUSIONES.md` — cualquier correlación entre esta columna y el ingreso de reserva es un artefacto de construcción, no un hallazgo, porque ambas comparten los factores `noches` y `pasajeros`.

### Normalización a esquema estrella

Se extraen cinco dimensiones desde la tabla plana, cada una con clave subrogada generada por `range()`:

| Tabla | Filas | Clave |
|---|---:|---|
| `ships_dim` | 8 | `id_ship` |
| `countries_dim` | 8 | `id_country` |
| `suites_dim` | 4 | `id_suite` |
| `packages_dim` | 4 | `id_package` |
| `booking_sources_dim` | 3 | `id_booking_source` |
| `bookings_fact` | 77.040 | `booking_id` |

Los identificadores se reincorporan a la tabla de hechos mediante `merge()` con `how="left"` sobre los atributos naturales, y la tabla de hechos final conserva únicamente claves, fechas y medidas.

### Validaciones

`postgres.py` implementa un **contrato de datos** que se ejecuta antes de cualquier escritura (`_validar_star_schema`), y aborta la carga si falla:

1. **Contrato de columnas.** Verifica que cada DataFrame tenga exactamente el conjunto de columnas esperado — ni de más ni de menos.
2. **Unicidad de llaves primarias.** Comprueba que ningún `id_*` ni `booking_id` esté duplicado.
3. **Integridad referencial preventiva.** Confirma que ninguna llave foránea de la tabla de hechos sea nula antes de intentar el INSERT.

A nivel de motor, el DDL agrega una segunda capa de validación con `CHECK` constraints:

```sql
CONSTRAINT ck_lead_time_positivo     CHECK (lead_time_days >= 0),
CONSTRAINT ck_nights_positivo        CHECK (nights_of_stay > 0),
CONSTRAINT ck_cabins_positivo        CHECK (booked_cabins > 0),
CONSTRAINT ck_passengers_positivo    CHECK (passengers_on_booking > 0),
CONSTRAINT ck_income_positivo        CHECK (total_reservation_income_usd >= 0),
CONSTRAINT ck_spending_positivo      CHECK (average_daily_guest_spending_usd >= 0),
CONSTRAINT ck_satisfaction_rango     CHECK (satisfaction_score BETWEEN 0.0 AND 5.0)
```

Y una validación final de conteos compara las filas del DataFrame contra las efectivamente registradas en Postgres, lanzando excepción ante cualquier divergencia.

### Load

La carga es **atómica**: todo el DDL y la ingesta ocurren dentro de una única transacción (`with engine.begin()`), de modo que un fallo en cualquier punto revierte la operación completa y no deja la base en estado intermedio.

Detalles de implementación:

- Las dimensiones se insertan antes que la tabla de hechos, respetando el orden de dependencia de las llaves foráneas.
- `bookings_fact` se carga por lotes (`chunksize=5000`, `method="multi"`).
- Los índices sobre llaves foráneas y fechas se crean **después** de la inserción, no antes, lo que acelera significativamente la carga masiva.
- El `DROP TABLE ... CASCADE` inicial hace el script idempotente: puede reejecutarse sin errores de estado previo.

---

## 4. Modelo de datos en PostgreSQL

```
                    ┌──────────────────┐
                    │  packages_dim    │
                    │  id_package (PK) │
                    └────────┬─────────┘
                             │
┌──────────────────┐    ┌────┴──────────────────┐   ┌──────────────────┐
│booking_sources   │    │   bookings_fact       │   │  countries_dim   │
│id_booking_source │────│   booking_id (PK)     │───│  id_country (PK) │
└──────────────────┘    │   id_ship      (FK)   │   └──────────────────┘
                        │   id_country   (FK)   │
┌──────────────────┐    │   id_suite     (FK)   │   ┌──────────────────┐
│   suites_dim     │────│   id_package   (FK)   │───│   ships_dim      │
│   id_suite (PK)  │    │   id_booking_… (FK)   │   │   id_ship (PK)   │
└──────────────────┘    │   + medidas           │   └──────────────────┘
                        └───────────────────────┘
```

**Decisiones de tipado:**

- `NUMERIC(12,2)` para importes monetarios, evitando el error de redondeo de punto flotante que introduciría `FLOAT`.
- `NUMERIC(5,2)` para porcentajes de ocupación y `NUMERIC(3,1)` para el puntaje de satisfacción, ajustados al rango real de cada variable.
- `DATE` en lugar de `TIMESTAMP`, dado que el dataset no maneja componente horario.
- Restricciones `UNIQUE` sobre los atributos naturales de cada dimensión (`ship_name`, `guest_country`, etc.) para impedir duplicados lógicos aunque la clave subrogada difiera.

---

## 5. Ejecución

### Requisitos

```bash
pip install pandas sqlalchemy psycopg2-binary
```

- Python 3.10+
- PostgreSQL con una base de datos llamada `cruises` ya creada

### Configuración

Ajusta las credenciales en la cabecera de `postgres.py`:

```python
USUARIO    = "postgres"
PASSWORD   = "tu_password"
HOST       = "localhost"
PUERTO     = 5432
BASE_DATOS = "cruises"
```

> En un entorno real estas credenciales deberían leerse de variables de entorno (`os.getenv`) y no estar en el código versionado.

### Ejecución del pipeline

```bash
python analisis_cruiseship.py
```

El script ejecuta las fases de extracción, transformación y normalización, e invoca automáticamente `cargar_esquema_estrella()` para la carga en PostgreSQL.

---

## 6. Evidencia de la carga

Consultas de verificación en `validacion_carga.sql`. Resultados esperados:

```
 ships | countries | suites | packages | sources | facts
-------+-----------+--------+----------+---------+-------
     8 |         8 |      4 |        4 |       3 | 77040
```

Verificación de integridad referencial (debe devolver 0 filas):

```sql
SELECT COUNT(*) FROM bookings_fact f
LEFT JOIN ships_dim s ON f.id_ship = s.id_ship
WHERE s.id_ship IS NULL;
```

---

## 7. Consumo desde Power BI

Conexión mediante **conector nativo PostgreSQL** en modo Importar:

```
Servidor: localhost:5432
Base de datos: cruises
```

En Power Query se aplica un filtro sobre `bookings_fact` que excluye los registros posteriores al 31 de diciembre de 2021.

**Justificación del recorte.** El dataset se interrumpe el 6 de febrero de 2022, dejando ese año con solo 2.040 registros frente a los ~18.720 de cada año completo. Incluirlo produciría una caída artificial al final de la serie temporal que se leería como un desplome de ingresos inexistente, y descuadraría las tarjetas KPI respecto a los gráficos. El análisis cubre por tanto **2018-2021**, cuatro años completos y comparables entre sí (75.000 reservas, 294,17 M USD).

El modelo en Power BI añade una tabla `calendario` desconectada del origen, relacionada 1:* con `bookings_fact[travel_date]` en dirección de filtro única, y marcada como tabla de fechas para habilitar las funciones de inteligencia temporal.

---

## 8. Estructura del repositorio

```
.
├── README.md
├── CONCLUSIONES.md
├── analisis_cruiseship.py
├── postgres.py
├── validacion_carga.sql
├── pipeline_etl.drawio
├── data/
│   └── cruises_unclean.csv
├── powerbi/
│   └── cruise_analytics.pbix
└── evidencias/
    ├── postgres_conteos.png
    ├── postgres_select.png
    ├── powerbi_conector.png
    └── q1_a_q5_visuales.png
```
