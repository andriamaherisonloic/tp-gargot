-- Étape 07 : « Au 15 octobre, le romazava passe de 7 000 à 7 500 Ar. Mais mes anciennes factures doivent
--              garder l'ancien prix ! »
-- Ordre important : (1) figer les prix déjà facturés dans ligne_commande, (2) créer l'historique,
--                   (3) seulement ensuite appliquer l'augmentation.

-- 1) Prix facturé mémorisé dans chaque ligne de commande
ALTER TABLE ligne_commande ADD prix_unitaire INTEGER;
UPDATE ligne_commande
   SET prix_unitaire = (SELECT p.prix FROM plat p WHERE p.id_plat = ligne_commande.id_plat);
ALTER TABLE ligne_commande ALTER COLUMN prix_unitaire SET NOT NULL;
-- Oracle : ALTER TABLE ligne_commande MODIFY (prix_unitaire NOT NULL);
ALTER TABLE ligne_commande ADD CONSTRAINT ck_lc_prix_unitaire CHECK (prix_unitaire >= 0);

-- 2) Bonus : historique des prix de chaque plat
CREATE TABLE prix_plat (
    id_plat    INTEGER NOT NULL,
    date_debut DATE    NOT NULL,
    prix       INTEGER NOT NULL CHECK (prix >= 0),
    PRIMARY KEY (id_plat, date_debut),
    CONSTRAINT fk_prix_plat_plat FOREIGN KEY (id_plat) REFERENCES plat (id_plat)
);
-- Prix initiaux (date de début = hypothèse de test : ouverture de la carte au 1er janvier 2026)
INSERT INTO prix_plat (id_plat, date_debut, prix)
    SELECT id_plat, DATE '2026-01-01', prix FROM plat;

-- 3) Augmentation du romazava au 15 octobre
UPDATE plat SET prix = 7500 WHERE nom = 'Romazava';
INSERT INTO prix_plat (id_plat, date_debut, prix)
    SELECT id_plat, DATE '2026-10-15', 7500 FROM plat WHERE nom = 'Romazava';

-- 4) Nouvelle commande après l'augmentation : elle est facturée au nouveau prix (7 500 Ar), les anciennes restent à 7 000 Ar
INSERT INTO commande (date_commande, id_client, id_serveur, id_table)       -- identifiant 6
    SELECT TIMESTAMP '2026-10-16 12:20:00', NULL, s.id_serveur, t.id_table
    FROM serveur s, table_salle t
    WHERE s.nom = 'Njaka Rakoto' AND t.numero = 2;
INSERT INTO ligne_commande (id_commande, id_plat, quantite, prix_unitaire)
    SELECT 6, id_plat, 1, 7500 FROM plat WHERE nom = 'Romazava';
