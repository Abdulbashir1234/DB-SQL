DROP DATABASE IF EXISTS Airline;
CREATE DATABASE IF NOT EXISTS Airline;
USE Airline;
    -- scelgo PK tra id e codiceFiscale:
    -- visto che id è stata messa apposta -> id
    -- codiceFiscale rimane candidata quindi UNIQUE!
CREATE TABLE Pilota (
    id INT AUTO_INCREMENT COMMENT "Unique auto generated user id",
    cognome VARCHAR(50) NOT NULL COMMENT "Cognome pilota",
    nome VARCHAR(50) NOT NULL COMMENT "Nome pilota",
    codiceFiscale VARCHAR(16) NOT NULL COMMENT "Codice Fiscale pilota",
    UNIQUE codiceFiscaleUnivoco (codiceFiscale), -- no duplicates
    PRIMARY KEY(id)
);
-- Attributo multiplo -> tabella
CREATE TABLE Telefono (
    telefono VARCHAR(50) NOT NULL COMMENT "Telefono pilota",
    pilota INT NOT NULL COMMENT "Pilota id",
    PRIMARY KEY(telefono), -- assumo telefono non condiviso tra utenti (in altri casi, va bene PK(telefono, pilota)
    CONSTRAINT telefonoOwner FOREIGN KEY (pilota) REFERENCES Pilota(id) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE Aeroporto (
    sigla VARCHAR(5) NOT NULL COMMENT "Indirizzo aeroporto",
    località VARCHAR(50) NOT NULL DEFAULT "Unknown" COMMENT "Località aeroporto",
    PRIMARY KEY(sigla)
);
CREATE TABLE Aereo (
    id INT AUTO_INCREMENT COMMENT "Unique airplane id",
    posti INT NOT NULL COMMENT "Posti disponibili",
    aeroporto VARCHAR(5) NULL COMMENT "Aeroporto attuale", -- opzionale!
    PRIMARY KEY(id),
    CONSTRAINT Position FOREIGN KEY (aeroporto) REFERENCES Aeroporto(sigla) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE Volo (
    aereo INT NOT NULL COMMENT "Airplane id",
    pilota INT NOT NULL COMMENT "Pilota id",
    stazDecollo VARCHAR(5) NOT NULL COMMENT "Aeroporto decollo",
    tempoDecollo TIMESTAMP NOT NULL COMMENT "Istante decollo",
    -- dati atterraggio opzionali (noleggio in corso)
    stazAtterraggio VARCHAR(5) NULL DEFAULT NULL COMMENT "Aeroporto atterraggio",
    tempoAtterraggio TIMESTAMP NULL DEFAULT NULL COMMENT "Istante atterraggio",
    durata TIME AS (TIMEDIFF(tempoAtterraggio, tempoDecollo)) VIRTUAL, -- calcolato!
    -- scelta PK: ovviamente un aereo può decollare una sola volta in un dato istante
    -- ma anche un pilota può decollare una sola volta in un dato istante
    PRIMARY KEY(aereo, tempoDecollo),
    CONSTRAINT Utilizzo FOREIGN KEY (aereo) REFERENCES Aereo(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Decollo FOREIGN KEY (stazDecollo) REFERENCES Aeroporto(sigla) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Atterraggio FOREIGN KEY (stazAtterraggio) REFERENCES Aeroporto(sigla) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT Responsabile FOREIGN KEY (pilota) REFERENCES Pilota(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    -- vincolo per volo in corso/terminato
    CONSTRAINT VoloFinito CHECK(ISNULL(stazAtterraggio) = ISNULL(tempoAtterraggio))
);
-- triggers per aggiornamento (non richiesti)
CREATE TRIGGER NuovoVolo
    AFTER INSERT ON Volo
    FOR EACH ROW
    UPDATE Aereo SET aeroporto = NULL WHERE id = NEW.aereo;
CREATE TRIGGER FineVolo
    AFTER UPDATE ON Volo
    FOR EACH ROW
    UPDATE Aereo SET aeroporto = NEW.stazAtterraggio WHERE id = NEW.aereo;
    