#!/bin/bash
# Restart PLS Data Grabber

docker compose down && git pull && docker compose build && docker compose up -d && docker compose logs -f