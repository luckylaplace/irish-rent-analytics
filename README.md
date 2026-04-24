# 🇮🇪 Irish Rent Analysis Pipeline (End-to-End Data Engineering)

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](https://www.docker.com/)
[![Prefect](https://img.shields.io/badge/Prefect-3.0-white.svg)](https://www.prefect.io/)
[![Metabase](https://img.shields.io/badge/Metabase-BI-509EE3.svg)](https://www.metabase.com/)

An end-to-end Data Engineering and Business Intelligence project that analyzes the Irish rental market. The pipeline extracts raw CSV data, transforms it using a **Medallion Architecture (Bronze -> Silver -> Gold)**, ensures data quality via automated tests, orchestrates the workflow with **Prefect**, and visualizes the results on a **Metabase** dashboard.

---

<details open>
<summary><h2>🇬🇧 English Documentation</h2></summary>

### 🏗️ Architecture & Tech Stack
- **Data Source**: Irish Rent Prices Dataset (CSV)
- **Database**: PostgreSQL (Containerized via Docker)
- **Orchestration**: Prefect (Python)
- **Transformation & Testing**: dbt (Data Build Tool)
- **Data Modeling**: Medallion Architecture & Star Schema (Fact & Dimensions)
- **BI / Visualization**: Metabase
- **Idempotency**: Handled natively by dbt (`TRUNCATE` and `INSERT`)

### ⚙️ Data Pipeline (Medallion Architecture)

```mermaid
graph LR
    A[(Raw CSV Data)] -->|load_bronze.py| B[(Bronze Layer<br/>Raw Tables)]
    B -->|dbt run| C[(Silver Layer<br/>Cleaned Data)]
    C -->|dbt run| D[(Gold Layer<br/>Star Schema)]
    D --> E[Metabase BI<br/>Dashboard]
```

1. **Bronze Layer (Raw Data)**: Python script (`load_bronze.py`) utilizes `execute_values` for high-performance bulk insertion.
2. **Silver Layer (Cleansed Data)**: **dbt** models clean the data, normalize columns, and remove duplicates.
3. **Gold Layer (Star Schema)**: **dbt** models transform the cleansed data into a Star Schema for analytical reporting.
4. **Data Quality Audits**: **dbt test** automatically validates referential integrity, null constraints, and uniqueness at the end of the pipeline.

### 🗄️ Data Model (Star Schema)

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

### 📊 The Dashboard
*A comprehensive view of the Irish rental market, visualizing price trends, county disparities, and property type distributions.*

<div align="center">
  <img src="images/rent_dashboard.png" alt="Metabase Dashboard" width="100%">
</div>

### 🚀 How to Run
1. **Start the Infrastructure**: `docker-compose up -d`
2. **Install Dependencies**: `pip install -r requirements.txt`
3. **Run the ETL Pipeline**: `python run_pipeline.py`
4. **View Dashboards**: Open `http://localhost:3000` to access Metabase.

</details>

<details>
<summary><h2>🇹🇷 Türkçe Dokümantasyon</h2></summary>

İrlanda kiralık ev piyasasını analiz eden, uçtan uca bir Veri Mühendisliği ve İş Zekası (BI) projesi. Bu boru hattı (pipeline); ham CSV verisini çeker, **Medallion Mimarisi (Bronze -> Silver -> Gold)** kullanarak dönüştürür, otomatik testlerle veri kalitesini sağlar, tüm iş akışını **Prefect** ile yönetir ve sonuçları **Metabase** panosu (dashboard) üzerinde görselleştirir.

### 🏗️ Mimari ve Teknolojiler
- **Veri Kaynağı**: İrlanda Kira Fiyatları Veriseti (CSV)
- **Veritabanı**: PostgreSQL (Docker ile çalışır)
- **Orkestrasyon**: Prefect (Python)
- **Dönüşüm ve Test (T)**: dbt (Data Build Tool)
- **Veri Modelleme**: Medallion Mimarisi & Star Schema (Fact ve Boyut Tabloları)
- **İş Zekası (BI)**: Metabase
- **Tekrarlanabilirlik (Idempotency)**: dbt tarafından otomatik sağlanır.

### ⚙️ Veri Boru Hattı (Medallion Mimarisi)

```mermaid
graph LR
    A[(Ham CSV Verisi)] -->|load_bronze.py| B[(Bronze Katmanı<br/>Ham Tablolar)]
    B -->|dbt run| C[(Silver Katmanı<br/>Temizlenmiş Veri)]
    C -->|dbt run| D[(Gold Katmanı<br/>Star Schema)]
    D --> E[Metabase BI<br/>Dashboard]
```

1. **Bronze Katmanı (Ham Veri)**: `load_bronze.py` dosyası, `execute_values` kullanarak devasa CSV verisini saniyeler içinde veritabanına yazar.
2. **Silver Katmanı (Temizlenmiş Veri)**: **dbt** modelleri (models) verileri temizler, standartlaştırır ve ayıklar.
3. **Gold Katmanı (Star Schema)**: **dbt** modelleri, temizlenen veriyi analitik raporlamaya uygun olarak Fact ve Dimension (Boyut) tablolarına böler.
4. **Veri Kalitesi Testleri**: Pipeline'ın en sonunda **dbt test** çalışarak verinin doğruluğunu (Referential Integrity, Null checks) otomatik olarak denetler.

### 🗄️ Veri Modeli (Star Schema)

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

### 📊 Raporlama ve Pano (Dashboard)
*İrlanda kiralık ev piyasasının kapsamlı bir özeti; fiyat trendleri, bölgesel farklar ve ev tipi dağılımları.*

<div align="center">
  <img src="images/rent_dashboard.png" alt="Metabase Dashboard" width="100%">
</div>

### 🚀 Nasıl Çalıştırılır?
1. **Altyapıyı Başlatın**: `docker-compose up -d`
2. **Gereksinimleri Yükleyin**: `pip install -r requirements.txt`
3. **ETL Sürecini (Pipeline) Başlatın**: `python run_pipeline.py`
4. **Raporları Görüntüleyin**: Metabase paneline erişmek için tarayıcınızda `http://localhost:3000` adresine gidin.

</details>
