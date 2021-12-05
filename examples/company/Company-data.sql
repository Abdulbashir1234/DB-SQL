SELECT "USE Company;" AS "Impostazione database di default (per evitare database.table...)";
USE Company;

-- branches, that's easy
LOAD DATA LOCAL INFILE 'Company.branch.csv' IGNORE
    INTO TABLE branch -- CHARACTER SET utf8
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n'
    IGNORE 1 LINES;

SHOW WARNINGS;

-- projects, that's easy
LOAD DATA LOCAL INFILE 'Company.project.csv' IGNORE
    INTO TABLE project -- CHARACTER SET utf8
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n'
    IGNORE 1 LINES;

SHOW WARNINGS;

-- employees, that's easy
LOAD DATA LOCAL INFILE 'Company.employee.csv' IGNORE
    INTO TABLE employee -- CHARACTER SET utf8
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n'
    IGNORE 1 LINES;

SHOW WARNINGS;

-- not enough employees, let's create some more
SELECT "Creating more employees ... please wait" AS Info;
SET @START = NOW(6);    -- this will take a while ...
INSERT IGNORE INTO employee(surname, salary, birthdate)
    SELECT CONCAT(SUBSTR(e1.surname, 1, RAND() * 10), SUBSTR(e2.surname, 1, RAND() * 10)), (e1.salary + e2.salary) / 2, e1.birthdate
        FROM employee e1, employee e2
        WHERE RAND() < 0.5;

SELECT COUNT(*) AS "Total Number of employees", TIMEDIFF(NOW(), @START) AS "Time needed [s]"
    FROM employee;

SELECT "Creating partecipations ... please wait" AS Info;
SET @START = NOW(6);    -- this will take a long while ...
-- partecipation, no need of mockaroo here
INSERT IGNORE INTO partecipation
    SELECT code, name, FROM_DAYS((TO_DAYS(birthdate) + TO_DAYS(release_date)) / 2)
    -- SELECT code, name, FROM_DAYS((TO_DAYS(birthdate) + TO_DAYS(IFNULL(release_date, NOW())) / 2)
        FROM employee, project
        WHERE RAND() < 0.1;

SELECT COUNT(*) AS "Total Number of partecipations", TIMEDIFF(NOW(), @START) AS "Time needed [s]"
    FROM partecipation;

-- departments, that's not so easy: departments must belong to a branch and have a manager
-- let's start with their names
CREATE TEMPORARY TABLE DepartmentNames (
    name VARCHAR(50) PRIMARY KEY
);

LOAD DATA LOCAL INFILE 'Company.department.name.csv' IGNORE
    INTO TABLE DepartmentNames -- CHARACTER SET utf8
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n'
    IGNORE 1 LINES;

SHOW WARNINGS;

-- max code of a manager
SELECT MAX(code) INTO @MaxCode
    FROM employee;

INSERT IGNORE INTO department
    SELECT name, city, RAND() * @MaxCode
        FROM DepartmentNames, branch
        WHERE RAND() < 0.5;

-- Let's get rid of it
DROP TABLE DepartmentNames;

-- Now for the phone numbers
-- the mandatory one
INSERT IGNORE INTO phone
    SELECT RAND() * 900000000 + 100000000, name, branch
        FROM department;

-- optional second
INSERT IGNORE INTO phone
    SELECT RAND() * 900000000 + 100000000, name, branch
        FROM department
        WHERE RAND() < 0.5;

-- optional third
INSERT IGNORE INTO phone
    SELECT RAND() * 900000000 + 100000000, name, branch
        FROM department
        WHERE RAND() < 0.5;

-- hey wait, no employee is member of any department :-(
-- Let's assign a random department to employees first
-- this will take the whole eternity ...
-- UPDATE IGNORE employee e, department d
    -- SET e.department = d.name, e.branch = d.branch
    -- WHERE RAND() < 0.001;
-- MariaDB [Company]> UPDATE IGNORE employee e, department d
--     -> 
--     ->     SET e.department = d.name, e.branch = d.branch
--     -> 
--     ->     WHERE RAND() < 0.001;
-- Query OK, 0 rows affected, 65535 warnings (31 min 35.781 sec)
-- Rows matched: 500823  Changed: 0  Warnings: 0
-- No changes ???!!!

-- Let's go through the managers ...
-- Table of managers with "random" progressive number
CREATE TEMPORARY TABLE Managers (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    code INT NOT NULL
) ENGINE=MEMORY; -- ram table, should be quick

-- Every manager will have an id from 1 to number of managers (i.e. number of departments)
INSERT IGNORE INTO Managers
    SELECT NULL, manager
        FROM department;

-- number of managers, i.e. max id of a manager
SELECT MAX(id) INTO @MaxManager
    FROM Managers;

-- Table of employees with a random managers (i.e. a random department)
CREATE TEMPORARY TABLE EmployeeManagers (
    employee INT NOT NULL PRIMARY KEY,
    manager INT NOT NULL,
    department VARCHAR(20) NULL COMMENT "1. Member of Department name",
    branch VARCHAR(30) NULL COMMENT "1. Member Department branch",
    start DATE NULL COMMENT "2. Membership start date"
); -- NO ram table, should be quick but 500k rows ...

-- Every employee will have their own manager id
SELECT "Every employee will have their own manager id" AS "Info";
INSERT IGNORE INTO EmployeeManagers(employee, manager)
    SELECT code, FLOOR(RAND() * @MaxManager + 1) -- should be fair enough
        FROM employee e;

-- Every employee will have their own manager real code
SELECT "Every employee will have their own manager real code" AS "Info";
UPDATE IGNORE EmployeeManagers e
    SET manager = (SELECT code FROM Managers m WHERE m.id = e.manager);

-- Every employee will have their own department
SELECT "Every employee will have their own department" AS "Info";
UPDATE IGNORE EmployeeManagers e
    SET department = (SELECT name FROM department d WHERE d.manager = e.manager),
        branch = (SELECT branch FROM department d WHERE d.manager = e.manager),
        start = SUBDATE(CURRENT_DATE(), e.manager / 500);

-- Now assign to every employee the department managed by their manager
SELECT "Now assign to every employee the department managed by their manager" AS "Info";
UPDATE IGNORE employee e
    SET e.department = (SELECT em.department FROM EmployeeManagers em WHERE e.code = em.employee),
        e.branch = (SELECT em.branch FROM EmployeeManagers em WHERE e.code = em.employee),
        e.start = (SELECT em.start FROM EmployeeManagers em WHERE e.code = em.employee);

-- Let's get rid of temporary tables
DROP TABLE Managers;
DROP TABLE EmployeeManagers;

-- Let's assign the managers to their department last
SELECT "Let's assign the managers to their department last" AS "Info";
UPDATE IGNORE employee e JOIN department d ON (e.code = d.manager)
    SET e.department = d.name, e.branch = d.branch, e.start = SUBDATE(CURRENT_DATE(), e.code / 500);
