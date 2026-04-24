# 🇮🇪 Irish Rent Analysis Pipeline (End-to-End Data Engineering)

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](https://www.docker.com/)
[![Prefect](https://img.shields.io/badge/Prefect-3.0-white.svg)](https://www.prefect.io/)
[![Metabase](https://img.shields.io/badge/Metabase-BI-509EE3.svg)](https://www.metabase.com/)

An end-to-end Data Engineering and Business Intelligence project that analyzes the Irish rental market. The pipeline extracts raw CSV data, transforms it using a **Medallion Architecture (Bronze -> Silver -> Gold)**, ensures data quality via automated tests, orchestrates the workflow with **Prefect**, and visualizes the results on a **Metabase** dashboard.

[🇹🇷 Türkçe açıklamayı aşağıda bulabilirsiniz.](#-türkçe-açıklama)

## 🏗️ Architecture & Tech Stack

- **Data Source**: Irish Rent Prices Dataset (CSV)
- **Database**: PostgreSQL (Containerized via Docker)
- **Orchestration**: Prefect (Python)
- **Data Modeling**: Medallion Architecture & Star Schema (Fact & Dimensions)
- **BI / Visualization**: Metabase
- **Idempotency**: Handled via `TRUNCATE` and `ON CONFLICT DO NOTHING`

## 📊 The Dashboard
*A comprehensive view of the Irish rental market, visualizing price trends, county disparities, and property type distributions.*

![Metabase Dashboard](images/dashboard.png)

## ⚙️ Data Pipeline (Medallion Architecture)

```mermaid
graph LR
    A[(Raw CSV Data)] -->|load_bronze.py| B[(Bronze Layer<br/>Raw Tables)]
    B -->|transform_silver.sql| C[(Silver Layer<br/>Cleaned Data)]
    C -->|build_gold.sql| D[(Gold Layer<br/>Star Schema)]
    D --> E[Metabase BI<br/>Dashboard]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#cd7f32,stroke:#333,stroke-width:2px
    style C fill:#c0c0c0,stroke:#333,stroke-width:2px
    style D fill:#ffd700,stroke:#333,stroke-width:2px
    style E fill:#87CEEB,stroke:#333,stroke-width:2px
```

1. **Bronze Layer (Raw Data)**: Python script (`load_bronze.py`) utilizes `psycopg2.extras.execute_values` for high-performance bulk insertion of raw CSV data into PostgreSQL.
2. **Silver Layer (Cleansed Data)**: SQL transformations (`transform_silver.sql`) clean the data, normalize columns, and remove duplicates.
3. **Gold Layer (Star Schema)**: SQL scripts (`build_gold.sql`) model the cleansed data into a Star Schema (`fact_rent`, `dim_location`, `dim_property`, `dim_time`) for analytical reporting.
4. **Data Quality Audits**: Automated SQL scripts (`tests/`) run integrity checks at the end of the pipeline to ensure data validity.

## 🚀 How to Run

1. **Start the Infrastructure**:
   ```bash
   docker-compose up -d
   ```
2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
3. **Run the ETL Pipeline**:
   ```bash
   python run_pipeline.py
   ```
4. **View Dashboards**: Open `http://localhost:3000` to access Metabase.

---

# 🇹🇷 Türkçe Açıklama

İrlanda kiralık ev piyasasını analiz eden, uçtan uca bir Veri Mühendisliği ve İş Zekası (BI) projesi. Bu boru hattı (pipeline); ham CSV verisini çeker, **Medallion Mimarisi (Bronze -> Silver -> Gold)** kullanarak dönüştürür, otomatik testlerle veri kalitesini sağlar, tüm iş akışını **Prefect** ile yönetir ve sonuçları **Metabase** panosu (dashboard) üzerinde görselleştirir.

## 🏗️ Mimari ve Teknolojiler

- **Veri Kaynağı**: İrlanda Kira Fiyatları Veriseti (CSV)
- **Veritabanı**: PostgreSQL (Docker ile çalışır)
- **Orkestrasyon**: Prefect (Python)
- **Veri Modelleme**: Medallion Mimarisi & Star Schema (Fact ve Boyut Tabloları)
- **İş Zekası (BI)**: Metabase
- **Tekrarlanabilirlik (Idempotency)**: `TRUNCATE` ve `ON CONFLICT DO NOTHING` ile sağlanmıştır.

## ⚙️ Veri Boru Hattı (Medallion Mimarisi)

```mermaid
erDiagram
    fact_rent {
        int id PK
        int dim_location_id FK
        int dim_property_id FK
        int dim_time_id FK
        numeric rent_euro
    }
    dim_location {
        int id PK
        string county
        string province
        string area
        string location
        boolean is_dublin
        boolean is_city
    }
    dim_property {
        int id PK
        string property_type
        string bedrooms
        int bedrooms_num
    }
    dim_time {
        int id PK
        int rent_year
        int half
    }
    
    dim_location ||--o{ fact_rent : "has"
    dim_property ||--o{ fact_rent : "has"
    dim_time ||--o{ fact_rent : "has"
```

1. **Bronze Katmanı (Ham Veri)**: `load_bronze.py` dosyası, `execute_values` (Bulk Insert) kullanarak devasa CSV verisini saniyeler içinde veritabanına yazar.
2. **Silver Katmanı (Temizlenmiş Veri)**: Veriler temizlenir, standartlaştırılır ve SQL ile ayıklanır (`transform_silver.sql`).
3. **Gold Katmanı (Star Schema)**: Temizlenen veri, analitik raporlamaya uygun olarak Fact ve Dimension (Boyut) tablolarına ayrılır (`build_gold.sql`).
4. **Veri Kalitesi Testleri**: Pipeline'ın en sonunda çalışan SQL testleri (`tests/`), verinin doğruluğunu ve eksiksiz olduğunu denetler.

## 🚀 Nasıl Çalıştırılır?

1. **Altyapıyı Başlatın**:
   ```bash
   docker-compose up -d
   ```
2. **Gereksinimleri Yükleyin**:
   ```bash
   pip install -r requirements.txt
   ```
3. **ETL Sürecini (Pipeline) Başlatın**:
   ```bash
   python run_pipeline.py
   ```
4. **Raporları Görüntüleyin**: Metabase paneline erişmek için tarayıcınızda `http://localhost:3000` adresine gidin.
