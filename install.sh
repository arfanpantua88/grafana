#!/bin/bash
apt update && apt -y upgrade
apt-get install sqlite3 libsqlite3-dev git

# Install Postgres
apt install postgresql postgresql-contrib
# Install python2
apt install software-properties-common -y
add-apt-repository ppa:deadsnakes/ppa -y
apt update
apt-get install python-minimal -y

git clone https://github.com/haron/grafana-migrator.git