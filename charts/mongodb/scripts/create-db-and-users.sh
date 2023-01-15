#!/bin/sh

# Fail on error
set -e

# Set alias with shell login to MongoDB
alias mongo='mongosh --host mongodb -u ${MONGODB_ROOT_USER} -p "${MONGO_INITDB_ROOT_PASSWORD}" --quiet'

# Check if the database exists
database_exists=$(mongo --eval "\"print(db.getMongo().getDBNames().indexOf('${NODEBB_DATABASE}') != -1)\"" 2>/dev/null)

# If the database does not exist, create it
if [ "$database_exists" = "false" ]; then
    mongo --eval "db.getSiblingDB('${NODEBB_DATABASE}').createCollection('${NODEBB_DATABASE}')"
    echo "Database '${NODEBB_DATABASE}' has been created."
else
    echo "Database '${NODEBB_DATABASE}' already exists."
fi

# Check if the user exists
user_exists=$(mongo -eval "db.getUsers().users.some (user => user.user == 'nodebb') " admin)

# If the user does not exist, add it and grant it permissions to the database
if [ "$user_exists" = "false" ]; then
    mongo --eval "\"db.createUser({ user: '${NODEBB_USERNAME}', pwd: '${NODEBB_PASSWORD}', roles: [{ role: 'readWrite', db: '${NODEBB_DATABASE}' }] })\"" admin
    echo "User '${NODEBB_USERNAME}' has been added to database '${NODEBB_DATABASE}' with read-write permissions."
else
    echo "User '${NODEBB_USERNAME}' already exists in database '${NODEBB_DATABASE}'."
fi
