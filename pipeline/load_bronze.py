import pandas as pd
import psycopg2
from datetime import datetime

# -------------------------
# CONFIG
# -------------------------
CSV_PATH = "data/rent_prices.csv"

conn = psycopg2.connect(
    host="localhost",
    database="rent_dwh",
    user="postgres",
    password="1234"
)

cur = conn.cursor()

# -------------------------
# LOAD CSV
# -------------------------
df = pd.read_csv(CSV_PATH)
df = df.where(pd.notnull(df), None)

row_count = len(df)
start_time = datetime.now()

# -------------------------
# INSERT QUERY
# -------------------------
insert_query = """
INSERT INTO bronze.rent_raw (
    rent_euro,
    year,
    half,
    half_year,
    time_period,
    county,
    province,
    area,
    location,
    property_type,
    bedrooms,
    bedrooms_num,
    is_dublin,
    is_city,
    is_county_aggregate,
    source_file
)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
"""

# -------------------------
# ETL PROCESS
# -------------------------
try:
    for _, row in df.iterrows():
        cur.execute(insert_query, (
            row["rent_euro"],
            row["year"],
            row["half"],
            row["half_year"],
            row["time_period"],
            row["county"],
            row["province"],
            row["area"],
            row["location"],
            row["property_type"],
            row["bedrooms"],
            row["bedrooms_num"],
            row["is_dublin"],
            row["is_city"],
            row["is_county_aggregate"],
            "rent_prices.csv"
        ))

    end_time = datetime.now()
    duration = end_time - start_time

    # SUCCESS LOG
    cur.execute("""
        INSERT INTO meta.etl_log (
            job_name, status, row_count,
            error_message, start_time, end_time, duration
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (
        "load_bronze",
        "success",
        row_count,
        None,
        start_time,
        end_time,
        duration
    ))

    conn.commit()
    print(f"[SUCCESS] {row_count} satır yüklendi.")

except Exception as e:
    conn.rollback()   # 🔥 KRİTİK

    end_time = datetime.now()
    duration = end_time - start_time

    # ERROR LOG
    cur.execute("""
        INSERT INTO meta.etl_log (
            job_name, status, row_count,
            error_message, start_time, end_time, duration
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (
        "load_bronze",
        "failed",
        0,
        str(e),
        start_time,
        end_time,
        duration
    ))

    conn.commit()
    print(f"[ERROR] {e}")

finally:
    cur.close()
    conn.close()