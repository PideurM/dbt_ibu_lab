{# TODO: Create a dimension table for races
   - Use SELECT DISTINCT to deduplicate
   - I let you decide which columns to include
   - Reference the staging model with {{ ref('stg_race_results') }} #}

SELECT DISTINCT
    race_id
    -- TODO: add the remaining race columns
FROM {{ ref('stg_race_results') }}
