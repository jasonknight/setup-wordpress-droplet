#!/bin/bash
if [[ $@ == *"wordpres"* ]]; then
	echo "Will be setting up wordpress";
fi
exit 0;
USERNAME=$1
echo -e "Beginning Debian Installation for $USERNAME\n";
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
HOMEDIR="/home/$USERNAME"
if [ -d "$HOMEDIR" ]; then
	echo "$USERNAME user exists!"
else
	echo "Creating $USERNAME user";
	useradd -G docker,sudo -d "$HOMEDIR" -s /bin/bash -p 'change_me' -m codeable
	wget https://raw.githubusercontent.com/jasonknight/setup-wordpress-droplet/master/templates/bashrc -qO- > "$HOMEDIR/.bashrc"
	chown "$USERNAME:$USERNAME" -R "$HOMEDIR"
fi
systemctl enable docker

# Install PHP

apt update -qq
apt install -y \
	php7.2 \
	php7.2-cli \
	php7.2-curl \
	php7.2-gd \
	php7.2-json \
	php7.2-mbstring \
	php7.2-opcache \
	php7.2-readline \
	php7.2-xml \
	php7.2-fpm \
	php7.2-phpdbg \
	php7.2-imap \
	php7.2-ldap \
	php7.2-pspell \
	php7.2-recode \
	php7.2-snmp \
	php7.2-tidy \
	php7.2-dev \
	php7.2-intl \
	php7.2-zip
ln -sf /etc/php/7.1 /etc/php/active
php util.php fpm/pool.d/www.conf > /etc/php/active/fpm/pool.d/www.conf
if [[ $@ == *"wordpress"* ]] || [[ $@ == *"nginx"* ]]; then
	echo "Installing nginx";
  apt install -y \
		php-redis \
		nginx
	# Now we configure the website, we assume it is hostname.com, so name your servers 
	# accordingly and this is automatical setup
	rm /etc/nginx/sites-enabled/default
	rm /etc/nginx/sites-available/default
	php util.php nginx/nginx.conf > /etc/nginx/nginx.conf
	mkdir -p /etc/nginx/global
	php util.php nginx/global/restrictions.conf > /etc/nginx/global/restrictions.conf
	if [[ $@ == *"wordpress"* ]]; then
		php util.php nginx/global/wordpress.conf > /etc/nginx/global/wordpress.conf
	fi
	php util.php nginx/website.conf > /etc/nginx/sites-available/website.conf
	ln -sf /etc/ngins/sites-available/website.conf /etc/nginx/sites-enabled/website.conf
	nginx -t
fi
if [[ $@ == *"mysql"* ]] || [[ $@ == *"wordpress"* ]]; then
	echo "Installing mysql";
	apt install -y \
		mysql-server \
		mysql-client
	cp -f /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.org
	php util.php mariadb/50-server.cnf > /etc/mysql/mariadb.conf.d/50-server.cnf
	apt install -y \
		php7.2-mysql
fi
if [ ! -f /swapfile ]; then
	echo "Allocating SWAP"
	fallocate -l 1G /swapfile
	chmod 0600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo "/swapfile none swap sw 0 0" >> /etc/fstab
else
	echo "SWAP Exists"
fi
echo "SWAP Info"
cat /proc/meminfo | grep -ir "swap"
