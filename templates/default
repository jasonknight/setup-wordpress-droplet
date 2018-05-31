server { 
	server_name <?= $site_name ?> www.<?=$site_name>; 
	root /var/www/<?= $site_name ?>/wordpress;
	include global/restrictions.conf;
	include global/wordpress.conf;
	error_log /var/www/<?= $site_name ?>/logs/errors.log info;
	access_log /var/www/<?= $site_name ?>/logs/access.log;
}
server {
	listen 443 ssl;
	server_name <?= $site_name ?> www.<?=$site_name>; 
	ssl_certificate /etc/letsencrypt/live/<?= $site_name ?>/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/<?= $site_name ?>/privkey.pem;

	root /var/www/<?= $site_name ?>/wordpress;
	include global/restrictions.conf;
	include global/wordpress.conf;

	error_log /var/www/<?= $site_name ?>/logs/errors.log info;
	access_log /var/www/<?= $site_name ?>/logs/access.log;
}
server { 
	server_name staging.<?= $site_name ?> www.staging.<?=$site_name>; 
	root /var/www/staging.<?= $site_name ?>/wordpress;
	include global/restrictions.conf;
	include global/wordpress.conf;
	error_log /var/www/staging.<?= $site_name ?>/logs/errors.log info;
	access_log /var/www/staging.<?= $site_name ?>/logs/access.log;
}
