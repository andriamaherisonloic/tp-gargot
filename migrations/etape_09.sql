-- Étape 09 : « Je propose un Menu Romazava à 8 000 Ar : un romazava, un ranon'ampango et des mofo gasy.
--              Le menu se commande comme un plat. »
-- Le menu est un plat (ligne de PLAT) ; association réflexive COMPOSITION_MENU entre un menu et les plats qu'il contient.

CREATE TABLE composition_menu (
    id_menu        INTEGER NOT NULL,
    id_plat_inclus INTEGER NOT NULL,
    quantite       INTEGER NOT NULL CHECK (quantite > 0),
    PRIMARY KEY (id_menu, id_plat_inclus),
    CONSTRAINT fk_cm_menu  FOREIGN KEY (id_menu)        REFERENCES plat (id_plat),
    CONSTRAINT fk_cm_inclus FOREIGN KEY (id_plat_inclus) REFERENCES plat (id_plat),
    CONSTRAINT ck_cm_pas_soi_meme CHECK (id_menu <> id_plat_inclus)   -- un menu ne peut pas se contenir lui-même
);

-- La catégorie d'un plat est obligatoire : on ajoute une catégorie « Menu »
INSERT INTO categorie (libelle) VALUES ('Menu');

-- Le menu est un plat comme les autres
INSERT INTO plat (nom, prix, id_categorie)
    SELECT 'Menu Romazava', 8000, id_categorie FROM categorie WHERE libelle = 'Menu';
INSERT INTO prix_plat (id_plat, date_debut, prix)
    SELECT id_plat, DATE '2026-10-16', 8000 FROM plat WHERE nom = 'Menu Romazava';   -- date de début : hypothèse de test

-- Contenu du menu : un romazava, un ranon'ampango et des mofo gasy
INSERT INTO composition_menu (id_menu, id_plat_inclus, quantite)
    SELECT m.id_plat, p.id_plat, 1 FROM plat m, plat p WHERE m.nom = 'Menu Romazava' AND p.nom = 'Romazava';
INSERT INTO composition_menu (id_menu, id_plat_inclus, quantite)
    SELECT m.id_plat, p.id_plat, 1 FROM plat m, plat p WHERE m.nom = 'Menu Romazava' AND p.nom = 'Ranon''ampango';
INSERT INTO composition_menu (id_menu, id_plat_inclus, quantite)
    SELECT m.id_plat, p.id_plat, 1 FROM plat m, plat p WHERE m.nom = 'Menu Romazava' AND p.nom = 'Mofo gasy (les 4)';

-- Le menu se commande comme un plat : commande 7 (1 Menu Romazava), sur place table 4, servie par Lalao Rasoa
INSERT INTO commande (date_commande, id_client, id_serveur, id_table)       -- identifiant 7
    SELECT TIMESTAMP '2026-10-16 13:10:00', NULL, s.id_serveur, t.id_table
    FROM serveur s, table_salle t
    WHERE s.nom = 'Lalao Rasoa' AND t.numero = 4;
INSERT INTO ligne_commande (id_commande, id_plat, quantite, prix_unitaire)
    SELECT 7, id_plat, 1, prix FROM plat WHERE nom = 'Menu Romazava';
