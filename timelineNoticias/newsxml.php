<?php 
	include("./db.inc.php");
	$db = new MySQL;
	if(!$db->init()) {
		die("¡¡¡ERROR!!!<BR>\n");
	}

	$db->writeNewsXml();
?> 
