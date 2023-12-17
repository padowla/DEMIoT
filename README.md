# DEMIoT
**DEMIot** (Docker + EJBCA + Mosquitto) is aimed at implementing the [Mosquitto MQTT](https://github.com/eclipse/mosquitto) broker and managing client authentication using digital certificates. 
A key element of this process is the integration of an Open Source Public Key Infrastructure (PKI), specifically the use of [EJBCA](https://github.com/Keyfactor/ejbca-ce) to issue the necessary certificates.
The primary objective of this initiative is to provide a reliable and secure laboratory environment for the development, testing and practical demonstration of the integration of Mosquitto MQTT as a messaging broker, combined with a rigorous client authentication process based on digital certificates. This implementation provides an in-depth exploration of MQTT's capabilities in an advanced security context, as well as offering a replicable model for real-world operational environments.

### :warning: Disclaimer
This is a project developed in the context of my master's thesis in Cybersecurity at the [University of Pisa](https://cybersecuritymaster.it/). <br> :notebook: Within this repository you can find the thesis developed.

## Architecture
![architecture](https://github.com/padowla/DEMIoT/assets/62257411/6c577bf6-ac37-46e5-b8ed-48f6ee324aaa)
The PKI exposes two ports, **8080/tcp** and **8443/tcp**, HTTP and HTTPS, respectively, for simplified management of users and certificates via the Web interface and for communication with the REST API interface. The various MQTT clients as well as the Mosquitto broker interact with the EJBCA API via HTTP protocol to request the generation of a digital certificate in X.509 format. All application communications, on the other hand, between the MQTT clients and the Mosquitto broker take place using MQTT over TLS. The broker exposes only port 8883/tcp through which clients communicate with the server. Finally, to conduct connection tests with the broker, a custom Ubuntu-based image with some of the tools needed to communicate with the broker was chosen as the MQTT clients.

In order for two containers to be able to communicate, they must belong to the same user-defined docker bridge network. In particular, it was decided to allow only client communication to the PKI via the network *access-ejbca-net* and the broker *broker-net* and broker communication with the PKI and clients via the networks *publisher-net* and *subscriber-net*. Any communication between MQTT clients turns out to be segregated at the network level.

## Project directories <a name="project_directories"></a>

```
DEMIoT
├── ca-certs
│   └── yourCA.pem
├── compose.yaml
├── Dockerfile-mosquitto
├── Dockerfile-publisher
├── Dockerfile-sidebroker
├── Dockerfile-subscriber
├── ejbca
├── mosquitto
│   ├── ca-certs
│   │   └── yourCA.pem
│   ├── certs
│   ├── config
│   │   └── mosquitto.conf
│   ├── data
│   ├── keys
│   └── log
├── publisher
│   ├── ca-certs
│   ├── pkcs10Enroll.sh
│   ├── publish.sh
│   ├── req_crt.sh
│   └── SuperAdmin.p12
├── sidebroker
│   ├── pkcs10Enroll.sh
│   ├── req_crt.sh
│   └── SuperAdmin.p12
├── deploy.sh
└── subscriber
    ├── ca-certs
    ├── pkcs10Enroll.sh
    ├── req_crt.sh
    ├── subscribe.sh
    └── SuperAdmin.p12
```
## Deploy
To create the environment in Docker and run the applications specified in docker compose file, it is only necessary to run the bash script [deploy.sh](deploy.sh).

## Configuration of EJBCA PKI
In order to be able to issue digital certificates, it is necessary to create a user in EJBCA that has permissions to generate new digital certificates. 
EJBCA offers the possibility of creating users with restricted roles while respecting the principle of least privilege. 
In this example, however, a user with an Administrator role was created as indicated in the documentation. This user has been associated with a certificate and a private key. 
The private key and certificate bundle are downloadable in a .p12 file that will be used later to make authenticated requests to the EJBCA REST API (the SuperAdmin.p12 detailed in [Project directories](#project_directories).
Refer to the [official documentation](https://doc.primekey.com/ejbca/tutorials-and-guides) for any further details.


