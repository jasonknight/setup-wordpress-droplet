<?php

$ifconfig = explode("\n",shell_exec("ifconfig | grep 'inet 10'"));
print_r($ifconfig);

