<?php

$ifconfig = explode("\n",shell_exec("ifconfig | grep 'inet 10'"));
preg_match("/^\s+inet\s+(\d+\.\d+\.\d+\.\d+)/",$ifconfig[1],$matches);
print_r($matches);

