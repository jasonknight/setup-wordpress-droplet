#!/bin/bash

echo -e "Beginning Wordpress Installation\n";
apt update -qq
apt instal -y -qq build-essential apt-transport-https lsb-release ca-certificates curl gnupg2 sudo software-properties-common dirmngr git
