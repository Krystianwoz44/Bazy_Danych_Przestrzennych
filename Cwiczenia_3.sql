CREATE DATABASE Cw_3_PostGis;
CREATE EXTENSION postgis;

-- Zad nr 1

-- bin path added to env variable
-- shp2pgsql -s 4326 "T2018_KAR_BUILDINGS" public.buildings_2018 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2019_KAR_BUILDINGS" public.buildings_2019 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2018_KAR_POI_TABLE" public.poi_2018 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2019_KAR_POI_TABLE" public.poi_2019 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2019_KAR_STREETS" public.streets_2019 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2019_KAR_STREET_NODE" public.streets_node_2019 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2019_KAR_LAND_USE_A" public.land_2019 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2019_KAR_WATER_LINES" public.water_lines_2019 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis
-- shp2pgsql -s 4326 "T2019_KAR_RAILWAYS" public.railways_2019 | psql -h localhost -p  5432 -U postgres -d cw_3_postgis



CREATE TABLE changed_buildings AS
SELECT b2019.*
FROM buildings_2018 b2018
RIGHT JOIN buildings_2019 b2019 
ON ST_Equals(b2018.geom, b2019.geom)
WHERE b2018.geom IS NULL OR NOT ST_Equals(b2018.geom, b2019.geom);



ALTER TABLE buildings_2018
  RENAME COLUMN type TO category;
  
ALTER TABLE buildings_2019
  RENAME COLUMN type TO category;

ALTER TABLE poi_2019
  RENAME COLUMN type TO poi_category;

ALTER TABLE poi_2019
  RENAME COLUMN category TO poi_category;

--Zad nr 2

SELECT poi_category, COUNT(DISTINCT poi_id)
FROM changed_buildings b
JOIN poi_2019
ON ST_DWithin(b.geom, poi_2019.geom, 0.005)
GROUP BY poi_category;

select * from poi_2019;
select * from streets_2019;


--Zad nr 3

CREATE TABLE streets_reprojected AS
SELECT * FROM streets_2019;

SELECT UpdateGeometrySRID('streets_reprojected', 'geom', 3068)


--Zad nr 4

CREATE TABLE input_points (
    id SERIAL PRIMARY KEY,
    geom GEOMETRY(Point)
);

INSERT INTO input_points (geom)
VALUES 
    (ST_MakePoint(8.36093, 49.03174)),
    (ST_MakePoint(8.39876, 49.00644));


--Zad nr 5

SELECT UpdateGeometrySRID('input_points', 'geom', 3068)

ALTER TABLE input_points
  RENAME COLUMN id TO iden;

--Zad nr 6

SELECT UpdateGeometrySRID('streets_node_2019', 'geom', 3068)

WITH buffered_line AS (
    SELECT ST_Buffer(ST_MakeLine(p.geom ORDER BY iden), 0.002) AS buffer_geom
    FROM input_points p
)
SELECT n.*
FROM streets_node_2019 n, buffered_line b
WHERE ST_Contains(b.buffer_geom, n.geom);

--Zad nr 7

SELECT UpdateGeometrySRID('poi_2019', 'geom', 3068);
SELECT UpdateGeometrySRID('land_2019', 'geom', 3068);

WITH buffer AS (
    SELECT ST_Buffer(l.geom, 0.003) AS buffer_geom
    FROM land_2019 l
	WHERE l.type = 'Park (City/County)'
)
SELECT COUNT(DISTINCT p.gid)
FROM poi_2019 p, buffer b
WHERE ST_Contains(b.buffer_geom, p.geom) AND p.poi_category = 'Sporting Goods Store';


--Zad nr 8

CREATE TABLE T2019_KAR_BRIDGES AS
SELECT ST_Intersection(r.geom, w.geom) AS geom
FROM railways_2019 r
JOIN water_lines_2019 w ON ST_Intersects(r.geom, w.geom);
