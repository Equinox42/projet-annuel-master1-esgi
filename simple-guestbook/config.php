<?php

// website name/title
$title = "ESGI Guestbook";

// messages to display per page
$per_page = 10;

// Timezone to use (default to UTC)
$timezone = "UTC";
date_default_timezone_set($timezone);

// database server credientials
$hostname = 'localhost';
$hostuser = 'guestuser';
$hostpass = 'supersecurepassword';
$dbname = 'guestbook';
$tablename = 'messages';

//connection between php and mysql (Do not change this!!!)
$dbconnect = new mysqli($hostname,$hostuser,$hostpass,$dbname);