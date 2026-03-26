SELECT DISTINCT
    race_id,
    event_id,
    race_description,
    km,
    cat_id,
    discipline_id,
    {{ parse_iso_timestamp('start_time') }} AS start_time,
    status_text
FROM {{ ref('stg_race_results') }}
