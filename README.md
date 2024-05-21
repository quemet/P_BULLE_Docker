# P_BULLE_Docker

## Application avec .NET

### 1. Résumé de l'application

Mon application est une app en APS.NET qui est donc une application Web avec du HTML, CSS, JS et du C#.  
Elle consiste a recrée en tout cas un niveau du célébre jeux mobile 'Geometry Dash' avec pour l'instant uniquement un seul niveau.  
Donc cela sera une application en 2 dimensions. 
Vu le temps imposé c'est compliqué de finire mais le but est de dockeriser l'application ASP.NET et la base de données MySQL.
Dans ce Readme le but est de présenter le projet, pour avois plus d'information. Veuillez consulter [la documentation](./P_Bulle_Docker-ASP.NET/Documentation.md)
Pour avoir plus d'information sur APS.NET : [APS.NET Dcoumentation](https://dotnet.microsoft.com/en-us/apps/aspnet)

### &nbsp; 2. Languages, Framework and Outils 🛠

![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?&style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/css3-%231572B6.svg?&style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/javascript-%23F7DF1E.svg?&style=for-the-badge&logo=javascript&logoColor=black)
![C#](https://img.shields.io/badge/c%23-%23239120.svg?style=for-the-badge&logo=csharp&logoColor=white)

![.Net](https://img.shields.io/badge/.NET-5C2D91?style=for-the-badge&logo=.net&logoColor=white)

![Visual Studio](https://img.shields.io/badge/Visual%20Studio-5C2D91.svg?style=for-the-badge&logo=visual-studio&logoColor=white)
![Visual Studio Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)

![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)

### 3. Nouveau Projet ?

Nous avions un premier projet dans le but était de conteneriser une application .NET.  
J'ai donc choisi une application ASP.NET au dans le projet de base.  
Un deuxième projet a suivi est dans celui ci il a fallu conteneriser l'environment de développement avec.  
Pour avoir plus d'information, veuillez consulter [la documentation](./P_Bulle_Docker-ASP.NET/Documentation.md)

### 4. Explication des commandes de base Dockerfile

* CMD	-> Spécifiez les commandes par défaut.
* COPY -> Permet de copier un dossier ou des fichiers.
* ENTRYPOINT -> Spécifiez l'exécutable par défaut.
* ENV	-> Permet de mettre des variables d'environment.
* EXPOSE -> Expose un port comme le 80.
* FROM -> Crée une nouvelle étape comme le build / deploiement à partir d'une image de base.
* RUN	-> Execute des commandes.
* WORKDIR	-> Change le répertoire de travail.

### 5. Explication des commande de base docker-compose

version -> Permet de définir la version
services -> Permet de définir les services à utiliser
image -> Défini l'image de base
environment -> Défini les variables d'environment
ports -> Défin les différents ports
volumes -> Défini des volumes
build -> Permet de définir des options pour build sa propre image depuis le docker-compose
  context -> Option de build permet de passer un chemin
  dockerfile -> Option de build permet de passer le nom du Dockerfile
  target -> Défin quelle étape du Dockerfile
depends_on -> Service qui dépend d'autres services
networks -> Spécifie le réseaux
