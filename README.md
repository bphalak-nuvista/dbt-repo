# lake_pipeline (dbt on EMR Spark, Iceberg, Glue Data Catalog)

bronze (Glue job) -> staging (cleaned) -> marts (dim, fact, summary tables)

Before the first run:
1. Run setup/create_databases.sql on EMR (databases need an S3 LOCATION).
2. Grant Lake Formation permissions on staging and marts to the EMR EC2 role.
3. Start the Spark Thrift Server on EMR.

Run in dbt Cloud:  dbt build
