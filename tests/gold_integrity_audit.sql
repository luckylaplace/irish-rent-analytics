-- Altın (Gold) Katmanı Veri ve İlişki Denetimi

SELECT 
    '1. Fact Tablosu Satır Sayısı' AS test_adi, 
    COUNT(*) AS sonuc, 
    '>0 olmalı' AS beklenen 
FROM gold.fact_rent

UNION ALL

SELECT 
    '2. Lokasyon Boyut Tablosu Satır Sayısı', 
    COUNT(*), 
    '>0 olmalı' 
FROM gold.dim_location

UNION ALL

SELECT 
    '3. Mülk Boyut Tablosu Satır Sayısı', 
    COUNT(*), 
    '>0 olmalı' 
FROM gold.dim_property

UNION ALL

SELECT 
    '4. Zaman Boyut Tablosu Satır Sayısı', 
    COUNT(*), 
    '>0 olmalı' 
FROM gold.dim_time

UNION ALL

-- ETL Loglarının Kontrolü
SELECT 
    '5. Başarılı Python ETL Logu Sayısı', 
    COUNT(*), 
    '>0 olmalı' 
FROM meta.etl_log 
WHERE status = 'success';
