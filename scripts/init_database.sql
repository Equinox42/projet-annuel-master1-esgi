CREATE DATABASE guestbook;

CREATE TABLE guestbook.messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL,
    message TEXT(600) NOT NULL,
    date DATETIME DEFAULT NOW() NOT NULL
) AUTO_INCREMENT=1;

CREATE USER 'guestuser'@'%' IDENTIFIED BY 'supersecurepassword';

GRANT SELECT, INSERT, UPDATE, DELETE ON guestbook.messages TO 'guestuser'@'%';
FLUSH PRIVILEGES;