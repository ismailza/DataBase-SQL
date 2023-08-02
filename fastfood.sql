
-- Epruve 2016-2017
-- Création de la base de données
CREATE DATABASE fastfood;
USE fastfood;

-- Création des tables
CREATE TABLE livreurs (
    n_livreur INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(26),
    prenom VARCHAR(26),
    adresse VARCHAR(40),
    phone VARCHAR(13)
);

CREATE TABLE commandes (
    n_commande INT PRIMARY KEY AUTO_INCREMENT,
    n_client INT,
    date_cmd DATE,
    n_livreur INT,
    FOREIGN KEY (n_livreur) REFERENCES livreurs (n_livreur) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE contient (
    n_commande INT,
    n_consommation INT,
    quantite INT,
    PRIMARY KEY (n_commande, n_consommation)
);

CREATE TABLE consommations (
    n_consommation INT PRIMARY KEY AUTO_INCREMENT,
    designation VARCHAR(30),
    prix_unitaire FLOAT,
    promotion INT
);

CREATE TABLE clients (
    n_client INT PRIMARY KEY AUTO_INCREMENT,
    nom_c VARCHAR(26),
    prenom_c VARCHAR(26),
    quartier VARCHAR(30),
    phone VARCHAR(13),
    age INT CHECK (age > 0)
);

-- Ajouter les contraintes des clés étrangères

ALTER TABLE contient ADD CONSTRAINT fk_consommations FOREIGN KEY (n_consommation) REFERENCES consommations (n_consommation) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE contient ADD CONSTRAINT fk_commandes FOREIGN KEY (n_commande) REFERENCES commandes (n_commande) ON DELETE CASCADE ON UPDATE CASCADE;


-- Q1: Nom des consommations commandées par le client "Ali" le 12 janvier 2017.
SELECT designation FROM consommations
WHERE n_consommation IN (
    SELECT n_consommation FROM contient C, commandes Cmd
    WHERE C.n_commande = Cmd.n_commande
    AND date_cmd = "2017-01-12"
    AND n_client IN (
        SELECT n_client FROM clients
        WHERE nom_c = "Ali"
    )
);

-- Q2: Les noms et prénoms des clients qui ont commandé à la fois "Pizza" (4 quantités) et "Jus Orange" (2 quantités).
SELECT nom_c, prenom_c FROM clients
WHERE n_client IN (
    SELECT n_client FROM commandes
    WHERE n_commande IN (
        SELECT n_commande FROM contient C1, consommations Cmt1
        WHERE C1.n_consommation = Cmt1.n_consommation
        AND designation = "Pizza"
        AND quantite = 4
        INTERSECT
        SELECT n_commande FROM contient C2, consommations Cmt2
        WHERE C2.n_consommation = Cmt2.n_consommation
        AND designation = "Jus_Orange"
        AND quantite = 2
    )
);

-- Q3: Les livreurs qui n'ont pas livré de commandes pour les clients du quartier "Alalia".
SELECT * FROM livreurs 
WHERE n_livreur NOT IN (
    SELECT n_livreur FROM commandes
    WHERE n_client IN (
        SELECT n_client FROM clients
        WHERE quartier = "Alalia"
    )
);

-- Q4: Le nom des livreurs et le nombre de commandes qu'ils ont livrées.
SELECT nom, COUNT(*) FROM commandes Cmd, livreurs L
WHERE Cmd.n_livreur = L.n_livreur
GROUP BY Cmd.n_livreur, nom;

-- Q5: Les noms des clients ayant commandé la pizza au moins une fois en 2016.
SELECT nom_c FROM clients
WHERE n_client IN (
    SELECT n_client FROM commandes
    WHERE YEAR(date_cmd) = '2016'
    AND n_commande IN (
        SELECT n_commande FROM contient C1, consommations Cmt1
        WHERE C1.n_consommation = Cmt1.n_consommation
        AND designation = "Pizza"
    )
    GROUP BY n_client
    HAVING COUNT(*) >= ALL (
        SELECT COUNT(*) FROM commandes
        WHERE YEAR(date_cmd) = '2016'
        AND n_commande IN (
            SELECT n_commande FROM contient C1, consommations Cmt1
            WHERE C1.n_consommation = Cmt1.n_consommation
            AND designation = "Pizza"
            GROUP BY n_client
        )
    )
);

-- Q6: Le numéro de commande, le nom du client, la date de la commande et le montant total de chaque commande.
SELECT Cmd.n_commande, nom_c, date_cmd, SUM(prix_unitaire*quantite) AS 'Prix'
FROM clients Cl, commandes Cmd, contient Ct, consommations Cmt
WHERE Cl.n_client = Cmd.n_client
AND Cmd.n_commande = Ct.n_commande
AND Ct.n_consommation = Cmt.n_consommation
GROUP BY Cmd.n_commande, Cl.n_client, nom_c, date_cmd;

-- Q7: Les noms et prénoms des clients et le montant total des commandes passées en 2016, pour chaque client, avec un montant supérieur ou égal à toutes les autres commandes.
SELECT nom_c, prenom_c, SUM(prix_unitaire*quantite) AS 'Prix'
FROM clients Cl, commandes Cmd, contient Ct, consommations Cmt
WHERE Cl.n_client = Cmd.n_client
AND Cmd.n_commande = Ct.n_commande
AND Ct.n_consommation = Cmt.n_consommation
AND YEAR(date_cmd) = '2016'
GROUP BY Cl.n_client, nom_c, prenom_c
HAVING Prix >= ALL (
    SELECT SUM(prix_unitaire*quantite)
    FROM commandes Cmd1, contient Ct1, consommations Cmt1
    WHERE Cmd1.n_commande = Ct1.n_commande
    AND Ct1.n_consommation = Cmt1.n_consommation
    AND YEAR(date_cmd) = '2016'
    GROUP BY n_client
);

-- Q8: Les livreurs qui ont livré des commandes à tous les clients.
SELECT * FROM livreurs
WHERE n_livreur IN (
    SELECT n_livreur FROM commandes
    GROUP BY n_livreur
    HAVING COUNT(DISTINCT n_client) = (
        SELECT COUNT(*) FROM clients
    )
);

-- Q9: Les noms des clients qui n'ont pas commandé de consommation avec une promotion de moins de 25%.
SELECT nom_c FROM clients
WHERE n_client NOT IN (
    SELECT n_client FROM commandes
    WHERE n_commande IN (
        SELECT n_commande FROM contient Ct, consommations Cmt
        WHERE Ct.n_consommation = Cmt.n_consommation
        AND promotion < 25
    )
);

-- Q10: La moyenne d'âge des clients qui ont commandé à la fois des hamburgers et des frites.
SELECT AVG(age) AS 'Moyenne_Age'
FROM clients
WHERE n_client IN (
    SELECT n_client FROM commandes
    WHERE n_commande IN (
        SELECT n_commande FROM contient ct1, consommations cmt1
        WHERE ct1.n_consommation = cmt1.n_consommation
        AND designation = 'hamburger'
        INTERSECT 
        SELECT n_commande FROM contient ct2, consommations cmt2
        WHERE ct2.n_consommation = cmt2.n_consommation
        AND designation = 'frites'
    )
);

-- Q11


-- Q12: Les désignations des consommations dont la somme des quantités dans la table "Contient" est inférieure ou égale à la somme des quantités de toutes les autres consommations.
SELECT designation FROM consommations csm, contient ct
WHERE csm.n_consommation = ct.n_consommation
GROUP BY csm.n_consommation
HAVING SUM(quantite) <= ALL (
    SELECT SUM(quantite) FROM contient ct1
    GROUP BY n_consommation
);
