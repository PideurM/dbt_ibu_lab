SELECT DISTINCT
    race_id,
    event_id,
    race_description,
    km,
    cat_id,
    discipline_id,
    start_time,
    status_text
FROM {{ ref('stg_race_results') }}
