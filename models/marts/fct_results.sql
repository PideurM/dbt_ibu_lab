{# TODO: Create a fact table for race results
   - One row = one athlete in one race (the grain)
   - Include foreign keys: athlete_id (renamed from ibu_id), race_id, event_id
   - Include measures: start_order, result_order, bib, leg, rank,
     shootings, shooting_total, run_time, total_time, behind,
     wc, nc, noc, start_group, result
   - Reference the staging model with {{ ref('stg_race_results') }} #}

SELECT
    r.ibu_id AS athlete_id,
    r.race_id,
    r.event_id
    -- TODO: add the remaining result columns
FROM {{ ref('stg_race_results') }} r
