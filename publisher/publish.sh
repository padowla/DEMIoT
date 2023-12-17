#!/bin/bash

# Configuration
BROKER_ADDRESS="broker"
BROKER_PORT="8883"
CA_CERT="ca-certs/IoTCA.pem"
CLIENT_CERT="publisher.crt"
CLIENT_KEY="publisher.key"
TOPIC="LAB"

# Infinite loop for publishing messages with timestamp every 10 seconds
while true; do
    TIMESTAMP=$(date +%s)  # Get current Unix timestamp
    MESSAGE="There is a new message! $(date)"  # Append formatted timestamp to your_message

    mosquitto_pub -h "$BROKER_ADDRESS" -p "$BROKER_PORT" --cafile "$CA_CERT" --cert "$CLIENT_CERT" --key "$CLIENT_KEY" -t "$TOPIC" -m "$MESSAGE" -d --insecure
    sleep 10  # Wait for 10 seconds before publishing again
done

