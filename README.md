# P_BULLE_Docker
1. Container MySQL
======
`docker pull mysql/mysql-server:5.7` -> **pull l'image mysql-server**  
`docker images` -> **Permet de check si l'image a bien été ajouté**  
`docker run --name mysql1 -e MYSQL_USER=root -e MYSQL_PASSWORD=root -e MYSQL_DATABASE=homedb -p 3306:3306 -d mysql/mysql-server:5.7` -> **crée le conteneur docker**   
`docker ps` -> **Permet de check que le conteneur a bien été crée**  
`docker logs mysql1 2>&1 | FindStr GENERATED` -> **Génére un mot de passe aléatoire**  
`windthy docker exec -it mysql1 mysql -uroot -p` -> **Se connecte au conteneur docker**  
`ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';` -> **Change le mot de passe pour root**  
`CREATE USER 'root'@'%' IDENTIFIED BY 'root';` -> **permet de créer un utilisateur**  
`GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;` -> **Donne tout les privilèges à root**  
Source : [create a MySQL Container](https://www.devgi.com/2018/11/install-mysql-docker-windows.html)
