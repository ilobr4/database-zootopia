DROP VIEW IF EXISTS gehege_futter;

-- Erstellt eine View, die anzeigt, was jede Tierart frisst und welches Futter in welchen Gehegen vorhanden sein muss
CREATE VIEW gehege_futter AS 
SELECT g.gehege_nr, g.gehege_name AS 'Name', a.tierart AS 'Tierart', f.sorte AS 'Futtersorte'
FROM gehege g
JOIN tiere t 
ON g.gehege_nr = t.gehege_nr
JOIN arten a
ON t.arten_id = a.arten_id
JOIN fressen fr
ON a.arten_id = fr.arten_id
JOIN futter f
ON fr.futter_id = f.futter_id
GROUP BY g.gehege_nr, g.gehege_name, a.tierart, f.sorte
ORDER BY g.gehege_nr;


DROP VIEW IF EXISTS gehege_mitarbeiter;

-- Erstellt eine View, die anzeigt, welche Mitarbeiter*innen in welchen Gehegen arbeiten
CREATE VIEW gehege_mitarbeiter AS 
SELECT m.mitarbeiter_id AS 'ID', CONCAT(m.nachname, ', ', m.vorname) AS 'Name', m.klasse, g.gehege_nr, g.gehege_name, g.bezeichnung, gefahrenklasse
FROM mitarbeiter m
JOIN verantwortlich v
ON m.mitarbeiter_id = v.mitarbeiter_id 
JOIN gehege g
ON v.gehege_nr = g.gehege_nr
ORDER BY m.nachname;


DROP VIEW IF EXISTS gehege_tiere;

-- Erstellt eine View, die anzeigt, welche und wie viele Tiere in den Gehegen leben
-- Wird auf unserer Website verwendet
CREATE VIEW gehege_tiere AS 
SELECT DISTINCT g.gehege_nr, g.gehege_name AS Gehege, a.tierart AS 'Tierart', COUNT(a.tierart) AS 'Anzahl'
FROM gehege g JOIN tiere t
ON g.gehege_nr = t.gehege_nr
JOIN arten a
ON t.arten_id = a.arten_id
GROUP BY g.gehege_nr, g.gehege_name, a.tierart
ORDER BY g.gehege_nr;


DROP VIEW IF EXISTS tiere_ohne_paten;

-- Erstellt eine View, die die Tier anzeigt, welche noch keinen Paten haben
-- Wird auf unserer Website verwendet
CREATE VIEW tiere_ohne_paten AS 
SELECT t.tiere_id AS ID, t.tier_name AS 'Name', a.tierart AS Tierart, k.kategorie_name AS Kategorie,  
	   t.geschlecht AS Geschlecht, TIMESTAMPDIFF(YEAR, t.geburtsdatum, CURDATE()) AS 'Alter'
FROM kategorie k JOIN tiere t
ON k.kategorie_id = t.kategorie_id 
	AND t.tiere_id NOT IN
			(SELECT tiere_id
			FROM patenschaften)
JOIN arten a
ON t.arten_id = a.arten_id
ORDER BY k.kategorie_name, a.tierart, t.tiere_id;