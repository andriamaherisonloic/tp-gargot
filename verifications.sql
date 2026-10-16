

-- Étape 1 : afficher les plats du plus cher au moins cher

SELECT nom, prix FROM plat ORDER BY prix DESC, nom;


-- Etape 2 : nombre de plats par catégorie, y compris les catégories sans plat

SELECT c.libelle, COUNT(p.id_plat) AS nb_plats
FROM categorie c
LEFT JOIN plat p ON p.id_categorie = c.id_categorie
GROUP BY c.id_categorie, c.libelle
ORDER BY c.id_categorie;

-- Etape 3 : montant total de chaque commande

SELECT c.id_commande,
       c.date_commande,
       COALESCE(SUM(lc.quantite * p.prix), 0) AS montant_total
FROM commande c
LEFT JOIN ligne_commande lc ON lc.id_commande = c.id_commande
LEFT JOIN plat p            ON p.id_plat = lc.id_plat
GROUP BY c.id_commande, c.date_commande
ORDER BY c.id_commande;


-- Étape 4 : commandes avec le nom du client,

SELECT c.id_commande,
       c.date_commande,
       COALESCE(cl.nom, 'client de passage') AS client
FROM commande c
LEFT JOIN client cl ON cl.id_client = c.id_client
ORDER BY c.id_commande;


-- Etape 5 : nombre de commandes et chiffre d'affaires par serveur

SELECT s.nom,
       COUNT(DISTINCT c.id_commande)          AS nb_commandes,
       COALESCE(SUM(lc.quantite * p.prix), 0) AS chiffre_affaires
FROM serveur s
LEFT JOIN commande c        ON c.id_serveur = s.id_serveur
LEFT JOIN ligne_commande lc ON lc.id_commande = c.id_commande
LEFT JOIN plat p            ON p.id_plat = lc.id_plat
GROUP BY s.id_serveur, s.nom
ORDER BY s.id_serveur;

-- Bonus : sur place (numéro de table) ou à emporter
SELECT c.id_commande,
       s.nom AS serveur,
       COALESCE(CAST(t.numero AS VARCHAR(10)), 'à emporter') AS table_ou_emporter
FROM commande c
JOIN serveur s          ON s.id_serveur = c.id_serveur
LEFT JOIN table_salle t ON t.id_table = c.id_table
ORDER BY c.id_commande;




-- Étape 6 : commandes non soldées : montant dû, montant payé, reste à payer

SELECT c.id_commande,
       d.montant_du,
       COALESCE(pp.montant_paye, 0)                 AS montant_paye,
       d.montant_du - COALESCE(pp.montant_paye, 0)  AS reste_a_payer
FROM commande c
JOIN (SELECT id_commande, SUM(quantite * prix_unitaire) AS montant_du
      FROM ligne_commande
      GROUP BY id_commande) d  ON d.id_commande = c.id_commande
LEFT JOIN (SELECT id_commande, SUM(montant) AS montant_paye
           FROM paiement
           GROUP BY id_commande) pp ON pp.id_commande = c.id_commande
WHERE d.montant_du > COALESCE(pp.montant_paye, 0)
ORDER BY c.id_commande;

-- Étape 7 : 
SELECT c.id_commande,
       SUM(lc.quantite * lc.prix_unitaire) AS montant_fige,
       SUM(lc.quantite * p.prix)           AS montant_au_prix_actuel
FROM commande c
JOIN ligne_commande lc ON lc.id_commande = c.id_commande
JOIN plat p            ON p.id_plat = lc.id_plat
GROUP BY c.id_commande
ORDER BY c.id_commande;

SELECT p.nom, h.date_debut, h.prix
FROM prix_plat h
JOIN plat p ON p.id_plat = h.id_plat
WHERE p.id_plat IN (SELECT id_plat FROM prix_plat GROUP BY id_plat HAVING COUNT(*) > 1)
ORDER BY p.nom, h.date_debut;

SELECT p.nom, h.date_debut, h.prix
FROM plat p
JOIN prix_plat h ON h.id_plat = p.id_plat
WHERE p.nom = 'Romazava'
  AND h.date_debut = (SELECT MAX(h2.date_debut) FROM prix_plat h2
                      WHERE h2.id_plat = p.id_plat AND h2.date_debut <= DATE '2026-10-14');


-- Etape 8 :
SELECT i.nom,
       i.unite,
       SUM(lc.quantite * co.quantite) AS consommation_theorique
FROM commande c
JOIN ligne_commande lc ON lc.id_commande = c.id_commande
JOIN composition co    ON co.id_plat = lc.id_plat
JOIN ingredient i      ON i.id_ingredient = co.id_ingredient
WHERE c.date_commande >= TIMESTAMP '2026-10-12 00:00:00'
  AND c.date_commande <  TIMESTAMP '2026-10-13 00:00:00'
GROUP BY i.id_ingredient, i.nom, i.unite
ORDER BY consommation_theorique DESC, i.nom;

-- Étape 9 : pour chaque menu : son prix, la somme des prix à la carte et l'économie du client

SELECT m.nom                          AS menu,
       m.prix                         AS prix_menu,
       SUM(cm.quantite * p.prix)      AS somme_a_la_carte,
       SUM(cm.quantite * p.prix) - m.prix AS economie
FROM plat m
JOIN composition_menu cm ON cm.id_menu = m.id_plat
JOIN plat p              ON p.id_plat = cm.id_plat_inclus
GROUP BY m.id_plat, m.nom, m.prix
ORDER BY m.nom;

SELECT lc.id_commande, p.nom, lc.quantite, lc.prix_unitaire
FROM ligne_commande lc
JOIN plat p ON p.id_plat = lc.id_plat
WHERE p.id_plat IN (SELECT id_menu FROM composition_menu);
