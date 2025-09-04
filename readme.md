
### 数据库

gcloud sql connect racketrallydb --user=postgres --database=postgres --project=ldtech
SHOW client_encoding;
\encoding UTF8
\set ON_ERROR_STOP on
\i D:/ldtech/health/halth/Database/health_postgres.sql

### 数据库操作

\conninfo
\c health
\c postgres

CMD）psql -d postgres -U postgres

SET search_path TO health, public;
SHOW search_path;

### 创建数据库

CREATE DATABASE postgres;

SET app.env = 'dev';
\i D:/ldtech/health/halth/Database/health_postgres.sql

### 1）查看数据库

SELECT datname FROM pg_database WHERE datistemplate = false;
