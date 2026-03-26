import os
import snowflake.connector

account  = os.environ["SNOWFLAKE_ACCOUNT"]
user     = os.environ["SNOWFLAKE_USER"]
password = os.environ["SNOWFLAKE_PASSWORD"]
role     = os.environ["SNOWFLAKE_ROLE"]
warehouse= os.environ["SNOWFLAKE_WAREHOUSE"]
database = os.environ["SNOWFLAKE_DATABASE"]
schema   = os.environ["SNOWFLAKE_SCHEMA"]
csv_path = os.path.abspath("seeds/races_results_raw.csv")

conn = snowflake.connector.connect(
    account=account,
    user=user,
    password=password,
    role=role,
    warehouse=warehouse,
)
cur = conn.cursor()

steps = [
    f"CREATE DATABASE IF NOT EXISTS {database}",
    f"CREATE SCHEMA IF NOT EXISTS {database}.{schema}",
    f"""CREATE OR REPLACE FILE FORMAT {database}.{schema}.csv_format
        TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1 NULL_IF = ('', 'NULL')""",
    f"""CREATE OR REPLACE STAGE {database}.{schema}.biathlon_stage
        FILE_FORMAT = {database}.{schema}.csv_format""",
    f"""CREATE OR REPLACE TABLE {database}.{schema}.races_results_raw (
        EventId VARCHAR, EventDescription VARCHAR, ShortDescription VARCHAR,
        Nat VARCHAR, Level VARCHAR, RaceId VARCHAR, RaceDescription VARCHAR,
        km VARCHAR, catId VARCHAR, DisciplineId VARCHAR, StartTime VARCHAR,
        StatusText VARCHAR, AthleteNat VARCHAR, StartOrder VARCHAR,
        ResultOrder VARCHAR, IRM VARCHAR, IBUId VARCHAR, IsTeam VARCHAR,
        Name VARCHAR, ShortName VARCHAR, FamilyName VARCHAR, GivenName VARCHAR,
        Bib VARCHAR, Leg VARCHAR, Rank VARCHAR, Shootings VARCHAR,
        ShootingTotal VARCHAR, RunTime VARCHAR, TotalTime VARCHAR,
        WC VARCHAR, NC VARCHAR, NOC VARCHAR, Behind VARCHAR,
        StartGroup VARCHAR, TeamId VARCHAR, PursuitStartDistance VARCHAR, Result VARCHAR
    )""",
]

print("Setting up Snowflake objects...")
for sql in steps:
    cur.execute(sql)
    print(f"  OK: {sql.strip()[:60]}...")

print(f"Uploading {csv_path}...")
cur.execute(f"USE DATABASE {database}")
cur.execute(f"USE SCHEMA {schema}")
cur.execute(f"PUT file://{csv_path} @biathlon_stage AUTO_COMPRESS=TRUE OVERWRITE=TRUE")
print("  Upload done.")

print("Loading data...")
cur.execute(f"""
    COPY INTO {database}.{schema}.races_results_raw
    FROM @{database}.{schema}.biathlon_stage/races_results_raw.csv.gz
    FILE_FORMAT = (FORMAT_NAME = '{database}.{schema}.csv_format')
    ON_ERROR = 'CONTINUE'
""")
cur.execute(f"SELECT COUNT(*) FROM {database}.{schema}.races_results_raw")
count = cur.fetchone()[0]
print(f"  Loaded {count} rows.")

cur.close()
conn.close()
