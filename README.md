README
======

ButteredScone is a way of parsing logs and uploading them into a database for querying. At the moment it supports Apache logs and Redshift as the query store.

## Parsing Logs

```bash
./bin/parse_apache_log.pl APACHE.log output.csv
./bin/add_csv_data.pl output.csv output.csv.ext
gzip output.csv.ext
```

The first command converts apache logs into a CSV format. The second one adds information such as the success method and event data.

## Loading into Redshift

### Create the schema

```sql
CREATE TABLE "log" (
  "ip" character varying(40) NOT NULL,
  "event" timestamp NOT NULL,
  "bytes" bigint NOT NULL,
  "code" integer NOT NULL,
  "user_agent" character varying(1024) NOT NULL,
  "url" character varying(65535) NOT NULL,
  "method" character varying(10) NOT NULL,
  "success" smallint NOT NULL,
  "year" smallint NOT NULL,
  "month" smallint NOT NULL,
  "day" integer NOT NULL,
  "quarter" smallint NOT NULL,
  CONSTRAINT "log_idx" UNIQUE ("event", "ip", "url", "method")
);
```

### Uploading into S3

```bash
./bin/upload_s3.pl ~/path/to/credentials.csv S3-BUCKET DIRECTORY
```

- `credentials.csv`: assumed to be a CSV with 3 columns. name,aws_access_key_id,aws_secret_access_key. Second row is assumed to have the details
- S3-BUCKET: make sure this is created on the S3 side
- DIRECTORY: where all the parsed logs are. Code will find anything with a *.csv.ext* extension and upload

The code also creates a manifest file

### Load 

```sql
copy log from 's3://S3-BUCKET/manifest.json' credentials 'aws_access_key_id=XXXXXXXXXXX;aws_secret_access_key=XXXXXXXXXX' delimiter ',' timeformat 'YYYY-MM-DDTHH:MI:SS' removequotes emptyasnull blanksasnull gzip manifest maxerror as 250;
```

## Example Queries

### All successful hits grouped by month

```sql
select year, month, count(*) 
from log 
where success = 1 
group by year, month 
order by year, month
```

### All successful hits grouped by quarter

```sql
select year, quarter, count(*) 
from log 
where success = 1 
group by year, quarter 
order by year, quarter
```
