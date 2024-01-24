# P_BULLE_Docker
Container MySQL
======
`docker pull mysql/mysql-server:5.7` -> **pull the docker image**  
`docker images` -> **Check docker image**  
`docker run --name mysql1 -e MYSQL_USER=root -e MYSQL_PASSWORD=root -e MYSQL_DATABASE=homedb -p 3306:3306   
-d mysql/mysql-server:5.7` -> **Run mysql instance**   
`docker ps` -> **Check docker processes**  
`docker logs mysql1 2>&1 | FindStr GENERATED` -> **Generate a random password**  
`windthy docker exec -it mysql1 mysql -uroot -p` -> **Connect to the MySQL container**  
`ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';` -> **Change the password**  
`CREATE USER 'root'@'%' IDENTIFIED BY 'root';` -> **Create a user**  
`GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;` -> **Give all priviligies to root**  
Source : [create a MySQL Container](https://www.devgi.com/2018/11/install-mysql-docker-windows.html)
