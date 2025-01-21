create database fme_rasters_cw8;

create extension postgis;
create extension postgis_raster;


create table wynik (geom geometry);
insert into wynik select st_union(geom) from "Exports";
select * from wynik;