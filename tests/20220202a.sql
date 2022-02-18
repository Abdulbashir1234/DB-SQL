DROP DATABASE IF EXISTS BikeRental;
CREATE DATABASE IF NOT EXISTS BikeRental;
USE BikeRental;
    -- scelgo PK tra id e codiceFiscale:
    -- visto che id è stata messa apposta -> id
    -- codiceFiscale rimane candidata quindi UNIQUE!
CREATE TABLE Utente (
    id INT AUTO_INCREMENT COMMENT "Unique auto generated user id",
    cognome VARCHAR(50) NOT NULL COMMENT "Cognome utente",
    nome VARCHAR(50) NOT NULL COMMENT "Nome utente",
    codiceFiscale VARCHAR(16) NOT NULL COMMENT "Codice Fiscale utente",
    UNIQUE codiceFiscaleUnivoco (codiceFiscale), -- no duplicates
    PRIMARY KEY(id)
);
-- Attributo multiplo -> tabella
CREATE TABLE Email (
    email VARCHAR(50) NOT NULL COMMENT "Indirizzo e-mail utente",
    utente INT NOT NULL COMMENT "User id",
    PRIMARY KEY(email), -- assumo e-mail non condivisa tra utenti (in altri casi, va bene PK(email, utente)
    CONSTRAINT emailOwner FOREIGN KEY (utente) REFERENCES Utente(id) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE Stazione (
    indirizzo VARCHAR(100) NOT NULL COMMENT "Indirizzo stazione",
    totali INT NOT NULL DEFAULT 50 COMMENT "Slot totali",
    liberi INT NOT NULL DEFAULT 0 COMMENT "Slot liberi", -- aggiornato tramite trigger
    PRIMARY KEY(indirizzo)
);
CREATE TABLE Bicicletta (
    id INT AUTO_INCREMENT COMMENT "Unique bike id",
    dataRevisione DATE NOT NULL COMMENT "Data revisione",
    stazione VARCHAR(100) NULL COMMENT "Stazione attuale", -- opzionale!
    PRIMARY KEY(id),
    CONSTRAINT Position FOREIGN KEY (stazione) REFERENCES Stazione(indirizzo) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE Noleggio (
    bicicletta INT NOT NULL COMMENT "Bike id",
    utente INT NOT NULL COMMENT "User id",
    stazPrelievo VARCHAR(100) NOT NULL COMMENT "Stazione prelievo",
    tempoPrelievo DATETIME NOT NULL COMMENT "Istante prelievo",
    -- dati riconsegna opzionali (noleggio in corso)
    stazRiconsegna VARCHAR(100) NULL DEFAULT NULL COMMENT "Stazione riconsegna",
    tempoRiconsegna DATETIME NULL DEFAULT NULL COMMENT "Istante riconsegna",
    durata TIME AS (TIMEDIFF(tempoRiconsegna, tempoPrelievo)) VIRTUAL, -- calcolato!
    -- scelta PK: ovviamente una bicicletta può essere prelevata una sola volta in un dato istante
    -- ma anche (forse no) un utente può prelevare una sola volta in un dato istante
    PRIMARY KEY(bicicletta, tempoPrelievo),
    CONSTRAINT Utilizzo FOREIGN KEY (bicicletta) REFERENCES Bicicletta(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Prelievo FOREIGN KEY (stazRiconsegna) REFERENCES Stazione(indirizzo) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Riconsegna FOREIGN KEY (stazPrelievo) REFERENCES Stazione(indirizzo) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Responsabile FOREIGN KEY (utente) REFERENCES Utente(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    -- vincolo per noleggio in corso/terminato
    CONSTRAINT NoleggioFinito CHECK(ISNULL(stazRiconsegna) = ISNULL(tempoRiconsegna))
);
-- triggers per aggiornamento (non richiesti)
DELIMITER //
CREATE TRIGGER NuovoNoleggio
    AFTER INSERT ON Noleggio
    FOR EACH ROW
    BEGIN
        UPDATE Bicicletta SET stazione = NULL WHERE id = NEW.bicicletta;
        UPDATE Stazione SET liberi = liberi + 1 WHERE id = NEW.stazPrelievo;
    END;
//
CREATE TRIGGER FineNoleggio
    AFTER UPDATE ON Noleggio
    FOR EACH ROW
    BEGIN
        UPDATE Bicicletta SET stazione = NEW.stazRiconsegna WHERE id = NEW.bicicletta;
        UPDATE Stazione SET liberi = liberi - 1 WHERE id = NEW.stazRiconsegna;
    END;
//
DELIMITER ;