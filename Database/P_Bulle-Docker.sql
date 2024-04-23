DROP DATABASE IF EXISTS db_bulle_docker;

CREATE DATABASE db_bulle_docker;

USE db_bulle_docker;

CREATE TABLE t_player (
   id_player INT(6),
   username VARCHAR(255),
   colorSkin VARCHAR(255),
   skin VARCHAR(255),
   PRIMARY KEY(id_player)
);

INSERT INTO t_player(id_player, username, colorSkin, skin) VALUES
(1, 'root', 'red', ''),
(2, 'etml', 'blue', ''),
(3, 'root', 'green', '');

CREATE TABLE t_score (
   id_score INT(6),
   score INT,
   fk_player INT(6) NOT NULL,
   PRIMARY KEY(id_score),
   FOREIGN KEY(fk_player) REFERENCES t_player(id_player)
);

INSERT INTO t_score(id_score, score, fk_player) VALUES
(1, 10, 1),
(2, 5, 3),
(3, 4, 2);
