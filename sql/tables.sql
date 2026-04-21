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