<?php
function maxMemoryPerPHPScript($a) {
	$p = floor($a * 0.33 / 5);
	if ($p > 256) {
		$p = 256;
	}
	return $p;
}
function queryCacheSize($available) {
	// we only allow 17%
	$assigned_to_mysql = $available;
	$cache_possible = $assigned_to_mysql * 0.10;
	if ( $cache_possible > 200 ) {
		return 200;
	}
	for ( $i = 2; $i < 100; $i+= 2 ) {
		if ( 2 * $i > $cache_possible ) {
			return 2 * $i - 2;
		}
	}
}
function queryCacheLimit($size) {
	if ( $size <= 30 ) {
		return 64;
	}
	if ( $size <= 60 ) {
		return 128;
	}
	if ($size <= 120 ) {
		return 256;
	}
	return 512;
}
function keyBufferSize($available) {
	return floor($available * 0.20);
}
function tableCacheSize($available) {
	return floor($available * 0.25);
}
function readBufferSize($available) {
	return floor($available * 0.20);
}

$matches = array();
$ifconfig = explode("\n",@shell_exec("ifconfig | grep 'inet 10'"));
if ( ! empty($ifconfig) && isset($ifconfig[1]) ) {
	preg_match("/^\s+inet\s+(\d+\.\d+\.\d+\.\d+)/",$ifconfig[1],$matches);
}
if ( $matches && ! empty($matches) ) {
	$private_ip = $matches[1];
}
$free = explode("\n",shell_exec("free -m | grep 'Mem:'"));
preg_match("/Mem.\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/",$free[0],$matches);
$available_memory = $matches[6];
$mysql_memory = $available_memory * 0.40;
$base_url = "https://raw.githubusercontent.com/jasonknight/setup-wordpress-droplet/master/templates";
$fqdn = trim(@shell_exec("hostname"));
if ( ! empty($fqdn) ) {
	$fqdn = "$fqdn.com";
}
if ( isset($_SERVER['argv']) && isset($_SERVER['argv'][1] ) ) {
	$contents = @file_get_contents($base_url . "/" . $_SERVER['argv'][1]);
	if ( ! empty( $contents ) ) {
		file_put_contents("/tmp/working.php", $contents);
		if ( preg_match("/.+\.php$/",$_SERVER['argv'][1]) ) {
			echo "<?php\n";
		}
		include("/tmp/working.php");
		unlink("/tmp/working.php");
	} else {
		echo "#empty\n";
	}
}
