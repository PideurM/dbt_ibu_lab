{# TODO: Create a dimension table for races
   - Use SELECT DISTINCT to deduplicate
   - Include: race_id, event_id, race_description, km, cat_id, discipline_id, start_time, status_text
   - Reference the staging model with {{ ref('stg_race_results') }} #}

SELECT DISTINCT
    race_id
    -- TODO: add the remaining race columns
FROM {{ ref('stg_race_results') }}
