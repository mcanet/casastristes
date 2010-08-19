<?php 
	include("./db.inc.php");
	$db = new MySQL;
	if(!$db->init()) {
		die("¡¡¡ERROR!!!<BR>\n");
	}

	//test get_news
	$news = $db->get_news();
	print ("<table border='1'>");
	print ("<tr><td>nid</td><td>title</td><td>teaser</td><td>link</td></tr>\n"); 
	while (list($key,$new) = each($news)) {
		if (!empty($new)){
			$nid=$new["nid"];
			$link=htmlentities($new["field_link_url"]); 
			$linktitle=htmlentities($new["field_link_title"]); 
	
			//get_node
			$node = $db->get_node($nid);
			$title = $node["title"];
			$teaser = $node["teaser"];

			//table layout for results 
			print ("<tr>");
			print ("<td>$nid</td>\n"); 
			print ("<td>$title</td>\n"); 
			print ("<td>$teaser</td>\n"); 
			print ("<td><a name='$nid'/a><a href='$link' target='_blank'>$linktitle</a></td>\n"); 
			print ("</tr>\n"); 
		}
	}
	print ("</table>");

	//$db->writeNewsXml();

/*
$filenamepath .=   "news.xml";
 
 $fp = fopen($filenamepath,'w');

            $write = fwrite($fp,$xml_output);
 
 echo $xml_output;  
*/
?> 
