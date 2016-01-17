#!/bin/bash

docker stop $(docker ps -a -q)

# Remove all stopped containers
docker rm $(docker ps -a -q)

# Remove all untagged images
docker rmi $(docker images -q -f dangling=true)
