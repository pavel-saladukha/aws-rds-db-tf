#!/bin/bash

rds_name=$1

rds_db_aray=$(rds_name=${rds_name} yq '.rds | to_entries | .[] | select(.key == env(rds_name)) | .key as $key | .value.databases[] | "\($key)->\(. )"' infra.yaml)

sops -d secrets.enc.yaml > secrets.yaml

# creating missing credentials following convention
for rds_db in ${rds_db_aray}
do

	rds=$(echo $rds_db | cut -d'-' -f1)
	db=$(echo $rds_db | cut -d'>' -f2)

	user_exists=$(key="${rds}_${db}_username" yq '. | has( env(key) )' secrets.yaml)
	if [ $user_exists = 'false' ]; then
		user=$(tr -dc a-z0-9 </dev/urandom | head -c 25; echo)
		key="${rds}_${db}_username" value="$user" yq -i '.[env(key)] = env(value) | .[env(key)] style="double" ' secrets.yaml
	fi

	pass_exists=$(key="${rds}_${db}_password" yq '. | has( env(key) )' secrets.yaml)
	if [ $pass_exists = 'false' ]; then
		pass=$(tr -dc A-Za-z0-9 </dev/urandom	 | head -c 25; echo)
		key="${rds}_${db}_password" value="$pass" yq -i '.[env(key)] = env(value) | .[env(key)] style="double" ' secrets.yaml
	fi
done

sops -e secrets.yaml > secrets.enc.yaml
