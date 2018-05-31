#!/bin/bash

echo -e "Beginning Wordpress Installation\n";
wget https://raw.githubusercontent.com/jasonknight/setup-wordpress-droplet/master/templates/bashrc -qO- > /root/.bashrc
apt update -qq
apt install -y \
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
apt -y install docker-ce
groupadd docker
if [ -d /home/codeable ]; then
	echo "Codeable user exists!"
else
	echo "Creating codeable user";
	useradd -G docker,sudo -d /home/codeable -s /bin/bash -p 'change_me' -m codeable
	wget https://raw.githubusercontent.com/jasonknight/setup-wordpress-droplet/master/templates/bashrc -qO- > /home/codeable/.bashrc
	chown codeable:codeable -R /home/codeable
fi
systemctl enable docker

# Install PHP

apt update -qq
apt install -y \
	php7.2 \
	php7.2-cli \
	php7.2-curl


