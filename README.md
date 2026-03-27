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

- [ ] **Step 1: Init project & Connect to Snowflake** <-- You are here
- [ ] Step 2: Star Schema (staging, dimensions, fact)
- [ ] Step 3: Jinja & macros
- [ ] Step 4: Built-in dbt tests
- [ ] Step 5: Documentation & packages
- [ ] Step 6: Final mart table (analytics)
- [ ] Step 7: CI/CD with GitHub Actions

---

## Step 1 — Init project & Connect to Snowflake

### Step 1.1 — Understand the dbt project structure

**Goal:** Understand the dbt project structure.

**Tasks:**
1. Explore the project structure:
   ```
   dbt_ibu_lab/
   ├── dbt_project.yml       # Project configuration
   ├── profiles.yml          # Snowflake connection
   ├── models/               # Where marts will exist
   ├── macros/               # Reusable Jinja macros
   ├── seeds/                # CSV files to load
   ├── scripts/              # Utility scripts
   └── target/               # Compiled SQL
   ```
2. Review `dbt_project.yml` — understand `name`, `profile`, `model-paths`, `materialized`

**Key concepts:**
- What is dbt? A transformation tool — it handles the **T** in ELT
- dbt compiles Jinja+SQL → pure SQL → runs it on your warehouse
- Convention over configuration: folder structure drives behavior

### Step 1.2 — Connect to Snowflake & load data

**Goal:** Connect dbt to Snowflake and load the raw CSV data.

**Tasks:**
1. Create a `.env` file based on `.env.sample` with your Snowflake credentials
2. Ensure `.env` is in `.gitignore`
3. Load the environment variables:
   ```bash
   set -a
   source .env
   set +a
   ```
   > **Why not just `source .env`?** When you do `source .env`, the variables exist in your current shell session but are **not passed down** to child processes. `dbt debug` runs as a child process — it won't see your variables unless they are **exported**. `set -a` tells your shell to automatically `export` every variable assignment, so `source .env` exports everything. `set +a` turns off auto-export afterward.
4. Review `profiles.yml` — notice how `{{ env_var() }}` reads from environment variables
5. Test the connection:
   ```bash
   uv run dbt debug
   ```
5. Load data to Snowflake:
   ```bash
   uv run scripts/load_to_snowflake.py
   ```
6. Verify data in Snowflake

**Key concepts:**
- `profiles.yml` — connection profiles, targets (dev/prod)
- `{{ env_var() }}` — first taste of Jinja: reading environment variables
- Never commit credentials

**Questions:**
- What does `dbt debug` check?
- Why do we use `env_var()` instead of hardcoding credentials?
- What is the difference between ELT and ETL?

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
