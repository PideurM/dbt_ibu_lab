{# TODO: Create a dimension table for athletes
   - Use SELECT DISTINCT to deduplicate
   - Rename ibu_id to athlete_id
   - I let you decide which columns to include
   - Reference the staging model with {{ ref('stg_race_results') }} #}

SELECT DISTINCT
    ibu_id AS athlete_id
    -- TODO: add the remaining athlete columns
FROM {{ ref('stg_race_results') }}
