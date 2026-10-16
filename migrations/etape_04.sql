-- Etape 04 

CREATE TABLE client (
    id_client INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom       VARCHAR(100) NOT NULL
);

INSERT INTO client (nom) VALUES ('Hery Andrianina');
INSERT INTO client (nom) VALUES ('Voahangy Rasoanaivo');
INSERT INTO client (nom) VALUES ('Tiana Randria');  

ALTER TABLE commande ADD id_client INTEGER;
ALTER TABLE commande ADD CONSTRAINT fk_commande_client
    FOREIGN KEY (id_client) REFERENCES client (id_client);

UPDATE commande SET id_client = (SELECT id_client FROM client WHERE nom = 'Hery Andrianina')
 WHERE id_commande IN (1, 5);
UPDATE commande SET id_client = (SELECT id_client FROM client WHERE nom = 'Voahangy Rasoanaivo')
 WHERE id_commande = 3;
