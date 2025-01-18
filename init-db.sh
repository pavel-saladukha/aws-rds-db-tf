#!/bin/bash

# 1. parse yaml config with RDS->db relatation
# 2. decrypt sops file
# 3. iterate over rds->db to check if credentials are in sops
# 	if nothing in sops file -> generate credentials and put those into sops

# 4. iterate ver credentails from sops
# 	if not exists apply to DB

rds_db_aray=$(yq '.rds | to_entries | .[] | .key as $key | .value.databases[] | "\($key)->\(. )"' infra.yaml)

sops decrypt -i secrets.yaml

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

# # create DBs and users for them if not exists
# for rds_db in ${rds_db_aray}
# do

# 	rds=$(echo $rds_db | cut -d'-' -f1)
# 	db=$(echo $rds_db | cut -d'>' -f2)

# 	user=$(key="${rds}_${db}_username" yq '.[env(key)]' secrets.yaml)
# 	pass=$(key="${rds}_${db}_password" yq '.[env(key)]' secrets.yaml)
	
# 	echo $user
# 	echo $pass

# 	cat <<EOF > create-user-if-not-exists.sql
# DO
# \$$
# BEGIN
#     IF EXISTS (SELECT * FROM pg_user WHERE usename = '$user') THEN
# 		RAISE NOTICE 'User $user already exists. Skipping.';
#     ELSE
#         CREATE USER $user WITH PASSWORD '$pass' LOGIN CREATEDB;
#     END IF;
# END
# \$$;

# EOF
# 	PGPASSWORD=example psql --host=localhost --username=postgres --file=create-user-if-not-exists.sql

# done

# if (select count(*) from pg_user where usename = 'bla') = 0 then select * from pg_user;  end if;

# PGPASSWORD=example psql -h localhost -U postgres -c "IF 1 = 0 then select * from pg_user;  end if;"
