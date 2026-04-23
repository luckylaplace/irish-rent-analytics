CREATE TABLE IF NOT EXISTS bronze.rent_raw (
   id SERIAL PRIMARY KEY,
   ingestion_time TIMESTAMP DEFAULT now(),
   source_file TEXT,

   rent_euro TEXT,
   year TEXT,
   half TEXT,
   half_year TEXT,
   time_period TEXT,
   county TEXT,
   province TEXT,
   area TEXT,
   location TEXT,
   property_type TEXT,
   bedrooms TEXT,
   bedrooms_num TEXT,
   is_dublin TEXT,
   is_city TEXT,
   is_county_aggregate TEXT
);


CREATE TABLE IF NOT EXISTS silver.rent_clean (
    id SERIAL PRIMARY KEY,
    ingestion_time TIMESTAMP DEFAULT now(),
    source_file TEXT,

    rent_euro NUMERIC,
    rent_year INTEGER,
    half INTEGER,
    property_type TEXT,    -- EKLEDİK
    bedrooms TEXT,         -- EKLEDİK
    bedrooms_num INTEGER,  -- EKLEDİK (NULL olanları 0 yapacağız)
    county TEXT,
    province TEXT,
    area TEXT,
    location TEXT,
    is_dublin BOOLEAN,
    is_city BOOLEAN,
    is_county_aggregate BOOLEAN
);


CREATE TABLE IF NOT EXISTS gold.dim_location(
    id SERIAL PRIMARY KEY,
    county TEXT NOT NULL,
    province TEXT,
    area TEXT,
    location TEXT,
    is_dublin BOOLEAN,
    is_city BOOLEAN,
    CONSTRAINT uq_location UNIQUE (county, province, area, location)
);

CREATE TABLE IF NOT EXISTS gold.dim_property(
    id SERIAL PRIMARY KEY,
    property_type TEXT,
    bedrooms TEXT,
    bedrooms_num INTEGER,
    CONSTRAINT uq_property UNIQUE (property_type, bedrooms)
);

CREATE TABLE IF NOT EXISTS gold.dim_time(
    id SERIAL PRIMARY KEY,
    rent_year INTEGER,
    half INTEGER,
    CONSTRAINT uq_time UNIQUE (rent_year, half)
);

CREATE TABLE IF NOT EXISTS gold.fact_rent (
    id SERIAL PRIMARY KEY,
    dim_location_id INTEGER REFERENCES gold.dim_location(id), -- Lokasyon tablosuna bağlantı
    dim_property_id INTEGER REFERENCES gold.dim_property(id), -- Mülk tablosuna bağlantı
    dim_time_id INTEGER REFERENCES gold.dim_time(id),         -- Zaman tablosuna bağlantı
    rent_euro NUMERIC(10, 2),                                 -- Asıl metrik: Kira miktarı
    
    -- Veri tutarlılığı için UNIQUE kısıtı: 
    -- Aynı lokasyon, aynı mülk tipi ve aynı zamanda sadece bir kira kaydı olabilir.
    CONSTRAINT uq_fact_rent UNIQUE (dim_location_id, dim_property_id, dim_time_id)
);



CREATE TABLE IF NOT EXISTS meta.etl_log (
    id SERIAL PRIMARY KEY,
    job_name TEXT,
    status TEXT CHECK (status IN ('success', 'failed')),
    row_count INTEGER,
    error_message TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    duration INTERVAL,
    executed_at TIMESTAMP DEFAULT now()
);