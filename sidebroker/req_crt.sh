#!/bin/sh

CERT_FILE="broker.crt" # Define the path client certificate
CSR_FILE="broker.csr" # Define the path client Certificate Signing Request
PRIVATE_KEY="broker.key" # Define the path client private key
EJBCA_P12_AUTH_FILE="SuperAdmin.p12" # Define the path to P12 authentication file EJBCA
EJBCA_PASSWORD_AUTH_FILE="foo123" # Define the password of P12 authentication file EJBCA
EJBCA_HOST="ejbca-node1:8443" # Define the FQDN or IP address EJBCA
EJBCA_TRUST_CHAIN="ca-certs/IoTCA.pem" # Define the path trust chain or single CA file EJBCA
EJBCA_USERNAME_END_ENTITY="superadmin" # Define the username of the entity created EJBCA
EJBCA_CERTIFICATE_PROFILE_NAME="SERVER" # Define the certificate profile name EJBCA
EJBCA_END_ENTITY_PROFILE_NAME="EMPTY" # Define the end entity profile name EJBCA
EJBCA_CA_NAME="IoTCA" # Define the CA name EJBCA
RETRY_CHECK_EJBCA=5 # Define the time to wait before retry the EJBCA REST API availability
SERVICE_URL="http://ejbca-node1:8080/ejbca/publicweb/healthcheck/ejbcahealth" # Define the URL and port of the EJBCA REST API service



# Define a function that request a X.509 certificate
request_x509_certificate() {
	echo "[-] Certificate file not found, publisher requesting certificate..."
	# Create a CSR
	openssl req -new -out $CSR_FILE -newkey rsa:2048 -nodes -sha256 -keyout $PRIVATE_KEY -subj "/CN=broker"

	# Make the script runnable
	chmod a+x pkcs10Enroll.sh

	# Request the certificate
	./pkcs10Enroll.sh \
	    -c "$CSR_FILE" \
	    -P "$EJBCA_P12_AUTH_FILE" \
	    -s "$EJBCA_PASSWORD_AUTH_FILE" \
	    -H "$EJBCA_HOST" \
	    -t "$EJBCA_TRUST_CHAIN" \
	    -u "$EJBCA_USERNAME_END_ENTITY" \
	    -p "$EJBCA_CERTIFICATE_PROFILE_NAME" \
	    -e "$EJBCA_END_ENTITY_PROFILE_NAME" \
	    -n "$EJBCA_CA_NAME"


	# Rename the certificate
	mv "$EJBCA_USERNAME_END_ENTITY.crt" "$CERT_FILE"

	# Check the exit status of openssl
	if [ $? -eq 0 ]; then
		echo "Certificate requested done correctly!"
		  # Copy the generated certificate and key inside the broker container volume
		  cp $CERT_FILE /mosquitto/certs
  		  cp $PRIVATE_KEY /mosquitto/keys
  		  exit 0
	else
	  	echo "Error during certificate request! Check logs"
	  	tail -f /dev/null #in case of error do not terminate to run
	fi
}



until $(curl --output /dev/null --silent --head --fail $SERVICE_URL); do
    echo "Waiting for the service to be available..."
    sleep $RETRY_CHECK_EJBCA
done

echo "[+] EJBCA available"



# Check if the certificate file exists
if [ ! -f "$CERT_FILE" ]; then
	request_x509_certificate
else
		
	# Get the expiration date of the certificate
	expiration_date=$(openssl x509 -in "$CERT_FILE" -noout -enddate | cut -d= -f2)

	# Convert the expiration date to Unix timestamp
	expiration_timestamp=$(date -d "$expiration_date" +%s)

	# Get the current Unix timestamp
	current_timestamp=$(date +%s)

	# Compare expiration date with current date
	if [ "$expiration_timestamp" -ge "$current_timestamp" ]; then
	    echo "Certificate is valid. Expiration date: $expiration_date"
	    exit 0
	else
	    echo "Certificate has expired. Expiration date: $expiration_date"
	    request_x509_certificate # Request a new certificate
	fi
fi


