-- Active: 1776776061504@@127.0.0.1@5432@rent_dwh
INSERT INTO gold.dim_location (county, province, area, location, is_dublin, is_city)
SELECT DISTINCT 
    county, province, area, location, is_dublin, is_city
FROM silver.rent_clean;

INSERT INTO gold.dim_property (property_type, bedrooms, bedrooms_num)
SELECT DISTINCT 
    property_type, bedrooms, bedrooms_num
FROM silver.rent_clean;

INSERT INTO gold.dim_time (rent_year, half)
SELECT DISTINCT 
    rent_year, half
FROM silver.rent_clean;


INSERT INTO gold.fact_rent (dim_location_id, dim_property_id, dim_time_id, rent_euro)
SELECT 
    l.id AS dim_location_id, -- Metin yerine sayı (ID)
    p.id AS dim_property_id, -- Metin yerine sayı (ID)
    t.id AS dim_time_id,     -- Metin yerine sayı (ID)
    s.rent_euro              -- Asıl metrik (Kira)
FROM silver.rent_clean s
-- 1. Lokasyon eşleştirmesi
JOIN gold.dim_location l ON 
    s.location = l.location AND s.county = l.county AND s.area = l.area
-- 2. Mülk özellikleri eşleştirmesi
JOIN gold.dim_property p ON 
    s.property_type = p.property_type AND s.bedrooms = p.bedrooms
-- 3. Zaman eşleştirmesi
JOIN gold.dim_time t ON 
    s.rent_year = t.rent_year AND s.half = t.half;