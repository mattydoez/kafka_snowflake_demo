-- Use a role that can create and manage roles and privileges.
USE ROLE accountadmin;

-- Create a Snowflake role with the privileges to work with the connector.
CREATE ROLE IF NOT EXISTS kafka_connector_role_1;

CREATE DATABASE IF NOT EXISTS kafka_db;
CREATE SCHEMA IF NOT EXISTS kafka_schema;

-- Grant privileges on the database.
GRANT USAGE ON DATABASE kafka_db TO ROLE kafka_connector_role_1;

-- Grant privileges on the schema.
GRANT USAGE ON SCHEMA kafka_schema TO ROLE kafka_connector_role_1;
GRANT CREATE TABLE ON SCHEMA kafka_schema TO ROLE kafka_connector_role_1;
GRANT CREATE STAGE ON SCHEMA kafka_schema TO ROLE kafka_connector_role_1;
GRANT CREATE PIPE ON SCHEMA kafka_schema TO ROLE kafka_connector_role_1;

CREATE USER IF NOT EXISTS kafka_user;

-- Grant the custom role to an existing user.
GRANT ROLE kafka_connector_role_1 TO USER kafka_user;

-- Set the custom role as the default role for the user.
-- If you encounter an 'Insufficient privileges' error, verify the role that has the OWNERSHIP privilege on the user.
ALTER USER kafka_user SET DEFAULT_ROLE = kafka_connector_role_1;

ALTER USER kafka_user SET RSA_PUBLIC_KEY='<created_private_key>';

GRANT USAGE ON DATABASE kafka_db TO ROLE ACCOUNTADMIN;
GRANT USAGE ON SCHEMA kafka_db.kafka_schema TO ROLE ACCOUNTADMIN;
GRANT SELECT ON TABLE kafka_db.kafka_schema.customers TO ROLE ACCOUNTADMIN;
GRANT SELECT ON TABLE kafka_db.kafka_schema.orders TO ROLE ACCOUNTADMIN;

