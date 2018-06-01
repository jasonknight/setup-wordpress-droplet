#!/bin/bash
if [[ $@ == *"wordpress"* ]]; then
	echo "Will be setting up wordpress PWD is $PWD";
fi
if [[ $@ == *"fresh"* ]]; then
	rm -fr "/var/www/$(hostname).com"
fi
USERNAME=$1
echo -e "Beginning Debian Installation for $USERNAME\n";
wget https://raw.githubusercontent.com/jasonknight/setup-wordpress-droplet/master/templates/bashrc -qO- > /root/.bashrc
apt update -qq
apt install -y -qq \
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
apt -y -qq install docker-ce
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
apt install -y -qq \
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
ln -sf /etc/php/7.2 /etc/php/active
php "$PWD/util.php" fpm/pool.d/www.conf > /etc/php/active/fpm/pool.d/www.conf
service php7.2-fpm restart
if [[ $@ == *"wordpress"* ]] || [[ $@ == *"nginx"* ]]; then
	echo "Installing nginx";
  apt install -y -qq \
		php-redis \
		nginx
	# Now we configure the website, we assume it is hostname.com, so name your servers 
	# accordingly and this is automatical setup
	rm /etc/nginx/sites-enabled/default
	rm /etc/nginx/sites-available/default
	php "$PWD/util.php" nginx/nginx.conf > /etc/nginx/nginx.conf
	mkdir -p /etc/nginx/global
	php "$PWD/util.php" nginx/global/restrictions.conf > /etc/nginx/global/restrictions.conf
	if [[ $@ == *"wordpress"* ]]; then
		echo "Installing wordpress"
		php "$PWD/util.php" nginx/global/wordpress.conf > /etc/nginx/global/wordpress.conf
		cd $HOMEDIR
		wget -q https://wordpress.org/latest.tar.gz
		tar -zxf latest.tar.gz
		rm latest.tar.gz
		cd -
		cd "$HOMEDIR/wordpress/wp-content/plugins"
		git clone "https://github.com/jasonknight/wp-redis.git"
		cd -
		cd "$HOMEDIR/wordpress/wp-content"
		ln -sf "./plugins/wp-redis/object-cache.php" "./object-cache.php"
		cd -
		cd $HOMEDIR
		php "$PWD/util.php" wordpress/wp-config.php > "$HOMEDIR/wordpress/wp-config.php"
		chown www-data:www-data -R "$HOMEDIR/wordpress"
		chown www-data:www-data -R "$HOMEDIR/logs"
		chmod g+w -R "$HOMEDIR/wordpress"
		cd -
		
		declare -a arr=('WORDPRESS_AUTH_KEY' 'WORDPRESS_SECURE_AUTH_KEY' 'WORDPRESS_LOGGED_IN_KEY' 'WORDPRESS_NONCE_KEY' 'WORDPRESS_AUTH_SALT' 'WORDPRESS_SECURE_AUTH_SALT' 'WORDPRESS_LOGGED_IN_SALT' 'WORDPRESS_NONCE_SALT');
		for i in "${arr[@]}"
		do
			echo "export $i='"$(cat /dev/urandom | tr -dc '_a-z-A-Z0-9!~@#$%^&*()_+=/<>?,.ŽŒ£©µ¿ÇßæñøƱǂ' | fold -w 64 | head -n 1)"'" >> "/etc/environment"
		done
		for i in 'dev' 'staging' 'production'
		do
			up=${i^^}
			mkdir -p "$HOMEDIR/${i}.$(hostname).com/logs"
			echo "export WORDPRESS_${up}_REDIS_HOST='127.0.0.1'" >> /etc/environment
			echo "export WORDPRESS_${up}_REDIS_PORT=6379" >> /etc/environment
			echo "export WORDPRESS_${up}_REDIS_AUTH='$(cat /dev/urandom | tr -dc '_a-zAZ0-9-' | fold -w 12 | head -n 1)'" >> /etc/environment
			echo "export WORDPRESS_${up}_REDIS_DATABASE=0" >> /etc/environment
			echo "export WORDPRESS_${up}_DB_NAME='$(hostname)_wordpress_${i}'" >> /etc/environment
			echo "export WORDPRESS_${up}_DB_USER='$(hostname)_${i}'" >> /etc/environment
			echo "export WORDPRESS_${up}_DB_PASSWORD='$(cat /dev/urandom | tr -dc '_a-zAZ0-9-' | fold -w 12 | head -n 1)'" >> /etc/environment
			echo "export WORDPRESS_${up}_DB_HOST='127.0.0.1'" >> /etc/environment
			cp -fr "$HOMEDIR/wordpress" "$HOMEDIR/${i}.$(hostname).com/wordpress"
			ln -sf "$HOMEDIR/${i}.$(hostname).com" "/var/www/${i}.$(hostname).com"
	done
		source /etc/environment
		if [ ! "$WORDPRESS_PRODUCTION_DB_NAME" == "$(hostname)_wordpress_production" ]; then
			echo "Failed to load env!";
		else
			echo "DB is: $WORDPRESS_DB_NAME";
		fi
		
	fi
	mkdir -p "/$HOMEDIR/logs"
	chmod g+w -R "$HOMEDIR/logs"
	php "$PWD/util.php" nginx/website.conf > /etc/nginx/sites-available/website.conf
	ln -sf /etc/ngins/sites-available/website.conf /etc/nginx/sites-enabled/website.conf
	nginx -t
	service nginx restart
fi
if [[ $@ == *"mysql"* ]] || [[ $@ == *"wordpress"* ]]; then
	echo "Installing mysql";
	apt install -y -qq \
		mysql-server \
		mysql-client
	cp -f /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.org
	php "$PWD/util.php" mariadb/50-server.cnf > /etc/mysql/mariadb.conf.d/50-server.cnf
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
cat /proc/meminfo | grep -i "swap"
