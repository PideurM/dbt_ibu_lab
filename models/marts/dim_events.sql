{# TODO: Create a dimension table for events
   - Use SELECT DISTINCT to deduplicate
   - Include: event_id, event_description, short_description, country (renamed from nat), level
   - Reference the staging model with {{ ref('stg_race_results') }} #}

SELECT DISTINCT
    event_id
    -- TODO: add the remaining event columns
FROM {{ ref('stg_race_results') }}
