-- Étape 07 : 
ALTER TABLE ligne_commande ADD prix_unitaire INTEGER;
UPDATE ligne_commande
   SET prix_unitaire = (SELECT p.prix FROM plat p WHERE p.id_plat = ligne_commande.id_plat);
ALTER TABLE ligne_commande ALTER COLUMN prix_unitaire SET NOT NULL;
ALTER TABLE ligne_commande ADD CONSTRAINT ck_lc_prix_unitaire CHECK (prix_unitaire >= 0);

CREATE TABLE prix_plat (
    id_plat    INTEGER NOT NULL,
    date_debut DATE    NOT NULL,
    prix       INTEGER NOT NULL CHECK (prix >= 0),
    PRIMARY KEY (id_plat, date_debut),
    CONSTRAINT fk_prix_plat_plat FOREIGN KEY (id_plat) REFERENCES plat (id_plat)
);
INSERT INTO prix_plat (id_plat, date_debut, prix)
    SELECT id_plat, DATE '2026-01-01', prix FROM plat;

UPDATE plat SET prix = 7500 WHERE nom = 'Romazava';
INSERT INTO prix_plat (id_plat, date_debut, prix)
    SELECT id_plat, DATE '2026-10-15', 7500 FROM plat WHERE nom = 'Romazava';

INSERT INTO commande (date_commande, id_client, id_serveur, id_table)      
    SELECT TIMESTAMP '2026-10-16 12:20:00', NULL, s.id_serveur, t.id_table
    FROM serveur s, table_salle t
    WHERE s.nom = 'Njaka Rakoto' AND t.numero = 2;
INSERT INTO ligne_commande (id_commande, id_plat, quantite, prix_unitaire)
    SELECT 6, id_plat, 1, 7500 FROM plat WHERE nom = 'Romazava';
