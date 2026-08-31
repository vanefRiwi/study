import pandas as pd
import os
from postgres import cargar_esquema_estrella


# Crea la carpeta para guardar los resultados
os.makedirs("salidas2", exist_ok=True)

# Hace que pandas imprima todas las columnas sin cortarlas
pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

# Estilo de titulo y subtitulo para separar cada paso en la consola 
def titulo(texto):
    """Imprime un titulo para separar cada paso en la consola."""
    print("\n" + "=" * 79)
    print(texto)
    print("=" * 79)

def sub(texto):
    print("\n--- " + texto + " ---")

# =============================================================================
# PASO 0 - LEER Y PREPARAR EL CSV ORIGINAL
# =============================================================================
titulo("PASO 0 - CARGA Y PREPARACIÓN DEL ARCHIVO ORIGINAL")

# Reading original dataset directly
df = pd.read_csv("cruises_unclean.csv")


# Column renaming map
columnas_map = {
    'RES_ID': 'booking_id',
    'Fecha_Viaje': 'travel_date',
    'Fecha_Reserva': 'booking_date',
    'Lead_Time_Dias': 'lead_time_days',
    'Noches_Estancia': 'nights_of_stay',
    'Barco': 'ship_name',
    'Compañia': 'company',
    'Tipo_Ruta': 'route_type',
    'Suite_Type': 'suite_type',
    'Booking_Source': 'booking_source',
    'Package': 'package',
    'Guest_Country': 'guest_country',
    'Cabinas_Totales_Barco': 'total_cabins',
    'Cabinas_Reservadas': 'booked_cabins',
    'Porcentaje_Ocupacion_Ciclo': 'cycle_occupancy_percentage',
    'Pasajeros_Reserva': 'passengers_on_booking',
    'Tripulacion': 'total_crew',
    'Ingreso_Total_Reserva_USD': 'total_reservation_income_usd',
    'Gasto_Promedio_Diario_Huesped_USD': 'average_daily_guest_spending_usd',
    'Puntuacion_Satisfaccion': 'satisfaction_score'
}

df = df.rename(columns=columnas_map)

# Translate route_type values
df['route_type'] = df['route_type'].replace({
    'Mediterráneo': 'Mediterranean',
    'Caribe': 'Caribbean',
    'Transatlántico': 'Transatlantic'
})

print(f"El archivo tiene {df.shape[0]} filas y {df.shape[1]} columnas.")
sub("Primeras 5 filas tras homologación")
print(df.head())

# =============================================================================
# PASO 1 - DATA INSIGHTS
# =============================================================================
titulo("PASO 1 - DATA INSIGHTS")


df = df.copy() # saving a copy of the original dataframe 

print(f"El archivo tiene {df.shape[0]} filas y {df.shape[1]} columnas.")
sub("Primeras 5 filas")
print(df.head())

titulo("Información del DataFrame for cleaning")

sub("Estadísticas descriptivas")
print(df.describe())

print("\n ---  NULL VALUE AUDIT ---")
print(df.isnull().sum())

sub("Información del DataFrame")
print(df.info())



titulo("PASO 2 - LIMPIEZA DE DATOS")

# Cleaning and Feature Conversion
# Convert date columns to datetime format

print("Tipo antes del cambio (travel_date):", df['travel_date'].dtype)
print("Tipo antes del cambio (booking_date):", df['booking_date'].dtype)
# After Converting date columns to datetime format

df['travel_date'] = pd.to_datetime(df['travel_date'])
df['booking_date'] = pd.to_datetime(df['booking_date'])

print("Tipo después del cambio (travel_date):", df['travel_date'].dtype)
print("Tipo después del cambio (booking_date):", df['booking_date'].dtype)

# Check for duplicates
print("Número de filas duplicadas:", df.duplicated().sum())

# Handle duplicate rows if present
initial_count = len(df)
df = df.drop_duplicates()
print(f"\n Removed {initial_count - len(df)} duplicate records. Total clean records: {len(df)}")

# -----------------------------------------------------------------------------
# CREACIÓN DE COLUMNAS DERIVADAS
# -----------------------------------------------------------------------------

# 1. Total Guest Spending (Métrica continua)
df['total_guest_spending_usd'] = (
    df['average_daily_guest_spending_usd'] * df['nights_of_stay'] * df['passengers_on_booking']
)

# 2. Price Category (Categoría discreta en tercios/cuantiles)
df['price_category'] = pd.qcut(
    df['total_reservation_income_usd'], 
    q=3, 
    labels=['Low', 'Medium', 'High']
)

sub("Muestra de nuevas columnas derivadas")
print(df[['total_reservation_income_usd', 'price_category', 'total_guest_spending_usd']].head())
df.to_csv("salidas2/cruises_newcol.csv", index=False)