#import "../styles/notes.typ": note, example

= Aspects éthiques

Les données ne sont pas neutres. Elles reflètent un contexte social,
institutionnel et technique. Une analyse peut améliorer une décision, mais elle
peut aussi reproduire des inégalités, amplifier un biais historique ou porter
atteinte à la vie privée.

Une vigilance éthique est nécessaire dès la formulation de la question:

- qui est représenté dans les données ?
- qui ne l'est pas ?
- quelle décision sera prise à partir du modèle ?
- quelles erreurs sont les plus coûteuses ?
- quelles personnes peuvent être affectées par ces erreurs ?

== Finalité et proportionnalité

Une analyse doit avoir une finalité claire. Collecter ou utiliser des données
parce qu'elles sont disponibles ne suffit pas. Il faut relier les données à une
question légitime, puis vérifier que le niveau de détail collecté est
proportionné à cette question.

La proportionnalité concerne aussi les modèles. Un modèle très intrusif ou très
opaque peut être difficile à justifier si une règle plus simple produit une
décision comparable avec moins de risques.

== Confidentialité

L'anonymisation ne consiste pas seulement à retirer les noms. Des identifiants
indirects, comme une date de naissance, un code postal ou une combinaison rare de
caractéristiques, peuvent permettre une ré-identification.

Pour réduire les risques, on peut:

- supprimer ou transformer les identifiants directs;
- réduire la granularité, par exemple regrouper les âges;
- regrouper les modalités rares;
- limiter les variables diffusées;
- ajouter du bruit à certains résultats;
- utiliser des méthodes de confidentialité différentielle lorsque le contexte le
  justifie.

Le niveau de protection doit être adapté aux risques et à l'utilité attendue de
l'analyse.

== Biais et implications sociales

Un modèle peut être biaisé pour plusieurs raisons:

- l'échantillon ne représente pas la population cible;
- la variable réponse contient des décisions historiques biaisées;
- certaines classes sont trop peu représentées;
- la performance varie fortement selon les groupes;
- des variables apparemment neutres servent de proxys à des variables sensibles.

#example[
  Retirer la variable "genre" d'un modèle ne garantit pas l'absence de biais. Le
  modèle peut l'inférer indirectement à partir d'autres variables corrélées,
  comme certains parcours scolaires, emplois ou habitudes de consommation.
]

== Équité et performance

L'équité ne se réduit pas à une seule métrique. On peut comparer les taux
d'erreur, les faux positifs, les faux négatifs, la calibration ou l'accès à une
décision favorable selon les groupes. Ces critères peuvent entrer en tension:
améliorer l'un peut dégrader l'autre.

Il faut donc expliciter le choix retenu et le relier au contexte. Dans un modèle
de dépistage, un faux négatif peut être plus grave qu'un faux positif. Dans un
modèle d'accès à un service, refuser à tort une personne peut avoir des
conséquences sociales importantes.

== Réduire les biais

Les interventions peuvent se faire à plusieurs moments.

- En amont: améliorer la collecte, rééquilibrer l'échantillon, documenter les
  limites et corriger les erreurs connues.
- Pendant l'apprentissage: modifier la fonction de perte ou imposer des
  contraintes de performance selon les groupes.
- En aval: recalibrer les probabilités, ajuster les seuils ou surveiller les
  performances après déploiement.

Aucune correction automatique ne remplace la compréhension du contexte et la
discussion des conséquences.

== Transparence et responsabilité

Un résultat d'analyse doit être accompagné de ses conditions de validité: quelles
données ont été utilisées, quelles hypothèses ont été faites, quelles variables
ont été exclues, quelles erreurs restent probables et quelle décision sera prise
à partir du résultat.

La responsabilité ne disparaît pas parce qu'une méthode est automatique. Les
personnes qui conçoivent, déploient ou utilisent un modèle doivent pouvoir
expliquer son objectif, ses limites et les recours possibles pour les personnes
affectées.

#note[
  L'analyse de données est à la fois une science et une pratique. Elle demande
  des méthodes, mais aussi du jugement, de la documentation et une attention aux
  effets concrets des décisions prises à partir des résultats.
]

#heading(level: 2, outlined: false)[Exercices]

1. Citez deux risques de ré-identification dans un jeu de données anonymisé.
2. Formulez une question éthique à poser avant de déployer un modèle prédictif.
3. Donnez un exemple de compromis possible entre performance globale et équité.
4. Pourquoi retirer une variable sensible ne garantit-il pas l'absence de biais ?
