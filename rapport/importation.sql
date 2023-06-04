DROP TABLE IF EXISTS import;
DROP TABLE IF EXISTS import_regions;

CREATE TABLE import (
	ID integer NOT NULL,
	Name varchar(200) NOT NULL,
	Sex char(1) CHECK (Sex IN ('M','F')),
	Age integer,
	Height integer DEFAULT NULL,
	Weight decimal DEFAULT NULL,
	Team varchar(200) NOT NULL,
	NOC char(3) NOT NULL,
	Games char(11) NOT NULL,
	Year integer NOT NULL,
	Season char(6) CHECK (Season IN ('Summer','Winter')),
	City varchar(200) NOT NULL,
	Sport varchar(200) NOT NULL,
	Event varchar(500) NOT NULL,
	Medal varchar(10) DEFAULT NULL
);

\copy import FROM 'athlete_events.csv' WITH (FORMAT CSV, HEADER true, NULL 'NA');

DELETE FROM import WHERE (Year<1920 OR Sport LIKE 'Art%');

CREATE TABLE import_regions (
	NOC char(3) NOT NULL,
	region varchar(50) NOT NULL,
	notes varchar(50) DEFAULT NULL
);

\copy import_regions FROM 'noc_regions.csv' WITH (FORMAT CSV, HEADER true);

UPDATE import_regions SET NOC='SGP' WHERE region='Singapore';


-- Ventilation


DROP TABLE IF EXISTS athletes CASCADE;
DROP TABLE IF EXISTS regions CASCADE;
DROP TABLE IF EXISTS jeux CASCADE;
DROP TABLE IF EXISTS participe CASCADE;

CREATE TABLE regions (
	noc char(3),
	region varchar(50) NOT NULL,
	notes varchar(50) DEFAULT NULL,
	CONSTRAINT pk_region PRIMARY KEY (NOC) 
);

CREATE TABLE jeux (
	id_jeu SERIAL,
	noc char(3),
	annee INTEGER,
	saison char(6) CHECK (saison IN ('Summer','Winter')),
	ville varchar(200) NOT NULL,
	sport varchar(200) NOT NULL,
	evenement varchar(500) NOT NULL,
	CONSTRAINT pk_jeux PRIMARY KEY(id_jeu),
	CONSTRAINT fk_jeux_noc FOREIGN KEY (noc) REFERENCES regions(noc)
);

CREATE TABLE athletes (
	id_ath INTEGER,
	nom CHAR(200) NOT NULL,
	sexe CHAR(1) CHECK (sexe IN ('F', 'M')),
	taille INTEGER DEFAULT NULL,
	poids decimal DEFAULT NULL,
	CONSTRAINT pk_athletes PRIMARY KEY (id_ath)
);

CREATE TABLE participe (
	id_ath INTEGER NOT NULL,
	id_jeu INTEGER NOT NULL,
	age INTEGER, -- pour une raison inconnue certain ont un âge NULL, sont-ils immortels?
	medaille varchar(10) DEFAULT NULL,
	equipe varchar(200) NOT NULL,
	CONSTRAINT pk_participe PRIMARY KEY(id_ath,id_jeu),
	CONSTRAINT fk_ath FOREIGN KEY (id_ath) REFERENCES athletes(id_ath),
	CONSTRAINT fk_jeu FOREIGN KEY (id_jeu) REFERENCES jeux(id_jeu)
);

INSERT INTO regions SELECT * FROM import_regions;

INSERT INTO athletes
	SELECT DISTINCT ID, Name, Sex, Height, Weight from import;

INSERT INTO jeux (noc, annee, saison, ville, sport, evenement)
	SELECT DISTINCT NOC, Year, Season, City, Sport, Event FROM import;

INSERT INTO participe
	SELECT ID, j.id_jeu, i.medal, i.age, i.team from import as i, jeux as j
	where i.noc=j.noc
		and i.Year=j.annee
		and i.Season=j.saison
		and i.City=j.ville
		and i.Sport=j.sport
		and i.Event=j.evenement;

-- La requête pour recréer le fichier "athlete_events.csv"
-- Cependant on a volontairement jarté la colonne "Games" qui est juste la concaténation de "Year" (annee) et "Season" (saison).
--select a.id_ath, nom, sexe, age, taille, poids, equipe, noc, annee, saison, ville, sport, evenement, medaille from athletes as a, participe as p, jeux as j
--where a.id_ath=p.id_ath and j.id_jeu=p.id_jeu order by a.id_ath asc;

-- Ici c'est la même requête, mais on demande le nombre de lignes.
-- On doit obtenir le même nombre de lignes que "import".
-- Et c'est good, on a bien 255080 lignes !
select count(*) from athletes as a, participe as p, jeux as j
where a.id_ath=p.id_ath and j.id_jeu=p.id_jeu;



