<?php

function write_token_user($name, $token)
{
	$result	= false;
	$json	= false;
	$arr	= array();

	if (!is_dir("database/user/$name"))
	{
		mkdir("database/user/$name", 0777, true);
	}

	if (is_file("database/user/$name/tokens.json"))
	{
		$json = atomic_get_contents("database/user/$name/tokens.json");
	}

	if ($json != false)
	{
		$arr = json_decode($json, true);
	}

	array_push($arr, json_decode('{"token": "'.$token.'", "date": "1999010101010101"}', true));

	if (atomic_put_contents("database/user/$name/tokens.json", json_encode($arr)) != false)
	{
		$result = true;
	}

	return $result;
}

function write_token_global($name, $token)
{
	$result	= false;
	$json	= false;
	$arr	= array();

	if (!is_dir("database/global"))
	{
		mkdir("database/global", 0777, true);
	}

	if (is_file("database/global/tokens.json"))
	{
		$json = atomic_get_contents("database/global/tokens.json");
	}

	if ($json != false)
	{
		$arr = json_decode($json, true);
	}

	array_push($arr, json_decode('{"name":"'.$name.'", "token": "'.$token.'", "date": "1999010101010101"}', true));

	if (atomic_put_contents("database/global/tokens.json", json_encode($arr)) != false)
	{
		$result = true;
	}

	return $result;
}

function add_new_token($name)
{
	$token = bin2hex(openssl_random_pseudo_bytes(32));

	if (write_token_user($name, $token))
	{
		return $token;
	}

	return false;
}

?>
