<?php
// error_reporting(E_ALL);

include 'listInbox.php';
include 'getFile.php';
include 'deleteFile.php';
include 'login.php';
include 'changePassword.php';
include 'register.php';
include 'versionRequired.php';
include 'userList.php';
include 'postGroup.php';

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

	if(hasParam("action"))
	{
		if ($_SERVER['REQUEST_METHOD'] === "POST")
		{
			if ($_POST["action"] === "postGroup")
			{
				if (hasParam("from"))
				{
					if (hasParam("group") && is_array($_POST["group"]))
					{
						if (isset($_FILES["filename"]))
						{
							print(json_encode(postGroup($_POST["from"], $_POST["group"], $_FILES["filename"]["name"])));
						}
						else
						{
							print(json_encode(errorMissingParameter("filename")));
						}
					}
					else
					{
						print(json_encode(errorMissingParameter("group")));
					}
				}
				else
				{
					print(json_encode(errorMissingParameter("from")));
				}
			}
			else
			{
				print(json_encode(array("status" => "fail", "message" => "Unknown command")));
			}
		}
		else if ($_GET["action"] === "versionRequired")
		{
			print(json_encode(versionRequired()));
		}
		else if ($_GET["action"] === "userList")
		{
			print(json_encode(userList()));
		}
		else if (hasParam("name"))
		{
			switch($_GET["action"])
			{
				case "listInbox":
					print(json_encode(listInbox($_GET["name"])));
					break;
				case "getFile":
					if (hasParam("file"))
					{
						print(json_encode(getFile($_GET["name"], $_GET["file"])));
					}
					else
					{
						print(json_encode(errorMissingParameter("file")));
					}
					break;
				case "deleteFile":
					if (hasParam("file"))
					{
						print(json_encode(deleteFile($_GET["name"], $_GET["file"])));
					}
					else
					{
						print(json_encode(errorMissingParameter("file")));
					}
					break;
				case "login":
					if (hasParam("password"))
					{
						print(json_encode(login($_GET["name"], $_GET["password"])));
					}
					else
					{
						print(json_encode(errorMissingParameter("password")));
					}
					break;
				case "changePassword":
					if (hasParam("password"))
					{
						if (hasParam("newpassword"))
						{
							print(json_encode(changePassword($_GET["name"], $_GET["password"], $_GET["newpassword"])));
						}
						else
						{
							print(json_encode(errorMissingParameter("newpassword")));
						}
					}
					else
					{
						print(json_encode(errorMissingParameter("password")));
					}
					break;
				case "register":
					if (hasParam("password"))
					{
						print(json_encode(register($_GET["name"], $_GET["password"])));
					}
					else
					{
						print(json_encode(errorMissingParameter("password")));
					}
					break;
				case "postGroup":
					print(json_encode(array("status" => "fail", "message" => "unimplemented")));
					break;
				default:
					print(json_encode(array("status" => "fail", "message" => "Unknown command")));
					break;
			}
		}
		else
		{
			print(json_encode(errorMissingParameter("name")));
		}
	}
	else
	{
		print(json_encode(errorMissingParameter("action")));
	}
?>