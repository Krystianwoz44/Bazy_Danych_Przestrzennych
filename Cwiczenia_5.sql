CREATE DATABASE bdp_cw4;
CREATE EXTENSION postgis;


-- Zadanie nr 1
CREATE TABLE obiekty (
    nazwa TEXT,
    geometria GEOMETRY
);


INSERT INTO obiekty (nazwa, geometria)
VALUES 
('obiekt1', ST_Collect(ARRAY[
ST_GeomFromText('LINESTRING(0 1, 1 1)'), 
ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)'), 
ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)'), 
ST_GeomFromText('LINESTRING(5 1, 6 1)')])),

('obiekt2', ST_Collect(ARRAY[
ST_GeomFromText('LINESTRING(10 6, 14 6)'), 
ST_GeomFromEWKT('CIRCULARSTRING(14 6, 16 4, 14 2)'), 
ST_GeomFromEWKT('CIRCULARSTRING(14 2, 12 0, 10 2)'), 
ST_GeomFromText('LINESTRING(10 2, 10 6)'), 
ST_GeomFromEWKT('CIRCULARSTRING(11 2, 12 3, 13 2)'),
ST_GeomFromEWKT('CIRCULARSTRING(11 2, 12 1, 13 2)')])),

('obiekt3', ST_Collect(ARRAY[
ST_GeomFromText('LINESTRING(7 15, 10 17)'), 
ST_GeomFromText('LINESTRING(10 17, 12 13)'),
ST_GeomFromText('LINESTRING(12 13, 7 15)')])),

('obiekt4', ST_Collect(ARRAY[
ST_GeomFromText('LINESTRING(20 20, 25 25)'), 
ST_GeomFromText('LINESTRING(25 25, 27 24)'),
ST_GeomFromText('LINESTRING(27 24, 25 22)'),
ST_GeomFromText('LINESTRING(25 22, 26 21)'), 
ST_GeomFromText('LINESTRING(26 21, 22 19)'),
ST_GeomFromText('LINESTRING(22 19, 20.5 19.5)')])),

('obiekt5', ST_Collect(ARRAY[
ST_GeomFromText('POINT(30 30 59)'), 
ST_GeomFromText('POINT(38 32 234)')])),

('obiekt6', ST_Collect(ARRAY[
ST_GeomFromText('LINESTRING(1 1, 3 2)'), 
ST_GeomFromText('POINT(4 2)')]));



--Zadanie nr 2
WITH najkrotsza_linia AS (
    SELECT ST_ShortestLine(o1.geometria, o2.geometria) AS linia
    FROM obiekty o1, obiekty o2
    WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4'
)
SELECT ST_Area(ST_Buffer(linia, 5)) AS pole_powierzchni_bufora
FROM najkrotsza_linia;


--Zadanie nr 3
-- Aby obiekt nr 4 stał się poligonem musi byc domknięty
UPDATE obiekty
SET geometria = ST_Collect(geometria, 'LINESTRING(20 20, 20.5 19.5)')
WHERE nazwa = 'obiekt4';

UPDATE obiekty
SET geometria = ST_CollectionExtract(geometria, 3)
WHERE nazwa = 'obiekt4';

SELECT nazwa, ST_GeometryType(geometria)
FROM obiekty
WHERE nazwa = 'obiekt4';

--Zadanie nr 4
INSERT INTO obiekty (nazwa, geometria)
SELECT 'obiekt7', ST_Collect(o1.geometria, o2.geometria)
FROM obiekty o1, obiekty o2
WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4';


--Zadanie nr 5
WITH obiekty_bez_lukow AS (
    SELECT nazwa, ST_Buffer(geometria, 5) AS bufor
    FROM obiekty
    WHERE NOT ST_HasArc(geometria)
)
SELECT nazwa, ST_Area(bufor) AS pole_powierzchni_bufora
FROM obiekty_bez_lukow;

-- zmiana typu geometrii obiektów 1 i 2 w celu wyświetlenia wyniku
UPDATE obiekty
SET geometria = ST_CurveToLine(geometria)
WHERE nazwa = 'obiekt1';

UPDATE obiekty
SET geometria = ST_CurveToLine(geometria)
WHERE nazwa = 'obiekt2';

select * from obiekty order by nazwa;
