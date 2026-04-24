{{ config(materialized='table') }}

SELECT 
    ROW_NUMBER() OVER(ORDER BY rent_year, half) as id,
    rent_year,
    half
FROM (
    SELECT DISTINCT
        rent_year,
        half
    FROM {{ ref('silver_rent') }}
) t
