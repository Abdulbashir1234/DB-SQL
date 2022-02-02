-- Translations from figure 7.25 & 7.26
-- 
-- Binary many-to-many relationship: E1 (x,N) - R - (x,N) E2
-- 
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11)
) COMMENT "Table for entity E1";
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE R (
    -- primary key field(s)
    AE11 VARCHAR(30),
    AE21 VARCHAR(30),
    -- mandatory fields
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11, AE21),
    COSTRAINT RE1 FOREIGN KEY AE11 REFERENCES E1(AE11),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21)
) COMMENT "Table for relationship R";
-- 
-- Ternary many-to-many relationship
-- 
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11)
) COMMENT "Table for entity E1";
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE E3 (
    -- primary key field(s)
    AE31 VARCHAR(30),
    -- mandatory fields
    AE32 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE31)
) COMMENT "Table for entity E3";
CREATE TABLE R (
    -- primary key field(s)
    AE11 VARCHAR(30),
    AE21 VARCHAR(30),
    AE31 VARCHAR(30),
    -- mandatory fields
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11, AE21, AE31),
    COSTRAINT RE1 FOREIGN KEY AE11 REFERENCES E1(AE11),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21),
    COSTRAINT RE3 FOREIGN KEY AE31 REFERENCES E3(AE31)
) COMMENT "Table for relationship R";
-- 
-- One-to-many relationship with mandatory participation: E1 (1,1) - R - (x,N) E2
-- 
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    AE21 VARCHAR(30) NOT NULL,
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21)
) COMMENT "Table for entity E1";
-- 
-- One-to-many relationship with optional participation: E1 (0,1) - R - (x,N) E2
-- 
-- Possibilità 1 (probabilità di partecipazione elevata e/o associazione molto usata)
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    AE21 VARCHAR(30) NULL,
    AR DECIMAL(10, 2) NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21),
    CHECK (ISNULL(AE21) = ISNULL(AR))
) COMMENT "Table for entity E1";
-- Possibilità 2 (probabilità di partecipazione scarsa e/o associazione poco usata)
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11)
) COMMENT "Table for entity E1";
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE R (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE21 VARCHAR(30) NOT NULL,
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11),
    COSTRAINT RE1 FOREIGN KEY AE11 REFERENCES E1(AE11),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21)
) COMMENT "Table for relationship R";
-- 
-- Relationship with external identifiers: E1 (1,1) -*- R - (x,N) E2
-- 
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    AE21 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11, AE21),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21)
) COMMENT "Table for entity E1";
-- 
-- One-to-one relationship with mandatory participation for both entities: E1 (1,1) - R - (1,1) E2
-- 
-- Possibilità 1
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    AE21 VARCHAR(30) NOT NULL,
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11),
    COSTRAINT RE2max UNIQUE(AE21),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21)
) COMMENT "Table for entity E1";
-- Possibilità 2 (semplice scambio di E1 con E2 in caso simmetrico)
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11)
) COMMENT "Table for entity E1";
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    AE11 VARCHAR(30) NOT NULL,
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21),
    COSTRAINT RE1max UNIQUE(AE11),
    COSTRAINT RE1 FOREIGN KEY AE11 REFERENCES E1(AE11)
) COMMENT "Table for entity E2";
-- 
-- One-to-one relationship with optional participation for one entity: E1 (1,1) - R - (0,1) E2
-- 
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    AE21 VARCHAR(30) NOT NULL,
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11),
    COSTRAINT RE2max UNIQUE(AE21),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21)
) COMMENT "Table for entity E1";
-- 
-- One-to-one relationship with optional participation for both entities: E1 (0,1) - R - (0,1) E2
-- 
-- Possibilità 1
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11)
) COMMENT "Table for entity E1";
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- optional fields
    AE11 VARCHAR(30) NULL,
    AR DECIMAL(10, 2) NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21),
    COSTRAINT RE1max UNIQUE(AE11),
    COSTRAINT RE1 FOREIGN KEY AE11 REFERENCES E1(AE11),
    CHECK (ISNULL(AE11) = ISNULL(AR))
) COMMENT "Table for entity E2";
-- Possibilità 2
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    -- optional fields
    AE21 VARCHAR(30) NULL,
    AR DECIMAL(10, 2) NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11),
    COSTRAINT RE2max UNIQUE(AE21),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21),
    CHECK (ISNULL(AE21) = ISNULL(AR))
) COMMENT "Table for entity E1";
-- Possibilità 3
CREATE TABLE E1 (
    -- primary key field(s)
    AE11 VARCHAR(30),
    -- mandatory fields
    AE12 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE11)
) COMMENT "Table for entity E1";
CREATE TABLE E2 (
    -- primary key field(s)
    AE21 VARCHAR(30),
    -- mandatory fields
    AE22 DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    PRIMARY KEY (AE21)
) COMMENT "Table for entity E2";
CREATE TABLE R (
    -- primary key field(s)
    AE11 VARCHAR(30) NOT NULL,
    AE21 VARCHAR(30) NOT NULL,
    -- mandatory fields
    AR DECIMAL(10, 2) NOT NULL,
    -- CONSTRAINTS:
    -- PRIMARY KEY (AE11),
    -- COSTRAINT RE2max UNIQUE(AE21),
    PRIMARY KEY (AE21),
    COSTRAINT RE1max UNIQUE(AE11),
    COSTRAINT RE1 FOREIGN KEY AE11 REFERENCES E1(AE11),
    COSTRAINT RE2 FOREIGN KEY AE21 REFERENCES E2(AE21)
) COMMENT "Table for relationship R";