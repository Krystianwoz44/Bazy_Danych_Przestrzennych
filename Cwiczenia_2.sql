create database CW2_PostGis_2;
create extension postgis;


create table roads (id int, geometry geometry, name varchar(50));
create table buildings (id int, geometry geometry, name varchar(50));
create table poi (id int, geometry geometry, name varchar(50));


insert into roads (id, name, geometry) values
(1, 'RoadX', 'LINESTRING(0 4.5, 12 4.5)'),
(2, 'RoadY', 'LINESTRING(7.5 10.5, 7.5 0)');
select * from roads

insert into buildings (id, name, geometry) values
(1, 'BuildingA', 'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))'),
(2, 'BuildingB', 'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))'),
(3, 'BuildingC', 'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))'),
(4, 'BuildingD', 'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))'),
(5, 'BuildingE', 'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))');

select * from buildings;

insert into poi (id, name, geometry) values
(1, 'G', 'POINT(1 3.5)'),
(2, 'H', 'POINT(5.5 1.5)'),
(3, 'I', 'POINT(9.5 6)'),
(4, 'J', 'POINT(6.5 6)'),
(5, 'K', 'POINT(6 9.5)');

select * from poi;

--Zadanie 6.

--A)

SELECT SUM(ST_Length(geometry)) AS total_road_length FROM roads;

--B)

SELECT ST_AsText(geometry) AS geometry_wkt, ST_Area(geometry) AS area, ST_Perimeter(geometry) AS perimeter
FROM buildings
WHERE name = 'BuildingA';


--C)

SELECT name, ST_Area(geometry) AS area
FROM buildings
ORDER BY name;


--D)

SELECT name, ST_Perimeter(geometry) AS perimeter
FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2;


--E)

SELECT ST_Distance(b.geometry, p.geometry) AS shortest_distance
FROM buildings b, poi p
WHERE b.name = 'BuildingC' AND p.name = 'K';


--F)

SELECT ST_Area(ST_Difference(b1.geometry, ST_Buffer(b2.geometry, 0.5))) AS area
FROM buildings b1, buildings b2
WHERE b1.name = 'BuildingC' AND b2.name = 'BuildingB';


--G)

SELECT b.name
FROM buildings b, roads r
WHERE r.name = 'RoadX' AND ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_Centroid(r.geometry));


--H)

WITH polygon AS (
    SELECT ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))') AS geom
)
SELECT ST_Area(ST_SymDifference(b.geometry, p.geom)) AS area
FROM buildings b, polygon p
WHERE b.name = 'BuildingC';
