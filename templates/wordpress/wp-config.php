/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */
$envs = file("/etc/environment");
foreach ($envs as $e){
	$ne = trim(str_replace("export ","",$e));
	$ne = str_replace("'",'',$ne);
	putenv($ne);
}
$environment = "PRODUCTION";
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', @getenv("WORDPRESS_{$environment}_DB_NAME"));

/** MySQL database username */
define('DB_USER', @getenv("WORDPRESS_{$environment}_DB_USER"));

/** MySQL database password */
define('DB_PASSWORD', @getenv("WORDPRESS_{$environment}_DB_PASSWORD"));

/** MySQL hostname */
define('DB_HOST', @getenv("WORDPRESS_{$environment}_DB_HOST"));

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');
echo "mysql -u " . DB_USER . " -p" . DB_PASSWORD . " " . DB_NAME;

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         @getenv("WORDPRESS_AUTH_KEY"));
define('SECURE_AUTH_KEY',  @getenv("WORDPRESS_SECURE_AUTH_KEY"));
define('LOGGED_IN_KEY',    @getenv("WORDPRESS_LOGGED_IN_KEY"));
define('NONCE_KEY',        @getenv("WORDPRESS_NONCE_KEY"));
define('AUTH_SALT',        @getenv("WORDPRESS_AUTH_SALT"));
define('SECURE_AUTH_SALT', @getenv("WORDPRESS_SECURE_AUTH_SALT"));
define('LOGGED_IN_SALT',   @getenv("WORDPRESS_LOGGED_IN_SALT"));
define('NONCE_SALT',       @getenv("WORDPRESS_NONCE_SALT"));

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);
if ( $environment == "PRODUCTION" ) {
	$_the_url = 'https://<?= $fqdn ?>.com';
} else {
	$_the_url = "https://" . strtolower($environment) . ".<?= $fqdn ?>.com";
}
define('WP_HOME',$_the_url);
define('WP_SITEURL',$_the_url);
$redis_server = array(
	'host'     => @getenv("WORDPRESS_{$environment}_REDIS_HOST"),
	'port'     => @getenv("WORDPRESS_{$environment}_REDIS_PORT"), //6379,
	'auth'     => @getenv("WORDPRESS_{$environment}_REDIS_AUTH"),
	'database' => @getenv("WORDPRESS_{$environment}_REDIS_DATABASE"), // Optionally use a specific numeric Redis database. Default is 0.
);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
