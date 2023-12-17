# Configuration
BROKER_ADDRESS="broker"
BROKER_PORT="8883"
CA_CERT="ca-certs/IoTCA.pem"
CLIENT_CERT="subscriber.crt"
CLIENT_KEY="subscriber.key"
TOPIC="LAB"


# Infinite loop for subscribing and receiving messages every 10 seconds
while true; do
    mosquitto_sub -h "$BROKER_ADDRESS" -p "$BROKER_PORT" --cafile "$CA_CERT" --cert "$CLIENT_CERT" --key "$CLIENT_KEY" -t "$TOPIC" -d 
    sleep 10  # Wait for 10 seconds before subscribing again
done
