{{ config(materialized='table') }}

SELECT 
    ROW_NUMBER() OVER(ORDER BY property_type, bedrooms) as id,
    property_type,
    bedrooms,
    bedrooms_num
FROM (
    SELECT DISTINCT
        property_type,
        bedrooms,
        bedrooms_num
    FROM {{ ref('silver_rent') }}
) t
