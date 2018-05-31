<?php
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
$base_url = "https://raw.githubusercontent.com/jasonknight/setup-wordpress-droplet/master/templates/";
if ( isset($_SERVER['argv']) && isset($_SERVER['argv'][1] ) ) {
	$contents = @file_get_contents($base_url . "/" . $_SERVER['argv'][1]);
	if ( ! empty( $contents ) ) {
		file_put_contents("/tmp/working.php", $contents);
		include("/tmp/working.php");
		unlink("/tmp/working.php");
	} else {
		echo "#empty\n";
	}
}
