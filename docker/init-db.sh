#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE DATABASE taskflow_dev;
  CREATE DATABASE taskflow_test;
  CREATE DATABASE taskflow_eventstore;
  CREATE DATABASE taskflow_eventstore_test;
EOSQL
