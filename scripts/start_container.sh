#!/bin/bash
set -e

# Pull the Docker image from Docker Hub
docker pull abdurakhimovda522/hotel-app:latest

# Run the Docker image as a container
docker run -dit -p 5000:5000 abdurakhimovda522/hotel-app:latest
