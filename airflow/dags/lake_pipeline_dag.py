from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator

DBT_CLOUD_CONN_ID = "dbt_cloud_default"
DBT_CLOUD_ACCOUNT_ID = 70506183168462
DBT_CLOUD_JOB_ID = 70506183141729

GLUE_JOB_NAME = "glue-bronze-ingest-bp"

default_args = {
    "owner": "bphalak",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="nfl_lake_pipeline",
    description="Landing -> raw Glue ingestion, then dbt Cloud build for staging and marts",
    default_args=default_args,
    schedule=timedelta(minutes=15),
    start_date=datetime(2026, 1, 1),
    catchup=False,
    max_active_runs=1,
    tags=["nfl", "emr", "iceberg", "dbt"],
) as dag:

    ingest_raw = GlueJobOperator(
        task_id="glue_landing_to_raw",
        job_name=GLUE_JOB_NAME,
        region_name="us-east-1",
    )

    build_staging = DbtCloudRunJobOperator(
        task_id="dbt_build_staging",
        dbt_cloud_conn_id=DBT_CLOUD_CONN_ID,
        account_id=DBT_CLOUD_ACCOUNT_ID,
        job_id=DBT_CLOUD_JOB_ID,
        steps_override=["dbt build --select staging.*"],
        wait_for_termination=True,
        check_interval=30,
        timeout=3600,
    )

    build_marts = DbtCloudRunJobOperator(
        task_id="dbt_build_marts",
        dbt_cloud_conn_id=DBT_CLOUD_CONN_ID,
        account_id=DBT_CLOUD_ACCOUNT_ID,
        job_id=DBT_CLOUD_JOB_ID,
        steps_override=["dbt build --select marts.*"],
        wait_for_termination=True,
        check_interval=30,
        timeout=3600,
    )

    ingest_raw >> build_staging >> build_marts
