-- Il n'est pas conseillé d'exécuter le fichier en un coup
-- parce que bon ça va afficher une liste sans fin de résultats des SELECT.

-- Ce fichier récapitule les exercices 3, 5 et 6
-- Il contient des commentaires intéressants qui détaillent chacune des commandes complexes.
-- On n'a pas écrit les requêtes dans le rapport pour ne pas avoir à recopier bêtement tout ce qui est écrit ici.

-- Exercice 3

-- Q1
SELECT COUNT(*) FROM information_schema.columns
WHERE table_name = 'import';

-- Q2
SELECT COUNT(*) FROM import;

-- Q3
SELECT COUNT(DISTINCT noc) FROM import_regions;

-- Q4
SELECT COUNT(DISTINCT id) FROM import;

-- Q5
SELECT COUNT(*) FROM import WHERE medal='Gold';

-- Q6
SELECT COUNT(*) FROM import WHERE name LIKE 'Carl Lewis %';

-- Exercice 5

-- Q1
select region, count(*) from participe as p, jeux as j, regions as r
where p.id_jeu=j.id_jeu and j.noc=r.noc group by region order by count(*) desc;
-- on peut vérifier avec la requête suivante :
-- select noc, count(*) from import group by noc order by count(*) desc limit 10;

-- Q2
select region, count(*) from participe as p, jeux as j, regions as r
where p.id_jeu=j.id_jeu and j.noc=r.noc and medaille='Gold' group by region, medaille order by count(*) desc;
-- on peut vérifier avec la requête suivante :
-- select noc, count(*) from import where medal='Gold' group by noc, medal order by count(*) desc limit 10;

-- Q3
select region, count(*) from participe as p, jeux as j, regions as r
where p.id_jeu=j.id_jeu and j.noc=r.noc and medaille is not null group by region order by count(*) desc:
-- on peut vérifier avec la requête suivante :
-- select noc, count(*) from import where medal is not null group by noc order by count(*) desc limit 10;

-- Q4
-- on demande 3 colonnes mais on sait pas pourquoi lol
select nom, count(*) from participe as p, athletes as a
where p.id_ath=a.id_ath and medaille='Gold' group by p.id_ath, a.nom order by count(*) desc;
-- on peut vérifier avec la requête suivante :
-- select name, count(*) from import where medal='Gold' group by ID, name order by count(*) desc limit 10;

-- Q5
-- on veut le nombre de médailles gagnées par pays à Albertville
select region, count(*) from participe as p, jeux as j, regions as r
where p.id_jeu=j.id_jeu and j.noc=r.noc and medaille is not null and j.ville='Albertville'
group by region order by count(*) desc;
-- on peut vérifier avec la requête suivante :
-- select noc, count(*) from import where medal is not null and city='Albertville' group by noc order by count(*) desc

-- Q6
select count(distinct a.id_ath) from participe as p1, participe as p2, jeux as j1, jeux as j2, athletes as a
where p1.id_ath=p2.id_ath and p1.id_jeu=j1.id_jeu and p2.id_jeu=j2.id_jeu
and j1.annee<j2.annee and j2.noc='FRA' and j1.noc!='FRA' and a.id_ath=p1.id_ath;
-- Pour se renseigner sur lequel est le plus connu, on peut calculer le nombre de médailles d'or pour chacun.
-- On fait une vue pour se simplifier la vie on en peut plus
create view new_french_great_guys as
select distinct a.nom, p1.id_ath, p1.equipe as previous_team, p2.equipe as best_team from participe as p1, participe as p2, jeux as j1, jeux as j2, athletes as a
where p1.id_ath=p2.id_ath and p1.id_jeu=j1.id_jeu and p2.id_jeu=j2.id_jeu
and j1.annee<j2.annee and j2.noc='FRA' and j1.noc!='FRA' and a.id_ath=p1.id_ath;

-- Parmis les joueurs qui ont joué une première fois pour une autre équipe,
-- puis qui ont rejoint l'équipe de France pour leur dernière participation,
-- il y en a 2 qui ont gagné une médaille d'or : Angelo Parisi et Choi Min-Kyung.
-- Cependant, cette dernière a gagné sa médaille d'or alors qu'elle était dans l'équipe coréenne,
-- et Angelo en tant que joueur Français, donc pour le plus bogoss on va garder Angelo.
-- C'est le résultat de la requête ci-dessous.
select f.nom, f.id_ath, count(*) from new_french_great_guys as f, participe as p, jeux as j
where p.id_ath=f.id_ath and p.medaille='Gold' and p.id_jeu=j.id_jeu and j.noc='FRA'
group by f.nom, f.id_ath, medaille
order by count(*) desc;

-- Q7
-- Même chose que Q6, on va juste à l'envers :
select count(distinct a.id_ath) from participe as p1, participe as p2, jeux as j1, jeux as j2, athletes as a
where p1.id_ath=p2.id_ath and p1.id_jeu=j1.id_jeu and p2.id_jeu=j2.id_jeu
and j1.annee<j2.annee and j1.noc='FRA' and j2.noc!='FRA' and a.id_ath=p1.id_ath;

create view defectors as
select distinct a.nom, a.id_ath, p1.equipe as abandoned_team, p2.equipe as host_team from participe as p1, participe as p2, jeux as j1, jeux as j2, athletes as a
where p1.id_ath=p2.id_ath and p1.id_jeu=j1.id_jeu and p2.id_jeu=j2.id_jeu
and j1.annee<j2.annee and j1.noc='FRA' and j2.noc!='FRA' and a.id_ath=p1.id_ath order by a.id_ath;

-- Ici on calcule les défecteurs qui ont le plus de médailles au nom de la France.
-- Il y en a deux : Julien Bahain et Philippe Boccara.
-- Le plus connu est sans doute Julien Bahain car sa dernière participation était en 2016.
select d.nom, d.id_ath, count(*) from defectors as d, participe as p, jeux as j
where p.id_ath=d.id_ath and p.medaille is not null and p.id_jeu=j.id_jeu and j.noc='FRA'
group by d.nom, d.id_ath, medaille
order by count(*) desc;

-- Q8
select age, count(*) as nombre_medailles_or from participe
where medaille='Gold' and age is not null
group by age
order by age desc;

-- Q9
select sport, count(*), medaille from participe as p join jeux as j using (id_jeu)
where p.age>50 and p.medaille is not null
group by sport, medaille
order by count(*) desc;

-- Q10
select count(distinct evenement) as "Nombres d'événements", annee, saison from jeux
group by saison, annee
order by annee asc, count(distinct evenement) asc;

-- Q11
select count(*), annee from participe as p, jeux as j, athletes as a
where p.id_jeu=j.id_jeu and p.id_ath=a.id_ath and j.saison='Summer' and a.sexe='F' and p.medaille is not null
group by annee
order by annee asc, count(*) asc;

-- Exercice 6

-- Pays choisi : Turquie (Turkey, TUR)
-- Sport choisi : Wrestling

-- Les 4 requêtes proposées sont :
-- 1. Le meilleur athlète turc de tous les temps (celui avec le plus de médailles d'or)
-- 2. La dernière année de victoire d'une médaille d'or dans le sport choisi
-- 3. Le plus agé des athlètes turcs à avoir gagné une médaille d'or
-- 4. Nombre total de médailles accordées à la Turquie pour le sport choisi

-- Requête 1.
select a.nom from participe as p, athletes as a, jeux as j
where p.id_ath=a.id_ath and p.id_jeu=j.id_jeu
and j.noc='TUR' and p.medaille='Gold'
group by p.id_ath, a.nom having count(*) >= ALL (
    select count(*) from participe as p2, athletes as a2, jeux as j2
    where p2.id_ath=a2.id_ath and p2.id_jeu=j2.id_jeu
    and j2.noc='TUR' and p2.medaille='Gold'
    group by p2.id_ath, a2.nom
);

-- Requête 2.
select j.annee from participe as p, jeux as j
where p.id_jeu=j.id_jeu and p.medaille='Gold' and j.noc='TUR' and j.sport='Wrestling'
order by j.annee desc limit 1;

-- Requête 3.
-- Note: tant pis pour ceux qui n'ont pas d'âge.
select a.nom, p.age from participe as p, jeux as j, athletes as a
where p.id_ath=a.id_ath and p.id_jeu=j.id_jeu and j.noc='TUR' and p.medaille='Gold' and p.age is not null
group by a.nom, p.age having p.age >= ALL (
    select p2.age from participe as p2, jeux as j2
    where p2.id_jeu=j2.id_jeu and j2.noc='TUR' and p2.medaille='Gold' and p2.age is not null
);

-- Requête 4.
select count(*) from participe as p, jeux as j
where p.id_jeu=j.id_jeu and j.sport='Wrestling' and j.noc='TUR' and p.medaille is not null;