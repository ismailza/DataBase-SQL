-- Creation de la base de donnees
CREATE DATABASE epreuve_tp;
USE epreuve_tp;

-- Creation des tables
CREATE TABLE messages (
    nomsg       INT PRIMARY KEY AUTO_INCREMENT,
    sujet       VARCHAR(300),
    date        DATE,
    corps       TEXT,
    adremetteur VARCHAR(60)
);

ALTER TABLE messages ADD COLUMN nb_octets INT;

CREATE TABLE destinataires (
    nomsg           INT,
    adrdestinataire VARCHAR(60),
    PRIMARY KEY (nomsg, adrdestinataire)
);

CREATE TABLE reponses (
    nomsgrep      INT PRIMARY KEY AUTO_INCREMENT,
    nomsgint      INT
);

CREATE TABLE locuteurs (
    adremail    VARCHAR(60) PRIMARY KEY,
    nom         VARCHAR(30),
    type        CHAR(1)
);

CREATE TABLE compositions (
    adremailgroupe  VARCHAR(60),
    adremailpers    VARCHAR(60),
    PRIMARY KEY (adremailgroupe, adremailpers)
);

-- Definition des cles etrangeres
ALTER TABLE messages ADD CONSTRAINT fk_messages_locuteurs FOREIGN KEY (adremetteur) REFERENCES locuteurs (adremail) ON DELETE CASCADE;
ALTER TABLE destinataires ADD CONSTRAINT fk_destinataires_messages FOREIGN KEY (nomsg) REFERENCES messages (nomsg) ON DELETE CASCADE;
ALTER TABLE destinataires ADD CONSTRAINT fk_destinataires_locuteurs FOREIGN KEY (adrdestinataire) REFERENCES locuteurs (adremail) ON DELETE CASCADE;
ALTER TABLE reponses ADD CONSTRAINT fk_reponses_messages_rep FOREIGN KEY (nomsgrep) REFERENCES messages (nomsg) ON DELETE CASCADE;
ALTER TABLE reponses ADD CONSTRAINT fk_reponses_messages_int FOREIGN KEY (nomsgint) REFERENCES messages (nomsg) ON DELETE CASCADE;
ALTER TABLE compositions ADD CONSTRAINT fk_compositions_locuteurs_grp FOREIGN KEY (adremailgroupe) REFERENCES locuteurs (adremail) ON DELETE CASCADE;
ALTER TABLE compositions ADD CONSTRAINT fk_compositions_locuteurs_per FOREIGN KEY (adremailpers) REFERENCES locuteurs (adremail) ON DELETE CASCADE;

-- Epreuve TP SQL

-- Q1: Nom des locuteurs qui ont envoye un message au liste-ine2.inpt.ac.ma
-- Method 1:
SELECT nom FROM locuteurs
WHERE adremail IN (
    SELECT adremetteur FROM messages
    WHERE nomsg IN (
        SELECT nomsg FROM destinataires
        WHERE adrdestinataire = 'liste-ine2@inpt.ac.ma'
    )
);

-- Method 2:
SELECT nom FROM locuteurs L
WHERE EXISTS (
    SELECT * FROM destinataires D
    WHERE D.adrdestinataire = 'liste-ine2@inpt.ac.ma'
    AND nomsg = D.nomsg
);

-- Q2: L'adresse email et le nom des locuteurs qui sont dans le groupe liste-prof.inpt.ac.ma
SELECT adremail, nom FROM locuteurs
WHERE adremail IN (
    SELECT adremailpers FROM compositions
    WHERE adremailgroupe = 'liste-prof@inpt.ac.ma'
);

-- Q3: Le nombre de messages reçus par foulane@inpt.ac.ma
SELECT COUNT(*) FROM destinataires
WHERE adrdestinataire = 'foulane@inpt.ac.ma';

-- Q4: L'adresse, le nom et le nombre de personne de chaque groupe
SELECT C.adremailgroupe, L.nom, COUNT(*)
FROM locuteurs L
JOIN compositions C ON L.adremail = C.adremailgroupe
GROUP BY C.adremailgroupe, L.nom;

-- Q5: L'adresse email de la personne qui appartient au plus grand nombre de groupes
SELECT adremailpers FROM compositions
GROUP BY adremailpers
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*) FROM compositions
    GROUP BY adremailpers
);

-- Q6: Le numéro et le sujet des messages qui n'ont aucune réponse
SELECT nomsg, sujet FROM messages
WHERE nomsg NOT IN (
    SELECT nomsgint FROM reponses
);

-- Q7: Les locuteurs qui appartiennent à tous les groupes
-- Method 1:
SELECT adremail, nom FROM locuteurs
WHERE adremail IN (
    SELECT adremailpers FROM compositions
    GROUP BY adremailpers
    HAVING COUNT(*) = (
        SELECT COUNT(*) FROM locuteurs
        WHERE type = 'G'
    )
);

-- Method 2:
SELECT adremail, nom FROM locuteurs L1
WHERE NOT EXISTS (
    SELECT * FROM locuteurs L2
    WHERE type = 'G'
    AND NOT EXISTS (
        SELECT * FROM compositions Co
        WHERE Co.adremailpers = L1.adremail
        AND Co.adremailgroupe = L2.adremail
    )
);

-- Method 3:
CREATE VIEW groupes AS
SELECT adremail 'adremailgroupe'
FROM locuteurs
WHERE type = 'G';

CREATE VIEW R AS
SELECT R1.adremailpers, groupes.adremailgroupe FROM (
    SELECT adremailpers FROM compositions
) R1, groupes
EXCEPT
SELECT adremailpers, adremailgroupe FROM compositions;

SELECT adremail, nom FROM locuteurs
WHERE adremail IN (
    SELECT adremailpers FROM compositions
    EXCEPT
    SELECT adremailpers FROM r
);




INSERT INTO messages (sujet, date, corps, adremetteur)
VALUES 
    ("sjt1", "2022-6-12", "corps", "abc@gmail.com"),
    ("sjt2", "2022-6-12", "corps", "qsd@gmail.com"),
    ("sjt3", "2022-6-12", "corps", "abc@gmail.com"),
    ("sjt4", "2022-6-12", "corps", "abc@gmail.com");

INSERT INTO messages (sujet, date, corps, adremetteur, nb_octets)
VALUES 
    ("sjt4", "2022-6-12", "corps", "abc@gmail.com", 8),
    ("sjt4", "2022-6-12", "corps", "abc@gmail.com", 12);

SELECT * FROM messages;
SELECT AVG(nb_octets) FROM messages;
SELECT SUM(nb_octets) / COUNT(nb_octets) FROM messages;
