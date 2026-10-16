-- Etape 02 : 
CREATE TABLE categorie (
    id_categorie INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    libelle      VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO categorie (libelle) VALUES ('Plat malagasy');
INSERT INTO categorie (libelle) VALUES ('Plat chinois');
INSERT INTO categorie (libelle) VALUES ('Soupe');
INSERT INTO categorie (libelle) VALUES ('Dessert et goûter');
INSERT INTO categorie (libelle) VALUES ('Boisson');
INSERT INTO categorie (libelle) VALUES ('Entrée');

ALTER TABLE plat ADD id_categorie INTEGER;
ALTER TABLE plat ADD CONSTRAINT fk_plat_categorie
    FOREIGN KEY (id_categorie) REFERENCES categorie (id_categorie);

UPDATE plat SET id_categorie = (SELECT id_categorie FROM categorie WHERE libelle = 'Plat malagasy')
 WHERE nom IN ('Romazava', 'Ravitoto sy henakisoa', 'Akoho sy voanio');
UPDATE plat SET id_categorie = (SELECT id_categorie FROM categorie WHERE libelle = 'Plat chinois')
 WHERE nom = 'Mi sao';
UPDATE plat SET id_categorie = (SELECT id_categorie FROM categorie WHERE libelle = 'Soupe')
 WHERE nom = 'Soupe chinoise';
UPDATE plat SET id_categorie = (SELECT id_categorie FROM categorie WHERE libelle = 'Dessert et goûter')
 WHERE nom = 'Mofo gasy (les 4)';
UPDATE plat SET id_categorie = (SELECT id_categorie FROM categorie WHERE libelle = 'Boisson')
 WHERE nom = 'Ranon''ampango';


ALTER TABLE plat ALTER COLUMN id_categorie SET NOT NULL;
