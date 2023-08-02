
-- Création de la base de données
CREATE DATABASE cinema;
USE cinema;

-- Création des tables

CREATE TABLE acteurs (
    n_acteur INT PRIMARY KEY AUTO_INCREMENT,
    prenom VARCHAR(30),
    nom VARCHAR(30),
    date_naiss DATE,
    nationnalite VARCHAR(15)
);

CREATE TABLE realisateurs (
    n_realisateur INT PRIMARY KEY AUTO_INCREMENT,
    prenom VARCHAR(30),
    nom VARCHAR(30),
    date_naiss DATE,
    nationnalite VARCHAR(15)
);

CREATE TABLE films (
    n_film INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(30),
    categorie VARCHAR(30)
);

CREATE TABLE jouer (
    n_acteur INT,
    n_film INT,
    PRIMARY KEY (n_acteur, n_film),
    FOREIGN KEY (n_acteur) REFERENCES acteurs (n_acteur) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (n_film) REFERENCES films (n_film) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE realiser (
    n_film INT,
    n_realisateur INT,
    PRIMARY KEY (n_film, n_realisateur),
    FOREIGN KEY (n_film) REFERENCES films (n_film) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (n_realisateur) REFERENCES realisateurs (n_realisateur) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE salles_cine (
    n_salle INT PRIMARY KEY AUTO_INCREMENT,
    nom_salle VARCHAR(30),
    capacite INT,
    ville VARCHAR(20),
    adresse VARCHAR(45)
);

CREATE TABLE projections (
    n_film INT,
    n_salle INT,
    date_proj DATE,
    heure_proj TIME,
    version VARCHAR(12),
    PRIMARY KEY (n_film, n_salle, date_proj, heure_proj),
    FOREIGN KEY (n_film) REFERENCES films (n_film) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (n_salle) REFERENCES salles_cine (n_salle) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Ajouter les contraintes des clés étrangères
ALTER TABLE jouer ADD CONSTRAINT fk_act FOREIGN KEY (n_acteur) REFERENCES acteurs (n_acteur) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE jouer ADD CONSTRAINT fk_film FOREIGN KEY (n_film) REFERENCES films (n_film) ON DELETE CASCADE ON UPDATE CASCADE;

-- Les requêtes SQL de l'exercice

-- Q1: Sélectionner les acteurs qui ont joué dans des films de la catégorie "Science fiction".
SELECT * FROM acteurs NATURAL JOIN jouer
WHERE n_film IN (
    SELECT n_film FROM films
    WHERE categorie = "Science fiction"
);

-- Q2: Sélectionner les réalisateurs qui ont réalisé uniquement des films de la catégorie "Comédie".
-- Methode 1:
SELECT * FROM realisateurs 
WHERE n_realisateur IN (
    SELECT n_realisateur 
    FROM realiser NATURAL JOIN films
    WHERE categorie = "Comedie"
    EXCEPT 
    SELECT n_realisateur 
    FROM realiser NATURAL JOIN films
    WHERE categorie != "Comedie"
);
-- Methode 2:
SELECT * FROM realisateurs 
WHERE n_realisateur IN (
    SELECT n_realisateur 
    FROM realiser NATURAL JOIN films
    WHERE categorie = "Comedie"
    AND n_realisateur NOT IN (
        SELECT n_realisateur 
        FROM realiser NATURAL JOIN films
        WHERE categorie != "Comedie"
    )
);
-- Methode 3:
SELECT * FROM realisateurs
WHERE EXISTS (
    SELECT * FROM realiser R1 NATURAL JOIN films
    WHERE categorie = 'Comedie'
    AND NOT EXISTS (
        SELECT * 
        FROM realiser R2 NATURAL JOIN films
        WHERE categorie != 'Comedie'
        AND R1.n_realisateur = R2.n_realisateur
    )
);

-- Q3: Calculer la moyenne des capacités des salles de cinéma pour chaque ville.
SELECT ville , AVG(capacite)
FROM salles_cine
GROUP BY ville;

-- Q4: Sélectionner les acteurs qui ont joué dans tous les films réalisés par le réalisateur Steven Spielberg.
SELECT * FROM acteurs 
WHERE n_acteur IN (
    SELECT n_acteur
    FROM jouer NATURAL JOIN realiser
    WHERE n_realisateur = (
        SELECT n_realisateur FROM realisateurs
        WHERE prenom = 'Steven'
        AND nom = 'Spielberg'
    )
    GROUP BY n_acteur
    HAVING COUNT(*) = (
        SELECT COUNT(*)
        FROM realiser NATURAL JOIN realisateurs
        WHERE prenom = 'Steven'
        AND nom = 'Spielberg'
    )
);

-- Q5: Afficher le nombre de films réalisés par chaque réalisateur pour chaque catégorie.
SELECT nom, categorie, COUNT(*) AS 'Nombre de films'
FROM realisateurs NATURAL JOIN realiser NATURAL JOIN films
GROUP BY nom, categorie;

-- Q6: Sélectionner les salles de cinéma à Casablanca où le film "La leçon de piano" a été projeté en version anglaise le 03 mars 2018.
SELECT * FROM salles_cine 
WHERE ville = 'Casablanca'
AND n_salle IN (
    SELECT n_salle FROM projections
    WHERE n_film = (
        SELECT n_film FROM films
        WHERE titre = 'La lecon de piano'
    )
    AND date_proj = '2018-03-03'
    AND version = 'Anglaise'
);

-- Q7: Sélectionner les acteurs qui ont joué dans chaque film avec leur nom, prénom, numéro du film, titre et catégorie du film.
SELECT nom, prenom, n_film, titre, categorie
FROM acteurs NATURAL JOIN jouer NATURAL JOIN films
GROUP BY nom, prenom, n_film, titre, categorie;

-- Q8: Sélectionner les acteurs qui ont joué dans au moins 10 films de la catégorie "Policier".
SELECT * FROM acteurs
WHERE n_acteur IN (
    SELECT n_acteur FROM jouer
    WHERE n_film IN (
        SELECT n_film FROM films
        WHERE categorie = 'Policier'
    )
    GROUP BY n_acteur
    HAVING COUNT(*) >= 10
);

-- Q9: Sélectionner les salles de cinéma où la version arabe des films a été projetée le plus grand nombre de fois.
SELECT * FROM salles_cine
WHERE n_salle IN (
    SELECT n_salle FROM projections
    WHERE version = 'Arabe'
    GROUP BY n_salle
    HAVING COUNT(DISTINCT n_film) >= ALL (
        SELECT COUNT(DISTINCT n_film)
        FROM projections
        WHERE version = 'Arabe'
        GROUP BY n_salle
    )
);

-- Q10: Sélectionner les acteurs qui n'ont pas joué dans des films projetés dans la salle "La renaissance" à Rabat.
SELECT * FROM acteurs
WHERE n_acteur NOT IN (
    SELECT n_acteur FROM jouer
    WHERE n_film IN (
        SELECT n_film FROM projections
        WHERE n_salle = (
            SELECT n_salle FROM salles_cine
            WHERE nom_salle = 'La renaissance'
            AND ville = 'Rabat'
        )
    )
);

-- Q11: Sélectionner les titres des films projetés dans la salle "La renaissance" à Rabat et dans la salle "Rialto" à Casablanca.
SELECT titre FROM films 
WHERE n_film IN (
    SELECT n_film FROM projections 
    WHERE n_salle = (
        SELECT n_salle FROM salles_cine 
        WHERE nom_salle = 'La renaissance'
        AND ville = 'Rabat'
    )
    AND (n_film, date_proj, heure_proj) IN (
        SELECT n_film, date_proj, heure_proj
        FROM projections
        WHERE n_salle = (
            SELECT n_salle FROM salles_cine
            WHERE nom_salle = 'Rialto'
            AND ville = 'Casablanca'
        )
    )
);
