-- Run once (beeline or any Spark SQL client). Databases MUST have an S3 location,
-- otherwise Spark places them on HDFS (spark.sql.warehouse.dir).
CREATE DATABASE IF NOT EXISTS staging LOCATION 's3://emr-learning-bp/warehouse/staging.db/';
CREATE DATABASE IF NOT EXISTS marts   LOCATION 's3://emr-learning-bp/warehouse/marts.db/';
-- bronze is created by the Glue ingestion job.
-- Also grant Lake Formation permissions on staging and marts to the EMR EC2 role.
