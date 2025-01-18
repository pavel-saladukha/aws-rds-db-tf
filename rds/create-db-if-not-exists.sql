SELECT
    NOT EXISTS(SELECT 1 FROM pg_database WHERE datname = :'DB_NAME') as is_db
\gset
\if :is_db
    CREATE DATABASE :DB_NAME WITH OWNER = :USER_NAME;
\else
    \echo 'DB \"':DB_NAME'\" already exists. Skipping.';
\endif
