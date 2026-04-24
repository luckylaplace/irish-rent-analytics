{{ config(materialized='table') }}

SELECT 
    ROW_NUMBER() OVER(ORDER BY county, area, location) as id,
    county,
    province,
    area,
    location,
    is_dublin,
    is_city
FROM (
    SELECT DISTINCT
        county,
        province,
        area,
        location,
        is_dublin,
        is_city
    FROM {{ ref('silver_rent') }}
) t
