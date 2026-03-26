{# TODO: Create a mart showing each athlete's ranking evolution over the season.
   For each athlete and race, compute:
   - Their cumulative average rank across the season (ordered by race start_time)
   - The number of races completed so far

   This requires a WINDOW FUNCTION — you cannot do this with GROUP BY alone!

   Hint:
     AVG(rank) OVER(PARTITION BY ... ORDER BY ... ROWS UNBOUNDED PRECEDING)

   Join fct_results with dim_athletes and dim_races.
   Filter out rows where rank IS NULL (IRM results). #}

SELECT
    f.athlete_id
    -- TODO: complete the query with window functions
FROM {{ ref('fct_results') }} f
