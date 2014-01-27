<?php

function setContacts($name)
{
	if (userExists($name))
	{
		if (!is_dir("database/user/$name"))
		{
			mkdir("database/user/$name", 0777, true);
		}

		if (copy($_FILES['filename']['tmp_name'], "database/user/$name/contacts.json"))
		{
			chmod("database/user/$name/contacts.json", 0777);

			$result = array("status" => "success",
							"message" => "Updated profile successfully");
		}
		else
		{
			$result = array("status" => "fail",
							"message" => "Could not copy upload to $name's contacts.json");
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
