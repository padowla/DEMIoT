#!/bin/bash
echo "[+] Starting DEMIoT..."
docker compose up -d --build --force-recreate
echo "[+] Succesfully deployed. Enjoy :)"
