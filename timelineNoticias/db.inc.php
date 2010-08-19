<?php 

class MySQL
{
	var $HOSTNAME = "localhost"; 	//The database server. 
	var $USERNAME = "*****"; 	// The username you created for this database. 
	var $PASSWORD = "*****"; 		// The password you created for the username. 
	var $DBNAME = "*****"; 	// This is the name of the database you made. 
	var $CONN = "";
	
	function error($text)
	{
		$no = mysql_errno();
		$msg = mysql_error();
		echo "db.inc.php::: [$text] ( $no : $msg )<br>\n";
		exit;	
	}
	
	function init()
	{
		$user = $this->USERNAME;
		$pass = $this->PASSWORD;
		$server = $this->HOSTNAME;
		$dbase = $this->DBNAME;
		$conn = mysql_connect($server, $user, $pass);
		if (!$conn){
			$this->error("DB connection unavailable");
		}
		$dbsel = mysql_select_db("$dbase");
		if (!$dbsel){
			$this->error("Unable to select database"); 
		}
		$this->CONN = $conn;
		return true;
	}
/*--------------------------------------------------
	GENERAL functions
--------------------------------------------------*/
	
	function select ($sql="")
	{
		if(empty($sql)) { return false; }
		if(!eregi("^select",$sql))
		{
			echo "<H2>SQL statement must begin with select!</H2>\n";
			return false;
		}
		if(empty($this->CONN)) { return false; }
		$conn = $this->CONN;
		$results = mysql_query($sql,$conn);
		
		if ((!$results) or (empty($results))) {
			mysql_free_result($results);
			return false;
		}
		
		$count = 0;
		$data = array();
		while ($row = mysql_fetch_array($results))
		{
			$data[$count] = $row;
			$count++;
		}
		
		mysql_free_result($results);
		return $data;
	}

	
/*--------------------------------------------------
	GET functions
--------------------------------------------------*/

	function get_news(){
		$sql = "SELECT * 
			FROM content_type_noticia
			ORDER BY field_date_value";
		$results = $this->select($sql);
		if (empty($results)) {
			$results = array();
		}
		return $results;
	}

	function get_node($nid="")
	{
		if(empty($nid)){
			$nid = "= 0";
		} else {
			$nid = "= $nid";
		}
		$sql = "SELECT * 
			FROM node_revisions
			WHERE nid $nid";
		$results = $this->select($sql);
		if (!empty($results)) {
			$results = $results[0];
		} else {
			$results = "";
		}
		return $results;
	}

	function printNews()
	{
		$news = $this->get_news();
		print ("<table border='1'>");
		print ("<tr><td>nid</td><td>title</td><td>teaser</td><td>link</td></tr>\n"); 
		while (list($key,$new) = each($news)) {
			if (!empty($new)){
				$nid=$new["nid"];
				$link=htmlentities($new["field_link_url"]); 
				$linktitle=htmlentities($new["field_link_title"]); 

				//get_node
				$node = $this->get_node($nid);
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
	}

/*--------------------------------------------------
	XML serealizer
--------------------------------------------------*/

	function writeNewsXML(){
		$filepath = "noticias.xml";
		$fp = fopen($filepath,'w');
		$xml = $this->createNewsXML();
		//echo $xml;
    $write = fwrite($fp,$xml);
		fclose($fp);
	}

	function createNewsXML(){
		$xml = "<?xml version='1.0' encoding='UTF-8'?>\n";
		$xml .= "<data date-time-format='iso8601'>\n";
		$news = $this->get_news();
		foreach($news as $new){
			$nid = $new['nid'];
			$link = $this->strescape($new['field_link_url']);
			$linktitle = $this->strescape($new["field_link_title"]);
			$date = $new["field_date_value"];
			$date = substr($date,0,10);

			//get_node
			$node = $this->get_node($nid);
			$title = $this->strescape($node["title"]);
			$teaser = $this->strescape($node["teaser"]);

			$xml .= "\t<event\n\t\tstart='$date'\n\t\ttitle='$title'\n\t\ticon='icontriste.gif'\n\t\t>\n\t\t$teaser\n\t\t&lt;strong&gt;Fuente:&lt;/strong&gt; &lt;a href='$link' target='_blank'&gt;$linktitle&lt;/a&gt;\n\t</event>\n";
		}
		$xml .= "</data>\n";
		return $xml;
	}

	function strescape($t="")
	{
		$t = str_replace("'", "\"", $t);
		$t = str_replace("“", "\"", $t);
		$t = str_replace("&", "&amp;", $t);
		$t = str_replace(">", "&gt;", $t);
		$t = str_replace("<", "&lt;", $t);
		return utf8_encode($t);
	}
}
?>
