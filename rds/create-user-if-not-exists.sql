SELECT
    NOT EXISTS(SELECT 1 FROM pg_user WHERE usename = :'USER_NAME') as is_user
\gset
\if :is_user
    CREATE USER :USER_NAME WITH PASSWORD ':USER_PASSWORD' LOGIN CREATEDB;
\else
    \echo 'User \"':USER_NAME'\" already exists. Skipping.';
\endif
