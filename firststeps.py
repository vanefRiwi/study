import pandas as pd
import os
os.makedirs('salidas', exist_ok=True)

df = pd.read_csv("reporte_cruceros_revenue_management.csv")

print(df.head())
df['RES_ID'] = df['RES_ID'].str.replace('RES-', '').astype(int)
print(df.head())

# Guarda el DataFrame editado en un nuevo archivo CSV
df.to_csv('salidas/cruises_unclean.csv', index=False)