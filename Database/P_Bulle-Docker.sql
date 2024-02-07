DROP DATABASE IF EXISTS db_bulle_docker;

CREATE DATABASE db_bulle_docker;

USE db_bulle_docker;

CREATE TABLE t_player (
   id_player VARCHAR(255),
   username VARCHAR(255),
   colorSkin VARCHAR(255),
   skin VARCHAR(255),
   PRIMARY KEY(id_player)
);

CREATE TABLE t_score (
   id_score VARCHAR(255),
   score INT,
   id_player VARCHAR(255) NOT NULL,
   PRIMARY KEY(id_score),
   UNIQUE(id_player),
   FOREIGN KEY(id_player) REFERENCES t_player(id_player)
);
