-- Etape 01 :
CREATE TABLE plat (
    id_plat INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom     VARCHAR(100) NOT NULL UNIQUE,
    prix    INTEGER      NOT NULL CHECK (prix >= 0)   
);

INSERT INTO plat (nom, prix) VALUES ('Romazava', 7000);
INSERT INTO plat (nom, prix) VALUES ('Ravitoto sy henakisoa', 8000);
INSERT INTO plat (nom, prix) VALUES ('Akoho sy voanio', 8500);
INSERT INTO plat (nom, prix) VALUES ('Mi sao', 6000);
INSERT INTO plat (nom, prix) VALUES ('Soupe chinoise', 5000);
INSERT INTO plat (nom, prix) VALUES ('Mofo gasy (les 4)', 1000);
INSERT INTO plat (nom, prix) VALUES ('Ranon''ampango', 500);
