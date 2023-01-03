#!/bin/bash


cd chrome_docker
docker build -t chrome_docker .
cd ..

cd python_executor
docker build -t python_executor .
cd ..
