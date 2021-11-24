SELECT "DROP DATABASE IF EXISTS Company;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS Company;

SELECT "CREATE DATABASE IF NOT EXISTS Company;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS Company;

SELECT "USE Company;" AS "Impostazione database di default (per evitare database.table...)";
USE Company;

SELECT "CREATE TABLE project (...);" AS "Creazione nuova tabella project";
CREATE TABLE project (
    -- primary key field(s)
    name VARCHAR(30) COMMENT "Nome",
    -- mandatory fields
    budget DECIMAL(10,2) NOT NULL COMMENT "Budget up to 99.999.999,99",
    -- optional fields (NULL can be omitted)
    release_date DATE NULL DEFAULT NULL COMMENT "Data di rilascio",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (name),
    -- DOMAIN (optional)
    CHECK(budget > 0.00)
) COMMENT "Table for entity Project";

SELECT "EXPLAIN project;" AS "Visualizzazione sintetica della tabella";
EXPLAIN project;

SELECT "SHOW CREATE TABLE project;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE project;

SELECT "CREATE TABLE branch (...);" AS "Creazione nuova tabella branch";
CREATE TABLE branch (
    -- primary key field(s)
    city VARCHAR(30) COMMENT "city",
    -- mandatory fields
    number VARCHAR(10) NOT NULL COMMENT "number",
    street VARCHAR(30) NOT NULL COMMENT "street",
    postcode VARCHAR(5) NOT NULL COMMENT "postcode",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (city)
) COMMENT "Table for entity Branch";

SELECT "EXPLAIN branch;" AS "Visualizzazione sintetica della tabella";
EXPLAIN branch;

SELECT "SHOW CREATE TABLE branch;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE branch;

SELECT "CREATE TABLE employee (...);" AS "Creazione nuova tabella employee";
CREATE TABLE employee (
    -- primary key field(s)
    code INT AUTO_INCREMENT COMMENT "matricola",
    -- mandatory fields
    surname VARCHAR(30) NOT NULL COMMENT "surname",
    salary DECIMAL(8,2) NOT NULL COMMENT "salary",
    birthdate DATE NOT NULL COMMENT "nascita",
    -- derived (computed) fields
    age INT AS (DATEDIFF(NOW(), birthdate) / 365) VIRTUAL COMMENT "age wrong...",
    -- age INT AS (DATEDIFF(NOW(), birthdate) / 365) PERSISTENT COMMENT "age wrong...",
    -- N.B. NOW() (and similar non-deterministic functions) not allowed on persistent attributes
    -- "Usual" representation of membership relationship:
    -- foreign key for membership (optional partecipation)
    -- department VARCHAR(20) NULL COMMENT "Member of Department name",
    -- branch VARCHAR(30) NULL COMMENT "Member Department branch",
    -- attribute startdate of membership (optional since partecipation is optional)
    -- start DATE NULL COMMENT "Membership start date",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (code) -- ,
    -- if "Usual" representation of membership relationship is used 
    -- FOREIGN KEYS (optional)
    -- CONSTRAINT memberOfDepartment FOREIGN KEY(department, branch) REFERENCES department(name, branch)
        -- ON UPDATE CASCADE ON DELETE NO ACTION
    -- OPTIONAL FOREIGN KEY MEANINGFUL: (both NULL or none NULL)
    -- CONSTRAINT NoMixUp CHECK(department IS NULL = branch IS NULL)
    -- Optional Relationship mandatory attribute MEANINGFUL: (NULL if no partecipation)
    -- CONSTRAINT NoStarDateIfNoMembership CHECK(department IS NULL = start IS NULL)
) COMMENT "Table for entity Employee";

SELECT "EXPLAIN employee;" AS "Visualizzazione sintetica della tabella";
EXPLAIN employee;

SELECT "SHOW CREATE TABLE employee;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE employee;

SELECT "CREATE TABLE partecipation (...);" AS "Creazione nuova tabella partecipation";
CREATE TABLE partecipation (
    -- primary key field(s)
    employee INT COMMENT "Partecipating employee code",
    project VARCHAR(30) COMMENT "Project name",
    -- mandatory fields
    start DATE NOT NULL COMMENT "Starting date",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (employee, project),
    -- FOREIGN KEYS (optional)
    -- CONSTRAINT nomeVincolo1 FOREIGN KEY(f1_k1,f1_k2) REFERENCES other_table(k1,k2)
    --  ON UPDATE <ACTION> ON DELETE <ACTION>,
    -- where ACTION = RESTRICT | NO ACTION | CASCADE | SET NULL
    CONSTRAINT RealEmployee FOREIGN KEY(employee) REFERENCES employee(code)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT RealProject FOREIGN KEY(project) REFERENCES project(name)
        ON UPDATE CASCADE ON DELETE NO ACTION
) COMMENT "Table for association Partecipation";

SELECT "EXPLAIN partecipation;" AS "Visualizzazione sintetica della tabella";
EXPLAIN partecipation;

SELECT "SHOW CREATE TABLE partecipation;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE partecipation;

SELECT "CREATE TABLE department (...);" AS "Creazione nuova tabella department";
CREATE TABLE department (
    -- primary key field(s)
    name VARCHAR(20) COMMENT "Department name",
    branch VARCHAR(30) COMMENT "city branch",
    -- mandatory fields
    manager INT NOT NULL COMMENT "Manager employee code",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (name, branch),
    -- FOREIGN KEYS (optional)
    CONSTRAINT PartOfBranch FOREIGN KEY(branch) REFERENCES branch(city)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT RealManager FOREIGN KEY(manager) REFERENCES employee(code)
        ON UPDATE CASCADE ON DELETE NO ACTION
) COMMENT "Table for entity Department";

SELECT "EXPLAIN department;" AS "Visualizzazione sintetica della tabella";
EXPLAIN department;

SELECT "SHOW CREATE TABLE department;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE department;

SELECT "CREATE TABLE phone (multiple attribute...);" AS "Creazione nuova tabella phone";
CREATE TABLE phone (
    -- primary key field(s)
    number VARCHAR(10) COMMENT "phone number",
    department VARCHAR(20) COMMENT "Department name",
    branch VARCHAR(30) COMMENT "department city branch",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (number, department, branch), -- if a number can be shared between departments
    -- PRIMARY KEY (number), -- if a number is unique to a department
    -- FOREIGN KEYS (optional)
    CONSTRAINT BelongsToDepartment FOREIGN KEY(department, branch) REFERENCES department(name, branch)
        ON UPDATE CASCADE ON DELETE NO ACTION
) COMMENT "Table for multiple attribute phone of entity Department";

SELECT "EXPLAIN phone;" AS "Visualizzazione sintetica della tabella";
EXPLAIN phone;

SELECT "SHOW CREATE TABLE phone;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE phone;

-- This table isn't really needed ...
SELECT "CREATE TABLE membership (...);" AS "Creazione nuova tabella membership";
CREATE TABLE membership (
    -- primary key field(s)
    employee INT COMMENT "Member employee code",
    department VARCHAR(20) COMMENT "Department name",
    branch VARCHAR(30) COMMENT "city branch",
    -- mandatory fields
    start DATE NOT NULL COMMENT "Starting date",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (employee),
    -- FOREIGN KEYS (optional)
    CONSTRAINT RealMember FOREIGN KEY(employee) REFERENCES employee(code)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT MemberOfDepartment FOREIGN KEY(department, branch) REFERENCES department(name, branch)
        ON UPDATE CASCADE ON DELETE NO ACTION
) COMMENT "Table (not really needed) for relationship Membership between entities Employee and Department";

SELECT "EXPLAIN membership;" AS "Visualizzazione sintetica della tabella";
EXPLAIN membership;

SELECT "SHOW CREATE TABLE membership;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE membership;
