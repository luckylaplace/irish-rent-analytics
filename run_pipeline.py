import os
import sys
import subprocess
import psycopg2
from dotenv import load_dotenv

def execute_sql_file(file_path, cursor):
    print(f"⏳ İşleniyor: {file_path} ...")
    
    # 1. Dosyayı okuma modunda ('r') açıyoruz. encoding='utf-8' Türkçe/özel karakter hatasını önler.
    with open(file_path, 'r', encoding='utf-8') as file:
        sql_query = file.read() # İçindeki SQL metnini değişkene atıyoruz
        
    # 2. Aldığımız metni veritabanına gönderip çalıştırıyoruz
    cursor.execute(sql_query)
    print(f"✅ Tamamlandı: {file_path}\n")


# Ana programın başladığı yer burası:
if __name__ == "__main__":
    print("🚀 --- VERİ BORU HATTI (PIPELINE) BAŞLATILIYOR --- 🚀\n")
    
    # --- ADIM 1: BRONZE KATMANI (Python kodu çalıştırma) ---
    print("ADIM 1: Bronze katmanı verileri yükleniyor...")
    # subprocess komutu, senin terminale kod yazıp entera basmanı taklit eder.
    # sys.executable, sistemindeki doğru (sanal) python sürümünü otomatik seçer
    subprocess.run([sys.executable, "pipeline/load_bronze.py"], check=True)
    print("ADIM 1 BAŞARILI.\n")
    
    # --- VERİTABANINA BAĞLANTI (Silver ve Gold İçin SQL bağlantısı) ---
    load_dotenv() # .env dosyasındaki bilgileri hafızaya al
    
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD")
    )
    # Autocommit: Yapılan işlemleri beklemeden anında veritabanına kaydet
    conn.autocommit = True 
    cur = conn.cursor()

    try:
        # --- ADIM 2: SILVER KATMANI ---
        print("ADIM 2: Silver katmanı dönüştürülüyor...")
        execute_sql_file("pipeline/transform_silver.sql", cur)

        # --- ADIM 3: GOLD KATMANI ---
        print("ADIM 3: Gold katmanı modelleniyor...")
        execute_sql_file("pipeline/build_gold.sql", cur)
        
        print("🎉 --- TÜM SÜREÇ BAŞARIYLA TAMAMLANDI! --- 🎉")
        
    except Exception as e:
        print(f"❌ BİR HATA OLUŞTU: {e}")
        
    finally:
        # Hata çıksa da çıkmasa da güvenli çıkış için kapıları (bağlantıları) kapat
        cur.close()
        conn.close()


    