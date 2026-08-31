# README — KPI Comparativos en Power BI

## Objetivo

Crear tarjetas KPI que muestren:
- Valor actual de la métrica.
- Variación respecto al año anterior.
- `N/A` cuando no se haya seleccionado un año.
- Comparación respetando Company, Route Type, Booking Source y Suite Type.

> Recomendación: usar selección única en el slicer `Year`. Para la presentación, usar 2021 vs. 2020 si 2022 es parcial.

---

# 1. Ubicación de las medidas

Crear todas las medidas en la tabla `Medidas`.

Estructura:

- Total Reservation Income
- Revenue Previous Year
- Revenue YoY %
- Revenue YoY Display
- Total Bookings
- Bookings Previous Year
- Bookings YoY %
- Bookings YoY Display
- Total Guest Spending
- Guest Spending Previous Year
- Guest Spending YoY %
- Guest Spending YoY Display
- Average Income per Booking
- Average Income Previous Year
- Average Income YoY %
- Average Income YoY Display
- Average Nights of Stay
- Average Nights Previous Year
- Average Nights YoY %
- Average Nights YoY Display
- Average Occupancy
- Average Occupancy Previous Year
- Occupancy Change PP
- Occupancy Change Display

---

# 2. KPI — Total Reservation Revenue

## Medida principal

```DAX
Total Reservation Income =
SUM('public bookings_fact'[total_reservation_income_usd])
```

## Año anterior

```DAX
Revenue Previous Year =
IF(
    NOT(ISFILTERED(calendario[Año])),
    BLANK(),
    VAR SelectedYear = MAX(calendario[Año])
    RETURN
        CALCULATE(
            [Total Reservation Income],
            REMOVEFILTERS(calendario),
            calendario[Año] = SelectedYear - 1
        )
)
```

## Variación

```DAX
Revenue YoY % =
IF(
    ISBLANK([Revenue Previous Year]),
    BLANK(),
    DIVIDE(
        [Total Reservation Income] - [Revenue Previous Year],
        [Revenue Previous Year]
    )
)
```

Formato: Percentage, 1 decimal.

## Texto para tarjeta

```DAX
Revenue YoY Display =
VAR Variation = [Revenue YoY %]
RETURN
    IF(
        ISBLANK(Variation),
        "N/A",
        IF(
            Variation > 0,
            "▲ +" & FORMAT(Variation, "0.0%") & " vs. previous year",
            IF(
                Variation < 0,
                "▼ " & FORMAT(Variation, "0.0%") & " vs. previous year",
                "— 0.0% vs. previous year"
            )
        )
    )
```

Tarjeta:
- Callout value: `[Total Reservation Income]`
- Reference label: `[Revenue YoY Display]`

---

# 3. KPI — Total Bookings

## Medida principal

```DAX
Total Bookings =
DISTINCTCOUNT('public bookings_fact'[booking_id])
```

## Año anterior

```DAX
Bookings Previous Year =
IF(
    NOT(ISFILTERED(calendario[Año])),
    BLANK(),
    VAR SelectedYear = MAX(calendario[Año])
    RETURN
        CALCULATE(
            [Total Bookings],
            REMOVEFILTERS(calendario),
            calendario[Año] = SelectedYear - 1
        )
)
```

## Variación

```DAX
Bookings YoY % =
IF(
    ISBLANK([Bookings Previous Year]),
    BLANK(),
    DIVIDE(
        [Total Bookings] - [Bookings Previous Year],
        [Bookings Previous Year]
    )
)
```

Formato: Percentage, 1 decimal.

## Texto

```DAX
Bookings YoY Display =
VAR Variation = [Bookings YoY %]
RETURN
    IF(
        ISBLANK(Variation),
        "N/A",
        IF(
            Variation > 0,
            "▲ +" & FORMAT(Variation, "0.0%") & " vs. previous year",
            IF(
                Variation < 0,
                "▼ " & FORMAT(Variation, "0.0%") & " vs. previous year",
                "— 0.0% vs. previous year"
            )
        )
    )
```

Tarjeta:
- Callout value: `[Total Bookings]`
- Reference label: `[Bookings YoY Display]`

---

# 4. KPI — Total Guest Spending

## Medida principal

```DAX
Total Guest Spending =
SUM('public bookings_fact'[total_guest_spending_usd])
```

## Año anterior

```DAX
Guest Spending Previous Year =
IF(
    NOT(ISFILTERED(calendario[Año])),
    BLANK(),
    VAR SelectedYear = MAX(calendario[Año])
    RETURN
        CALCULATE(
            [Total Guest Spending],
            REMOVEFILTERS(calendario),
            calendario[Año] = SelectedYear - 1
        )
)
```

## Variación

```DAX
Guest Spending YoY % =
IF(
    ISBLANK([Guest Spending Previous Year]),
    BLANK(),
    DIVIDE(
        [Total Guest Spending] - [Guest Spending Previous Year],
        [Guest Spending Previous Year]
    )
)
```

Formato: Percentage, 1 decimal.

## Texto

```DAX
Guest Spending YoY Display =
VAR Variation = [Guest Spending YoY %]
RETURN
    IF(
        ISBLANK(Variation),
        "N/A",
        IF(
            Variation > 0,
            "▲ +" & FORMAT(Variation, "0.0%") & " vs. previous year",
            IF(
                Variation < 0,
                "▼ " & FORMAT(Variation, "0.0%") & " vs. previous year",
                "— 0.0% vs. previous year"
            )
        )
    )
```

Tarjeta:
- Callout value: `[Total Guest Spending]`
- Reference label: `[Guest Spending YoY Display]`

---

# 5. KPI — Average Income per Booking

## Medida principal

```DAX
Average Income per Booking =
DIVIDE(
    [Total Reservation Income],
    [Total Bookings]
)
```

## Año anterior

```DAX
Average Income Previous Year =
IF(
    NOT(ISFILTERED(calendario[Año])),
    BLANK(),
    VAR SelectedYear = MAX(calendario[Año])
    RETURN
        CALCULATE(
            [Average Income per Booking],
            REMOVEFILTERS(calendario),
            calendario[Año] = SelectedYear - 1
        )
)
```

## Variación

```DAX
Average Income YoY % =
IF(
    ISBLANK([Average Income Previous Year]),
    BLANK(),
    DIVIDE(
        [Average Income per Booking] - [Average Income Previous Year],
        [Average Income Previous Year]
    )
)
```

Formato: Percentage, 1 decimal.

## Texto

```DAX
Average Income YoY Display =
VAR Variation = [Average Income YoY %]
RETURN
    IF(
        ISBLANK(Variation),
        "N/A",
        IF(
            Variation > 0,
            "▲ +" & FORMAT(Variation, "0.0%") & " vs. previous year",
            IF(
                Variation < 0,
                "▼ " & FORMAT(Variation, "0.0%") & " vs. previous year",
                "— 0.0% vs. previous year"
            )
        )
    )
```

Tarjeta:
- Callout value: `[Average Income per Booking]`
- Reference label: `[Average Income YoY Display]`

---

# 6. KPI — Average Nights of Stay

## Medida principal

```DAX
Average Nights of Stay =
AVERAGE(
    'public bookings_fact'[nights_of_stay]
)
```

## Año anterior

```DAX
Average Nights Previous Year =
IF(
    NOT(ISFILTERED(calendario[Año])),
    BLANK(),
    VAR SelectedYear = MAX(calendario[Año])
    RETURN
        CALCULATE(
            [Average Nights of Stay],
            REMOVEFILTERS(calendario),
            calendario[Año] = SelectedYear - 1
        )
)
```

## Variación

```DAX
Average Nights YoY % =
IF(
    ISBLANK([Average Nights Previous Year]),
    BLANK(),
    DIVIDE(
        [Average Nights of Stay] - [Average Nights Previous Year],
        [Average Nights Previous Year]
    )
)
```

Formato: Percentage, 1 decimal.

## Texto

```DAX
Average Nights YoY Display =
VAR Variation = [Average Nights YoY %]
RETURN
    IF(
        ISBLANK(Variation),
        "N/A",
        IF(
            Variation > 0,
            "▲ +" & FORMAT(Variation, "0.0%") & " vs. previous year",
            IF(
                Variation < 0,
                "▼ " & FORMAT(Variation, "0.0%") & " vs. previous year",
                "— 0.0% vs. previous year"
            )
        )
    )
```

Tarjeta:
- Callout value: `[Average Nights of Stay]`
- Reference label: `[Average Nights YoY Display]`

---

# 7. KPI — Average Occupancy

## Paso 1: revisar el formato de la columna

Si `cycle_occupancy_percentage` contiene valores como `85`, `90`, `91`, usar:

```DAX
Average Occupancy =
DIVIDE(
    AVERAGE(
        'public bookings_fact'[cycle_occupancy_percentage]
    ),
    100
)
```

Si ya contiene `0.85`, `0.90`, `0.91`, usar:

```DAX
Average Occupancy =
AVERAGE(
    'public bookings_fact'[cycle_occupancy_percentage]
)
```

Formato: Percentage.

## Año anterior

```DAX
Average Occupancy Previous Year =
IF(
    NOT(ISFILTERED(calendario[Año])),
    BLANK(),
    VAR SelectedYear = MAX(calendario[Año])
    RETURN
        CALCULATE(
            [Average Occupancy],
            REMOVEFILTERS(calendario),
            calendario[Año] = SelectedYear - 1
        )
)
```

## Cambio en puntos porcentuales

```DAX
Occupancy Change PP =
IF(
    ISBLANK([Average Occupancy Previous Year]),
    BLANK(),
    [Average Occupancy] -
    [Average Occupancy Previous Year]
)
```

## Texto

```DAX
Occupancy Change Display =
VAR ChangePP = [Occupancy Change PP]
RETURN
    IF(
        ISBLANK(ChangePP),
        "N/A",
        IF(
            ChangePP > 0,
            "▲ +" & FORMAT(ChangePP, "0.0%") & " pp vs. previous year",
            IF(
                ChangePP < 0,
                "▼ " & FORMAT(ABS(ChangePP), "0.0%") & " pp vs. previous year",
                "— 0.0 pp vs. previous year"
            )
        )
    )
```

Tarjeta:
- Callout value: `[Average Occupancy]`
- Reference label: `[Occupancy Change Display]`

> Para Occupancy es preferible mostrar `pp` (puntos porcentuales), no una variación porcentual relativa.

---

# 8. Cómo configurar las tarjetas modernas

Para cada tarjeta de Power BI:

**Callout value:** medida principal.

**Reference label:** medida `Display`.

Ejemplo:

    Callout value:
    [Total Reservation Income]

    Reference label:
    [Revenue YoY Display]

---

# 9. Interacción con los filtros

Los comparativos deben mantener:
- Company
- Route Type
- Booking Source
- Suite Type

y eliminar temporalmente el filtro de calendario con:

```DAX
REMOVEFILTERS(calendario)
```

Ejemplo:

Si se selecciona:

    Year = 2021
    Company = Cunard Line
    Route Type = Transatlantic
    Suite Type = Luxury

el KPI compara:

    Cunard + Transatlantic + Luxury — 2021

contra:

    Cunard + Transatlantic + Luxury — 2020

---

# 10. Recomendación para Year

Activar:

    Year → Single Select

Esto evita que `MAX(calendario[Año])` tenga que decidir qué año utilizar cuando se seleccionan varios.

---

# 11. Nota sobre 2022

Si 2022 es un año parcial, no usarlo como año actual para una comparación YoY contra un año completo.

Para la presentación se recomienda:

    2021 vs. 2020

y agregar una nota:

    2022 represents a partial year.

---

# 12. Checklist final

- [ ] Todas las medidas están en `Medidas`.
- [ ] Year está en selección única.
- [ ] Revenue está en moneda.
- [ ] Bookings no tiene decimales innecesarios.
- [ ] Average Income está en moneda.
- [ ] Average Nights tiene aproximadamente 2 decimales.
- [ ] Occupancy está en porcentaje.
- [ ] Los comparativos muestran ▲, ▼ o N/A.
- [ ] Los comparativos dicen `vs. previous year`.
- [ ] Occupancy utiliza `pp`.
- [ ] Company, Route Type, Booking Source y Suite Type siguen filtrando los KPI.
- [ ] 2022 está identificado como año parcial si corresponde.
- [ ] Las tarjetas utilizan Callout value + Reference label.

---

# 13. Resultado visual esperado

    ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐
    │ TOTAL RESERVATION  │ │ TOTAL BOOKINGS     │ │ TOTAL GUEST        │
    │ REVENUE            │ │                    │ │ SPENDING           │
    │                    │ │                    │ │                    │
    │    $73.35M         │ │     18.72K         │ │     $XX.XXM        │
    │ ▼ -0.8% YoY       │ │ ▲ +X.X% YoY       │ │ ▲ +X.X% YoY       │
    └────────────────────┘ └────────────────────┘ └────────────────────┘

    ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐
    │ AVG INCOME PER     │ │ AVG NIGHTS OF      │ │ AVERAGE OCCUPANCY  │
    │ BOOKING            │ │ STAY               │ │                    │
    │                    │ │                    │ │                    │
    │     $3,916         │ │       7.66         │ │        91%          │
    │ ▲ +X.X% YoY       │ │ ▲ +X.X% YoY       │ │ ▲ +X.X pp YoY      │
    └────────────────────┘ └────────────────────┘ └────────────────────┘
