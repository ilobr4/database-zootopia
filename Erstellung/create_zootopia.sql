/********************************************************
* This script creates the database named zootopia
*********************************************************/

DROP DATABASE IF EXISTS zootopia;
CREATE DATABASE zootopia;
USE zootopia;

CREATE TABLE gehege (
  gehege_nr 			INT				PRIMARY KEY,
  gehege_name 			VARCHAR(255)    NOT NULL,
  größe 				DECIMAL(10,2)	NOT NULL,
  kapazität 			INT				NOT NULL,
  bezeichnung 			ENUM('Aquarium', 'Trockenland', 'Wasserland', 'Regenwald', 'Polar', 'Terrarium') NOT NULL,
  gefahrenklasse		ENUM('1', '2', '3')	NOT NULL
);


CREATE TABLE kategorie (
  kategorie_id			INT 			PRIMARY KEY		 AUTO_INCREMENT,
  kategorie_name		VARCHAR(255) 	NOT NULL		 UNIQUE
);


CREATE TABLE arten (
  arten_id				INT 			PRIMARY KEY		 AUTO_INCREMENT,
  tierart				VARCHAR(255) 	NOT NULL		 UNIQUE
);


CREATE TABLE tiere (
  tiere_id 				INT 			PRIMARY KEY		 AUTO_INCREMENT,
  tier_name 			VARCHAR(255) 	NOT NULL,
  geburtsdatum 			DATE			NOT NULL,
  geschlecht 			ENUM('weiblich', 'männlich')	NOT NULL,
  größe 				DECIMAL(10,4),
  gewicht 				DECIMAL(10,4),	
  arten_id				INT				NOT NULL,
  kategorie_id 			INT				NOT NULL,
  gehege_nr 			INT				NOT NULL,
  CONSTRAINT tiere_fk_arten
	FOREIGN KEY (arten_id) 
	REFERENCES arten(arten_id),
  CONSTRAINT tiere_fk_kategorie 
	FOREIGN KEY (kategorie_id) 
	REFERENCES kategorie(kategorie_id),
  CONSTRAINT tiere_fk_gehege 
	FOREIGN KEY (gehege_nr) 
    REFERENCES gehege(gehege_nr)
);


CREATE TABLE futter (
  futter_id 			INT 			PRIMARY KEY		 AUTO_INCREMENT,
  sorte					VARCHAR(255)	NOT NULL		 UNIQUE
);


CREATE TABLE fressen (
  futter_id				INT 			NOT NULL,
  arten_id				INT 			NOT NULL,
  CONSTRAINT fressen_fk_futter
	FOREIGN KEY (futter_id) 
    REFERENCES futter(futter_id),
  CONSTRAINT fressen_fk_arten
	FOREIGN KEY (arten_id) 
    REFERENCES arten(arten_id)
);


CREATE TABLE mitarbeiter (
  mitarbeiter_id 		INT 			PRIMARY KEY 	AUTO_INCREMENT,
  vorname				VARCHAR(60)		NOT NULL,
  nachname 				VARCHAR(60)		NOT NULL,
  email_adresse			VARCHAR(255)	NOT NULL		UNIQUE,
  klasse				ENUM('1', '2', '3') NOT NULL
);


CREATE TABLE verantwortlich (
  mitarbeiter_id 		INT 			NOT NULL,
  gehege_nr 			INT				NOT NULL,
  CONSTRAINT verantwortlich_fk_mitarbeiter
	FOREIGN KEY (mitarbeiter_id) 
    REFERENCES mitarbeiter(mitarbeiter_id),
  CONSTRAINT verantwortlich_fk_gehege 
	FOREIGN KEY (gehege_nr) 
    REFERENCES gehege(gehege_nr)
);


CREATE TABLE paten (
  paten_id 				INT 			PRIMARY KEY		AUTO_INCREMENT,
  vorname				VARCHAR(60)		NOT NULL,
  nachname 				VARCHAR(60)		NOT NULL,
  email_adresse			VARCHAR(255)	NOT NULL		UNIQUE
);


CREATE TABLE patenschaften (
  paten_id 				INT 			NOT NULL,
  tiere_id				INT				NOT NULL,
  datum 				DATE			NOT NULL,
  betrag 				DECIMAL(10,2)	NOT NULL,
  CONSTRAINT patenschaften_fk_paten
	FOREIGN KEY (paten_id) 
    REFERENCES paten(paten_id),
  CONSTRAINT patenschaften_fk_tiere
	FOREIGN KEY (tiere_id) 
    REFERENCES tiere(tiere_id)
);

CREATE INDEX ps_datum ON patenschaften (datum);

-- Eine Tier darf nur einmal in der Tabelle Patenschaften vorkommen
CREATE UNIQUE INDEX unique_tiere_id ON patenschaften (tiere_id);


CREATE TABLE jubilaeum (
    id 					INT 			PRIMARY KEY 		AUTO_INCREMENT,
    nachricht 			VARCHAR(255) 	NOT NULL,
    erstellt 			DATETIME 		NOT NULL
);
  