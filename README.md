# Db2022
Normalization of a database as a school project at ITHS. In this repository your will find a ER diagram to show the relationships in the normalized data and a script to normalize a database (UNF). The JBDC CRUD you will find in my other repository: https://github.com/UlrikaMyAlva/CrudJbdc.git.  
<br>
<br>
To make this diagram we have used Mermaid, which is a tool to be able to draw a diagram using markdown language. <br>
<br>
<br>
# ER diagram  
<br>
<br>
In the original table, everything where together with a column each. To normalize it each subject has gotten their own column. StudentId is used as a key in most of the tables, except School and Hobby that is linked to the StudentId via tables StudentSchool and StudentHobby.   
<br>

![mermaid-diagram-2023-01-11-181400](https://user-images.githubusercontent.com/117780904/211872360-f6637edd-19df-463b-a40d-15655df05e8b.png)

<br>

# GitBash

<br>
<br>

**To run the script you need to run the following commands in GitBash (Or similar Unix Shell)** 


curl -L https://raw.githubusercontent.com/UlrikaMyAlva/db2022/main/denormalized-data.csv -o denormalized-data.csv <br>
<br>
docker start iths-mysql <br>
<br>
docker cp denormalized-data.csv iths-mysql:/var/lib/mysql-files <br>
<br>
cd ws
<br>
<br>
docker exec -i iths-mysql mysql -uroot -proot < normalisering.sql <br>
<br>
winpty docker exec -it iths-mysql bash <br>
<br>
mysql -uroot -proot 



# Script

<br>
<br>

**First, you need to load the table that is going to be normalized (UNF) into the database. The denormalized-data.csv exists in this git repository.** 
**After that the normalization starts. All the tables are dropped if they exist.** 

**The first table, Student, have the StudentId and the Students names. StudentId is the Primary Key.**

**The Grade Table had a lot of spelling mistakes that needed to be updated manually.** 

**School needed to be created before StudentSchool, even though StudentSchool is the link between the Student table and the School table.**
**This makes StudentSchool able to get the SchoolId column. After StudentSchool, the foreign key is added to School.** 
**Here, SchoolId is joined using the values that corelates between the name of the school in UNF and School**

**In the Hobby Table, multiple hobbies where listed in the same box. To combat this, substrings are used.** 

**In the Phone table, each Number and StudentId is moved from UNF to Phone.**
**Then, each type is populated after each kind of phone, making it possible to use 'IS NULL' to alter the type.**

<br>
<br>

```USE iths;

DROP TABLE IF EXISTS UNF;

 CREATE TABLE `UNF` ( 
	`Id` DECIMAL(38, 0) NOT NULL, 
	`Name` VARCHAR(26) NOT NULL, 
	`Grade` VARCHAR(11) NOT NULL, 
	`Hobbies` VARCHAR(25), 
	`City` VARCHAR(10) NOT NULL,
	`School` VARCHAR(30) NOT NULL, 
	`HomePhone` VARCHAR(15), 
	`JobPhone` VARCHAR(15), 
	`MobilePhone1` VARCHAR(15), 
	`MobilePhone2` VARCHAR(15) 
) ENGINE=INNODB; 

LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv' 
INTO TABLE UNF
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;<br> ```


DROP TABLE IF EXISTS iths.Grade; 
DROP TABLE IF EXISTS iths.School;
DROP TABLE IF EXISTS iths.StudentSchool; 
DROP TABLE IF EXISTS iths.Hobby; 
DROP TABLE IF EXISTS iths.StudentHobby; 
DROP TABLE IF EXISTS iths.Phone; 
DROP TABLE IF EXISTS iths.Student; 


DROP TABLE IF EXISTS iths.Student;

Create table Student (

	StudentId INT NOT NULL,
	Student VARCHAR(26) NOT NULL,
	PRIMARY KEY (StudentId)

);

INSERT INTO Student (StudentId, Student) SELECT DISTINCT Id,
Name FROM UNF;


DROP TABLE IF EXISTS iths.Grade; 

Create table Grade (

	StudentId INT NOT NULL,
	Grade VARCHAR(26),
	PRIMARY KEY (StudentId),
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)

);

INSERT INTO Grade (StudentId, Grade) SELECT DISTINCT Id,
Grade FROM UNF;

UPDATE Grade SET Grade = 'First-class'
WHERE Grade IN ('First class', 'Firstclass');

UPDATE Grade SET Grade = 'Excellent'
WHERE Grade IN ('Eksellent');

UPDATE Grade SET Grade = 'Awesome'
WHERE Grade IN ('Awessome');

UPDATE Grade SET Grade = 'Gorgeous'
WHERE Grade IN ('Gorgetus', 'Gorgeus');


DROP TABLE IF EXISTS iths.School;

CREATE TABLE School (

	SchoolId INT NOT NULL AUTO_INCREMENT,
	Name VARCHAR(26) NOT NULL UNIQUE,
	City VARCHAR(26) NOT NULL UNIQUE,
	PRIMARY KEY (SchoolId)

);

INSERT INTO School (Name, City)
SELECT DISTINCT School, City FROM UNF;


DROP TABLE IF EXISTS iths.StudentSchool;

CREATE TABLE StudentSchool (

	StudentId INT NOT NULL,
	SchoolId INT NOT NULL,
	PRIMARY KEY (SchoolId, StudentId),
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)

);


INSERT INTO StudentSchool (StudentId, SchoolId)
SELECT DISTINCT Id, School.SchoolId 
FROM UNF
INNER JOIN School ON School.Name = UNF.School;

ALTER TABLE School
ADD FOREIGN KEY (SchoolId) REFERENCES StudentSchool(SchoolId);


DROP TABLE IF EXISTS iths.Hobby;

CREATE TABLE Hobby (

	HobbyId INT NOT NULL AUTO_INCREMENT,
	Name VARCHAR(26) NOT NULL,
	PRIMARY KEY (HobbyId)

);

INSERT INTO Hobby (Name) 
SELECT DISTINCT Hobby FROM ( 
  SELECT Id as StudentId, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF
  WHERE HOBBIES != ""
  UNION SELECT Id as StudentId, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) FROM UNF
  WHERE HOBBIES != ""
  UNION SELECT Id as StudentId, trim(substring_index(Hobbies, ",", -1)) FROM UNF
  WHERE HOBBIES != ""
) AS Hobbies2;


DROP TABLE IF EXISTS iths.StudentHobby;

CREATE TABLE StudentHobby (

	StudentId INT NOT NULL,
	HobbyId INT NOT NULL,
	PRIMARY KEY (StudentId, HobbyId),
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)

);

INSERT INTO StudentHobby (StudentId, HobbyId)
SELECT DISTINCT StudentId, Hobby.HobbyId FROM (
	SELECT Id as StudentId, trim(SUBSTRING_INDEX(Hobbies, ",", 1)) AS Hobby FROM UNF
  	WHERE HOBBIES != ""
  	UNION SELECT Id as StudentId, trim(substring_index(substring_index(Hobbies, ",", -2),"," ,1)) FROM UNF
  	WHERE HOBBIES != ""
  	UNION SELECT Id as StudentId, trim(substring_index(Hobbies, ",", -1)) FROM UNF
  	WHERE HOBBIES != ""

) AS Hobbies2 INNER JOIN Hobby ON Hobbies2.Hobby = Hobby.Name;

ALTER TABLE Hobby
ADD FOREIGN KEY (HobbyId) REFERENCES StudentHobby(HobbyId);


DROP TABLE IF EXISTS iths.Phone;

Create table Phone (

	StudentId INT NOT NULL,
	Type VARCHAR(26),
	Number VARCHAR(26),
	PRIMARY KEY (StudentId, Number),
	FOREIGN KEY (StudentId) REFERENCES Student(StudentId)

);

INSERT INTO Phone(Number, StudentId)
SELECT DISTINCT HomePhone, Id FROM UNF 
WHERE HomePhone IS NOT NULL AND HomePhone != '';

UPDATE Phone 
SET Type = "Home" 
WHERE Type IS NULL;

INSERT INTO Phone(Number, StudentId)
SELECT DISTINCT JobPhone, Id FROM UNF
WHERE JobPhone IS NOT NULL AND JobPhone != '';

UPDATE Phone 
SET Type = "Job"
WHERE Type IS NULL;

INSERT INTO Phone(Number, StudentId)
SELECT DISTINCT MobilePhone1, Id FROM UNF 
WHERE MobilePhone1 IS NOT NULL AND MobilePhone1 != '';

UPDATE Phone 
SET Type = "Mobile" 
WHERE Type IS NULL;

INSERT INTO Phone(Number, StudentId) 
SELECT DISTINCT MobilePhone2, Id FROM UNF 
WHERE MobilePhone2 IS NOT NULL AND MobilePhone2 != ''; 

UPDATE Phone
SET Type = "Mobile"
WHERE Type IS NULL;```


