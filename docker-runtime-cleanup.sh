#!/bin/bash


docker stop "centos6-runtime"
docker stop "centos7-runtime"
docker stop "fedora22-runtime"
docker stop "ubuntu14-runtime"
docker stop "ubuntu15-runtime"
docker stop "debian8-runtime"

# Remove all stopped containers
docker rm $(docker ps -a -q)

# Remove all untagged images
docker rmi $(docker images -q -f dangling=true)
