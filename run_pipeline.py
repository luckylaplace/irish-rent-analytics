import sys
import subprocess
from prefect import flow, task

@task(name="Load Bronze Data (Python)")
def load_bronze():
    print("ADIM 1: Bronze katmanı verileri yükleniyor...")
    subprocess.run([sys.executable, "pipeline/load_bronze.py"], check=True)
    print("ADIM 1 BAŞARILI.\n")

@task(name="dbt Transform & Test")
def run_dbt():
    print("ADIM 2 & 3 & 4: dbt ile Silver ve Gold katmanları dönüştürülüyor ve test ediliyor...")
    
    # dbt run: Tüm dönüşümleri yap
    print("--> 'dbt run' başlatılıyor...")
    subprocess.run(["dbt", "run"], cwd="rent_dbt", check=True, shell=True)
    
    # dbt test: Veri kalitesi testlerini yap
    print("\n--> 'dbt test' başlatılıyor...")
    subprocess.run(["dbt", "test"], cwd="rent_dbt", check=True, shell=True)
    
    print("dbt İŞLEMLERİ BAŞARILI.\n")

@flow(name="Irish Rent ETL Pipeline (Modern dbt)", log_prints=True)
def main_pipeline():
    print("🚀 --- MODERN VERİ BORU HATTI (PREFECT + DBT) BAŞLATILIYOR --- 🚀\n")
    
    try:
        # 1. Adım: Dışarıdan CSV'yi veritabanına at
        load_bronze()
        
        # 2., 3., 4. Adım: Veritabanı içi dönüşümler ve testleri dbt'ye bırak
        run_dbt()
        
        print("🎉 --- TÜM SÜREÇ VE TESTLER BAŞARIYLA TAMAMLANDI! --- 🎉")
    except Exception as e:
        print(f"❌ BİR HATA OLUŞTU: {e}")
        raise e

if __name__ == "__main__":
    main_pipeline()