{# TODO: Create an analytical mart aggregating athlete performance by discipline.
   - Join fct_results with dim_athletes and dim_races using ref()
   - Filter out rows where rank IS NULL
   - Group by athlete + discipline
   - Aggregate: COUNT(*), AVG(shooting_total), AVG(rank)
   - One row = one athlete per discipline #}

SELECT
    f.athlete_id
    -- TODO: complete the query
FROM {{ ref('fct_results') }} f
