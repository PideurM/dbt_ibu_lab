SELECT
    -- TODO: Create the cleaned measures for the intermediate model 
FROM {{ ref('stg_race_results') }}
