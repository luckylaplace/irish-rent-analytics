-- Gümüş Katmanı Veri Kalite Denetimi
SELECT 
    '1. Toplam Satır Sayısı' AS test_adi, COUNT(*) AS sonuc, 'Fark etmez' AS beklenen FROM silver.rent_clean
UNION ALL
-- 2. Kritik sütunlarda NULL var mı? (0 olmalı)
SELECT 
    '2. NULL Kira Tutarı Sayısı', COUNT(*), '0' FROM silver.rent_clean WHERE rent_euro IS NULL
UNION ALL
-- 3. Mantıksız kira değerleri (0 veya negatif olmamalı)
SELECT 
    '3. Hatalı Kira (<=0) Sayısı', COUNT(*), '0' FROM silver.rent_clean WHERE rent_euro <= 0
UNION ALL
-- 4. Yıl aralığı kontrolü (2020 altı veri olmamalı)
SELECT 
    '4. 2020 Öncesi Kayıt Sayısı', COUNT(*), '0' FROM silver.rent_clean WHERE rent_year < 2020
UNION ALL
-- 5. Dosya kaynağı eksikliği
SELECT 
    '5. source_file Eksik Satır Sayısı', COUNT(*), '0' FROM silver.rent_clean WHERE source_file IS NULL OR source_file = '';