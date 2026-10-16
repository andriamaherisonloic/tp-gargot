# Schéma relationnel – La gargote de Rado

Le schéma à jour est celui de la **dernière étape** (dernière section de ce fichier).

**Notation** : **clé primaire** en gras · `#` devant une clé étrangère · `?` après un attribut facultatif (NULL autorisé) ·
(nouveau) / (modifié) pour ce qui change à l'étape.

---

## Étape 1 – La carte

> « Je veux la liste de mes plats avec leur prix. »

**Schéma après l'étape 1**

- PLAT(**id_plat**, nom, prix) (nouveau)

**Piège** – *Quel type pour le prix ? Quel identifiant ?*
Le prix est un `INTEGER` : les montants sont en ariary, sans centimes, et un entier évite les erreurs d'arrondi des
types flottants. L'identifiant est une clé de substitution `id_plat` auto-générée (`IDENTITY`) plutôt que le nom du plat,
qui peut être modifié, est long à référencer et n'est pas garanti stable (le nom reste tout de même `UNIQUE`).

---

## Étape 2 – Les catégories

> « Je range mes plats par catégorie : plats malagasy, plats chinois, soupes, desserts, boissons. »

**Schéma après l'étape 2**

- CATEGORIE(**id_categorie**, libelle) (nouveau)
- PLAT(**id_plat**, nom, prix, #id_categorie) (modifié : ajout de #id_categorie)

**Migration** : la table `plat` contient déjà des données, on ne la recrée donc pas. On ajoute `id_categorie` (nullable),
on remplit la colonne avec des `UPDATE`, puis on la rend `NOT NULL`.

**Piège** – *Pourquoi pas une colonne `categorie VARCHAR(50)` dans `plat` ?*
Le texte libre est répété sur chaque ligne : une faute de frappe (« Plat malgache » au lieu de « Plat malagasy ») crée
une catégorie fantôme et fausse le `GROUP BY`, et renommer une catégorie oblige à modifier tous les plats concernés.
De plus, une catégorie sans plat n'existerait pas du tout, alors que Rado veut pouvoir la lister.

---

## Étape 3 – Les commandes

> « J'enregistre les commandes : la date, quels plats, et combien de chaque. »

**Schéma après l'étape 3**

- CATEGORIE(**id_categorie**, libelle)
- PLAT(**id_plat**, nom, prix, #id_categorie)
- COMMANDE(**id_commande**, date_commande) (nouveau)
- LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite) (nouveau)

**Choix de conception** : une commande contient plusieurs plats et un plat figure dans plusieurs commandes (association
plusieurs-à-plusieurs) → table d'association `LIGNE_COMMANDE` dont la clé primaire est le couple (`id_commande`, `id_plat`).

**Piège** – *Où placer la quantité ?*
Dans `LIGNE_COMMANDE` : la quantité dépend du couple (commande, plat) et non de la commande seule ni du plat seul.

> Remarque : le prix reste dans `PLAT`, donc un changement de prix modifierait le montant des anciennes commandes.
> Le TP ne le demande pas à ce stade ; une colonne de prix figé dans la ligne de commande serait la solution.

---

## Étape 4 – Les habitués

> « Certains clients sont des habitués, je veux les reconnaître. Mais la plupart sont de passage et je ne leur demande rien. »

**Schéma après l'étape 4**

- CATEGORIE(**id_categorie**, libelle)
- PLAT(**id_plat**, nom, prix, #id_categorie)
- CLIENT(**id_client**, nom) (nouveau)
- COMMANDE(**id_commande**, date_commande, #id_client?) (modifié : ajout de #id_client?)
- LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite)

**Choix de conception** : un client passe plusieurs commandes, une commande a au plus un client → clé étrangère simple
placée côté `COMMANDE`, **facultative** (NULL = client de passage).

**Piège** – *La clé étrangère est-elle `NOT NULL` ? Quelle jointure ?*
Non : `id_client` est facultatif (`#id_client?`), car la plupart des clients sont de passage et n'ont pas de fiche.
Il faut un `LEFT JOIN` de `COMMANDE` vers `CLIENT` (avec `COALESCE` pour l'affichage) : un `INNER JOIN` ferait disparaître
toutes les commandes sans client.

---

## Étape 5 – Serveurs et tables

> « Je veux savoir quel serveur a pris la commande et à quelle table. Pour les plats à emporter, il n'y a pas de table. »

**Schéma après l'étape 5 (schéma final du niveau 1)**

- CATEGORIE(**id_categorie**, libelle)
- PLAT(**id_plat**, nom, prix, #id_categorie)
- CLIENT(**id_client**, nom)
- SERVEUR(**id_serveur**, nom) (nouveau)
- TABLE_SALLE(**id_table**, numero) (nouveau)
- COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table?) (modifié : ajout de #id_serveur et #id_table?)
- LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite)

**Choix de conception** :
- un serveur prend plusieurs commandes, une commande est prise par un seul serveur → `#id_serveur` obligatoire (on suppose
  que chaque commande, y compris à emporter, est prise par un serveur) ;
- une table de la salle accueille plusieurs commandes au fil du temps, une commande a au plus une table →
  `#id_table?` facultatif, NULL = plat à emporter ;
- la table de la salle s'appelle `TABLE_SALLE` car `TABLE` est un mot réservé.

**Piège** – *Table de la salle ≠ commande ? Pourquoi `table` pose problème en SQL ?*
Une table de la salle est un objet physique permanent (huit au total) réutilisé par de nombreuses commandes, alors
qu'une commande est un événement daté, qui n'a lieu qu'une fois : ce sont deux entités distinctes liées par une
association un-à-plusieurs. `TABLE` est un mot réservé du SQL (`CREATE TABLE`, …) : l'utiliser comme nom de table provoque
une erreur de syntaxe, sauf à le mettre entre guillemets, d'où `table_salle`.
