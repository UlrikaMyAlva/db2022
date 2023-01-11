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
 CREATE TABLE `UNF` ( <br>
	`Id` DECIMAL(38, 0) NOT NULL, <br>
	`Name` VARCHAR(26) NOT NULL, <br>
	`Grade` VARCHAR(11) NOT NULL, <br>
	`Hobbies` VARCHAR(25), <br>
	`City` VARCHAR(10) NOT NULL, <br>
	`School` VARCHAR(30) NOT NULL, <br>
	`HomePhone` VARCHAR(15), <br>
	`JobPhone` VARCHAR(15), <br>
	`MobilePhone1` VARCHAR(15), <br>
	`MobilePhone2` VARCHAR(15) <br>
) ENGINE=INNODB; <br>
<br>
LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv' <br>
INTO TABLE UNF<br>
CHARACTER SET latin1<br>
FIELDS TERMINATED BY ','<br>
ENCLOSED BY '"'<br>
LINES TERMINATED BY '\n'<br>
IGNORE 1 ROWS;<br>


**After that the normalization starts. All the tables are dropped if they exist.** <br>
**The first table, Student, have the StudentId and the Students names**<br>
<br>
<br>
DROP TABLE IF EXISTS iths.Grade; <br>
DROP TABLE IF EXISTS iths.School; <br>
DROP TABLE IF EXISTS iths.StudentSchool; <br>
DROP TABLE IF EXISTS iths.Hobby; <br>
DROP TABLE IF EXISTS iths.StudentHobby; <br>
DROP TABLE IF EXISTS iths.Phone; <br>
DROP TABLE IF EXISTS iths.Student; <br>
<br>
<br>
DROP TABLE IF EXISTS iths.Student;<br>
<br>
Create table Student (<br>
<br>
<br>
	StudentId INT NOT NULL,<br>
	Student VARCHAR(26) NOT NULL,<br>
	PRIMARY KEY (StudentId)<br>
<br>
<br>);
<br>
INSERT INTO Student (StudentId, Student) SELECT DISTINCT Id,<br>
Name FROM UNF;<br>
<br>
<br>
DROP TABLE IF EXISTS iths.Grade; <br>
<br>
Create table Grade (<br>
<br>
	StudentId INT NOT NULL,<br>
	Grade VARCHAR(26),<br>
	PRIMARY KEY (StudentId),<br>
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)<br>
<br>
);<br>
<br>
INSERT INTO Grade (StudentId, Grade) SELECT DISTINCT Id,<br>
Grade FROM UNF;<br>
<br>
UPDATE Grade SET Grade = 'First-class'<br>
WHERE Grade IN ('First class', 'Firstclass');<br>
<br>
UPDATE Grade SET Grade = 'Excellent'<br>
WHERE Grade IN ('Eksellent');<br>
<br>
UPDATE Grade SET Grade = 'Awesome'<br>
WHERE Grade IN ('Awessome');<br>
<br>
UPDATE Grade SET Grade = 'Gorgeous'<br>
WHERE Grade IN ('Gorgetus', 'Gorgeus');<br>
<br>
<br>
DROP TABLE IF EXISTS iths.School;<br>
<br>
CREATE TABLE School (<br>
<br>
	SchoolId INT NOT NULL AUTO_INCREMENT,<br>
	Name VARCHAR(26) NOT NULL UNIQUE,<br>
	City VARCHAR(26) NOT NULL UNIQUE,<br>
	PRIMARY KEY (SchoolId)<br>
<br>
);<br>
<br>
INSERT INTO School (Name, City)<br>
SELECT DISTINCT School, City FROM UNF;<br>
<br>
<br>
DROP TABLE IF EXISTS iths.StudentSchool;<br>
<br>
CREATE TABLE StudentSchool (<br>
<br>
	StudentId INT NOT NULL,<br>
	SchoolId INT NOT NULL,<br>
	PRIMARY KEY (SchoolId, StudentId),<br>
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)<br>
<br>
);<br>
<br>
INSERT INTO StudentSchool (StudentId, SchoolId)<br>
SELECT DISTINCT Id, School.SchoolId <br>
FROM UNF<br>
INNER JOIN School ON School.Name = UNF.School;<br>
<br>
ALTER TABLE School<br>
ADD FOREIGN KEY (SchoolId) REFERENCES StudentSchool(SchoolId);<br>
<br>
<br>
DROP TABLE IF EXISTS iths.Hobby;<br>
<br>
CREATE TABLE Hobby (<br>
<br>
	HobbyId INT NOT NULL AUTO_INCREMENT,<br>
	Name VARCHAR(26) NOT NULL,<br>
	PRIMARY KEY (HobbyId)<br>
<br>
);<br>
<br>
INSERT INTO Hobby (Name) <br>
SELECT DISTINCT Hobby FROM ( <br>
  SELECT Id as StudentId, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF <br>
  WHERE HOBBIES != ""<br>
  UNION SELECT Id as StudentId, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) FROM UNF<br>
  WHERE HOBBIES != ""<br>
  UNION SELECT Id as StudentId, trim(substring_index(Hobbies, ",", -1)) FROM UNF<br>
  WHERE HOBBIES != ""<br>
) AS Hobbies2;<br>
<br>
<br>
DROP TABLE IF EXISTS iths.StudentHobby;<br>
<br>
CREATE TABLE StudentHobby (<br>
<br>	
	StudentId INT NOT NULL,<br>
	HobbyId INT NOT NULL,<br>
	PRIMARY KEY (StudentId, HobbyId),<br>
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)<br>
<br>
<br>);
<br>
INSERT INTO StudentHobby (StudentId, HobbyId)<br>
SELECT DISTINCT StudentId, Hobby.HobbyId FROM (<br>
	SELECT Id as StudentId, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF<br>
  	WHERE HOBBIES != ""<br>
  	UNION SELECT Id as StudentId, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) FROM UNF<br>
  	WHERE HOBBIES != ""<br>
  	UNION SELECT Id as StudentId, trim(substring_index(Hobbies, ",", -1)) FROM UNF<br>
  	WHERE HOBBIES != ""<br>
<br>
) AS Hobbies2 INNER JOIN Hobby ON Hobbies2.Hobby = Hobby.Name;<br>
<br>
<br>
ALTER TABLE Hobby<br>
ADD FOREIGN KEY (HobbyId) REFERENCES StudentHobby(HobbyId);<br>
<br>
<br>
DROP TABLE IF EXISTS iths.Phone;<br>
<br>
Create table Phone (<br>
<br>
	StudentId INT NOT NULL,<br>
	Type VARCHAR(26),<br>
	Number VARCHAR(26),<br>
	PRIMARY KEY (StudentId, Number),<br>
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)<br>
<br>
);<br>
<br>
INSERT INTO Phone(Number, StudentId)<br>
SELECT DISTINCT HomePhone, Id FROM UNF <br>
WHERE HomePhone IS NOT NULL AND HomePhone != '';<br>
<br>
UPDATE Phone <br>
SET Type = "Home" <br>
WHERE Type IS NULL;<br>
<br>
INSERT INTO Phone(Number, StudentId)<br>
SELECT DISTINCT JobPhone, Id FROM UNF <br>
WHERE JobPhone IS NOT NULL AND JobPhone != '';<br>
<br>
UPDATE Phone <br>
SET Type = "Job" <br>
WHERE Type IS NULL;<br>
<br>
INSERT INTO Phone(Number, StudentId)<br>
SELECT DISTINCT MobilePhone1, Id FROM UNF <br>
WHERE MobilePhone1 IS NOT NULL AND MobilePhone1 != '';<br>
<br>
UPDATE Phone <br>
SET Type = "Mobile" <br>
WHERE Type IS NULL;<br>
<br>
INSERT INTO Phone(Number, StudentId) <br>
SELECT DISTINCT MobilePhone2, Id FROM UNF <br>
WHERE MobilePhone2 IS NOT NULL AND MobilePhone2 != ''; <br>
<br>
UPDATE Phone <br>
SET Type = "Mobile" <br>
WHERE Type IS NULL; <br>
