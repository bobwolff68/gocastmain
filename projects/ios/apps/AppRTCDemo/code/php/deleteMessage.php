<?php

function deleteMessage($name, $audio)
{
	if (userExists($name))
	{
		if (!is_dir("database/user/$name"))
		{
			mkdir("database/user/$name", 0777, true);
		}

		if (is_dir("database/user/$name"))
		{
			$json = false;

			if (is_file("database/user/$name/messages.json"))
			{
				$json = file_get_contents("database/user/$name/messages.json");

				if ($json != false)
				{
					$arr = json_decode($json, true);

					$arr2 = array();

					$found = false;

					foreach($arr as $item)
					{
						if (strcmp($item["audio"], $audio) != 0)
						{
							array_push($arr2, $item);
						}
						else
						{
							$found = true;
						}
					}
					
					if ($found)
					{
						if (file_put_contents("database/user/$name/messages.json", json_encode($arr2, true)))
						{
							$result = array("status" => "success",
											"message" => "Delete successful");
						}
						else
						{
							$result = array("status" => "fail",
											"message" => "Couldn't write inbox file");
						}
					}
					else
					{
						$result = array("status" => "fail",
										"message" => "Couldn't find message to delete");
					}
				}
				else
				{
					$result = array("status" => "fail",
									"message" => "User inbox is empty");
				}
			}
			else
			{
				$result = array("status" => "fail",
								"message" => "User inbox does not exist");
			}
		}
		else
		{
			$result = array("status" => "fail",
							"message" => "User directory does not exist");
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
