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
- [x] Step 3: Jinja & macros
- [ ] **Step 4: Built-in dbt tests** <-- You are here
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

**Goal:** Learn Jinja templating by creating reusable macros to solve real data quality issues.

**Theory — Jinja basics:**
- `{{ }}` — expressions: output a value (variable, function call, macro)
- `{% %}` — statements: control flow (if, for, macro, set)
- `{# #}` — comments: ignored in compiled SQL
- dbt compiles Jinja → pure SQL before sending to Snowflake

### Step 3.1 — Discover the problem

**Tasks:**
1. Run `cleaned_measures_raw.sql` — a naive attempt to cast columns:
   ```bash
   uv run dbt run --select cleaned_measures_raw
   ```
2. Surprise: dbt says **SUCCESS** — the view is created in Snowflake!
3. Now try to query it:
   ```bash
   uv run dbt show --select cleaned_measures_raw
   ```
4. **Error!** The view exists in Snowflake but the SQL inside fails when queried.

> **Why?** With `materialized: view`, dbt runs `CREATE VIEW AS SELECT ...`. Snowflake accepts the DDL without executing the SELECT — it only validates syntax, not data. When you (or dbt show) actually **query** the view, Snowflake runs the SELECT and hits the casting error. This is a key difference between views and tables: a table would fail immediately at `dbt run` because the SELECT is executed to materialize the data.

### Step 3.2 — The `parse_iso_timestamp` macro (demo)

1. Review `macros/parse_iso_timestamp.sql` — a macro that parses ISO timestamps
2. See how it's used in `dim_races.sql` for `start_time`
3. See the compiled SQL:
   ```bash
   uv run dbt compile --select dim_races
   cat target/compiled/dbt_biathlon/models/marts/dim_races.sql
   ```

### Step 3.3 — Exercise: Create your own macros

Now it's your turn! Open `models/intermediate/cleaned_measures.sql` and the macro files — follow the TODO comments.

**Exercise 1:** Complete `macros/clear_km_relay.sql`
- Goal: extract the km value from relay format (e.g., `4x6` → `6`)
- Hint: use `RIGHT()`, `LENGTH()`, and `POSITION('x' IN ...)`
- Don't forget to add an `AS` alias!

**Exercise 2:** Complete `macros/select_spares.sql`
- Goal: split the `shootings` column (`0+1`) into two columns: `shootings` (prone) and `shootings_spare` (standing)
- Hint: use `LEFT()`, `RIGHT()`, `LENGTH()`, and `POSITION('+' IN ...)`
- The macro must output **two columns** separated by a comma

**Exercise 3:** Update `models/intermediate/cleaned_measures.sql`
- Replace the TODO placeholders with calls to your macros
- Run and verify:
   ```bash
   uv run dbt run --select cleaned_measures
   ```

**Exercise 4** Update the fct_results ref for cleaned_measures
   ```bash
   uv run dbt run --select fct_results
   ```

**Key concepts:**
- Macros = reusable SQL functions written in Jinja
- `dbt compile` — see the generated SQL without running it
- DRY principle: write once, use everywhere
- Jinja is a Python templating language — dbt runs it at compile time
- Intermediate models handle data quality issues between staging and marts

**Questions:**
- What is the difference between `{{ }}` and `{% %}`?
- Why is `dbt compile` useful for debugging?
- Why did `cleaned_measures_raw.sql` fail but `stg_race_results.sql` didn't?

---

## Step 4 — Built-in dbt tests

**Goal:** Add data quality tests to the models.

**Tasks:**
1. Create `models/marts/_schema.yml` with tests for all mart models
2. Use the 4 built-in test types:
   - `unique` — no duplicate values
   - `not_null` — no NULL values
   - `accepted_values` — column values must be in a list
   - `relationships` — foreign key integrity (value exists in another model)
3. Run the tests:
   ```bash
   uv run dbt test
   ```
4. Observe which tests pass and which fail — discuss why
5. Try `dbt build` (run + test together):
   ```bash
   uv run dbt build
   ```

### Exercise 1: A test that fails

1. Run the tests:
   ```bash
   uv run dbt test
   ```
2. The `not_null` test on `fct_results.rank` **fails**. Why?
3. Investigate: what rows have a NULL rank? Look at the `irm` column — what does it contain? (DNF, DNS, LAP, DSQ...)
4. **Fix the test** so it passes: rank can be NULL, but **only when IRM is not NULL**. Hint: the `not_null` test accepts a `where` config.

### Exercise 2: Add your own tests

Add tests for `stg_race_results` in a new `models/staging/_schema.yml`. What columns should be tested?

### Exercise 3: Tolerance with warn_if / error_if

After fixing the rank test with `where: "irm IS NULL"`, you may still have a few edge cases (para-biathlon athletes with no rank and no IRM). Instead of failing the pipeline, you can set tolerance thresholds:

```yaml
- not_null:
    where: "irm IS NULL"
    warn_if: ">0"
    error_if: ">10"
```

- `warn_if: ">0"` — emit a **warning** if any rows fail (pipeline continues)
- `error_if: ">10"` — only **error** if more than 10 rows fail (pipeline stops)

Try adding this to your rank test. This is useful when you accept known edge cases in the data without breaking the build.

**Key concepts:**
- 4 built-in tests: `unique`, `not_null`, `accepted_values`, `relationships`
- Tests are SQL queries — a test fails if it returns rows
- `_schema.yml` — model documentation + tests in one file
- `dbt build` = `dbt run` + `dbt test` in dependency order
- Tests catch data quality issues early

**Questions:**
- What SQL does dbt generate for a `unique` test?
- Why might a `relationships` test fail?
- When should you use `dbt build` vs `dbt run` + `dbt test` separately?

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
