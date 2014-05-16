<?php

function login($name, $password, $device)
{
	$name = trim($name);
	$password = trim($password);

	if ($name !== '' && $password !== '')
	{
		if (is_file($GLOBALS['database']."/accounts.json"))
		{
			$json = atomic_get_contents($GLOBALS['database']."/accounts.json");
			$arr = json_decode($json, true);

			if(isset($arr[$name]) && !empty($arr[$name]))
			{
				if ($arr[$name] === $password)
				{
					$token = add_new_token($name);
					if ($token != false)
					{
						$user		= json_decode( '{ "authToken": "' . $token . '" }', true);

						add_new_device($name, $device);

						$result = array("status" => "success",
										"message" => "Login was successful",
										"user" => $user);
					}
					else
					{
						$result = array("status" => "fail",
										"message" => "Token generation failed");
					}
				}
				else
				{
					$result = array("status" => "fail",
									"message" => "Password is incorrect");
				}
			}
			else
			{
				$result = array("status" => "fail",
								"message" => "User does not exist");
			}
		}
		else
		{
			$result = array("status" => "fail",
							"message" => "No login file found");
		}
	}
	else
	{
		$result = array("status" => "fail",
						"message" => "User name or password invalid");
	}

	return $result;
}

?>