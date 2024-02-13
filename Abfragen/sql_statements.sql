-- SQL Statements

-- Welcher drei Mitarbeiter betreuen die meisten Tiere?
SELECT m.mitarbeiter_id AS 'ID', CONCAT(m.vorname, ' ', m.nachname) AS 'Name', COUNT(t.tiere_id) AS Anzahl_Tiere
FROM tiere t JOIN gehege g
ON t.gehege_nr = g.gehege_nr
JOIN verantwortlich v
ON g.gehege_nr = v.gehege_nr
JOIN mitarbeiter m
ON v.mitarbeiter_id = m.mitarbeiter_id
GROUP BY m.mitarbeiter_id
ORDER BY Anzahl_Tiere DESC
LIMIT 3;

-- Welche Mitarbeiter*innen füttern Tiere mit Fleisch?
SELECT DISTINCT m.mitarbeiter_id AS 'ID', CONCAT(m.vorname, ' ', m.nachname) AS 'Name', klasse
FROM mitarbeiter m
JOIN verantwortlich v
ON m.mitarbeiter_id = v.mitarbeiter_id
JOIN tiere t
ON v.gehege_nr = t.gehege_nr
JOIN fressen fr
ON t.arten_id = fr.arten_id
JOIN futter f
WHERE fr.futter_id = f.futter_id 
AND f.sorte = 'Fleisch';

-- Welches Futter wird von wie vielen Tieren gegessen?
SELECT f.sorte AS 'Futtersorte', COUNT(*) AS Anzahl_Tiere
FROM futter f JOIN fressen fr
ON f.futter_id = fr.futter_id
JOIN tiere t
ON fr.arten_id = t.arten_id
GROUP BY f.sorte
ORDER BY Anzahl_Tiere DESC;

-- Welche Tiere sind älter als 20 Jahre und schwerer als 1000kg?
SELECT t.tiere_id, t.tier_name, a.tierart, k.kategorie_name AS kategorie, t.geburtsdatum, TIMESTAMPDIFF(YEAR, geburtsdatum, CURDATE()) AS 'Alter', t.gewicht
FROM tiere t JOIN kategorie k
ON k.kategorie_id = t.kategorie_id
JOIN arten a 
ON t.arten_id = a.arten_id
WHERE TIMESTAMPDIFF(YEAR, geburtsdatum, CURDATE()) > 20
AND t.gewicht > 1000
ORDER BY kategorie, tierart;

-- Welche Gehege haben die meisten freien Plätze?
SELECT g.gehege_nr, freiePlätze(g.gehege_nr) AS freie_plätze
FROM gehege g JOIN tiere t
ON g.gehege_nr = t.gehege_nr
GROUP BY gehege_nr
ORDER BY freie_plätze DESC
LIMIT 3;

-- Welches Gehege hat die meisten Mitarbeiter?
SELECT g.gehege_nr, g.gehege_name, COUNT(*) AS Anzahl_Mitarbeiter
FROM gehege g JOIN verantwortlich v
ON g.gehege_nr = v.gehege_nr
JOIN mitarbeiter m
ON v.mitarbeiter_id = m.mitarbeiter_id
GROUP BY gehege_nr
ORDER BY Anzahl_Mitarbeiter DESC
LIMIT 1;

-- Welcher Pate zahlt den höchsten Betrag und wie viele Tiere hat er oder sie?
SELECT p.paten_id AS 'ID', CONCAT(p.vorname, ' ', p.nachname) AS 'Name', SUM(ps.betrag) AS Gesamt_Betrag, COUNT(ps.tiere_id) AS Anzahl_Tiere
FROM paten p 
JOIN patenschaften ps 
ON p.paten_id = ps.paten_id
GROUP BY p.paten_id
ORDER BY Gesamt_Betrag DESC
LIMIT 1;

-- Welche Patenschaft besteht schon am längsten und welches Tier gehört zu ihm oder ihr?
SELECT p.paten_id AS 'ID', CONCAT(p.vorname, ' ', p.nachname) AS 'Name', ps.datum AS 'Seit', t.tiere_id, t.tier_name, a.tierart
FROM patenschaften ps
JOIN paten p
ON p.paten_id = ps.paten_id
AND ps.datum = (SELECT MIN(datum) FROM patenschaften)
JOIN tiere t 
ON ps.tiere_id = t.tiere_id
JOIN arten a
ON t.arten_id = a.arten_id;