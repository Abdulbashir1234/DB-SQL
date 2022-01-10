SELECT "DROP DATABASE IF EXISTS ERDiagram;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS ERDiagram;

SELECT "CREATE DATABASE IF NOT EXISTS ERDiagram;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS ERDiagram;

SELECT "USE ERDiagram;" AS "Impostazione database di default (per evitare database.table...)";
USE ERDiagram;

SELECT "CREATE TABLE basicconstruct (...);" AS "Creazione nuova tabella basicconstruct";
CREATE TABLE basicconstruct (
    -- primary key field(s)
    name VARCHAR(30) COMMENT "name",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (name)
);

SELECT "EXPLAIN basicconstruct;" AS "Visualizzazione sintetica della tabella";
EXPLAIN basicconstruct;

SELECT "SHOW CREATE TABLE basicconstruct;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE basicconstruct;

SELECT "CREATE TABLE entity (...);" AS "Creazione nuova tabella entity";
CREATE TABLE entity (
    -- primary key field(s)
    construct VARCHAR(30) COMMENT "basic construct name",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (construct),
    -- FOREIGN KEYS (optional)
    CONSTRAINT EntityIsABasicConstruct FOREIGN KEY(construct) REFERENCES basicconstruct(name)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

SELECT "EXPLAIN entity;" AS "Visualizzazione sintetica della tabella";
EXPLAIN entity;

SELECT "SHOW CREATE TABLE entity;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE entity;

SELECT "CREATE TABLE relationship (...);" AS "Creazione nuova tabella relationship";
CREATE TABLE relationship (
    -- primary key field(s)
    construct VARCHAR(30) COMMENT "basic construct name",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (construct),
    -- FOREIGN KEYS (optional)
    CONSTRAINT RelationshipIsABasicConstruct FOREIGN KEY(construct) REFERENCES basicconstruct(name)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

SELECT "EXPLAIN relationship;" AS "Visualizzazione sintetica della tabella";
EXPLAIN relationship;

SELECT "SHOW CREATE TABLE relationship;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE relationship;

SELECT "CREATE TABLE generalization (...);" AS "Creazione nuova tabella generalization";
CREATE TABLE generalization (
    -- primary key field(s)
    number INT AUTO_INCREMENT COMMENT "Numero distintivo",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (number)
);

SELECT "EXPLAIN generalization;" AS "Visualizzazione sintetica della tabella";
EXPLAIN generalization;

SELECT "SHOW CREATE TABLE generalization;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE generalization;

SELECT "CREATE TABLE attribute (...);" AS "Creazione nuova tabella attribute";
CREATE TABLE attribute (
    -- primary key field(s)
    name VARCHAR(30) COMMENT "nome",
    construct VARCHAR(30) COMMENT "basic construct name",
    -- mandatory fields
    minimum ENUM('0', '1') NOT NULL COMMENT "minimum cardinality",
    maximum ENUM('1', 'N') NOT NULL COMMENT "maximum cardinality",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (name, construct),
    -- FOREIGN KEYS (optional)
    CONSTRAINT Membership FOREIGN KEY(construct) REFERENCES basicconstruct(name)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

SELECT "EXPLAIN attribute;" AS "Visualizzazione sintetica della tabella";
EXPLAIN attribute;

SELECT "SHOW CREATE TABLE attribute;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE attribute;

SELECT "CREATE TABLE compositeattribute (...);" AS "Creazione nuova tabella compositeattribute";
CREATE TABLE compositeattribute (
    -- primary key field(s)
    attribute VARCHAR(30) COMMENT "attribute name",
    construct VARCHAR(30) COMMENT "basic construct name",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (attribute, construct),
    -- FOREIGN KEYS (optional)
    CONSTRAINT CompositeIsAnAttribute FOREIGN KEY(attribute, construct) REFERENCES attribute(name, construct)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

SELECT "EXPLAIN compositeattribute;" AS "Visualizzazione sintetica della tabella";
EXPLAIN compositeattribute;

SELECT "SHOW CREATE TABLE compositeattribute;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE compositeattribute;

SELECT "CREATE TABLE child (...);" AS "Creazione nuova tabella child";
CREATE TABLE child (
    -- primary key field(s)
    generalization INT COMMENT "Numero distintivo della generalizzazione",
    entity VARCHAR(30) COMMENT "entity name",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (generalization, entity),
    -- FOREIGN KEYS (optional)
    CONSTRAINT ChildGeneralization FOREIGN KEY(generalization) REFERENCES generalization(number)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT ChildEntity FOREIGN KEY(entity) REFERENCES entity(construct)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

SELECT "EXPLAIN child;" AS "Visualizzazione sintetica della tabella";
EXPLAIN child;

SELECT "SHOW CREATE TABLE child;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE child;

SELECT "CREATE TABLE participation (...);" AS "Creazione nuova tabella participation";
CREATE TABLE participation (
    -- primary key field(s)
    relationship VARCHAR(30) COMMENT "relationship name",
    entity VARCHAR(30) COMMENT "entity name",
    -- mandatory fields
    minimum ENUM('0', '1') NOT NULL COMMENT "minimum cardinality",
    maximum ENUM('1', 'N') NOT NULL COMMENT "maximum cardinality",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (relationship, entity),
    -- FOREIGN KEYS (optional)
    CONSTRAINT ParticipationRelationship FOREIGN KEY(relationship) REFERENCES relationship(construct)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT ParticipationEntity FOREIGN KEY(entity) REFERENCES entity(construct)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

SELECT "EXPLAIN participation;" AS "Visualizzazione sintetica della tabella";
EXPLAIN participation;

SELECT "SHOW CREATE TABLE participation;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE participation;

SELECT "ALTER TABLE generalization (...);" AS "Modifica tabella generalization";
ALTER TABLE generalization
    ADD COLUMN parent VARCHAR(30) NOT NULL COMMENT "parent entity name",
    -- CONSTRAINTS:
    -- FOREIGN KEYS (optional)
    ADD CONSTRAINT Parent FOREIGN KEY(parent) REFERENCES entity(construct)
        ON UPDATE CASCADE ON DELETE NO ACTION;

SELECT "EXPLAIN generalization;" AS "Visualizzazione sintetica della tabella";
EXPLAIN generalization;

SELECT "SHOW CREATE TABLE generalization;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE generalization;

SELECT "ALTER TABLE attribute (...);" AS "Modifica tabella attribute";
ALTER TABLE attribute 
    ADD COLUMN compositeName VARCHAR(30) COMMENT "composite attribute name",
    ADD COLUMN compositeConstruct VARCHAR(30) COMMENT "composite construct name",
    -- CONSTRAINTS:
    -- FOREIGN KEYS (optional)
    ADD CONSTRAINT Composition FOREIGN KEY(compositeName, compositeConstruct) REFERENCES compositeattribute(attribute, construct);

SELECT "EXPLAIN attribute;" AS "Visualizzazione sintetica della tabella";
EXPLAIN attribute;

SELECT "SHOW CREATE TABLE attribute;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE attribute;

