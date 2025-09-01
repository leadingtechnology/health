
### 数据库

gcloud sql connect racketrallydb --user=postgres --database=postgres --project=ldtech
SHOW client_encoding;
\encoding UTF8
\set ON_ERROR_STOP on
\i D:/ldtech/health/halth/Database/health_postgres.sql

### 数据库操作

\conninfo
\c racketrally
\c postgres

CMD）psql -d racketrally -U postgres

SET search_path TO health, public;
SHOW search_path;
