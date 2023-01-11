# Db2022
Normalization of a database as a school project at ITHS. In this repository your will find a script to normalize a database, a ER model to show the relationships in the normalized data and a JBDC CRUD.  


To make this diagram we have used Mermaid, which is a tool to be able to draw a diagram using markdown language.   


# ER diagram  


In the original table, everything where together with a column each. To normalize it each subject has gotten their own column. StudentId is used as a key in most of the tables, except School and Hobby that is linked to the StudentId via tables StudentSchool and StudentHobby.   


![mermaid-diagram-2023-01-11-181400](https://user-images.githubusercontent.com/117780904/211872360-f6637edd-19df-463b-a40d-15655df05e8b.png)



# Script
<br>
<br>
## First, you need to load the table that is going to be normalized (UNF) into the database. The denormalized-data.csv exists in this git repository.
<br>
<br>
USE iths;
<br>
DROP TABLE IF EXISTS UNF;
<br>
> CREATE TABLE `UNF` ( <br>
>	`Id` DECIMAL(38, 0) NOT NULL, <br>
>	`Name` VARCHAR(26) NOT NULL, <br>
>	`Grade` VARCHAR(11) NOT NULL, <br>
>	`Hobbies` VARCHAR(25), <br>
>	`City` VARCHAR(10) NOT NULL, <br>
>	`School` VARCHAR(30) NOT NULL, <br>
>	`HomePhone` VARCHAR(15), <br>
>	`JobPhone` VARCHAR(15), <br>
>	`MobilePhone1` VARCHAR(15), <br>
>	`MobilePhone2` VARCHAR(15) <br>
>) ENGINE=INNODB; <br>
><br>
>LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv' <br>
>INTO TABLE UNF<br>
>CHARACTER SET latin1<br>
>FIELDS TERMINATED BY ','<br>
>ENCLOSED BY '"'<br>
>LINES TERMINATED BY '\n'<br>
>IGNORE 1 ROWS;<br>


