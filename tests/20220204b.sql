DROP DATABASE IF EXISTS Libro;
CREATE DATABASE IF NOT EXISTS Libro;
USE Libro;
    -- scelgo PK tra id e codiceFiscale:
    -- visto che id è stata messa apposta -> id
    -- codiceFiscale rimane candidata quindi UNIQUE!
CREATE TABLE Lettore (
    id INT AUTO_INCREMENT COMMENT "Unique auto generated user id",
    cognome VARCHAR(50) NOT NULL COMMENT "Cognome lettore",
    nome VARCHAR(50) NOT NULL COMMENT "Nome lettore",
    codiceFiscale VARCHAR(16) NOT NULL COMMENT "codiceFiscale lettore",
    nascita DATE NOT NULL COMMENT "data nascita lettore",
    UNIQUE codiceFiscaleUnivoco (codiceFiscale), -- no duplicates
    PRIMARY KEY(id)
);
CREATE TABLE Libreria (
    indirizzo VARCHAR(50) NOT NULL COMMENT "Indirizzo libreria",
    proprietario VARCHAR(50) NOT NULL COMMENT "Proprietario libreria",
    PRIMARY KEY(indirizzo)
);
CREATE TABLE Libro (
    id INT AUTO_INCREMENT COMMENT "Unique book id",
    titolo VARCHAR(50) NOT NULL COMMENT "Titolo",
    libreria VARCHAR(50) NULL COMMENT "Libreria attuale", -- opzionale!
    PRIMARY KEY(id),
    CONSTRAINT Position FOREIGN KEY (libreria) REFERENCES Libreria(indirizzo) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- Attributo multiplo -> tabella
CREATE TABLE Autori (
    autore VARCHAR(50) NOT NULL COMMENT "Nome e cognome autore",
    libro INT NOT NULL COMMENT "Book id",
    PRIMARY KEY(autore, libro),
    CONSTRAINT writtenBy FOREIGN KEY (libro) REFERENCES Libro(id) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE Prestito (
    libro INT NOT NULL COMMENT "Book id",
    lettore INT NOT NULL COMMENT "User id",
    libInizio VARCHAR(50) NOT NULL COMMENT "Libreria inizio",
    tempoInizio DATETIME NOT NULL COMMENT "Istante inizio",
    -- dati fine opzionali (noleggio in corso)
    libFine VARCHAR(50) NULL DEFAULT NULL COMMENT "Libreria fine",
    tempoFine DATETIME NULL DEFAULT NULL COMMENT "Istante fine",
    durata INT AS (DATEDIFF(tempoFine, tempoInizio)) VIRTUAL, -- calcolato! in giorni
    -- scelta PK: ovviamente una Libro può partire una sola volta in un dato istante
    PRIMARY KEY(libro, tempoInizio),
    -- ma anche (forse no) un lettore può partire una sola volta in un dato istante
    -- UNIQUE(lettore, tempoInizio),
    CONSTRAINT Utilizzo FOREIGN KEY (Libro) REFERENCES Libro(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Inizio FOREIGN KEY (libFine) REFERENCES Libreria(indirizzo) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Fine FOREIGN KEY (libInizio) REFERENCES Libreria(indirizzo) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Responsabile FOREIGN KEY (lettore) REFERENCES Lettore(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    -- vincolo per corsa in corso/terminato
    CONSTRAINT PrestitoFinito CHECK(ISNULL(libFine) = ISNULL(tempoFine))
);
