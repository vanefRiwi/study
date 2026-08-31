# Conclusiones del tablero — Cruise Industry Revenue Analytics

**Alcance:** 2018-2022 · 77.040 reservas · 301,67 M USD
**Métrica principal:** `total_reservation_income_usd`
**Fuente:** PostgreSQL (esquema estrella) vía conector nativo de Power BI

---

## KPIs de resumen

| Indicador | Valor |
|---|---:|
| Ingreso total por reservas | 301,67 M USD |
| Reservas | 77.040 |
| Gasto total a bordo | 179,97 M USD |
| Ingreso promedio por reserva | 3.915,75 USD |
| Duración promedio del crucero | 7,66 noches |
| Ocupación promedio del ciclo | 91,18% |
| Satisfacción promedio | 4,58 / 5 |

---

## Nota metodológica

**Cobertura temporal desigual.** El dataset abarca del 5 de enero de 2018 al 6 de febrero de 2022. Los cuatro primeros años están completos (~18.720 reservas cada uno), mientras que **2022 contiene únicamente 2.040 registros correspondientes a cinco semanas de operación**.

| Año | Reservas | Ingreso | Cobertura |
|---|---:|---:|---|
| 2018 | 18.720 | 73,39 M | Completo |
| 2019 | 18.720 | 73,51 M | Completo |
| 2020 | 18.720 | 73,92 M | Completo |
| 2021 | 18.840 | 73,35 M | Completo |
| **2022** | **2.040** | **7,49 M** | **Parcial (ene – 6 feb)** |

Esto tiene una consecuencia directa sobre la lectura de los visuales: **la caída del ingreso en 2022 no representa un deterioro comercial**, sino la interrupción de la serie de datos. Cualquier comparación que involucre 2022 —variación anual, ranking por año, participación relativa— carece de validez, y por ello los análisis comparativos de este documento se apoyan en el periodo 2018-2021.

**Descarte de una correlación aparente.** La columna derivada `total_guest_spending_usd` se calcula como `gasto_diario × noches × pasajeros`. Correlacionarla contra el ingreso de reserva arroja r = 0,979, pero ambas variables comparten los factores *noches* y *pasajeros*: la correlación es un artefacto aritmético de la construcción de la columna, no un hallazgo de negocio. Se sustituyó por un par de variables genuinamente independientes para responder Q5.

---

## Q1 — ¿Cómo ha evolucionado el ingreso por reservas a lo largo del tiempo?

**Visual:** gráfico de líneas, tendencia anual · **Apoyo:** ingreso promedio por mes y matriz de estacionalidad mensual

### Respuesta

El ingreso anual es **estructuralmente estable** durante todo el periodo completo: 73,39 M (2018), 73,51 M (2019), 73,92 M (2020) y 73,35 M (2021). La variación acumulada en cuatro años no alcanza el 1%. La caída visible en 2022 corresponde al corte del dataset, no a una contracción del negocio.

La evolución relevante no está en el nivel anual sino en el **ciclo intra-anual**, que se repite de forma prácticamente idéntica cada año. El ingreso promedio por reserva oscila entre 3.575 USD en noviembre y 4.151 USD en julio.

| Mes | Ingreso promedio por reserva |
|---|---:|
| Enero | 3.616 |
| Febrero | 3.628 |
| Marzo | 3.896 |
| Junio | 4.122 |
| **Julio (pico)** | **4.151** |
| Agosto | 4.137 |
| **Noviembre (valle)** | **3.575** |
| Diciembre | 4.061 |

El patrón muestra un ascenso sostenido de enero a julio, meseta en agosto-octubre, mínimo anual en noviembre y repunte en diciembre por temporada de fin de año.

### Implicación

Un análisis limitado al agregado anual concluiría que el negocio está estancado. La lectura correcta es que **el negocio es estable en volumen pero fuertemente estacional en distribución**, lo que traslada la decisión de planeación del eje anual al eje mensual: dotación de tripulación, programación de mantenimiento y campañas comerciales deben calendarizarse contra el ciclo de verano y el valle de noviembre.

---

## Q2 — ¿Qué cinco navieras generan el mayor ingreso por reservas?

**Visual:** barras horizontales Top 5 · **Apoyo:** tabla con volumen, ticket promedio e ingreso por noche

### Respuesta

| # | Naviera | Ingreso | Reservas | Ticket promedio | Ingreso/noche |
|---|---|---:|---:|---:|---:|
| 1 | Cunard Line | 76,29 M | 9.630 | 7.921,70 | 587,54 |
| 2 | Celebrity Cruises | 47,34 M | 9.630 | 4.916,39 | 513,22 |
| 3 | Norwegian Cruise Line | 37,58 M | 9.630 | 3.902,58 | 460,48 |
| 4 | Royal Caribbean | 34,27 M | 9.630 | 3.558,22 | 543,38 |
| 5 | MSC Cruceros | 30,75 M | 9.630 | 3.193,17 | 493,38 |
| 6 | Costa Cruceros | 28,31 M | 9.630 | 2.940,14 | 450,06 |
| 7 | AIDA Cruises | 27,41 M | 9.630 | 2.846,35 | 433,54 |
| 8 | Disney Cruise Line | 19,72 M | 9.630 | 2.047,46 | 562,70 |

Las ocho navieras registran **exactamente 9.630 reservas cada una**. Con el volumen fijado, el ranking no mide popularidad ni cuota de mercado: mide únicamente ticket promedio. Cunard factura 3,87 veces lo de Disney, y su ticket promedio es 3,87 veces mayor — la proporción coincide porque el volumen se cancela.

### El dato que cambia la conclusión

Al normalizar por noche vendida, **Disney escala de la última posición a la segunda** (562,70 USD), a solo un 4% de Cunard. La ventaja de Cunard no proviene de cobrar más por noche sino de operar travesías más largas: Transatlantic promedia 13,48 noches frente a las 3,64 de Bahamas.

### Implicación

El ranking por facturación absoluta premia la duración del itinerario, no la eficiencia comercial. Medida por noche, la brecha entre la primera y la última naviera se reduce de **3,87x a 1,04x**. Cualquier benchmarking o decisión de inversión basada solo en ingreso total estaría comparando modelos de negocio distintos como si fueran competidores directos.

---

## Q3 — ¿Qué rutas concentran aproximadamente el 80% de los ingresos por reservas?

**Visual:** Pareto — columnas de ingreso por ruta + línea de acumulado + referencia al 80%

### Respuesta

| Ruta | Ingreso | % acumulado |
|---|---:|---:|
| Transatlantic | 76,29 M | 25,3% |
| Mediterranean | 59,06 M | 44,9% |
| Alaska | 47,34 M | 60,6% |
| Fiordos | 37,58 M | 73,0% |
| **Caribbean** | **34,27 M** | **84,4%** |
| Canarias | 27,41 M | 93,5% |
| Bahamas | 19,72 M | 100% |

**No se cumple el principio de Pareto.** Se requieren **cinco de siete rutas** —el 71% de los grupos, no el 20%— para superar el 80% del ingreso. La línea acumulada cruza el umbral en Caribbean, la quinta ruta.

La distribución es notablemente uniforme: no existe un itinerario que domine la cartera ni rutas residuales que puedan descartarse sin costo relevante. Aun así, hay una jerarquía clara — Transatlantic aporta casi cuatro veces lo de Bahamas.

### Matiz necesario

Esa jerarquía no refleja rentabilidad sino **duración del itinerario**. Transatlantic encabeza con 13,48 noches promedio; Bahamas cierra con 3,64. Normalizando por noche vendida, el orden se comprime drásticamente y Bahamas resulta competitiva pese a ocupar el último lugar en facturación absoluta.

### Implicación

La cartera de itinerarios está **diversificada, no concentrada**. Ninguna ruta representa un riesgo de dependencia, y ninguna es prescindible por bajo aporte. La decisión sobre qué itinerarios priorizar debe tomarse sobre ingreso por noche —que mide el rendimiento del activo escaso, el barco— y no sobre ingreso por reserva.

---

## Q4 — ¿Cuál fue la variación porcentual del ingreso entre trimestres consecutivos?

**Visual:** columnas por trimestre + matriz con variación QoQ e indicadores de dirección

### Respuesta

La comparación año contra año es estéril: **2021 vs 2020 arroja −0,77%**, indistinguible del ruido. Bajando al nivel trimestral aparece un patrón que se repite los cuatro años completos **sin una sola excepción**:

| Transición | 2018 | 2019 | 2020 | 2021 |
|---|---:|---:|---:|---:|
| Q1 → Q2 | +11,6% | +7,7% | +8,5% | +9,4% |
| Q2 → Q3 | +3,2% | +2,5% | +1,3% | +0,9% |
| Q3 → Q4 | −6,9% | −7,1% | −4,3% | −3,2% |
| Q4 → Q1 (año sig.) | −3,6% | −2,6% | −6,3% | — |

Dieciséis transiciones consecutivas, cero excepciones al patrón: **el segundo trimestre siempre sube entre 7,7% y 11,6%; el cuarto siempre cae**. La oscilación entre el pico de Q2-Q3 y el valle de Q4-Q1 ronda los 15 puntos porcentuales.

Se observa además una **atenuación progresiva**: las caídas de Q4 se moderan de −6,9% en 2018 a −3,2% en 2021, sugiriendo una suavización gradual de la estacionalidad.

> **Lectura de la última fila del visual.** La matriz muestra 2022-Q1 con −59,2%. Esta cifra **no es interpretable**: el trimestre contiene solo cinco semanas de datos frente a un trimestre completo de comparación. Debe excluirse de cualquier conclusión.

### Implicación

La elección del periodo de comparación no es un detalle técnico sino una decisión analítica que determina la conclusión. Comparando años, el negocio "no hace nada". Comparando trimestres, revela una estacionalidad predecible y accionable sobre la que sí se puede planear capacidad, precios dinámicos e inventario.

---

## Q5 — ¿Existe relación entre satisfacción y gasto diario a bordo?

**Visual:** dispersión con línea de tendencia · Correlación de Pearson: **r = 0,734**

### Respuesta

| Satisfacción | Gasto diario (USD) |
|---:|---:|
| 4,0 | 137,27 |
| 4,1 | 136,71 |
| 4,2 | 137,04 |
| 4,3 | 139,77 |
| 4,4 | 147,44 |
| 4,5 | 158,21 |
| 4,6 | 171,79 |
| 4,7 | 186,18 |
| 4,8 | 195,54 |
| 4,9 | 200,27 |
| 5,0 | 203,17 |

Sí, la relación es positiva y fuerte. Pero **el hallazgo no es la correlación sino la forma de la curva**: entre 4,0 y 4,3 el gasto está congelado —se mueve dos dólares y medio en total, incluso con un leve descenso en 4,1—, y a partir de 4,3 se dispara hasta acumular **+45%** en el tramo restante.

Existe un **umbral en torno a 4,3** por debajo del cual la mejora de experiencia no se traduce en monetización.

### Contraste por itinerario

| Ruta | Satisfacción | Gasto diario | Posición |
|---|---:|---:|---|
| Canarias | 4,30 | 129,29 | **Punto de inflexión** |
| Mediterranean | 4,35 | 151,75 | **Punto de inflexión** |
| Fiordos | 4,50 | 144,38 | Zona rentable |
| Alaska | 4,70 | 175,13 | Zona rentable |
| Caribbean | 4,80 | 191,05 | Zona rentable |
| Transatlantic | 4,80 | 218,78 | Saturación |
| Bahamas | 4,88 | 204,12 | Saturación |

### Implicación

La inversión en experiencia a bordo no rinde igual en todas las rutas. **Canarias (4,30) y Mediterranean (4,35) están exactamente en el punto de inflexión**: una mejora marginal de satisfacción en esos itinerarios tendría el mayor retorno incremental en gasto a bordo. Bahamas (4,88) ya opera en la zona plana superior de la curva, donde una mejora adicional aportaría poco.

### Limitación

La dirección causal no queda establecida: es igualmente plausible que quienes gastan más a bordo reporten mayor satisfacción por haber consumido más servicios. Determinarlo exigiría un diseño experimental que el dataset no permite.

---

## Análisis complementarios

Visuales adicionales incluidos en el tablero como soporte de las cinco preguntas principales.

**Composición por categoría de precio.** El tercil High concentra 167,35 M (55,5% del ingreso) frente a 51,21 M del tercil Low (17,0%), pese a que los tres grupos contienen exactamente el mismo número de reservas por construcción del `qcut`. La diferencia de ingreso promedio entre extremos es de 3,3x (6.516,88 vs 1.994,19 USD).

**Distribución por tipo de camarote.** Balcony lidera con 106,36 M (35,3%), seguido de Interior (89,93 M), Oceanview (75,74 M) y Suite (29,63 M, 9,8%). Sin embargo, el ingreso **promedio** por reserva es prácticamente idéntico entre categorías: Balcony 3.910,44 USD frente a Suite 3.933,18 USD, una diferencia inferior al 1%. El tipo de camarote determina volumen de reservas, no valor por reserva.

**Distribución por canal de venta.** B2B domina con 134,83 M (44,7%), seguido de Web (105,96 M) y Direct (60,88 M). Al igual que con el camarote, el ticket promedio apenas varía entre canales (Web 3.929,28 vs B2B 3.901,29 USD). El canal determina volumen, no valor.

**Duración promedio por ruta.** Transatlantic 13,48 noches, Alaska 9,58, Fiordos 8,48, Canarias 6,57, Caribbean 6,55, Mediterranean 6,50, Bahamas 3,64. Esta tabla es la que explica el ranking de Q2 y el orden del Pareto de Q3.

**Distribución geográfica de la demanda.** Estados Unidos concentra más de un tercio del ingreso, seguido a distancia por Alemania, Reino Unido y España. Los cuatro mercados restantes (Canadá, Italia, Francia, México) aportan aproximadamente un 5% cada uno, configurando dos bloques diferenciados: cuatro mercados core y cuatro marginales de tamaño casi idéntico entre sí.

---

## Síntesis ejecutiva

| Pregunta | Hallazgo | Acción sugerida |
|---|---|---|
| Q1 · Tendencia | Ingreso anual plano con ciclo estacional consistente | Planear capacidad contra el ciclo mensual |
| Q2 · Top navieras | Volumen idéntico; el ranking mide duración, no precio | Evaluar por ingreso/noche, no por facturación |
| Q3 · Distribución | Cartera diversificada; se requieren 5 de 7 rutas para el 80% | Ninguna ruta es prescindible ni dominante |
| Q4 · Periodos | −0,77% anual, pero ±15 puntos entre trimestres | Usar el trimestre como unidad de comparación |
| Q5 · Relación | r = 0,734 con umbral de monetización en 4,3 | Priorizar Canarias y Mediterranean en experiencia |

---

## Limitaciones del análisis

1. **Cobertura temporal desigual.** El año 2022 aporta solo 2.040 registros de cinco semanas. Todos los visuales lo incluyen para preservar la integridad del dataset cargado en PostgreSQL, pero ninguna conclusión comparativa se apoya en él.
2. **Volumen uniforme por naviera.** Las 9.630 reservas idénticas en las ocho compañías indican un dataset construido de forma balanceada, lo que anula cualquier análisis de cuota de mercado o captación de demanda.
3. **Ausencia del efecto pandemia.** El año 2020 no registra caída alguna respecto a 2019, comportamiento que no corresponde con el del sector real de cruceros. Las conclusiones son válidas dentro del dataset pero no extrapolables a la industria.
4. **Colinealidad entre dimensiones.** Naviera, barco y ruta son prácticamente equivalentes: cada compañía opera un único barco en un único itinerario, con la sola excepción de Mediterranean (compartida por MSC y Costa). Esto impide separar el efecto de la compañía del efecto de la ruta, y explica por qué el ranking de Q2 y el Pareto de Q3 comparten cifras.
5. **Dimensiones sin poder discriminante.** `suite_type` y `booking_source` no muestran diferencias apreciables de ticket promedio (menos del 1% entre categorías), por lo que su aporte al análisis es descriptivo y no explicativo.
