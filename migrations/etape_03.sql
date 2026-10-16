--Etape3:
CREATE TABLE commande (
    id_commande   INTEGER   GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_commande TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ligne_commande (
    id_commande INTEGER NOT NULL,
    id_plat     INTEGER NOT NULL,
    quantite    INTEGER NOT NULL CHECK (quantite > 0),
    PRIMARY KEY (id_commande, id_plat),
    CONSTRAINT fk_lc_commande FOREIGN KEY (id_commande) REFERENCES commande (id_commande),
    CONSTRAINT fk_lc_plat     FOREIGN KEY (id_plat)     REFERENCES plat (id_plat)
);

INSERT INTO commande (date_commande) VALUES (TIMESTAMP '2026-10-12 12:10:00');  
INSERT INTO commande (date_commande) VALUES (TIMESTAMP '2026-10-12 12:40:00');  
INSERT INTO commande (date_commande) VALUES (TIMESTAMP '2026-10-13 12:05:00');  
INSERT INTO commande (date_commande) VALUES (TIMESTAMP '2026-10-13 13:00:00');  
INSERT INTO commande (date_commande) VALUES (TIMESTAMP '2026-10-14 12:30:00');  

-- Commande 1 : 2 Romazava + 2 Ranon'ampango
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 1, id_plat, 2 FROM plat WHERE nom = 'Romazava';
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 1, id_plat, 2 FROM plat WHERE nom = 'Ranon''ampango';
-- Commande 2 : Mi sao + Soupe chinoise + Mofo gasy
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 2, id_plat, 1 FROM plat WHERE nom = 'Mi sao';
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 2, id_plat, 1 FROM plat WHERE nom = 'Soupe chinoise';
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 2, id_plat, 1 FROM plat WHERE nom = 'Mofo gasy (les 4)';
-- Commande 3 : Akoho sy voanio + Ranon'ampango
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 3, id_plat, 1 FROM plat WHERE nom = 'Akoho sy voanio';
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 3, id_plat, 1 FROM plat WHERE nom = 'Ranon''ampango';
-- Commande 4 : 3 Ravitoto sy henakisoa + Mofo gasy
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 4, id_plat, 3 FROM plat WHERE nom = 'Ravitoto sy henakisoa';
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 4, id_plat, 1 FROM plat WHERE nom = 'Mofo gasy (les 4)';
-- Commande 5 : Romazava + Mi sao + 2 Ranon'ampango
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 5, id_plat, 1 FROM plat WHERE nom = 'Romazava';
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 5, id_plat, 1 FROM plat WHERE nom = 'Mi sao';
INSERT INTO ligne_commande (id_commande, id_plat, quantite) SELECT 5, id_plat, 2 FROM plat WHERE nom = 'Ranon''ampango';
