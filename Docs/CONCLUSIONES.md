# Conclusiones e insights

**Proyecto:** Cruise Revenue & Booking Analytics
**Alcance del análisis:** 2018-2021 · 75.000 reservas · 294,17 M USD
**Métrica principal:** `total_reservation_income_usd`

---

## Nota metodológica previa

Dos decisiones condicionan la lectura de todo lo que sigue, y conviene declararlas antes de los hallazgos.

**Exclusión de 2022.** El dataset se interrumpe el 6 de febrero de 2022, dejando ese año con 2.040 registros frente a los ~18.720 de un año completo. Incluirlo habría producido una caída del 89% al final de la serie temporal, interpretable como un colapso comercial inexistente. El análisis se acota a los cuatro años completos.

**Descarte de una correlación aparente.** `total_guest_spending_usd`, una de las columnas derivadas del ETL, se calcula como `gasto_diario × noches × pasajeros`. Correlacionarla contra el ingreso de reserva arroja r = 0,979, pero esa cifra no describe una relación de negocio: ambas variables comparten los factores *noches* y *pasajeros*, de modo que la correlación es un artefacto aritmético de la construcción de la columna. Se descartó como respuesta a la pregunta de relación entre variables y se sustituyó por un par de variables genuinamente independientes.

---

## Hallazgo 1 — La estabilidad anual esconde una estacionalidad fuerte

El ingreso anual es prácticamente constante: 73,39 M (2018), 73,51 M (2019), 73,92 M (2020) y 73,35 M (2021). La variación entre 2020 y 2021 es de **−0,77%**, indistinguible del ruido.

Un análisis año contra año habría concluido que no ocurre nada. Al bajar al nivel trimestral aparece un patrón que **se repite los cuatro años sin una sola excepción**:

| Transición | 2018 | 2019 | 2020 | 2021 |
|---|---:|---:|---:|---:|
| Q1 → Q2 | +11,6% | +7,7% | +8,5% | +9,4% |
| Q2 → Q3 | +3,2% | +2,5% | — | +0,9% |
| Q3 → Q4 | −6,9% | −7,1% | −4,3% | −3,2% |

La oscilación entre el pico de Q2-Q3 y el valle de Q4-Q1 ronda los 15 puntos porcentuales. A nivel mensual, el ticket promedio va de 3.575 USD en noviembre a 4.151 USD en julio.

**Implicación.** La planeación de capacidad, dotación de tripulación e inventario debe seguir el ciclo trimestral, no la tendencia anual. La elección del periodo de comparación no es un detalle técnico: determina si el análisis concluye "no pasa nada" o identifica una estacionalidad predecible sobre la que sí se puede actuar.

---

## Hallazgo 2 — El ranking de navieras mide precio, no desempeño comercial

Las ocho navieras del dataset registran **exactamente 9.630 reservas cada una**. Con el volumen fijado, la diferencia de facturación solo puede explicarse por el ticket promedio.

| Naviera | Ingreso | Reservas | Ticket promedio | Ingreso por noche |
|---|---:|---:|---:|---:|
| Cunard Line | 76,3 M | 9.630 | 7.921,70 | 587,54 |
| Celebrity Cruises | 47,3 M | 9.630 | 4.916,39 | 513,22 |
| Norwegian Cruise Line | 37,6 M | 9.630 | 3.902,58 | 460,48 |
| Royal Caribbean | 34,3 M | 9.630 | 3.558,22 | 543,38 |
| MSC Cruceros | 30,8 M | 9.630 | 3.193,17 | 493,38 |
| Costa Cruceros | 28,3 M | 9.630 | 2.940,14 | 450,06 |
| AIDA Cruises | 27,4 M | 9.630 | 2.846,35 | 433,54 |
| Disney Cruise Line | 19,7 M | 9.630 | 2.047,46 | 562,70 |

Cunard factura 3,87 veces lo de Disney, y su ticket promedio es 3,87 veces mayor: la proporción coincide exactamente porque el volumen se cancela.

**El dato que cambia la conclusión.** Al normalizar por noche vendida, Disney escala de la última a la **segunda posición** (562,70 USD), a solo un 4% de Cunard. La ventaja de Cunard no viene de cobrar mejor, sino de operar travesías mucho más largas: Transatlantic promedia 13,48 noches frente a las 3,64 de Bahamas.

**Implicación.** El ranking por ingreso total premia la duración del itinerario, no la eficiencia comercial. Medida por noche, la brecha entre la primera y la última naviera se reduce de 3,87x a 1,04x. Cualquier decisión de inversión o benchmarking basada únicamente en facturación absoluta estaría comparando modelos de negocio distintos como si fueran competidores directos.

---

## Hallazgo 3 — Concentración moderada de mercado, sin regla 80/20

| País | Ingreso | % del total | % acumulado |
|---|---:|---:|---:|
| USA | 105,3 M | 34,9% | 34,9% |
| Germany | 45,6 M | 15,1% | 50,0% |
| UK | 45,2 M | 15,0% | 65,0% |
| Spain | 44,9 M | 14,9% | **79,9%** |
| Canada | 15,5 M | 5,1% | 85,0% |
| Italy | 15,1 M | 5,0% | 90,1% |
| France | 15,1 M | 5,0% | 95,0% |
| Mexico | 14,9 M | 4,9% | 100% |

**No se cumple el principio de Pareto.** Se requieren cuatro de ocho países —la mitad de los grupos, no el 20%— para alcanzar el 80% del ingreso. Un 80/20 estricto exigiría que 1,6 países llegaran a esa marca, y Estados Unidos por sí solo alcanza apenas el 34,9%.

Lo que sí existe es un **quiebre estructural nítido**: los cuatro primeros mercados van de 105 M a 45 M, y del quinto en adelante caen a ~15 M y se aplanan. España triplica a Canadá. No es una distribución gradual sino dos bloques diferenciados: cuatro mercados core y cuatro marginales de tamaño casi idéntico entre sí.

**Implicación.** La dependencia de Estados Unidos, con más de un tercio del ingreso, constituye el principal riesgo de concentración de la cartera. Los cuatro mercados marginales, al ser homogéneos entre sí (~5% cada uno), representan un espacio de crecimiento donde una estrategia común podría aplicarse sin diferenciación por país.

*La distribución por ruta, en cambio, es notablemente uniforme: se necesitan cinco de siete rutas para llegar al 80%. Y esa distribución replica las cifras del ranking de navieras, porque cada compañía opera un único barco en un único itinerario (con la sola excepción de Mediterranean, compartida por MSC y Costa).*

---

## Hallazgo 4 — La satisfacción monetiza, pero solo por encima de un umbral

Relación entre `satisfaction_score` y `average_daily_guest_spending_usd`, dos variables independientes del dataset: **r = 0,735**.

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
| 4,9 | 200,59 | 7.743 |
| 5,0 | 203,59 | 6.535 |

**La correlación no es el hallazgo; la forma de la curva sí lo es.** Entre 4,1 y 4,3 el gasto está prácticamente congelado —se mueve tres dólares en total—. A partir de 4,3 se dispara, hasta acumular un +45% en el tramo restante. La relación no es lineal: existe un **umbral en torno a 4,3** por debajo del cual la mejora de experiencia no se traduce en monetización.

Contrastado por itinerario:

| Ruta | Satisfacción | Gasto diario | Posición respecto al umbral |
|---|---:|---:|---|
| Canarias | 4,30 | 129,54 | En el punto de inflexión |
| Mediterranean | 4,35 | 152,07 | En el punto de inflexión |
| Fiordos | 4,50 | 144,69 | Zona rentable |
| Alaska | 4,70 | 175,50 | Zona rentable |
| Caribbean | 4,80 | 191,46 | Zona rentable |
| Transatlantic | 4,80 | 219,21 | Saturación |
| Bahamas | 4,88 | 204,54 | Saturación |

**Implicación.** La inversión en experiencia a bordo no rinde igual en todas las rutas. Canarias (4,30) y Mediterranean (4,35) están exactamente en el punto de inflexión: una mejora marginal de satisfacción en esos itinerarios tendría el mayor retorno incremental en gasto a bordo. Bahamas (4,88), en cambio, ya opera en la zona plana superior de la curva, donde una mejora adicional aportaría poco.

**Limitación.** La dirección causal no queda establecida: es igualmente plausible que quienes gastan más a bordo reporten mayor satisfacción por haber consumido más servicios. Determinarlo requeriría un diseño experimental que el dataset no permite.

---

## Síntesis

| Pregunta | Respuesta | Acción sugerida |
|---|---|---|
| Tendencia temporal | Ingreso anual plano con estacionalidad trimestral consistente | Planear capacidad por ciclo trimestral |
| Top navieras | Cunard lidera con 76,3 M; el ranking mide duración, no precio | Comparar por ingreso/noche, no por facturación |
| Distribución | Concentración moderada; sin 80/20; USA en 34,9% | Diversificar exposición al mercado estadounidense |
| Comparación entre periodos | −0,77% anual, pero ±15 puntos entre trimestres | Usar el trimestre como unidad de comparación |
| Relación entre variables | r = 0,735 con umbral en satisfacción 4,3 | Priorizar Canarias y Mediterranean en experiencia |

## Limitaciones del análisis

1. **Volumen uniforme por naviera.** Las 9.630 reservas idénticas en las ocho compañías sugieren que el dataset fue construido de forma balanceada. Esto anula cualquier análisis de cuota de mercado o de captación de demanda.
2. **Ausencia del efecto pandemia.** El año 2020 no registra caída alguna respecto a 2019, lo que no corresponde con el comportamiento real del sector de cruceros en ese periodo. Las conclusiones son válidas dentro del dataset, pero no extrapolables a la industria.
3. **Colinealidad entre dimensiones.** Naviera, barco y ruta son prácticamente equivalentes entre sí, lo que limita el análisis multidimensional: no es posible separar el efecto de la compañía del efecto del itinerario.
4. **Dimensiones sin poder discriminante.** `suite_type` y `booking_source` no muestran diferencias apreciables de ingreso (Balcony 3.910 USD vs Suite 3.933; Web 3.929 vs B2B 3.901), por lo que se descartaron como ejes de segmentación del tablero.
