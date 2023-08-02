-- Creation de la base de données
CREATE DATABASE jeu_equipe DEFAULT CHARACTER SET = 'utf8mb4';
USE jeu_equipe;

-- Création des tables
CREATE TABLE pays (
    code_pays       INT PRIMARY KEY AUTO_INCREMENT,
    pays            VARCHAR(20),
    continent       VARCHAR(20)
);

CREATE TABLE athletes (
    num_athlete     INT PRIMARY KEY,
    nom_athlete     VARCHAR(20),
    prenom_athlete  VARCHAR(20),
    code_pays       INT
);

CREATE TABLE disciplines (
    nom_discipline  VARCHAR(20) PRIMARY KEY,
    date_debut      DATE,
    date_fin        DATE
);

CREATE TABLE epreuves (
    nom_discipline  VARCHAR(20),
    num_epreuve     INT,
    nom_epreuve     VARCHAR(30),
    sexe            VARCHAR(10),
    PRIMARY KEY (nom_discipline, num_epreuve)
);

CREATE TABLE medailles (
    nom_discipline  VARCHAR(20),
    num_epreuve     INT,
    num_athlete     INT,
    couleur         VARCHAR(10),
    PRIMARY KEY (nom_discipline, num_epreuve, num_athlete)
);

-- Ajouter les contraintes des clés étrangères
ALTER TABLE athletes ADD CONSTRAINT fk_athletes_pays FOREIGN KEY (code_pays) REFERENCES pays (code_pays) ON DELETE CASCADE;
ALTER TABLE epreuves ADD CONSTRAINT fk_epreuves_disciplines FOREIGN KEY (nom_discipline) REFERENCES disciplines (nom_discipline) ON DELETE CASCADE;
ALTER TABLE medailles ADD CONSTRAINT fk_medailles_disciplines FOREIGN KEY (nom_discipline, num_epreuve) REFERENCES epreuves (nom_discipline, num_epreuve) ON DELETE CASCADE;
ALTER TABLE medailles ADD CONSTRAINT fk_medailles_athletes FOREIGN KEY (num_athlete) REFERENCES athletes (num_athlete) ON DELETE CASCADE;

-- Les requêtes SQL de l'exercice

-- Q1- Les noms des athlètes qui ont eu des médailles d'Or en discipline Natation
SELECT nom_athlete FROM athletes
WHERE num_athlete IN (SELECT num_athlete FROM medailles
                      WHERE couleur = 'Or'
                      AND nom_discipline = 'Natation');

-- Q2- Le nom des épreuves où l'athlète Ali a eu une médaille
SELECT nom_epreuve FROM epreuves
WHERE num_epreuve IN (SELECT num_epreuve FROM medailles
                      WHERE num_athlete IN (SELECT num_athlete FROM athletes
                                             WHERE nom_athlete = 'Ali'));

-- Q3- Le pays qui a eu des médailles dans toutes les disciplines
SELECT * FROM pays
WHERE code_pays IN (SELECT code_pays FROM athletes NATURAL JOIN medailles
                    GROUP BY code_pays
                    HAVING COUNT(DISTINCT nom_discipline) = (SELECT COUNT(*) FROM disciplines));

-- Q4- Le nombre d'épreuves par discipline
SELECT nom_discipline, COUNT(*) FROM epreuves
GROUP BY nom_discipline;

-- Q5- L'athlète qui a eu le plus grand nombre de médailles
SELECT * FROM athletes
WHERE num_athlete IN (SELECT num_athlete FROM medailles
                      GROUP BY num_athlete
                      HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM medailles
                                              GROUP BY num_athlete));

-- Q6- La discipline qui a duré le plus grand temps
SELECT nom_discipline, date_debut, date_fin, DATEDIFF(date_fin, date_debut) AS 'Nb_Jours' 
FROM disciplines
WHERE DATEDIFF(date_fin, date_debut) >= ALL (SELECT DATEDIFF(date_fin, date_debut) 
                                            FROM disciplines);


-- Insertion des données

-- Insert data into 'pays' table
INSERT INTO pays (pays, continent) VALUES
    ('France', 'Europe'),
    ('USA', 'North America'),
    ('Japan', 'Asia');

-- Insert data into 'athletes' table
INSERT INTO athletes (num_athlete, nom_athlete, prenom_athlete, code_pays) VALUES
    (1, 'Smith', 'John', 1),
    (2, 'Johnson', 'Emma', 2),
    (3, 'Ali', 'Ahmed', 3),
    (4, 'Lee', 'Soo', 3);

-- Insert data into 'disciplines' table
INSERT INTO disciplines (nom_discipline, date_debut, date_fin) VALUES
    ('Swimming', '2023-07-01', '2023-07-10'),
    ('Running', '2023-07-05', '2023-07-15'),
    ('Cycling', '2023-07-08', '2023-07-18');

-- Insert data into 'epreuves' table
INSERT INTO epreuves (nom_discipline, num_epreuve, nom_epreuve, sexe) VALUES
    ('Swimming', 1, '50m Freestyle', 'Male'),
    ('Swimming', 2, '100m Backstroke', 'Female'),
    ('Running', 1, 'Marathon', 'Male'),
    ('Running', 2, '100m Sprint', 'Female'),
    ('Cycling', 1, 'Road Race', 'Male'),
    ('Cycling', 2, 'BMX Racing', 'Male'),
    ('Cycling', 3, 'BMX Racing', 'Female');

-- Insert data into 'medailles' table
INSERT INTO medailles (nom_discipline, num_epreuve, num_athlete, couleur) VALUES
    ('Swimming', 1, 1, 'Gold'),
    ('Swimming', 2, 2, 'Silver'),
    ('Running', 1, 3, 'Bronze'),
    ('Running', 2, 3, 'Gold'),
    ('Cycling', 1, 2, 'Gold'),
    ('Cycling', 2, 4, 'Silver'),
    ('Cycling', 3, 3, 'Gold');
