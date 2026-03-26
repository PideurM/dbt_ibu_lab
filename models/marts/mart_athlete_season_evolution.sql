WITH results AS (
    SELECT
        f.athlete_id,
        a.family_name,
        a.given_name,
        a.athlete_nat,
        f.race_id,
        r.race_description,
        r.discipline_id,
        r.start_time,
        f.rank,
        f.shooting_total
    FROM {{ ref('fct_results') }} f
    LEFT JOIN {{ ref('dim_athletes') }} a ON f.athlete_id = a.athlete_id
    LEFT JOIN {{ ref('dim_races') }} r ON f.race_id = r.race_id
    WHERE f.rank IS NOT NULL
)

SELECT
    athlete_id,
    family_name,
    given_name,
    athlete_nat,
    race_id,
    race_description,
    discipline_id,
    start_time,
    rank,
    shooting_total,
    ROW_NUMBER() OVER(PARTITION BY athlete_id ORDER BY start_time) AS race_number,
    AVG(rank) OVER(PARTITION BY athlete_id ORDER BY start_time ROWS UNBOUNDED PRECEDING) AS cumulative_avg_rank,
    AVG(shooting_total) OVER(PARTITION BY athlete_id ORDER BY start_time ROWS UNBOUNDED PRECEDING) AS cumulative_avg_shooting
FROM results
