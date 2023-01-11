USE iths;

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
IGNORE 1 ROWS;



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
WHERE Type IS NULL;