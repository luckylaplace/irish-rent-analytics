INSERT INTO silver.rent_clean (
    source_file, -- Kaynak dosya adını ekledik
    rent_euro, 
    rent_year, 
    half, 
    county, 
    province, 
    area, 
    location, 
    is_dublin, 
    is_city, 
    is_county_aggregate
)
SELECT 
    source_file, -- Bronze'dan gelen dosya bilgisini direkt alıyoruz
    CAST(NULLIF(NULLIF(rent_euro, 'NaN'), '') AS NUMERIC) AS rent_euro,
    CAST(CAST(NULLIF(NULLIF(year, 'NaN'), '') AS NUMERIC) AS INTEGER) AS rent_year,
    CAST(CAST(NULLIF(NULLIF(half, 'NaN'), '') AS NUMERIC) AS INTEGER) AS half,
    TRIM(LOWER(county)) AS county,
    TRIM(LOWER(province)) AS province,
    TRIM(LOWER(area)) AS area,
    TRIM(LOWER(location)) AS location,
    (LOWER(is_dublin) = 'true') AS is_dublin,
    (LOWER(is_city) = 'true') AS is_city,
    (LOWER(is_county_aggregate) = 'true') AS is_county_aggregate
FROM bronze.rent_raw
WHERE 
    rent_euro IS NOT NULL 
    AND rent_euro != 'NaN' 
    AND rent_euro ~ '^[0-9.]+$';