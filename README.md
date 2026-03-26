# dbt Biathlon Lab — Build a Star-Schema Datamart

Build a star-schema datamart from scratch using **dbt-core** and **Snowflake**, based on IBU biathlon race results (2024-2025 season, 18,503 rows).

## Prerequisites

- Python 3.12+
- Snowflake account (provided by instructor)
- Git installed
- Terminal / VS Code

## Installation

1. Install [uv](https://docs.astral.sh/uv/) (Python package manager):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
2. Install project dependencies:
   ```bash
   uv sync
   ```

## Navigating the course

Each step of the course is a git branch. To move to a step:
```bash
git checkout step/01-init-proj   # Start here
git checkout step/02-star-schema # Next step (contains step 1 solution)
# etc.
```

## Course Progress

- [x] Step 1: Init project & Connect to Snowflake
- [x] Step 2: Star Schema (staging, dimensions, fact)
- [ ] **Step 3: Jinja & macros** <-- You are here
- [ ] Step 4: Built-in dbt tests
- [ ] Step 5: Documentation & packages
- [ ] Step 6: Final mart table (analytics)
- [ ] Step 7: CI/CD with GitHub Actions

---

## Step 1 — Init project & Connect to Snowflake (completed)

Project initialized with dbt-core + Snowflake connection via `profiles.yml` and `env_var()`. Data loaded with `scripts/load_to_snowflake.py`.

---

## Step 2 — Create Star Schema

### Step 2.1 — Staging model

**Goal:** Create the first dbt model and define a source.

**Tasks:**
1. Create the folder structure:
   ```
   models/
   └── staging/
       ├── _sources.yml
       └── stg_race_results.sql
   ```
2. Define the source in `_sources.yml`:
   ```yaml
   version: 2
   sources:
     - name: raw
       database: "{{ env_var('SNOWFLAKE_DATABASE') }}"
       schema: "{{ env_var('SNOWFLAKE_SCHEMA') }}"
       tables:
         - name: races_results_raw
   ```
3. Write `stg_race_results.sql`:
   - Reference the source with `{{ source('raw', 'races_results_raw') }}`
   - Rename columns to snake_case
   - Cast types (e.g., `km` → FLOAT, `rank` → INT, `is_team` → BOOLEAN)
   - Filter out invalid records (`IRM IS NULL`)
4. Run and verify:
   ```bash
   uv run dbt run --select stg_race_results
   ```

**Key concepts:**
- `{{ source() }}` — referencing raw tables
- `_sources.yml` — declaring source tables
- Staging models: clean, rename, cast — no business logic
- `stg_` naming convention

### Step 2.2 — Dimension tables

**Goal:** Build the star schema dimension tables.

**Tasks:**
1. Create dimension models in `models/marts/`:
   - `dim_athletes.sql` — unique athletes with nationality
   - `dim_events.sql` — unique events with location and level
   - `dim_races.sql` — unique races with discipline and distance
2. Use `{{ ref('stg_race_results') }}` to reference the staging model
3. Use `SELECT DISTINCT` to deduplicate from the flat source
4. Run all models:
   ```bash
   uv run dbt run
   ```

**Key concepts:**
- `{{ ref() }}` — referencing other models (creates dependencies)
- Dimension tables: descriptive attributes, no metrics
- Star schema: dimensions describe the "who/what/where/when"
- dbt builds models in dependency order automatically

### Step 2.3 — Fact table

**Goal:** Build the central fact table connecting all dimensions.

**Tasks:**
1. Create `models/marts/fct_results.sql`:
   - Select measurable columns: rank, shootings, run_time, total_time, etc.
   - Include foreign keys: athlete_id, race_id, event_id
2. Discuss grain: one row = one athlete in one race
3. Run the full pipeline:
   ```bash
   uv run dbt run
   ```
4. Check the execution order in terminal output

**Key concepts:**
- Fact tables: measurable events, foreign keys to dimensions
- Grain — what does each row represent?
- The full pipeline runs staging → dimensions → fact in order

**Questions:**
- What is the difference between `source()` and `ref()`?
- Why do we use `SELECT DISTINCT` in dimension tables but not in the fact table?
- What happens if you run `dbt run --select fct_results` without running staging first?

---

## Step 3 — Jinja & macros

**Goal:** Learn Jinja templating by creating a reusable macro.

**Theory — Jinja basics:**
- `{{ }}` — expressions: output a value (variable, function call, macro)
- `{% %}` — statements: control flow (if, for, macro, set)
- `{# #}` — comments: ignored in compiled SQL
- dbt compiles Jinja → pure SQL before sending to Snowflake

**Tasks:**
1. Create `macros/parse_iso_timestamp.sql`:
   ```sql
   {% macro parse_iso_timestamp(column_name) %}
       TRY_TO_TIMESTAMP_NTZ({{ column_name }}, 'YYYY-MM-DD"T"HH24:MI:SSZ')
   {% endmacro %}
   ```
2. Use it in `dim_races.sql` to parse `start_time`
3. See the compiled SQL:
   ```bash
   uv run dbt compile --select dim_races
   cat target/compiled/dbt_biathlon/models/marts/dim_races.sql
   ```
4. **Exercise:** Create a `convert_time_to_seconds` macro that converts `MM:SS.s` format to total seconds using `{% if %}`. Use it in `fct_results.sql` for `run_time`.
5. Run and verify:
   ```bash
   uv run dbt run
   ```

**Key concepts:**
- Macros = reusable SQL functions written in Jinja
- `dbt compile` — see the generated SQL without running it
- DRY principle: write once, use everywhere
- Jinja is a Python templating language — dbt runs it at compile time

**Questions:**
- What is the difference between `{{ }}` and `{% %}`?
- Why is `dbt compile` useful for debugging?
- How would you pass multiple arguments to a macro?

---

## Useful commands

```bash
uv run dbt debug              # Test connection
uv run dbt run                # Run all models
uv run dbt run --select <model>  # Run one model
uv run dbt test               # Run all tests
uv run dbt build              # Run + test in order
uv run dbt compile            # Compile Jinja → SQL (no execution)
uv run dbt docs generate      # Generate documentation
uv run dbt docs serve         # Serve docs on localhost
uv run dbt deps               # Install packages
```

## Resources

- [dbt Fundamentals Course](https://learn.getdbt.com/courses/dbt-fundamentals) — 5 hours
- [dbt + Snowflake Configuration](https://www.getdbt.com/blog/how-we-configure-snowflake)
