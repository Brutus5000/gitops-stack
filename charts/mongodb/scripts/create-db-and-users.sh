#!/bin/sh

# Fail on error
set -e

# Login to MongoDB
mongosh --host mongodb-0 -u root -p "${MONGO_INITDB_ROOT_PASSWORD}"

# Check if the database exists
database_exists=$(mongo --eval "print(db.getMongo().getDBNames().indexOf('my_database') != -1)" 2>/dev/null)

# If the database does not exist, create it
if [ "$database_exists" = "false" ]; then
    mongosh --host mongodb-0 --eval "db.getSiblingDB('${NODEBB_DATABASE}').createCollection('dummy_collection')"
    echo "Database '${NODEBB_DATABASE}' has been created."
else
    echo "Database '${NODEBB_DATABASE}' already exists."
fi

# Check if the user exists
user_exists=$(mongosh --host mongodb-0 --eval "db.getUsers().forEach(function(user) { if (user.user == '${NODEBB_USERNAME}') { print(true); } });" my_database 2>/dev/null)

# If the user does not exist, add it and grant it permissions to the database
if [ "$user_exists" = "" ]; then
    mongosh  --host mongodb-0 ${NODEBB_DATABASE} --eval "db.createUser({ user: '${NODEBB_USERNAME}', pwd: '${NODEBB_PASSWORD}', roles: [{ role: 'readWrite', db: '${NODEBB_DATABASE}' }] })"
    echo "User '${NODEBB_USERNAME}' has been added to database '${NODEBB_DATABASE}' with read-write permissions."
else
    echo "User '${NODEBB_USERNAME}' already exists in database '${NODEBB_DATABASE}'."
fi