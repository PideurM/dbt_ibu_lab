WITH results AS (
    SELECT
        f.athlete_id,
        a.family_name,
        a.given_name,
        a.athlete_nat,
        r.discipline_id,
        f.shooting_total,
        f.rank
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
    discipline_id,
    COUNT(*) AS race_count,
    AVG(shooting_total) AS avg_shooting_total,
    AVG(rank) AS avg_rank
FROM results
GROUP BY athlete_id, family_name, given_name, athlete_nat, discipline_id
