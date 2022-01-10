SELECT "DROP DATABASE IF EXISTS Formazione;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS Formazione;

SELECT "CREATE DATABASE IF NOT EXISTS Formazione;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS Formazione;

SELECT "USE Formazione;" AS "Impostazione database di default (per evitare database.table...)";
USE Formazione;

SELECT "CREATE TABLE telephone (...);" AS "Creazione nuova tabella telephone";
CREATE TABLE telephone (
    -- primary key field(s)
    number VARCHAR(15) COMMENT "Numero",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity telephone";

DESCRIBE telephone;

SELECT "CREATE TABLE employer (...);" AS "Creazione nuova tabella employer";
CREATE TABLE employer (
    -- primary key field(s)
    name VARCHAR(30) COMMENT "Nome",
    -- mandatory fields
    address VARCHAR(50) NOT NULL COMMENT "Indirizzo",
    phone VARCHAR(15) NOT NULL COMMENT "Telefono",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity employer";

DESCRIBE employer;

SELECT "CREATE TABLE course (...);" AS "Creazione nuova tabella course";
CREATE TABLE course (
    -- primary key field(s)
    code VARCHAR(10) COMMENT "Codice",
    -- mandatory fields
    name VARCHAR(50) NOT NULL COMMENT "Nome",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity course";

DESCRIBE course;

SELECT "CREATE TABLE employee (...);" AS "Creazione nuova tabella employee";
CREATE TABLE employee (
    -- mandatory fields
    position VARCHAR(30) NOT NULL COMMENT "Posizione",
    level VARCHAR(30) NOT NULL COMMENT "Livello"
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity employee";

DESCRIBE employee;

SELECT "CREATE TABLE instructor (...);" AS "Creazione nuova tabella instructor";
CREATE TABLE instructor (
    -- primary key field(s)
    SSN VARCHAR(16) COMMENT "Social Security Number",
    -- mandatory fields
    surname VARCHAR(30) NOT NULL COMMENT "Cognome",
    type ENUM('Freelance','Permanent') NOT NULL COMMENT "Freelance/Permanent",
    birthtown VARCHAR(30) NOT NULL COMMENT "Citta di nascita",
    birthdate DATE NOT NULL COMMENT "Data di nascita",
    age INT AS (FLOOR(DATEDIFF(NOW(), birthdate) / 365)) VIRTUAL COMMENT "age wrongly computed...",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (SSN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity instructor";

DESCRIBE instructor;


SELECT "CREATE TABLE class (...);" AS "Creazione nuova tabella class";
CREATE TABLE class (
    -- primary key field(s)
    datetime DATETIME COMMENT "data/ora",
    -- time TIME COMMENT "ora",
    room VARCHAR(5) COMMENT "stanza",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    -- PRIMARY KEY (date, time, room)
    PRIMARY KEY (datetime, room)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity class";

DESCRIBE class;


SELECT "CREATE TABLE edition (...);" AS "Creazione nuova tabella edition";
CREATE TABLE edition (
    -- primary key field(s)
    code VARCHAR(5) COMMENT "codice",
    -- mandatory fields
    start DATE NOT NULL COMMENT "data inizio",
    end DATE NOT NULL COMMENT "data fine",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (code),
    CHECK(end > start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity edition";

DESCRIBE edition;


SELECT "CREATE TABLE trainee (...);" AS "Creazione nuova tabella trainee";
CREATE TABLE trainee (
    -- primary key field(s)
    code INT AUTO_INCREMENT COMMENT "codice automatico",
    -- mandatory fields
    SSN VARCHAR(16) NOT NULL COMMENT "Social Security Number",
    surname VARCHAR(30) NOT NULL COMMENT "Cognome",
    sex CHAR(1) NOT NULL COMMENT "sesso....",
    birthtown VARCHAR(30) NOT NULL COMMENT "Citta di nascita",
    birthdate DATE NOT NULL COMMENT "Data di nascita",
    age INT AS (FLOOR(DATEDIFF(NOW(), birthdate) / 365)) VIRTUAL COMMENT "age wrongly computed...",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (code),
    CONSTRAINT UniqueSSN UNIQUE(SSN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity trainee";

DESCRIBE trainee;

SELECT "CREATE TABLE professional (...);" AS "Creazione nuova tabella professional";
CREATE TABLE professional (
    -- primary key field(s)
    trainee INT COMMENT "codice trainee",
    -- mandatory fields
    expertise VARCHAR(30) NOT NULL COMMENT "Specializzazione",
    -- optional fields
    title VARCHAR(30) NULL COMMENT "titolo professionale",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (trainee),
    CONSTRAINT IsATrainee FOREIGN KEY (trainee) REFERENCES trainee(code)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity professional";

DESCRIBE professional;

SELECT "CREATE TABLE qualification (...);" AS "Creazione nuova tabella qualification";
CREATE TABLE qualification (
    -- primary key field(s)
    course VARCHAR(10) COMMENT "Codice corso",
    instructor VARCHAR(16) COMMENT "Instructor Social Security Number",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (course, instructor),
    CONSTRAINT CourseExists FOREIGN KEY (course) REFERENCES course(code)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT InstructorExists FOREIGN KEY (instructor) REFERENCES instructor(SSN)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for relationship qualification";

DESCRIBE qualification;


SELECT "CREATE TABLE attendance (...);" AS "Creazione nuova tabella attendance";
CREATE TABLE attendance (
    -- primary key field(s)
    trainee INT COMMENT "codice trainee",
    course VARCHAR(10) COMMENT "Codice corso",
    -- optional fields
    marks VARCHAR(5) NULL COMMENT "Votazione",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (trainee, course),
    CONSTRAINT AttendanceOfATrainee FOREIGN KEY (trainee) REFERENCES trainee(code)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT AttendanceToACourse FOREIGN KEY (course) REFERENCES course(code)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for relationship attendance";

DESCRIBE attendance;

SELECT "CREATE TABLE employment (...);" AS "Creazione nuova tabella employment";
CREATE TABLE employment (
    -- primary key field(s)
    trainee INT COMMENT "codice trainee",
    employer VARCHAR(30) COMMENT "Nome employer",
    -- mandatory fields
    start DATE NOT NULL COMMENT "data inizio",
    end DATE NOT NULL COMMENT "data fine",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (trainee, employer),
    CONSTRAINT EmploymentOfATrainee FOREIGN KEY (trainee) REFERENCES trainee(code)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT EmploymentByEmployer FOREIGN KEY (employer) REFERENCES employer(name)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for relationship employment";

DESCRIBE employment;

ALTER TABLE telephone
    ADD COLUMN instructor VARCHAR(16) NOT NULL COMMENT "Instructor Social Security Number",
    ADD CONSTRAINT NumberOfInstructor FOREIGN KEY (instructor) REFERENCES instructor(SSN)
        ON UPDATE CASCADE ON DELETE RESTRICT;


DESCRIBE telephone;

ALTER TABLE edition
    ADD COLUMN instructor VARCHAR(16) NOT NULL COMMENT "Instructor Social Security Number",
    ADD CONSTRAINT TaughtByInstructor FOREIGN KEY (instructor) REFERENCES instructor(SSN)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD COLUMN course VARCHAR(10) NOT NULL COMMENT "Codice corso",
    ADD CONSTRAINT EditionOfACourse FOREIGN KEY (course) REFERENCES course(code)
        ON UPDATE CASCADE ON DELETE RESTRICT;

DESCRIBE edition;

