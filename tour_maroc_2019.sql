
-- Création de la base de données

CREATE DATABASE tour_maroc_2019;
USE tour_maroc_2019;

-- Création des tables

CREATE TABLE equipes (
    code_equipe INT PRIMARY KEY AUTO_INCREMENT,
    nom_equipe VARCHAR(30),
    directeur_sportif VARCHAR(30)
);

CREATE TABLE pays (
    code_pays INT PRIMARY KEY AUTO_INCREMENT,
    nom_pays VARCHAR(15)
);

CREATE TABLE coureurs (
    num_coureur INT PRIMARY KEY AUTO_INCREMENT,
    nom_coureur VARCHAR(30),
    code_equipe INT,
    code_pays INT,
    FOREIGN KEY (code_equipe) REFERENCES equipes (code_equipe) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (code_pays) REFERENCES pays (code_pays) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE type_etapes (
    code_type INT PRIMARY KEY AUTO_INCREMENT,
    libelle_type VARCHAR(30)
);

CREATE TABLE etapes (
    num_etape INT PRIMARY KEY AUTO_INCREMENT,
    date_etape DATE,
    ville_dep VARCHAR(20),
    ville_arr VARCHAR(20),
    nb_km INT,
    code_type INT,
    FOREIGN KEY (code_type) REFERENCES type_etapes (code_type) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE participer (
    num_coureur INT,
    num_etape INT,
    temps_realise FLOAT,
    PRIMARY KEY (num_coureur, num_etape),
    FOREIGN KEY (num_coureur) REFERENCES coureurs (num_coureur) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (num_etape) REFERENCES etapes (num_etape) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Requêtes SQL

-- Q1: Sélectionner le numéro du coureur, le nom du coureur et le nom du pays des coureurs appartenant à l'équipe "Festina".
SELECT num_coureur, nom_coureur, nom_pays
FROM coureurs Cr, pays P
WHERE Cr.code_pays = P.code_pays
AND code_equipe IN (
    SELECT code_equipe FROM equipes
    WHERE nom_equipe = 'Festina'
);

-- Q2: Sélectionner la ville de départ, la ville d'arrivée et le nombre de kilomètres de toutes les étapes dont le nombre de kilomètres est inférieur ou égal à tous les autres.
SELECT ville_dep, ville_arr, nb_km FROM etapes
WHERE nb_km <= ALL (
    SELECT nb_km FROM etapes
);

-- Q3: Compter le nombre de pays distincts dans la table "coureurs".
SELECT COUNT(DISTINCT code_pays) FROM coureurs;

-- Q4: Sélectionner toutes les équipes ayant exactement un seul pays représenté parmi leurs coureurs.
SELECT * FROM equipes 
WHERE code_equipe IN (
    SELECT code_equipe FROM coureurs
    GROUP BY code_equipe
    HAVING COUNT(DISTINCT code_pays) = 1
);

-- Q5: Sélectionner tous les pays dont le code pays est associé à un nombre de coureurs supérieur ou égal à tous les autres pays.
SELECT * FROM pays
WHERE code_pays IN (
    SELECT code_pays FROM coureurs
    GROUP BY code_pays
    HAVING COUNT(*) >= ALL (
        SELECT COUNT(*) FROM coureurs
        GROUP BY code_pays
    )
);

-- Q6: Calculer la somme totale du nombre de kilomètres de toutes les étapes.
SELECT SUM(nb_km) FROM etapes;

-- Q7: Calculer la somme totale du nombre de kilomètres pour toutes les étapes dont le type est "Haute montagne".
SELECT SUM(nb_km) FROM etapes
WHERE code_type IN (
    SELECT code_type FROM type_etapes
    WHERE libelle_type = 'Haute montagne'
);

-- Q8: Sélectionner le nom du coureur des coureurs n'ayant pas participé à une étape de type "Haute montagne".
SELECT nom_coureur FROM coureurs
WHERE num_coureur NOT IN (
    SELECT num_coureur FROM participer
    WHERE num_etape IN (
        SELECT num_etape
        FROM etapes E, type_etapes TE
        WHERE E.code_type = TE.code_type 
        AND libelle_type = 'Haute montagne'
    )
);

-- Q9: Sélectionner le nom du coureur des coureurs ayant participé à toutes les étapes.
SELECT nom_coureur FROM coureurs 
WHERE num_coureur IN (
    SELECT num_coureur FROM participer
    GROUP BY num_coureur
    HAVING COUNT(*) = (
        SELECT COUNT(*) FROM etapes
    )
);

-- Q10: Sélectionner le nom du coureur, le code de l'équipe, le code du pays et la somme des temps réalisés de chaque coureur pour les 13 premières étapes. Trier les résultats par classement.
SELECT nom_coureur, code_equipe, code_pays, SUM(temps_realise) AS classement
FROM coureurs Cr, participer P
WHERE Cr.num_coureur = P.num_coureur
AND num_etape <= 13
GROUP BY Cr.num_coureur, nom_coureur, code_equipe, code_pays
ORDER BY classement;

-- Q11: Sélectionner le nom de l'équipe et la somme des temps réalisés de chaque équipe pour les 13 premières étapes. Trier les résultats par classement.
SELECT nom_equipe, SUM(temps_realise) AS classement
FROM equipes Eq, coureurs Cr, participer P
WHERE Eq.code_equipe = Cr.code_equipe
AND Cr.num_coureur = P.num_coureur
AND num_etape <= 13
GROUP BY Eq.code_equipe, nom_equipe
ORDER BY classement;

-- Q12: Sélectionner le nom du coureur des coureurs ayant réalisé le meilleur temps dans les étapes de type "Contre la montre" et "Haute montagne".
SELECT nom_coureur FROM coureurs Cr, participer P
WHERE Cr.num_coureur = P.num_coureur
AND temps_realise <= ALL (
    SELECT temps_realise
    FROM participer P1, etapes E1, type_etapes TE1
    WHERE P1.num_etape = E1.num_etape
    AND E1.code_type = TE1.code_type
    AND libelle_type = 'Contre la montre'
)
AND temps_realise <= ALL (
    SELECT temps_realise
    FROM participer P2, etapes E2, type_etapes TE2
    WHERE P2.num_etape = E2.num_etape
    AND E2.code_type = TE2.code_type
    AND libelle_type = 'Haute montagne'
);

-- Q13: Sélectionner le nom de l'équipe et la somme des temps réalisés de chaque équipe. Comparer la somme des temps réalisés de chaque équipe avec la somme des temps réalisés des équipes.
SELECT nom_equipe, SUM(temps_realise) AS classement
FROM equipes E, coureurs Cr, participer P
WHERE E.code_equipe = Cr.code_equipe
AND Cr.num_coureur = P.num_coureur
GROUP BY E.code_equipe, nom_equipe
HAVING classement <= ALL (
    SELECT SUM(temps_realise) 
    FROM participer P1, coureurs Cr1
    WHERE P1.num_coureur = Cr1.num_coureur
    GROUP BY code_equipe
);

-- Q14: Sélectionner le code de l'équipe, le numéro de l'étape et la somme des temps réalisés de chaque équipe pour chaque étape. Trier les résultats par classement.
SELECT code_equipe, num_etape, SUM(temps_realise) AS classement
FROM participer P, coureurs Cr
WHERE P.num_coureur = Cr.num_coureur
GROUP BY code_equipe, num_etape
ORDER BY classement;
