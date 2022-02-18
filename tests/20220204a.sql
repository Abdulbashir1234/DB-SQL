DROP DATABASE IF EXISTS Autobus;
CREATE DATABASE IF NOT EXISTS Autobus;
USE Autobus;
    -- scelgo PK tra id e patente:
    -- visto che id è stata messa apposta -> id
    -- patente rimane candidata quindi UNIQUE!
CREATE TABLE Autista (
    id INT AUTO_INCREMENT COMMENT "Unique auto generated user id",
    cognome VARCHAR(50) NOT NULL COMMENT "Cognome autista",
    nome VARCHAR(50) NOT NULL COMMENT "Nome autista",
    patente VARCHAR(16) NOT NULL COMMENT "Patente autista",
    nascita DATE NOT NULL COMMENT "data nascita autista",
    UNIQUE patenteUnivoco (patente), -- no duplicates
    PRIMARY KEY(id)
);
CREATE TABLE Capolinea (
    sigla VARCHAR(10) NOT NULL COMMENT "Sigla capolinea",
    localita VARCHAR(50) NOT NULL COMMENT "Località capolinea",
    PRIMARY KEY(sigla)
);
CREATE TABLE Autobus (
    id INT AUTO_INCREMENT COMMENT "Unique bus id",
    posti INT NOT NULL COMMENT "Numero posti",
    capolinea VARCHAR(10) NULL COMMENT "Capolinea attuale", -- opzionale!
    PRIMARY KEY(id),
    CONSTRAINT Position FOREIGN KEY (capolinea) REFERENCES Capolinea(sigla) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- Attributo multiplo -> tabella
CREATE TABLE Sanificazione (
    data DATE NOT NULL COMMENT "Data di effettuazione",
    autobus INT NOT NULL COMMENT "Bus id",
    PRIMARY KEY(data, autobus),
    CONSTRAINT busSanified FOREIGN KEY (autobus) REFERENCES Autobus(id) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE Corsa (
    autobus INT NOT NULL COMMENT "Bus id",
    autista INT NOT NULL COMMENT "User id",
    stazInizio VARCHAR(100) NOT NULL COMMENT "Capolinea inizio",
    tempoInizio DATETIME NOT NULL COMMENT "Istante inizio",
    dataOraPartenza DATETIME NOT NULL COMMENT "Istante inizio previsto",
    prezzo DECIMAL(5,2) NOT NULL COMMENT "Prezzo",
    -- dati fine opzionali (noleggio in corso)
    stazFine VARCHAR(100) NULL DEFAULT NULL COMMENT "Capolinea fine",
    tempoFine DATETIME NULL DEFAULT NULL COMMENT "Istante fine",
    durata TIME AS (TIMEDIFF(tempoFine, tempoInizio)) VIRTUAL, -- calcolato!
    -- scelta PK: ovviamente una autobus può partire una sola volta in un dato istante
    PRIMARY KEY(autobus, tempoInizio),
    -- ma anche un autista può partire una sola volta in un dato istante
    UNIQUE(autista, tempoInizio),
    CONSTRAINT Utilizzo FOREIGN KEY (autobus) REFERENCES Autobus(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Inizio FOREIGN KEY (stazFine) REFERENCES Capolinea(sigla) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Fine FOREIGN KEY (stazInizio) REFERENCES Capolinea(sigla) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Responsabile FOREIGN KEY (autista) REFERENCES Autista(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    -- vincolo per corsa in corso/terminato
    CONSTRAINT CorsaFinita CHECK(ISNULL(stazFine) = ISNULL(tempoFine))
);
