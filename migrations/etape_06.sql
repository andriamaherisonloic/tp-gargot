-- Étape 06 : « On paie en espèces, MVola, Orange Money ou Airtel Money. Parfois un client paie une partie
--              en espèces et le reste par MVola. Pour le mobile money, je note la référence de la transaction. »
-- Table de référence mode_paiement + table paiement (une commande peut avoir plusieurs paiements).

CREATE TABLE mode_paiement (
    id_mode INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    libelle VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO mode_paiement (libelle) VALUES ('Espèces');
INSERT INTO mode_paiement (libelle) VALUES ('MVola');
INSERT INTO mode_paiement (libelle) VALUES ('Orange Money');
INSERT INTO mode_paiement (libelle) VALUES ('Airtel Money');

CREATE TABLE paiement (
    id_paiement   INTEGER   GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_commande   INTEGER   NOT NULL,
    id_mode       INTEGER   NOT NULL,
    montant       INTEGER   NOT NULL CHECK (montant > 0),       -- ariary, sans centimes
    reference     VARCHAR(50),                                   -- facultative : référence de transaction mobile money
    date_paiement TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_paiement_commande FOREIGN KEY (id_commande) REFERENCES commande (id_commande),
    CONSTRAINT fk_paiement_mode     FOREIGN KEY (id_mode)     REFERENCES mode_paiement (id_mode),
    CONSTRAINT uq_paiement_reference UNIQUE (id_mode, reference)  -- une même transaction ne s'enregistre qu'une fois
);

-- Commande 1 : 10 000 Ar en espèces + 5 000 Ar par MVola
INSERT INTO paiement (id_commande, id_mode, montant, reference, date_paiement)
    SELECT 1, id_mode, 10000, CAST(NULL AS VARCHAR(50)), TIMESTAMP '2026-10-12 12:50:00'
    FROM mode_paiement WHERE libelle = 'Espèces';
INSERT INTO paiement (id_commande, id_mode, montant, reference, date_paiement)
    SELECT 1, id_mode, 5000, 'MV261012A1', TIMESTAMP '2026-10-12 12:51:00'
    FROM mode_paiement WHERE libelle = 'MVola';

-- Commande 2 : 6 000 Ar par Orange Money (la commande n'est donc pas soldée)
INSERT INTO paiement (id_commande, id_mode, montant, reference, date_paiement)
    SELECT 2, id_mode, 6000, 'OM261012B7', TIMESTAMP '2026-10-12 13:10:00'
    FROM mode_paiement WHERE libelle = 'Orange Money';
