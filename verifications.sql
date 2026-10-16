

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
