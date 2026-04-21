-- Active: 1776776061504@@127.0.0.1@5432@rent_dwh
INSERT INTO silver.rent_clean (
    source_file,
    rent_euro, 
    rent_year, 
    half, 
    property_type,       -- YENİ: Mülk tipi (Apartman, ev vb.)
    bedrooms,            -- YENİ: Yatak odası etiketi (1 bed, 2 bed vb.)
    bedrooms_num,        -- YENİ: Sayısal yatak odası sayısı
    county, 
    province, 
    area, 
    location, 
    is_dublin, 
    is_city, 
    is_county_aggregate
)
SELECT 
    source_file, 
    -- Kira tutarını sayıya çeviriyoruz, hatalı verileri (NaN, boşluk) eliyoruz
    CAST(NULLIF(NULLIF(rent_euro, 'NaN'), '') AS NUMERIC) AS rent_euro,
    
    -- Yıl ve Yarım Yıl (Half) bilgisini tam sayıya (INTEGER) çeviriyoruz
    CAST(CAST(NULLIF(NULLIF(year, 'NaN'), '') AS NUMERIC) AS INTEGER) AS rent_year,
    CAST(CAST(NULLIF(NULLIF(half, 'NaN'), '') AS NUMERIC) AS INTEGER) AS half,
    
    -- Metin alanlarını temizliyoruz: Boşlukları sil (TRIM) ve küçük harfe çevir (LOWER)
    TRIM(LOWER(property_type)) AS property_type,
    TRIM(LOWER(bedrooms)) AS bedrooms,
    
    -- Sayısal yatak odası bilgisini alıyoruz. 
    -- CSV'deki NULL değerler için (Aggregate satırlar) 0 atıyoruz ki hesaplamalarda hata vermesin.
    COALESCE(CAST(CAST(NULLIF(NULLIF(bedrooms_num, 'NaN'), '') AS NUMERIC) AS INTEGER), 0) AS bedrooms_num,
    
    TRIM(LOWER(county)) AS county,
    TRIM(LOWER(province)) AS province,
    TRIM(LOWER(area)) AS area,
    TRIM(LOWER(location)) AS location,
    
    -- Boolean (Doğru/Yanlış) değerleri metinden mantıksal tipe çeviriyoruz
    (LOWER(is_dublin) = 'true') AS is_dublin,
    (LOWER(is_city) = 'true') AS is_city,
    (LOWER(is_county_aggregate) = 'true') AS is_county_aggregate
FROM bronze.rent_raw
WHERE 
    -- Sadece geçerli bir kira rakamı olan satırları alıyoruz (Veri kalitesi filtresi)
    rent_euro IS NOT NULL 
    AND rent_euro != 'NaN' 
    AND rent_euro ~ '^[0-9.]+$'
    AND rent_euro::NUMERIC > 0; -- 0 veya negatif kiraları işleme almıyoruz