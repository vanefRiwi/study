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

---

In simple terms, **`price_category`** is a **label that tags every single cruise booking as "Low", "Medium", or "High" spend based on how much revenue it brought in.**

Instead of looking at raw dollars (e.g., "$1,243.50" vs. "$4,810.00"), it groups bookings into three easy-to-understand categories.

Here is a breakdown of what that business rationale and methodology actually mean for your project:

**What the Business Rationale Means**

* **From Raw Numbers to Actionable Groups:** A business manager doesn't want to scan 70,000 unique dollar amounts. Grouping reservations into `Low`, `Medium`, and `High` tiers makes it effortless to answer executive questions like: *"Which ships attract the highest-spending customers?"* or *"Do customers from certain countries book mostly 'Low' or 'High' packages?"*
* **Targeting & Marketing:** It allows teams to build targeted strategies—like offering luxury upgrades to the **High** group or sending discount promotions to the **Low** group.

---

**What the Methodological Justification Means**

* **Why `pd.qcut` instead of `pd.cut`?:**
* If you used standard binning (`pd.cut`), you would set fixed dollar cuts (e.g., Low: $0–$1,000, Medium: $1,000–$5,000, High: $5,000+). But if 90% of your bookings happen to fall between $1,000 and $3,000, your "High" and "Low" buckets would be almost empty, making the feature useless.
* `pd.qcut` (Quantile Cut) fixes this by looking at your actual data distribution and dynamically drawing the lines so that **each of the 3 buckets gets roughly 33.3% of your total records** (a balanced split into *tertiles*).


* **Statistical Balance for Data Science:** By keeping all three categories evenly populated, your database queries (`GROUP BY price_category`) won't suffer from heavily skewed groups, and machine learning models won't become biased toward one overpopulated bucket.

assert df.duplicated().sum() == 0
assert df['satisfaction_score'].between(0, 5).all()
print(f"Validación OK — {len(df)} filas, {df.isnull().sum().sum()} nulos")
```
Y en ships_dim, cambia .drop_duplicates(ignore_index=True) por .drop_duplicates(subset=["ship_name"], ignore_index=True) para blindar el UNIQUE (ship_name) de Postgres.
