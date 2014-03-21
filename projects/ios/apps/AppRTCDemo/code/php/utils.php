<?php

function atomic_put_contents($filename, $data)
{
    $fp = fopen($filename, "w+");

	if ($fp != FALSE)
	{
		$count = 0;
		if (flock($fp, LOCK_EX))
		{
			$count = fwrite($fp, $data);
			flock($fp, LOCK_UN);
		}
		fclose($fp);

		return $count;
	}
	
	return FALSE;
}

function atomic_get_contents($filename)
{
    $fp = fopen($filename, "r+");

	if ($fp != FALSE)
	{
		$data = "";

		if (flock($fp, LOCK_EX))
		{
			if (filesize($filename) != 0)
			{
				$data = fread($fp, filesize($filename));
			}
			flock($fp, LOCK_UN);
		}
		fclose($fp);

		return $data;
	}

	return FALSE;
}

function userExists($name)
{
	if (is_file("database/accounts.json"))
	{
		$json = atomic_get_contents("database/accounts.json");
		$arr = json_decode($json, true);

		if(isset($arr[$name]) && !empty($arr[$name]))
		{
			return true;
		}
	}

	return false;
}

function hasParam($x)
{
	if( (isset($_GET[$x]) && !empty($_GET[$x])) ||
		(isset($_POST[$x]) && !empty($_POST[$x])) )
	{
		return true;
	}

	return false;
}

function errorMissingParameter($x)
{
	return array(	"status" => "fail",
					"message" => "Missing parameter: $x");
}

function errorAuthToken()
{
	return array(	"status" => "expired",
					"message" => "Invalid or expired token");
}

?>
