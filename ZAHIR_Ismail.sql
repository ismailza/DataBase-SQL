
-- Epreuve SQL 2022-2023
-- ZAHIR Ismail

-- Création de la base de données
CREATE DATABASE gestion_notes;
USE gestion_notes;

-- Création des tables
CREATE TABLE etudiants (
    num_etud INT PRIMARY KEY AUTO_INCREMENT,
    nom_etud VARCHAR(26) NOT NULL,
    date_naiss DATE,
    sexe CHAR(1),
    code_fac INT
);

CREATE TABLE enseignants (
    num_ens INT PRIMARY KEY AUTO_INCREMENT,
    nom_ens VARCHAR(26) NOT NULL,
    grade INT,
    anciennete INT
);

CREATE TABLE cours (
    num_cours INT PRIMARY KEY AUTO_INCREMENT,
    intitule VARCHAR(30) NOT NULL,
    heures_cours INT NOT NULL,
    heures_tp INT,
    num_ens INT,
    FOREIGN KEY (num_ens) REFERENCES enseignants (num_ens) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE notes (
    num_etud INT,
    num_cours INT,
    note1 FLOAT NOT NULL,
    note2 FLOAT NOT NULL,
    PRIMARY KEY (num_etud, num_cours),
    FOREIGN KEY (num_etud) REFERENCES etudiants (num_etud) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (num_cours) REFERENCES cours (num_cours) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE facultes (
    code_fac INT PRIMARY KEY AUTO_INCREMENT,
    libelle_fac VARCHAR(40) NOT NULL
);

ALTER TABLE etudiants ADD CONSTRAINT fk_faculte FOREIGN KEY (code_fac) REFERENCES facultes (code_fac) ON DELETE CASCADE ON UPDATE CASCADE;

-- Requête 4 : Sélectionner le nom de l'étudiant et sa moyenne (moyenne des notes1 et notes2).
SELECT nom_etud, (note1 + note2) / 2 AS 'Moyenne'
FROM etudiants E, notes N
WHERE E.num_etud = N.num_etud
ORDER BY nom_etud;

-- Requête 7 : Sélectionner le nom de l'étudiant qui a été enseigné par l'enseignant "BEKKHOUCHA", mais dont la moyenne est inférieure à 10.
SELECT nom_etud 
FROM etudiants E, notes N, cours C, enseignants En
WHERE En.nom_ens = 'BEKKHOUCHA'
AND E.num_etud = N.num_etud
AND N.num_cours = C.num_cours
AND C.num_ens = En.num_ens
AND E.num_etud NOT IN (
    SELECT num_etud
    FROM notes N1, cours C1, enseignants En1
    WHERE En1.nom_ens = 'BEKKHOUCHA'
    AND N1.num_cours = C1.num_cours
    AND C1.num_ens = En1.num_ens
    AND (note1 + note2) / 2 < 10
);

-- Requête 12 : Compter le nombre d'étudiants ayant une moyenne supérieure ou égale à 10.
SELECT COUNT(*)
FROM etudiants
WHERE num_etud IN (
    SELECT num_etud FROM notes
    GROUP BY num_etud
    HAVING AVG((note1 + note2) / 2) >= 10
);
