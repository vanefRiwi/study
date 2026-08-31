# Conclusiones del tablero — Cruise Industry Revenue Analytics

**Alcance:** 2018-2021 · 75.000 reservas · 294,18 M USD
**Métrica principal:** `total_reservation_income_usd`
**Fuente:** PostgreSQL (esquema estrella) vía conector nativo de Power BI

---

## KPIs de resumen

| Indicador | Valor |
|---|---:|
| Ingreso total por reservas | 294,18 M USD |
| Reservas | 75.000 |
| Gasto total a bordo | 175,49 M USD |
| Ingreso promedio por reserva | 3.922,34 USD |
| Duración promedio del crucero | 7,66 noches |
| Ocupación promedio del ciclo | 91,37% |
| Satisfacción promedio | 4,58 / 5 |

---

## Nota metodológica

**Exclusión de 2022.** El dataset se interrumpe el 6 de febrero de 2022, dejando ese año con 2.040 registros frente a los ~18.720 de un año completo. Incluirlo produce una caída del 89% al cierre de la serie temporal que se leería como un colapso comercial inexistente. El análisis se acota a los cuatro años completos y comparables.

**Descarte de una correlación aparente.** La columna derivada `total_guest_spending_usd` se calcula como `gasto_diario × noches × pasajeros`. Correlacionarla contra el ingreso de reserva arroja r = 0,979, pero ambas variables comparten los factores *noches* y *pasajeros*: la correlación es un artefacto aritmético, no un hallazgo. Se sustituyó por un par de variables genuinamente independientes para responder Q5.

---

## Q1 — ¿Cómo ha evolucionado el ingreso por reservas a lo largo del tiempo?

**Visual:** gráfico de líneas, ingreso mensual/anual · **Apoyo:** ingreso promedio por mes

### Respuesta

El ingreso anual es **estructuralmente estable**: 73,39 M (2018), 73,51 M (2019), 73,92 M (2020) y 73,35 M (2021). La variación acumulada en cuatro años no alcanza el 1%.

La evolución relevante no está en el nivel anual sino en el **ciclo intra-anual**, que se repite de forma idéntica los cuatro años. El ingreso promedio mensual va de 4,5 M en febrero a 6,7 M en agosto, con un valle secundario en noviembre (5,6 M).

| Mes | Ingreso promedio |
|---|---:|
| Febrero | 4,5 M |
| Marzo–Julio | 6,3–6,5 M |
| **Agosto (pico)** | **6,7 M** |
| Noviembre (valle) | 5,6 M |

El mínimo de febrero responde en parte a que el mes concentra menos fechas de zarpe, no solo a menor demanda.

### Implicación

Un análisis limitado al agregado anual concluiría que el negocio está estancado. La lectura correcta es que **el negocio es estable en volumen pero fuertemente estacional en distribución**, lo que traslada la decisión de planeación del eje anual al eje mensual: dotación de tripulación, programación de mantenimiento y campañas comerciales deben calendarizarse contra el ciclo de verano.

---

## Q2 — ¿Qué cinco navieras generan el mayor ingreso por reservas?

**Visual:** barras horizontales Top 5 · **Apoyo:** tabla con volumen, ticket promedio e ingreso por noche

### Respuesta

| # | Naviera | Ingreso | Reservas | Ticket promedio | Ingreso/noche |
|---|---|---:|---:|---:|---:|
| 1 | Cunard Line | 76,3 M | 9.630 | 7.921,70 | 587,54 |
| 2 | Celebrity Cruises | 47,3 M | 9.630 | 4.916,39 | 513,22 |
| 3 | Norwegian Cruise Line | 37,6 M | 9.630 | 3.902,58 | 460,48 |
| 4 | Royal Caribbean | 34,3 M | 9.630 | 3.558,22 | 543,38 |
| 5 | MSC Cruceros | 30,8 M | 9.630 | 3.193,17 | 493,38 |
| | *(8ª) Disney Cruise Line* | *19,7 M* | *9.630* | *2.047,46* | *562,70* |

Las ocho navieras registran **exactamente 9.630 reservas cada una**. Con el volumen fijado, el ranking no mide popularidad ni cuota de mercado: mide únicamente ticket promedio. Cunard factura 3,87 veces lo de Disney, y su ticket promedio es 3,87 veces mayor — la proporción coincide porque el volumen se cancela.

### El dato que cambia la conclusión

Al normalizar por noche vendida, **Disney escala de la última posición a la segunda** (562,70 USD), a solo un 4% de Cunard. La ventaja de Cunard no proviene de cobrar más por noche sino de operar travesías más largas: Transatlantic promedia 13,5 noches frente a las 3,6 de Bahamas.

### Implicación

El ranking por facturación absoluta premia la duración del itinerario, no la eficiencia comercial. Medida por noche, la brecha entre la primera y la última naviera se reduce de **3,87x a 1,04x**. Cualquier benchmarking o decisión de inversión basada solo en ingreso total estaría comparando modelos de negocio distintos como si fueran competidores directos.

---

## Q3 — ¿Cómo se distribuye el ingreso entre rutas? ¿Existe concentración?

**Visual:** Pareto — columnas de ingreso por ruta + línea de acumulado + referencia al 80%

### Respuesta

| Ruta | Ingreso | % acumulado |
|---|---:|---:|
| Transatlantic | 74,40 M | 25,3% |
| Mediterranean | 57,52 M | 44,8% |
| Alaska | 46,20 M | 60,6% |
| Fiordos | 36,69 M | 73,0% |
| **Caribbean** | **33,36 M** | **84,4%** |
| Canarias | 26,73 M | 93,4% |
| Bahamas | 19,27 M | 100% |

**No se cumple el principio de Pareto.** Se requieren **cinco de siete rutas** —el 71% de los grupos, no el 20%— para superar el 80% del ingreso. La línea acumulada cruza el umbral en Caribbean, la quinta ruta.

La distribución es notablemente uniforme: no hay un itinerario que domine la cartera ni rutas residuales que puedan descartarse sin costo relevante.

### Matiz necesario

La jerarquía observada no refleja rentabilidad sino **duración del itinerario**. Transatlantic encabeza con 13,5 noches promedio; Bahamas cierra con 3,6. Normalizando por noche vendida, el orden se comprime drásticamente y Bahamas resulta competitiva pese a ocupar el último lugar en facturación absoluta.

### Implicación

La cartera de itinerarios está **diversificada, no concentrada**. Ninguna ruta representa un riesgo de dependencia, y ninguna es prescindible por bajo aporte. La decisión sobre qué itinerarios priorizar debe tomarse sobre ingreso por noche —que mide el rendimiento del activo escaso, el barco— y no sobre ingreso por reserva.

---

## Q4 — ¿Cuál fue la variación porcentual del ingreso entre trimestres consecutivos?

**Visual:** columnas por trimestre + matriz con variación QoQ e indicadores de dirección

### Respuesta

La comparación año contra año es estéril: **2021 vs 2020 arroja −0,77%**, indistinguible del ruido. Bajando al nivel trimestral aparece un patrón que se repite los cuatro años **sin una sola excepción**:

| Transición | 2018 | 2019 | 2020 | 2021 |
|---|---:|---:|---:|---:|
| Q1 → Q2 | +11,6% | +7,7% | +8,5% | +9,4% |
| Q2 → Q3 | +3,2% | +2,5% | +1,3% | +0,9% |
| Q3 → Q4 | −6,9% | −7,1% | −4,3% | −3,2% |
| Q4 → Q1 (año sig.) | −1,6% | −7,1% | −6,3% | — |

Cuatro años, dieciséis transiciones, cero excepciones al patrón: **el segundo trimestre siempre sube entre 7,7% y 11,6%; el cuarto siempre cae**. La oscilación entre el pico de Q2-Q3 y el valle de Q4-Q1 ronda los 15 puntos porcentuales.

Se observa además una **atenuación progresiva**: las caídas de Q4 se moderan de −6,9% en 2018 a −3,2% en 2021, sugiriendo una suavización gradual de la estacionalidad.

### Implicación

La elección del periodo de comparación no es un detalle técnico sino una decisión analítica que determina la conclusión. Comparando años, el negocio "no hace nada". Comparando trimestres, revela una estacionalidad predecible y accionable sobre la que sí se puede planear capacidad, precios dinámicos e inventario.

---

## Q5 — ¿Existe relación entre satisfacción y gasto diario a bordo?

**Visual:** dispersión con línea de tendencia · Correlación de Pearson: **r = 0,735**

### Respuesta

| Satisfacción | Gasto diario (USD) | Reservas |
|---:|---:|---:|
| 4,1 | 136,99 | 3.109 |
| 4,2 | 137,32 | 5.627 |
| 4,3 | 140,03 | 6.927 |
| 4,4 | 147,76 | 7.575 |
| 4,5 | 158,58 | 8.101 |
| 4,6 | 172,10 | 8.824 |
| 4,7 | 186,61 | 9.581 |
| 4,8 | 195,97 | 9.628 |
| 5,0 | 203,59 | 6.535 |

Sí, la relación es positiva y fuerte. Pero **el hallazgo no es la correlación sino la forma de la curva**: entre 4,1 y 4,3 el gasto está congelado —se mueve tres dólares en total—, y a partir de 4,3 se dispara hasta acumular +45% en el tramo restante.

Existe un **umbral en torno a 4,3** por debajo del cual la mejora de experiencia no se traduce en monetización.

### Contraste por itinerario

| Ruta | Satisfacción | Gasto diario | Posición |
|---|---:|---:|---|
| Canarias | 4,30 | 129,54 | **Punto de inflexión** |
| Mediterranean | 4,35 | 152,07 | **Punto de inflexión** |
| Fiordos | 4,50 | 144,69 | Zona rentable |
| Alaska | 4,70 | 175,50 | Zona rentable |
| Caribbean | 4,80 | 191,46 | Zona rentable |
| Transatlantic | 4,80 | 219,21 | Saturación |
| Bahamas | 4,88 | 204,54 | Saturación |

### Implicación

La inversión en experiencia a bordo no rinde igual en todas las rutas. **Canarias (4,30) y Mediterranean (4,35) están exactamente en el punto de inflexión**: una mejora marginal de satisfacción en esos itinerarios tendría el mayor retorno incremental en gasto a bordo. Bahamas (4,88) ya opera en la zona plana superior, donde una mejora adicional aportaría poco.

### Limitación

La dirección causal no queda establecida: es igualmente plausible que quienes gastan más a bordo reporten mayor satisfacción por haber consumido más servicios. Determinarlo exigiría un diseño experimental que el dataset no permite.

---

## Análisis complementarios

Visuales adicionales incluidos en el tablero como soporte de las cinco preguntas principales.

**Composición por categoría de precio.** El tercil High concentra 163,40 M (55,5% del ingreso) frente a 49,67 M del tercil Low (16,9%), pese a que los tres grupos contienen exactamente el mismo número de reservas por construcción del `qcut`.

**Distribución por tipo de camarote.** Balcony lidera con 103,72 M (35,3%), seguido de Interior (87,60 M) y Oceanview (73,96 M). Suite aporta solo 28,90 M (9,8%), consistente con su menor disponibilidad. Sin embargo, el ingreso **promedio** por reserva es prácticamente idéntico entre categorías (Balcony 3.910 USD vs Suite 3.933 USD), por lo que el tipo de camarote no discrimina el valor de la reserva.

**Distribución por canal de venta.** B2B domina con 131,29 M (44,6%), seguido de Web (103,37 M) y Direct (59,51 M). Al igual que con el camarote, el ticket promedio no varía entre canales (Web 3.929 USD vs B2B 3.901 USD): el canal determina volumen, no valor.

**Duración promedio por ruta.** Transatlantic 13,5 noches, Alaska 9,6, Fiordos 8,5, Canarias 6,6, Caribbean 6,6, Mediterranean 6,5, Bahamas 3,6. Esta tabla es la que explica el ranking de Q2 y el orden del Pareto de Q3.

---

## Síntesis ejecutiva

| Pregunta | Hallazgo | Acción sugerida |
|---|---|---|
| Q1 · Tendencia | Ingreso anual plano con ciclo estacional consistente | Planear capacidad contra el ciclo mensual |
| Q2 · Top navieras | Volumen idéntico; el ranking mide duración, no precio | Evaluar por ingreso/noche, no por facturación |
| Q3 · Distribución | Cartera diversificada; se requieren 5 de 7 rutas para el 80% | Ninguna ruta es prescindible ni dominante |
| Q4 · Periodos | −0,77% anual, pero ±15 puntos entre trimestres | Usar el trimestre como unidad de comparación |
| Q5 · Relación | r = 0,735 con umbral de monetización en 4,3 | Priorizar Canarias y Mediterranean en experiencia |

---

## Limitaciones del análisis

1. **Volumen uniforme por naviera.** Las 9.630 reservas idénticas en las ocho compañías indican un dataset construido de forma balanceada, lo que anula cualquier análisis de cuota de mercado o captación de demanda.
2. **Ausencia del efecto pandemia.** El año 2020 no registra caída alguna respecto a 2019, comportamiento que no corresponde con el del sector real de cruceros. Las conclusiones son válidas dentro del dataset pero no extrapolables a la industria.
3. **Colinealidad entre dimensiones.** Naviera, barco y ruta son prácticamente equivalentes: cada compañía opera un único barco en un único itinerario, con la sola excepción de Mediterranean (compartida por MSC y Costa). Esto impide separar el efecto de la compañía del efecto de la ruta.
4. **Dimensiones sin poder discriminante.** `suite_type` y `booking_source` no muestran diferencias apreciables de ticket promedio, por lo que su aporte al análisis es descriptivo y no explicativo.
