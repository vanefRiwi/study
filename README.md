# PIPELINE DEL PROCESO DE ANALITICA DE DATOS

1. Crear el .env *esto para empaquetar en la versión correspondiente de mis librerias*
```bash
python -m venv env
```
Antes verificar que pyhton este instalado en PC `python --version` para windows python3 para mac

2. Activar el entorno virtual de python `env\Scripts\activate`
Sí ocurre algún problema utilizar este script `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`
Luego volver intentar la activación.
En caso que requieras salir del entorno virtual usa `deactivate`
3. Se puede tener un archivo `requirements.txt` con todas las librerias que se necesiten.
Para instalarlas se hace con el entorno virtual activo de la siguiente manera `pip install -r requirements.txt`
4. falta

5.  En analisis_cruiseship.py, tras drop_duplicates()
```
df = df.dropna(subset=['satisfaction_score'])   # o el criterio que decidas

assert df.duplicated().sum() == 0
assert df['satisfaction_score'].between(0, 5).all()
print(f"Validación OK — {len(df)} filas, {df.isnull().sum().sum()} nulos")
```
Y en ships_dim, cambia .drop_duplicates(ignore_index=True) por .drop_duplicates(subset=["ship_name"], ignore_index=True) para blindar el UNIQUE (ship_name) de Postgres.
