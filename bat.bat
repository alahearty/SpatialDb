@echo off

set pghost=localhost
set pgport=5432
set pguser=postgres
set pgpassword=worisoft@123
set pgdatabase=college_db

psql -h %pghost% -p %pgport% -U %pguser% -d %pgdatabase% -w -f CreateStatementScript.sql
psql -h %pghost% -p %pgport% -U %pguser% -d %pgdatabase% -w -f GeneratedDataScript.sql

echo All scripts have been executed successfully.

pause
