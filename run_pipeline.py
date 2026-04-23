import os
import sys
import subprocess
import psycopg2
from dotenv import load_dotenv
from prefect import flow, task
from prefect.cache_policies import NO_CACHE

@task(name="Run SQL Script", cache_policy=NO_CACHE)
def execute_sql_file(file_path, cursor):
    print(f"⏳ İşleniyor: {file_path} ...")
    with open(file_path, 'r', encoding='utf-8') as file:
        sql_query = file.read()
    cursor.execute(sql_query)
    print(f"✅ Tamamlandı: {file_path}\n")

@task(name="Data Quality Audit", cache_policy=NO_CACHE)
def run_audit_tests(file_path, cursor):
    print(f"🔍 Denetim (Test) Başlıyor: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as file:
        sql_query = file.read()
    
    cursor.execute(sql_query)
    results = cursor.fetchall() # Test sonuçlarını veritabanından çek
    
    for row in results:
        test_adi, sonuc, beklenen = row
        print(f"   👉 {test_adi}: Sonuç={sonuc} (Beklenen: {beklenen})")
    print("✅ Denetim Tamamlandı.\n")

@task(name="Load Bronze Data (Python)")
def load_bronze():
    print("ADIM 1: Bronze katmanı verileri yükleniyor...")
    subprocess.run([sys.executable, "pipeline/load_bronze.py"], check=True)
    print("ADIM 1 BAŞARILI.\n")

@flow(name="Irish Rent ETL Pipeline", log_prints=True)
def main_pipeline():
    print("🚀 --- VERİ BORU HATTI (PIPELINE) BAŞLATILIYOR --- 🚀\n")
    
    # 1. Adım: Bronze Katmanı
    load_bronze()
    
    # Veritabanı Bağlantısı
    load_dotenv()
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD")
    )
    conn.autocommit = True 
    cur = conn.cursor()

    try:
        # 2. Adım: Silver Katmanı
        print("ADIM 2: Silver katmanı dönüştürülüyor...")
        execute_sql_file("pipeline/transform_silver.sql", cur)

        # 3. Adım: Gold Katmanı
        print("ADIM 3: Gold katmanı modelleniyor...")
        execute_sql_file("pipeline/build_gold.sql", cur)
        
        # 4. Adım: Veri Kalitesi Testleri (Data Quality Checks)
        print("ADIM 4: Veri Kalitesi Testleri Çalıştırılıyor...")
        run_audit_tests("tests/silver_integrity_audit.sql", cur)
        run_audit_tests("tests/gold_integrity_audit.sql", cur)
        
        print("🎉 --- TÜM SÜREÇ VE TESTLER BAŞARIYLA TAMAMLANDI! --- 🎉")
    except Exception as e:
        print(f"❌ BİR HATA OLUŞTU: {e}")
        raise e
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main_pipeline()