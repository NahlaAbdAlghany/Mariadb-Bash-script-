#!/bin/bash
 
echo "Installing and configiring mariadb..."
 
sudo dnf module install mariadb -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
 
root_password=mypass
 
# Make sure that NOBODY can access the server without a password
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$root_password') WHERE User = 'root'"
 
# Kill the anonymous users
sudo mysql -e "DROP USER IF EXISTS ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
sudo mysql -e "DROP USER IF EXISTS ''@'$(hostname)'"
# Kill off the demo database
sudo mysql -e "DROP DATABASE IF EXISTS test"

echo "Creating iti database"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS iti"
echo " creating inv_master table"
sudo mysql -e "use iti;CREATE TABLE IF NOT EXISTS inv_master( \
	id int key, \
	date DATE, \
	total float );"
echo "creating inv_details table"
sudo mysql -e "use iti;CREATE TABLE IF NOT EXISTS inv_details( \
        item_id INT PRIMARY KEY, \
	item_name VARCHAR(255),\
	quantity INT,\
	invid INT,\
	 FOREIGN KEY (invid) REFERENCES inv_master(id)\
 );"

#Read and insert data into inv_master 
echo " Insert Data from inv_file"
sudo mysql -e "use iti; LOAD DATA LOCAL INFILE './inv_master.txt' INTO TABLE inv_master
FIELDS TERMINATED BY ':'
LINES TERMINATED BY '\n';"

#Read and insert data into inv_details
echo " Insert Data from inv_file"
sudo mysql -e "use iti; LOAD DATA LOCAL INFILE './inv_details.txt' INTO TABLE inv_details
FIELDS TERMINATED BY ':'
LINES TERMINATED BY '\n';"


