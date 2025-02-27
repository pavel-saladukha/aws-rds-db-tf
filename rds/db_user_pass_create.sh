#!/bin/bash

rds_name=$1

rds_db_aray=$(rds_name=${rds_name} yq '.rds | to_entries | .[] | select(.key == env(rds_name)) | .key as $key | .value.databases[] | "\($key)->\(. )"' infra.yaml)

sops -d secrets.enc.yaml > secrets.yaml

for rds_db in ${rds_db_aray}
do

	rds=$(echo $rds_db | cut -d'-' -f1)
	db=$(echo $rds_db | cut -d'>' -f2)

	user=$(key="${rds}_${db}_username" yq '.[env(key)]' secrets.yaml)
	pass=$(key="${rds}_${db}_password" yq '.[env(key)]' secrets.yaml)

	PGPASSWORD=example psql -h localhost -U postgres -v USER_NAME=$user -v USER_PASSWORD=$pass -f ./rds/create-user-if-not-exists.sql
	PGPASSWORD=example psql -h localhost -U postgres -v USER_NAME=$user -v DB_NAME=$db -f ./rds/create-db-if-not-exists.sql

done

rm secrets.yaml
