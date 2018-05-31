#!/bin/bash

echo -e "Beginning Wordpress Installation\n";
wget -q https://raw.githubusercontent.com/jasonknight/setup-wordpress-droplet/master/bashrc -o /root/.bashrc
source /root/.bashrc
apt update -qq
apt instal -y -qq \
	build-essential \
	apt-transport-https \
	lsb-release \
	ca-certificates \
	curl \
	gnupg2 \
	sudo \
	software-properties-common \
	dirmngr \
	git
echo "Adding Docker Repository\n";
SOURCES_LINE="deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
if grep -Fxq "$SOURCES_LINE" /etc/apt/sources.list
then
		echo "Docker already added\n";
else
	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -qq -
	add-apt-repository "$SOURCES_LINE"
fi
SOURCES_LINE="deb https://packages.sury.org/php/ $(lsb_release -cs) main"
echo "Adding Sury PHP repository\n";
if grep -Fxq "$SOURCES_LINE" /etc/apt/sources.list
then
		echo "Sury PHP Already Added\n";
else
	curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -qq -
	add-apt-repository "$SOURCES_LINE" 
fi

