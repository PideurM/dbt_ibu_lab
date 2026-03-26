SELECT DISTINCT
    ibu_id AS athlete_id,
    family_name,
    given_name,
    short_name,
    athlete_nat
FROM {{ ref('stg_race_results') }}
