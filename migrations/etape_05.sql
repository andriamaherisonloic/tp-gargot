-- Etape 05 :
CREATE TABLE serveur (
    id_serveur INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom        VARCHAR(100) NOT NULL
);

CREATE TABLE table_salle (
    id_table INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero   INTEGER NOT NULL UNIQUE CHECK (numero > 0)
);

INSERT INTO serveur (nom) VALUES ('Njaka Rakoto');
INSERT INTO serveur (nom) VALUES ('Lalao Rasoa');

INSERT INTO table_salle (numero) VALUES (1);
INSERT INTO table_salle (numero) VALUES (2);
INSERT INTO table_salle (numero) VALUES (3);
INSERT INTO table_salle (numero) VALUES (4);
INSERT INTO table_salle (numero) VALUES (5);
INSERT INTO table_salle (numero) VALUES (6);
INSERT INTO table_salle (numero) VALUES (7);
INSERT INTO table_salle (numero) VALUES (8);

ALTER TABLE commande ADD id_serveur INTEGER;
ALTER TABLE commande ADD id_table   INTEGER;
ALTER TABLE commande ADD CONSTRAINT fk_commande_serveur
    FOREIGN KEY (id_serveur) REFERENCES serveur (id_serveur);
ALTER TABLE commande ADD CONSTRAINT fk_commande_table
    FOREIGN KEY (id_table) REFERENCES table_salle (id_table);

UPDATE commande SET id_serveur = (SELECT id_serveur FROM serveur WHERE nom = 'Njaka Rakoto')
 WHERE id_commande IN (1, 3, 5);
UPDATE commande SET id_serveur = (SELECT id_serveur FROM serveur WHERE nom = 'Lalao Rasoa')
 WHERE id_commande IN (2, 4);

UPDATE commande SET id_table = (SELECT id_table FROM table_salle WHERE numero = 3) WHERE id_commande = 1;
UPDATE commande SET id_table = (SELECT id_table FROM table_salle WHERE numero = 5) WHERE id_commande = 3;
UPDATE commande SET id_table = (SELECT id_table FROM table_salle WHERE numero = 1) WHERE id_commande = 4;

ALTER TABLE commande ALTER COLUMN id_serveur SET NOT NULL;
