SELECT DISTINCT
    event_id,
    event_description,
    short_description,
    nat AS country,
    level
FROM {{ ref('stg_race_results') }}
