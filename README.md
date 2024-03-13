# P_BULLE_Docker
Application with the library .NET
======
## 1. Résumé de l'application
Mon application est une app en APS.NET qui est donc une application Web avec du HTML, CSS, JS et du C#.  
Elle consiste a recrée en tout cas un niveau du célébre jeux mobile 'Geometry Dash' avec pour l'instant uniquement un seul niveau.  
Donc cela sera une application en 2 dimensions. 
Vu le temps imposé c'est compliqué de finire mais le but est de dockeriser l'application ASP.NET et la base de données MySQL.
Dans ce Readme le but est de présenter les conteneurs utilisé et présenter le dockerfile.
Pour avoir plus d'information sur APS.NET : [APS.NET Dcoumentation](https://dotnet.microsoft.com/en-us/apps/aspnet)

&nbsp;Languages, Framework and Tools 🛠
------
![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?&style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/css3-%231572B6.svg?&style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/javascript-%23F7DF1E.svg?&style=for-the-badge&logo=javascript&logoColor=black)
![C#](https://img.shields.io/badge/c%23-%23239120.svg?style=for-the-badge&logo=csharp&logoColor=white)

![.Net](https://img.shields.io/badge/.NET-5C2D91?style=for-the-badge&logo=.net&logoColor=white)

![Visual Studio](https://img.shields.io/badge/Visual%20Studio-5C2D91.svg?style=for-the-badge&logo=visual-studio&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)

![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)
        
Container utilisé
======
# 1. Container MySQL
* `docker pull mysql:latest` -> **pull l'image mysql**  
* `docker images` -> **Permet de check si l'image a bien été ajouté**  
* `docker run --name mysql -e MYSQL_USER=root -e MYSQL_PASSWORD=root -e MYSQL_DATABASE=mysqldatabaser -p 3306:3306 -d mysql` -> **crée le conteneur docker**   
* `docker ps` -> **Permet de check que le conteneur a bien été crée**
* `docker exec -i mysql mysql -uroot -proot` -> **Permet de se connecter**
**Source : [create a MySQL Container](https://www.devgi.com/2018/11/install-mysql-docker-windows.html)**  
# 2. Container APS.NET
* Avant de commencer vérifier que APS.NET a bien été téléchaargé sinon Visual Studio Installer -> Visual Studio 2022 -> Modifier -> APS.NET -> Installer
* Ouvrez Visual Studio et sélectionnez Nouveau projet.
* Créer un projet -> Application web ASP.NET Core(La première proposition) -> Suivant.
* Entrer le nom de votre projet -> Suivant
* Sélectionnez .NET 6.0 ou plus -> Vérifier que les instructions de niveau supérieur est décochée -> Cliquer Crée
* Sélectionnez RazorPagesMovie dans l’Explorateur de solutions, puis appuyez sur Ctrl+F5 pour l’exécuter sans le débogueur.
* Ensuite pour Run le projet Ctrl + F5
* Une fenêtre apparaît sur les certificats SSL d'IIS Express si vous leur faites confiance cliquer Oui sinon Non
* Une fenêtre apparait sur le certificat de développement si vous leur faites confiance cliquer sur Oui sinon sur Non
* Après une fenêtre de navigateur va s'afficher avec votre application Web afficher.  
**Source : [create a APS.NET Container](https://learn.microsoft.com/fr-fr/aspnet/core/tutorials/razor-pages/razor-pages-start?view=aspnetcore-8.0&tabs=visual-studio)**

Dockerfile
======
```dockerfile
# Il utilise l'image de base mcr.microsoft.com/dotnet/aspnet:6.0, qui contient l'environnement d'exécution ASP.NET Core.
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["P_Bulle_Docker.csproj", "."]
RUN dotnet restore "./P_Bulle_Docker.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "P_Bulle_Docker.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "P_Bulle_Docker.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "P_Bulle_Docker.dll"]
```
