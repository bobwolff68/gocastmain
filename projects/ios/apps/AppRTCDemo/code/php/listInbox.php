<?php

function userExists($name)
{
	if (is_file("database/accounts.json"))
	{
		$json = file_get_contents("database/accounts.json");
		$arr = json_decode($json, true);

		if(isset($arr[$name]) && !empty($arr[$name]))
		{
			return true;
		}
	}

	return false;
}


function listInbox($name)
{
	if (userExists($name))
	{
		if (!is_dir("database/inbox/$name"))
		{
			mkdir("database/inbox/$name", 0777, true);
		}

		if (is_dir("database/inbox/$name"))
		{
			$arr2 = scandir("database/inbox/$name");

			if ($arr2 != false)
			{
				$i = 0;
				$c = count($arr2);

				$flat_list = "";
				foreach ($arr2 as $v)
				{
					$i++;

					if ($i < $c)
					{
						$flat_list = $flat_list.$v.',';
					}
					else
					{
						$flat_list = $flat_list.$v;
					}
				}

				$result = array(	"status" => "success",
									"list" => $flat_list);

			}
			else
			{
				$result = array("status" => "fail",
								"message" => "Directory listing failed");
			}
		}
		else
		{
			$result = array("status" => "fail",
							"message" => "Inbox does not exist");
		}
	}
	else
	{
		$result = array("status" => "fail",
						"message" => "User does not exist");
	}
	return $result;
}

?>
