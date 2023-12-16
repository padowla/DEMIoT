#!/bin/bash

# Elimina tutti i container Docker in esecuzione
docker rm -f $(docker ps -aq) 2>/dev/null

# Elimina tutte le immagini Docker
docker rmi -f $(docker images -aq) 2>/dev/null

# Elimina la cache Docker (volumi, reti, cache)
docker system prune -af --volumes

# Esegui il comando Docker Compose (aggiungi qui il tuo comando docker-compose up ...)
docker compose up -d --build --force-recreate

