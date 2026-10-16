-- Étape 08 :
CREATE TABLE ingredient (
    id_ingredient INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom           VARCHAR(100) NOT NULL UNIQUE,
    unite         VARCHAR(10)  NOT NULL,                        
    stock         INTEGER      NOT NULL DEFAULT 0 CHECK (stock >= 0)  
);

CREATE TABLE composition (
    id_plat       INTEGER NOT NULL,
    id_ingredient INTEGER NOT NULL,
    quantite      INTEGER NOT NULL CHECK (quantite > 0),        
    PRIMARY KEY (id_plat, id_ingredient),
    CONSTRAINT fk_compo_plat       FOREIGN KEY (id_plat)       REFERENCES plat (id_plat),
    CONSTRAINT fk_compo_ingredient FOREIGN KEY (id_ingredient) REFERENCES ingredient (id_ingredient)
);

INSERT INTO ingredient (nom, unite, stock) VALUES ('Riz', 'g', 50000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Viande de zébu', 'g', 20000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Brèdes mafana', 'g', 8000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Porc', 'g', 15000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Feuilles de manioc pilées', 'g', 6000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Poulet', 'g', 18000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Lait de coco', 'ml', 5000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Nouilles', 'g', 10000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Farine de riz', 'g', 12000);
INSERT INTO ingredient (nom, unite, stock) VALUES ('Sucre', 'g', 5000);

INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 250 FROM plat p, ingredient i WHERE p.nom = 'Romazava' AND i.nom = 'Riz';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 150 FROM plat p, ingredient i WHERE p.nom = 'Romazava' AND i.nom = 'Viande de zébu';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 100 FROM plat p, ingredient i WHERE p.nom = 'Romazava' AND i.nom = 'Brèdes mafana';

INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 250 FROM plat p, ingredient i WHERE p.nom = 'Ravitoto sy henakisoa' AND i.nom = 'Riz';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 150 FROM plat p, ingredient i WHERE p.nom = 'Ravitoto sy henakisoa' AND i.nom = 'Porc';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 100 FROM plat p, ingredient i WHERE p.nom = 'Ravitoto sy henakisoa' AND i.nom = 'Feuilles de manioc pilées';

INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 250 FROM plat p, ingredient i WHERE p.nom = 'Akoho sy voanio' AND i.nom = 'Riz';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 200 FROM plat p, ingredient i WHERE p.nom = 'Akoho sy voanio' AND i.nom = 'Poulet';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 100 FROM plat p, ingredient i WHERE p.nom = 'Akoho sy voanio' AND i.nom = 'Lait de coco';

INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 200 FROM plat p, ingredient i WHERE p.nom = 'Mi sao' AND i.nom = 'Nouilles';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 80 FROM plat p, ingredient i WHERE p.nom = 'Mi sao' AND i.nom = 'Poulet';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 100 FROM plat p, ingredient i WHERE p.nom = 'Soupe chinoise' AND i.nom = 'Nouilles';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 50 FROM plat p, ingredient i WHERE p.nom = 'Soupe chinoise' AND i.nom = 'Poulet';

INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 100 FROM plat p, ingredient i WHERE p.nom = 'Mofo gasy (les 4)' AND i.nom = 'Farine de riz';
INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 20 FROM plat p, ingredient i WHERE p.nom = 'Mofo gasy (les 4)' AND i.nom = 'Sucre';

INSERT INTO composition (id_plat, id_ingredient, quantite) SELECT p.id_plat, i.id_ingredient, 20 FROM plat p, ingredient i WHERE p.nom = 'Ranon''ampango' AND i.nom = 'Riz';
