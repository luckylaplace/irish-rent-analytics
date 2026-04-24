{{ config(materialized='table') }}

SELECT 
    source_file,
    -- Kira tutarını sayıya çeviriyoruz, hatalı verileri eliyoruz
    CAST(NULLIF(NULLIF(rent_euro, 'NaN'), '') AS NUMERIC) AS rent_euro,

    -- Yıl ve Yarım Yıl (Half) bilgisini tam sayıya çeviriyoruz
    CAST(CAST(NULLIF(NULLIF(year, 'NaN'), '') AS NUMERIC) AS INTEGER) AS rent_year,
    CAST(CAST(NULLIF(NULLIF(half, 'NaN'), '') AS NUMERIC) AS INTEGER) AS half,

    -- Metin alanlarını temizliyoruz
    TRIM(LOWER(property_type)) AS property_type,
    TRIM(LOWER(bedrooms)) AS bedrooms,

    -- Sayısal yatak odası bilgisi
    COALESCE(CAST(CAST(NULLIF(NULLIF(bedrooms_num, 'NaN'), '') AS NUMERIC) AS INTEGER), 0) AS bedrooms_num,
    
    TRIM(LOWER(county)) AS county,
    TRIM(LOWER(province)) AS province,
    TRIM(LOWER(area)) AS area,
    TRIM(LOWER(location)) AS location,

    -- Boolean değerler
    (LOWER(is_dublin) = 'true') AS is_dublin,
    (LOWER(is_city) = 'true') AS is_city,
    (LOWER(is_county_aggregate) = 'true') AS is_county_aggregate

FROM bronze.rent_raw
WHERE rent_euro IS NOT NULL
  AND rent_euro != 'NaN'
  AND rent_euro ~ '^[0-9.]+$'
  AND rent_euro::NUMERIC > 0
