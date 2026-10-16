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

---

# Niveau 2 – Intermédiaire (étapes 6 à 9)

## Étape 6 – Les paiements

> « On paie en espèces, MVola, Orange Money ou Airtel Money. Parfois un client paie une partie en espèces et le reste
> par MVola. Pour le mobile money, je note la référence de la transaction. »

**Schéma après l'étape 6**

- CATEGORIE(**id_categorie**, libelle)
- PLAT(**id_plat**, nom, prix, #id_categorie)
- CLIENT(**id_client**, nom)
- SERVEUR(**id_serveur**, nom)
- TABLE_SALLE(**id_table**, numero)
- COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table?)
- LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite)
- MODE_PAIEMENT(**id_mode**, libelle) (nouveau)
- PAIEMENT(**id_paiement**, #id_commande, #id_mode, montant, reference?, date_paiement) (nouveau)

**Choix de conception** : une commande peut être réglée en plusieurs fois et avec plusieurs modes → un paiement est une
ligne à part entière (association un-à-plusieurs avec `COMMANDE`). La référence est facultative (`reference?`) : elle n'a
de sens que pour le mobile money. `UNIQUE (id_mode, reference)` empêche d'enregistrer deux fois la même transaction.
Le reste à payer n'est jamais stocké : il se calcule (montant dû − somme des paiements).

**Piège** – *Pourquoi `montant_paye` dans `COMMANDE` ne suffit pas ? CHECK ou table de référence ?*
Une seule colonne ne peut ni représenter un paiement en plusieurs fois (10 000 Ar en espèces + 5 000 Ar par MVola), ni
garder le mode, la référence et la date de chaque versement ; c'est en plus une valeur dérivée qui peut se désynchroniser
des vrais paiements. Pour le mode, un `CHECK (mode IN (...))` est simple et évite une jointure, mais ajouter ou renommer
un mode oblige à modifier le schéma et il ne porte aucune information ; une table de référence se complète par un simple
`INSERT`, garantit l'intégrité par clé étrangère et peut porter des attributs, au prix d'une jointure en plus
(choix retenu ici).

---

## Étape 7 – Les prix changent

> « Au 15 octobre, le romazava passe de 7 000 à 7 500 Ar. Mais mes anciennes factures doivent garder l'ancien prix ! »

**Constat** (expérience réalisée sur la base de l'étape 6, en changeant simplement `plat.prix` puis en relançant la
requête de l'étape 3) : la **commande 1 passe de 15 000 à 16 000 Ar** (2 romazava × 500 Ar de plus), et la commande 5 de
14 000 à 14 500 Ar. La commande 1, déjà payée 15 000 Ar, deviendrait « non soldée » avec 1 000 Ar de reste. Cause :
`LIGNE_COMMANDE` ne mémorise pas le prix ; il est relu dans `PLAT` à chaque calcul, donc une facture ancienne change.

**Schéma après l'étape 7**

- CATEGORIE(**id_categorie**, libelle)
- PLAT(**id_plat**, nom, prix, #id_categorie) — `prix` = prix **actuel** de la carte
- PRIX_PLAT(**#id_plat**, **date_debut**, prix) (nouveau, bonus : historique des prix)
- CLIENT(**id_client**, nom)
- SERVEUR(**id_serveur**, nom)
- TABLE_SALLE(**id_table**, numero)
- COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table?)
- LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite, prix_unitaire) (modifié : ajout de prix_unitaire)
- MODE_PAIEMENT(**id_mode**, libelle)
- PAIEMENT(**id_paiement**, #id_commande, #id_mode, montant, reference?, date_paiement)

**Correction** : le prix facturé est recopié dans la ligne de commande (`prix_unitaire`) au moment de la commande ; le
montant d'une commande se calcule désormais avec `quantite * prix_unitaire` et ne dépend plus de `PLAT.prix`. La migration
fige d'abord les prix existants (anciens prix), **puis** applique l'augmentation.

**Bonus** : `PRIX_PLAT` conserve tous les prix de la carte avec leur date de début (le prix en vigueur à une date donnée
est la ligne dont `date_debut` est la plus récente avant cette date). `PLAT.prix` reste le prix actuel, pratique pour la
carte, mais il est redondant avec la dernière ligne de `PRIX_PLAT` : les deux doivent être mis à jour ensemble. La date de
début de l'historique initial (1er janvier 2026) est une hypothèse de test.

---

## Étape 8 – Les ingrédients

> « Je veux gérer mes ingrédients et savoir ce que chaque plat consomme : un romazava, c'est 250 g de riz, 150 g de viande
> de zébu et 100 g de brèdes mafana. »

**Schéma après l'étape 8**

- CATEGORIE(**id_categorie**, libelle)
- PLAT(**id_plat**, nom, prix, #id_categorie)
- PRIX_PLAT(**#id_plat**, **date_debut**, prix)
- CLIENT(**id_client**, nom)
- SERVEUR(**id_serveur**, nom)
- TABLE_SALLE(**id_table**, numero)
- COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table?)
- LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite, prix_unitaire)
- MODE_PAIEMENT(**id_mode**, libelle)
- PAIEMENT(**id_paiement**, #id_commande, #id_mode, montant, reference?, date_paiement)
- INGREDIENT(**id_ingredient**, nom, unite, stock) (nouveau)
- COMPOSITION(**#id_plat**, **#id_ingredient**, quantite) (nouveau)

**Choix de conception** : un plat utilise plusieurs ingrédients et un ingrédient entre dans plusieurs plats → table
d'association `COMPOSITION`, qui porte la quantité d'ingrédient **par portion** (exprimée dans l'unité de l'ingrédient).
`unite` et `stock` sont des attributs de l'ingrédient (le stock est dans cette même unité). La consommation théorique est
calculée : `quantité commandée × quantité par portion`. Le stock n'est pas décrémenté automatiquement (non demandé).

> Données de test : seule la composition du romazava vient de l'énoncé ; les autres compositions et les stocks sont des
> valeurs inventées pour tester.

**Piège** – *Pourquoi pas une colonne `ingredients VARCHAR(500)` contenant « riz, zébu, brèdes » ?*
Une liste dans un texte n'est pas exploitable par SQL : on ne peut ni stocker la quantité de chaque ingrédient, ni lui
associer une unité ou un stock, ni jointer ni additionner pour calculer la consommation, et rien n'empêche les fautes de
frappe (« brèdes » / « brede »). Il faut une ligne par couple (plat, ingrédient), donc une table d'association.

---

## Étape 9 – Les menus du jour

> « Je propose un Menu Romazava à 8 000 Ar : un romazava, un ranon'ampango et des mofo gasy. Le menu se commande comme un plat. »

**Schéma après l'étape 9 (schéma final du niveau 2)**

- CATEGORIE(**id_categorie**, libelle)
- PLAT(**id_plat**, nom, prix, #id_categorie)
- PRIX_PLAT(**#id_plat**, **date_debut**, prix)
- CLIENT(**id_client**, nom)
- SERVEUR(**id_serveur**, nom)
- TABLE_SALLE(**id_table**, numero)
- COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table?)
- LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite, prix_unitaire)
- MODE_PAIEMENT(**id_mode**, libelle)
- PAIEMENT(**id_paiement**, #id_commande, #id_mode, montant, reference?, date_paiement)
- INGREDIENT(**id_ingredient**, nom, unite, stock)
- COMPOSITION(**#id_plat**, **#id_ingredient**, quantite)
- COMPOSITION_MENU(**#id_menu**, **#id_plat_inclus**, quantite) (nouveau — association réflexive sur `PLAT`)

**Choix de conception** : le menu **est un plat** (une ligne de `PLAT`, avec son prix, sa catégorie et son historique de
prix) ; la table `COMPOSITION_MENU` relie un plat « menu » (`id_menu`) aux plats qu'il contient (`id_plat_inclus`), avec
une quantité. Comme le menu est un plat, il se commande tel quel dans `LIGNE_COMMANDE`, sans aucun changement. Une nouvelle
catégorie « Menu » est ajoutée pour le ranger (la catégorie est obligatoire).
Un plat est un menu s'il apparaît comme `id_menu` dans `COMPOSITION_MENU`.

**Remarque** : un menu n'a pas de recette propre dans `COMPOSITION` ; sa consommation d'ingrédients passerait par les
plats qu'il contient. La requête de l'étape 8 ne développe pas les menus (elle ne compte que les compositions directes).

**Piège** – *Pourquoi pas une table `menu` séparée ? Quelle contrainte empêche un menu de se contenir lui-même ?*
Avec une table séparée, `LIGNE_COMMANDE` devrait référencer tantôt un plat, tantôt un menu (deux clés étrangères
facultatives ou une table de plus), et le prix, la catégorie et l'historique seraient dupliqués ; en gardant le menu dans
`PLAT`, une seule clé étrangère suffit. Le `CHECK (id_menu <> id_plat_inclus)` interdit qu'un menu se contienne
directement lui-même ; il ne détecte pas un cycle indirect (A contient B qui contient A), qui demanderait un déclencheur
ou un contrôle applicatif.
