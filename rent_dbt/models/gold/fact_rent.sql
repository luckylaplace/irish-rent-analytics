{{ config(materialized='table') }}

SELECT
    l.id AS dim_location_id,
    p.id AS dim_property_id,
    t.id AS dim_time_id,
    s.rent_euro
FROM
    {{ ref('silver_rent') }} s
    
    -- Lokasyon eşleştirmesi
    JOIN {{ ref('dim_location') }} l 
        ON s.location = l.location AND s.county = l.county AND s.area = l.area
        
    -- Mülk özellikleri eşleştirmesi
    JOIN {{ ref('dim_property') }} p 
        ON s.property_type = p.property_type AND s.bedrooms = p.bedrooms
        
    -- Zaman eşleştirmesi
    JOIN {{ ref('dim_time') }} t 
        ON s.rent_year = t.rent_year AND s.half = t.half
