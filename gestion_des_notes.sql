
-- Création de la base de données
CREATE DATABASE gestion_etudiants;
USE gestion_etudiants;

-- Création des tables

CREATE TABLE etudiants (
    num_etu         INT PRIMARY KEY AUTO_INCREMENT,
    nom_etu         VARCHAR(26),
    date_naiss_etu  DATE,
    sexe_etu        ENUM('H','F'),
    faculte         INT
);

CREATE TABLE enseignants (
    num_ens         INT PRIMARY KEY AUTO_INCREMENT,
    nom_ens         VARCHAR(26),
    grade           INT,
    anciennte       INT
);

CREATE TABLE cours (
    num_cours       INT PRIMARY KEY AUTO_INCREMENT,
    intitule        VARCHAR(30),
    heures_cours    INT,
    heures_tp       INT,
    num_ens         INT
);

CREATE TABLE notes (
    num_etu         INT,
    num_cours       INT,
    note            FLOAT CHECK(note >= 0 AND note <= 20),
    PRIMARY KEY (num_etu, num_cours)
);

CREATE TABLE facultes (
    code_fac INT    PRIMARY KEY AUTO_INCREMENT,
    libelle_fac     VARCHAR(45)
);

-- Ajouter les contraintes des clés étrangères

ALTER TABLE cours ADD CONSTRAINT fk_cours_enseignants FOREIGN KEY (num_ens) REFERENCES enseignants (num_ens) ON DELETE CASCADE;
ALTER TABLE notes ADD CONSTRAINT fk_notes_etudiants FOREIGN KEY (num_etu) REFERENCES etudiants (num_etu) ON DELETE CASCADE;
ALTER TABLE notes ADD CONSTRAINT fk_notes_cours FOREIGN KEY (num_cours) REFERENCES cours (num_cours) ON DELETE CASCADE;
ALTER TABLE etudiants ADD CONSTRAINT fk_etudiants_faculte FOREIGN KEY (faculte) REFERENCES facultes (code_fac) ON DELETE CASCADE;

-- Les requêtes SQL de l'exercice

-- Q1: Le nombre des étudiants validés
SELECT COUNT(*) 'Total'
FROM etudiants
WHERE num_etu IN (
    SELECT num_etu
    FROM notes
    GROUP BY num_etu
    HAVING AVG(note) >= 10
);

-- Q2: le num et le nom des étudiants n'ayant pas de note en BDD
SELECT num_etu, nom_etu
FROM etudiants
WHERE num_etu NOT IN (
    SELECT N.num_etu
    FROM notes N, cours C
    WHERE N.num_cours = C.num_cours
    AND C.intitule = "BDD"
);

-- Q3: le nom et l'age et le sexe des étudiants qui ont une note en informatique > à la moyenne de la classe
SELECT E.nom_etu, E.date_naiss_etu, E.sexe_etu
FROM etudiants E, notes N, cours C
WHERE C.intitule = "informatique"
AND N.num_cours = C.num_cours
AND E.num_etu = N.num_etu 
AND N.note >= (
    SELECT AVG(N1.note)
    FROM notes N1, cours C1
    WHERE C1.intitule = "informatique"
    AND N1.num_cours = C1.num_cours
);

-- Q4: les notes des étudiants de fst qu'ont suivi tous les modules de M.kabil
SELECT n.note
FROM notes n, etudiants e, facultes f1
WHERE n.num_etu = e.num_etu
AND e.faculte = f1.code_fac
AND f1.libelle_fac = 'fst'
AND n.num_etu IN (
    SELECT n1.num_etu
    FROM cours c1, notes n1
    WHERE c1.num_cours = n1.num_cours
    AND n1.num_cours IN (
        SELECT c2.num_cours
        FROM cours c2, enseignants e2
        WHERE c2.num_ens = e2.num_ens
        AND e2.nom_ens = 'M.kabil'
    )
    GROUP BY n1.num_etu
    HAVING COUNT(*) = (
        SELECT COUNT(*)
        FROM cours c3, enseignants e3
        WHERE c3.num_ens = e3.num_ens
        AND e3.nom_ens = 'M.kabil'
    )
);

-- Q5: le cours suivi par le plus grand nombre d'étudiants
SELECT intitule
FROM cours
WHERE num_cours IN (
    SELECT num_cours
    FROM notes 
    GROUP BY num_cours
    HAVING COUNT(num_etu) >= ALL (
        SELECT COUNT(num_etu)
        FROM notes
        GROUP BY num_cours
    )
);

-- Q6: nom des étudiants qui ont suivi BDD et java et qui ont obtenu plus de 15 dans ces modules
SELECT nom_etu
FROM etudiants
WHERE num_etu IN (
    SELECT n.num_etu 
    FROM cours c, notes n 
    WHERE n.note > 15 
    AND c.num_cours = n.num_cours
    AND c.intitule = 'BDD'
)
AND num_etu IN (
    SELECT n.num_etu 
    FROM cours c, notes n 
    WHERE n.note > 15 
    AND c.num_cours = n.num_cours
    AND c.intitule = 'java'
);

-- Q7: le nom de l'enseignant qui a le plus petit volume horaire
SELECT nom_ens
FROM enseignants
WHERE num_ens IN (
    SELECT num_ens
    FROM cours 
    GROUP BY num_ens
    HAVING (SUM(heures_cours) + SUM(heures_tp)) <= ALL (
        SELECT (SUM(heures_cours) + SUM(heures_tp))
        FROM cours 
        GROUP BY num_ens
    )
);

-- Q8: les cours qui ont le même horaire de cours et de TP
SELECT c1.num_cours
FROM cours c1, cours c2
WHERE c1.num_cours < c2.num_cours
AND c1.heures_cours = c2.heures_cours
AND c1.heures_tp = c2.heures_tp;

-- Q9: les étudiants qui ont des notes plus grandes que les notes de "Ali" dans tous les modules suivis par "Ali"
SELECT nom_etu
FROM etudiants
WHERE num_etu IN (
    SELECT n2.num_etu
    FROM notes n1, notes n2
    WHERE n1.num_etu IN (
        SELECT num_etu
        FROM etudiants
        WHERE nom_etu = 'Ali'
    )
    AND n1.num_etu != n2.num_etu
    AND n1.num_cours = n2.num_cours
    AND n1.note < n2.note
    GROUP BY n2.num_etu
    HAVING COUNT(*) = (
        SELECT COUNT(*)
        FROM notes
        WHERE num_etu IN (
            SELECT num_etu
            FROM etudiants
            WHERE nom_etu = 'Ali'
        )
    )
);
