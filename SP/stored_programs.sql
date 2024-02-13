DROP FUNCTION IF EXISTS checkPaten;

-- Prüft, ob ein Tier schon einen Paten hat
-- Eingabeparameter: tiere_id
-- Rückgabewert: Boolean
-- Wird in der Prozedur neuerPate verwendet
DELIMITER $$
CREATE FUNCTION checkPaten(p_tiere_id INT) RETURNS BOOLEAN
READS SQL DATA
BEGIN
	DECLARE tier_paten INT DEFAULT NULL;
    
	SELECT tiere_id
	FROM patenschaften
	WHERE tiere_id = p_tiere_id
	into tier_paten;
     
	IF (tier_paten IS NULL) THEN 
		RETURN FALSE;
	ELSE 
		RETURN TRUE;
	END IF;
END$$
DELIMITER ;

-- Aufruf:
-- SELECT checkPaten(1);
-- SELECT checkPaten(5);


DROP FUNCTION IF EXISTS freiePlätze;

-- Berechnet, wie viele Plätze in einem Gehege frei sind
-- Eingabeparameter: gehege_nr
-- Rückgabewert: Integer
-- Wird im Trigger check_gehege_kapazität verwendet
DELIMITER $$
CREATE FUNCTION freiePlätze(p_gehege_nr INT) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE capacity INT DEFAULT 0;
	DECLARE belegung INT DEFAULT 0;
    DECLARE freiePlätze INT DEFAULT 0;
    
    -- Speichert die Kapazität in die Variable capacity
	SELECT kapazität
    FROM gehege
    WHERE gehege_nr = p_gehege_nr
    INTO capacity;

	-- Speichert die Anzahl der Tiere, die in diesem Gehege leben
    SELECT COUNT(*)
    FROM tiere
	WHERE gehege_nr = p_gehege_nr
    INTO belegung;
    
    -- Rechnet die Anzahl der freien Plätze aus
    SET freiePlätze = capacity - belegung;
    
    -- Prüft, ob die Anzahl der freien Plätze größer als 0 ist
    IF (freiePlätze IS NOT NULL AND freiePlätze > 0) THEN
		RETURN freiePlätze;
	ELSE
		RETURN 0;
    END IF;

END$$
DELIMITER ;

-- Aufruf:
-- SELECT freiePlätze(2);


DROP PROCEDURE IF EXISTS alleTiere;

-- Berechnet, wie viele Tiere im Zoo leben und zeigt alle Tiere an
-- Kein Eingabeparameter
-- Rückgabewert: Integer
DELIMITER $$

CREATE PROCEDURE alleTiere
	(OUT totalTiere INT)
    READS SQL DATA
BEGIN
    
    SELECT tiere_id AS 'ID', tier_name AS 'Name', tierart AS Tierart, kategorie_name AS Kategorie
	FROM tiere JOIN arten
    ON tiere.arten_id = arten.arten_id
    JOIN kategorie
    ON kategorie.kategorie_id = tiere.kategorie_id
	ORDER BY tiere_id;
    
	SELECT COUNT(*)
	INTO totalTiere
    FROM tiere;
    
END$$

DELIMITER ;

-- Aufruf:
-- CALL alleTiere(@count);
-- SELECT @count AS AnzahlTiere;


DROP PROCEDURE IF EXISTS neuerPate;

-- Fügt eine neue Zeile in Paten und Patenschaften ein
-- Eingabeparameter: vorname, nachname, email_adresse, tiere_id, betrag
-- Wird in unserer Schnittstelle verwendet
DELIMITER $$
CREATE PROCEDURE `neuerPate`
	(IN p_vorname VARCHAR(60), 
    IN p_nachname VARCHAR(60),
    IN p_email_adresse VARCHAR(255),
    IN p_tiere_id INT,
    IN p_betrag DECIMAL(10,2))
    MODIFIES SQL DATA
BEGIN    
	DECLARE neuerPateID INT;
	
    -- Prüft, ob Tier schon einen Paten hat
    IF checkPaten(p_tiere_id) = 0 THEN
		INSERT INTO paten (vorname, nachname, email_adresse) 
		VALUES (p_vorname, p_nachname, p_email_adresse);
		
		SELECT LAST_INSERT_ID()
		INTO neuerPateID;
		
		INSERT INTO patenschaften (paten_id, tiere_id, datum, betrag) VALUES 
		(neuerPateID, p_tiere_id, CURDATE(), p_betrag);
	ELSE
		SELECT CONCAT('Das Tier mit der ID ', p_tiere_id, ' hat schon einen Paten. Such dir bitte ein anderes Tier aus der Tabelle aus.') AS 'Fehler';
	END IF;

END$$
DELIMITER ;

-- Aufruf:
-- CALL neuerPate('max', 'muster', 'maxmus@web.de', 1, '150.00');


DROP PROCEDURE IF EXISTS tierDetails;

-- Gibt alle Details von einem Tier aus
-- Eingabeparameter: tiere_id
DELIMITER $$
CREATE PROCEDURE tierDetails(IN p_tiere_id INT)
READS SQL DATA
BEGIN
  SELECT tiere_id AS ID, tier_name AS 'name', t.geburtsdatum, t.geschlecht, t.größe, t.gewicht, a.tierart, k.kategorie_name, t.gehege_nr, g.gehege_name
  FROM tiere t JOIN kategorie k 
  ON t.kategorie_id = k.kategorie_id
  JOIN arten a
  ON t.arten_id = a.arten_id
  JOIN gehege g 
  ON t.gehege_nr = g.gehege_nr
  WHERE t.tiere_id = p_tiere_id;
END$$
DELIMITER ;

-- Aufruf:
-- CALL tierDetails(1);


DROP PROCEDURE IF EXISTS TierePatenlos;

-- Berechnet, wie viele Tiere keine Paten haben und zeigt diese Tiere an
-- Kein Eingabeparameter
-- Rückgabewert: Integer
DELIMITER $$
CREATE PROCEDURE TierePatenlos
	(OUT patenlos INT)
    READS SQL DATA
BEGIN
    
    SELECT tiere.tiere_id AS ID, tier_name AS 'Name', arten.tierart AS Tierart, kategorie.kategorie_name AS Kategorie
	FROM kategorie JOIN tiere
	ON kategorie.kategorie_id = tiere.kategorie_id 
	AND checkPaten(tiere.tiere_id) = FALSE
	JOIN arten
    ON tiere.arten_id = arten.arten_id
	ORDER BY kategorie_name;

    SELECT COUNT(*)
	FROM tiere
	WHERE checkPaten(tiere.tiere_id) = FALSE
	INTO patenlos;

END$$
DELIMITER ;

-- Aufruf:
-- CALL TierePatenlos(@count);
-- SELECT @count AS Anzahl_Patenlos;


DROP PROCEDURE IF EXISTS zeigePaten;

-- Gibt Name und ID von einem Paten an, der zu diesem Tier gehört
-- Eingabeparameter: tiere_id
-- Rückgabewert: Nachricht 'checkP' VARCHAR(255)
DELIMITER $$
CREATE PROCEDURE `zeigePaten`
	(IN p_tiere_id INT, 
	OUT checkP VARCHAR(200))
    READS SQL DATA
BEGIN
	DECLARE tier_paten INT DEFAULT NULL;
    DECLARE paten_name VARCHAR(200);
    DECLARE paten_id INT;
    
    -- Speichert die tiere_id in tier_paten, die dem Eingabeparameter entspricht
	SELECT tiere_id
	FROM patenschaften
	WHERE tiere_id = p_tiere_id
	into tier_paten;
     
	-- Ausgabe, wenn zu diesem Tier keine Patenschaft besteht
	IF (tier_paten IS NULL) THEN 
		SET checkP = 'Tier hat keinen Paten';
	-- Ausgabe, wenn zu diesem Tier eine Patenschaft besteht
	ELSE 
		SELECT CONCAT (p.vorname, ' ', p.nachname)
		FROM patenschaften ps JOIN paten p
		ON ps.tiere_id = p_tiere_id
			AND ps.paten_id = p.paten_id
		into paten_name;
        
        SELECT p.paten_id
		FROM patenschaften ps JOIN paten p
		ON ps.tiere_id = p_tiere_id
			AND ps.paten_id = p.paten_id
		into paten_id;
        
		SET checkP = CONCAT('Tier hat einen Paten namens ', paten_name, ' mit der Paten ID ', paten_id);
	END IF;
END$$
DELIMITER ;

-- Aufruf:
-- Call zeigePaten(1,@checkP);
-- Select @checkP AS Paten;
-- Call zeigePaten(5,@checkP);
-- Select @checkP AS Paten;


-- Trigger prüft vor dem Einfügen, wie viele Patenschaften dieser Pate schon hat
-- Falls ein Pate schon 3 Patenschaften hat, wird der Pate nicht hinzugefügt
DELIMITER $$
CREATE TRIGGER check_paten_count
BEFORE INSERT ON patenschaften
FOR EACH ROW
BEGIN
  DECLARE paten_count INT;
  
  -- Zähle die Anzahl der Patenschaften des aktuellen Paten
  SELECT COUNT(*) 
  FROM patenschaften
  WHERE paten_id = NEW.paten_id
  INTO paten_count;
  
  -- Überprüfe, ob die Anzahl der Patenschaften bereits 3 erreicht hat
  IF paten_count >= 3 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Dieser Pate hat schon drei Patenschaften.';
  END IF;
END $$

-- Trigger prüft vor dem Einfügen, für wie viele Gehege diese*r Mitarbeiter*in zuständig ist
-- Falls er oder sie schon für 2 Gehege zuständig ist, wird das Statement nicht eingefügt
CREATE TRIGGER check_mitarbeiter_count
BEFORE INSERT ON verantwortlich
FOR EACH ROW
BEGIN
  DECLARE mitarbeiter_count INT;
  
  -- Zähle die Anzahl der Vorkommen von Mitarbeiter*in
  SELECT COUNT(*) 
  FROM verantwortlich
  WHERE mitarbeiter_id = NEW.mitarbeiter_id
  INTO mitarbeiter_count;
  
  -- Überprüfe, ob die Anzahl der Vorkommen bereits 2 erreicht hat
  IF mitarbeiter_count >= 2 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Mitarbeiter*in ist schon für zwei Gehege verantwortlich.';
  END IF;
END $$

-- Trigger prüft vor dem Einfügen, ob das Gehege schon voll ist
CREATE TRIGGER check_gehege_kapazität
BEFORE INSERT ON tiere
FOR EACH ROW
BEGIN
  DECLARE anzahl_tiere INT;
  DECLARE max_kapazität INT;
  
  -- Überprüfe, ob die Anzahl der freien Plätze 0 ist
  IF freiePlätze(NEW.gehege_nr) <= 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Dieses Gehege ist schon voll.';
  END IF;
END $$

-- Trigger prüft vor dem Verändern, ob das Gehege schon voll ist
CREATE TRIGGER check_gehege_kapazität2
BEFORE UPDATE ON tiere
FOR EACH ROW
BEGIN
  DECLARE anzahl_tiere INT;
  DECLARE max_kapazität INT;
  
  -- Überprüfe, ob die Anzahl der freien Plätze 0 ist
  IF freiePlätze(NEW.gehege_nr) <= 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Dieses Gehege ist schon voll.';
  END IF;
END $$

-- Trigger prüft vor dem Einfügen, ob die Klasse des Mitarbeiters mit der Gefahrenklasse des Geheges übereinstimmt
CREATE TRIGGER check_gefahrenklasse
BEFORE INSERT ON verantwortlich
FOR EACH ROW
BEGIN
  DECLARE checkGK INT;
  
  -- Zähle, wie oft diese*r Mitarbeiter*in mit dieser Gehegenummer vorkommt, 
  -- wenn die Klasse mit der Gefahrenklasse übereinstimmt
  SELECT COUNT(*)
  FROM mitarbeiter, gehege
  WHERE NEW.mitarbeiter_id = mitarbeiter.mitarbeiter_id
  AND NEW.gehege_nr = gehege.gehege_nr
  AND mitarbeiter.klasse = gehege.gefahrenklasse
  INTO checkGK;
  
  -- Überprüfe, ob die Anzahl der Zeilen 0 ist
  IF checkGK <= 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Gefahrenklasse stimmt nicht überein.';
  END IF;
END $$


-- Event prüft jeden Tag, ob eine Patenschaft heute schon seit genau einem Jahr besteht
CREATE EVENT check_patenschaft_jubilaeum
ON SCHEDULE EVERY 1 DAY
DO
  BEGIN
    DECLARE heute DATE;
    DECLARE jubilaeum DATE;
    DECLARE newPatenID INT;
    DECLARE newTierID INT;
    
    SET heute = CURDATE();
    SET jubilaeum = DATE_SUB(heute, INTERVAL 1 YEAR);
    
    SELECT paten_id
    FROM patenschaften
    WHERE patenschaften.datum = jubilaeum
    INTO newPatenID;
    
    SELECT tiere_id
    FROM patenschaften
    WHERE patenschaften.datum = jubilaeum
    INTO newTierID;

	-- Wenn die Patenschaft seit genau einem Jahr besteht, wird ein Eintrag in die Tabelle 'jubilaeum' eingefügt
    IF newPatenID IS NOT NULL AND newTierID IS NOT NULL THEN
       INSERT INTO jubilaeum(nachricht, erstellt) 
       VALUES (CONCAT('Die Patenschaft mit dem Paten ', newPatenID, ' und dem Tier ', newTierID, ' besteht seit einem Jahr.'), NOW());
    END IF;
  END$$