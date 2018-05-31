<?php

$ifconfig = explode("\n",shell_exec("ifconfig | grep 'inet 10'"));
preg_match("/^\s+inet\s+(\d+\.\d+\.\d+\.\d+)/",$ifconfig[1],$matches);
$private_ip = $matches[1];
$free = explode("\n",shell_exec("free -m | grep 'Mem:'"));
print_r($free);
preg_match("/^Mem.\s+(\d+)\s+(\d+)\s+(\d+)\s(\d+)\s+(\d+)\s+(\d+)/",$free[0],$matches);
print_r($matches);

