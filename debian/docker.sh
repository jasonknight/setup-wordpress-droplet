#!/bin/bash
echo -e "Adding Docker Repository\n";
apt install -y -qq \
	build-essential \
	apt-transport-https \
	lsb-release \
	ca-certificates \
	gnupg2 \
	software-properties-common 

SOURCES_LINE="deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
if grep -Fxq "$SOURCES_LINE" /etc/apt/sources.list
then
		echo -e "Docker already added\n";
else
	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -qq -
	add-apt-repository "$SOURCES_LINE"
fi
