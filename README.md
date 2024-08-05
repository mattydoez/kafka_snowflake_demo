# Generating Synthetic Streaming Data And Streaming Into Snowflake Directly

This project demonstrates how to generate synthetic streaming data and ingest it directly into Snowflake.
## Prerequisites

- Docker
- Docker Compose
- ShadowTraffic License (Or Trial)
- Snowflake Account (Or Trial)

## Getting Started

### Setup Steps

1. Replace the `example_license.env` file in the shadowtraffic folder with your `license.env` file form your shadowtraffic trial or account. 

2. Create the private keys needed to connect Snowflake to Kafka:
```
openssl genpkey -algorithm RSA -out rsa_key.pem -pkeyopt rsa_keygen_bits:2048

openssl rsa -pubout -in rsa_key.pem -out rsa_key.pub

openssl pkcs8 -topk8 -inform PEM -outform DER -in rsa_key.pem -out rsa_key.p8 -nocrypt

base64 rsa_key.p8 > rsa_key_base64.txt
```

3. Replace the following properties in *example_snowflake_connector_config.json* with your Snowflake details:
```
"snowflake.url.name": "https://<snowflake_account_id>.snowflakecomputing.com",
"snowflake.user.name": "<snowflake_account_username>"
"snowflake.private.key": "<rsa_key_base64.txt>"
"snowflake.database.name": "<snowflake_db_name>"
"snowflake.schema.name": "<snowflake_schema_name>"
```


### Setting Up Services

1. **Build and Start Services**
  - First start the following three services before adding some necessary topics to kafka and starting the connect service.
   ```bash
   docker-compose up -d --build zookeeper
   docker-compose up -d --build kafka
   docker-comopse up -d --build kafdrop 
   ```

2. **Access Kafdrop**
- http://localhost:9000

3. Add in topics necessary to run kafka-connect, using the container id from the kafka service:
    ```
    docker exec -it <container_id> kafka-topics.sh --create --topic docker-connect-configs --partitions 1 --replication-factor 1 -config cleanup.policy=compact --bootstrap-server kafka:9092

    docker exec -it <container_id> kafka-topics.sh --create --topic docker-connect-offsets --partitions 1 --replication-factor 1 --config cleanup.policy=compact --bootstrap-server kafka:9092

    docker exec -it <container_id> kafka-topics.sh --create --topic docker-connect-status --partitions 1 --replication-factor 1 --config cleanup.policy=compact --bootstrap-server kafka:9092
    ```
4. Validate the creation of the topics by checking Kafdrop to see if the topics are listed. 
5. Start up the kafka-connect service and setup the connector:
    ```
    docker-compose up -d --build kafka-connect

    # post the connector config to the kafka-connect container
    curl -X POST -H "Content-Type: application/json" --data @snowflake_connector_config.json http://localhost:8083/connectors

    # verify the connector exists
    curl -X GET http://localhost:8083/connectors
    ```
6. Start up the shadowtraffic service:
    ```
    docker-compose up -d --build shadowtraffic
    ```
7. Once the consumer starts consuming the messages you can validate the data is flowing into Snowflake into the correct schema and tables. 

### Services Overview

- **Zookeeper**: Zookeeper is a distributed coordination service used by Kafka for managing distributed brokers. It maintains metadata, configuration, and state information for Kafka.
- **Kafka**: Kafka is a distributed event streaming platform that publishes and subscribes to streams of records. It's the core message broker where data is stored and processed.
- **Kafdrop**: Kafdrop is a web UI for Kafka that provides a visual interface to interact with Kafka topics, partitions, and messages.
- **Kafka-Connect**: Kafka Connect is a tool for scalable and reliable streaming data between Kafka and other systems (e.g., databases, file systems).
- **ShadowTraffic**: Shadowtraffic is a tool for generating and simulating streaming data. It produces synthetic data that can be ingested into Kafka for testing and development purposes.

### Exposed Ports
- Zookeeper: `2181`
- Kafka: `9092`
- Kafdrop: `9000`
- Kafka-Connect: `8083`





