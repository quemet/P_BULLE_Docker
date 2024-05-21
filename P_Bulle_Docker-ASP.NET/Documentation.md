# P_Bulle_Dev_Docker

## Sommaire des fichiers importants

[Dockerfile pour l'application](Dockerfile)  
[Dockerfile pour les tests](../Dockerfile.test)  
[Script pour la création des containeurs](setup.bat)  
[Script pour lancer l'application (Façon n°1)](build.sh)  
[Script pour lancer l'application (Façon n°2)](launch.sh)  
[Dump pour la créationde la base de données](../Database/P_Bulle-Docker.sql)  
[Fichier source pour les tests unitaires](../test/UnitTest1.cs)  

## Config de docker et des containeurs

Il y a deux façons de faire des containeurs :

### Façon n°1

#### Création du DevContainer

En suivant les étapes suivantes :
![Etape n°1](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_01.png)
On clique sur le bouton de départ "Create new environment"
![Etape n°2](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_02.png)  
On clique à nouveau sur le bouton "Get Started"
![Etape n°3](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_03.png)
Sur cette fenêtre on choisi si on veut un local ou avec git. j'ai choisi de le faire en local
![Etape n°4](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_04.png)
![Etape n°5](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_05.png)
![Etape n°6](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_06.png)  
On attend que docker fasse sont travail.  
![Etape n°7](https://github.com/quemet/P_BULLE_Docker/blob/main/Image/Documentation/Screen_07.png)  
C'est fini le containeur est crée. On peut l'ouvrir avec VS Code.

#### Lancement du programme

Je lance mon programme avec un script en [bash](./build.sh)

```sh
#!/bin/bash

# Crée un tableau avec le nom des images
containers=('application' 'mysql' 'test')

# Crée un tableau avec le nom des containers
images=('p_bulle_docker-aspnet-db' 'p_bulle_docker-aspnet-test' 'p_bulle_docker-aspnet-webapp')

# Affiche un message pour dire à l'utilisateur ce que va faire le script
echo ""
echo "Supprimer les conteneurs..."
echo ""

# Crée une variable qui est l'incrément des étapes
count=1

# Crée une variable avec tout les étapes
total_step=6

# Fais une boucle sur le tableau des containers
for container in "${containers[@]}"
do

    # Affiche l'étape avec le nom du container, le stoppe et le supprimme
    echo ""
    echo "[Step $count/$total_step] En train de supprimer le conteneur $container..."
    sudo docker stop $container
    sudo docker rm $container
    echo "Conteneur $container a été supprimé"
    echo ""

    # Incrémente la valeur de count
    ((count++))
done

# Fais une boucle sur le tableau des images
for image in "${images[@]}"
do

    # Affiche l'étape avec le nom de l'image et la supprimme
    echo ""
    echo "[Step $count/$total_step] En train de supprimer l'image $image..."
    sudo docker rmi $image
    echo "Image $image a été supprimée"
    echo ""

    # Incrémente la valeur de count
    ((count++))
done

# Informe l'utilisateur que les containeurs et images ont été supprimmé
echo ""
echo "Tous les conteneurs et images ont été supprimés."
echo ""


# Informe l'utilisateur que les containerus vont être lancé
echo ""
echo "Démarrage des services avec docker-compose..."
echo ""

# Informe et installe les dépendances de xdg
echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install xdg-utils
echo ""

# Lance le docker-compose pour la création des containeurs
sudo docker-compose up -d

# Ouvre une page web sur l'url suivante
xdg-open 'http://localhost:8080'
```

### Façon n°2

#### Création des containers

Dans la façon numéro 2. Nous démarron nos containeurs avec un [script bat](./setup.bat)

```bat
@echo off
setlocal
REM script permettant de créer des conteneurs docker dynamiquement, les versions et noms de fichiers ne sont pas codés en dur pour détecter ce que vous avez et ce dont vous avez besoin

REM Définir le nom du projet
set "PROJECT_NAME=myprojectdocker"

REM Vérifier si le répertoire test_results existe, sinon le créer
if not exist "test_results" (
    mkdir test_results
)

set "containers=myprojectdocker-db-1,myprojectdocker-dev-1,myprojectdocker-test-1"
set "images=geircode/string_to_hex,myprojectdocker_dev,myprojectdocker_test,mysql"

for %%c in (%containers%) do (
    docker stop %%c
    docker rm %%c
)

for %%i in (%images%) do (
    docker rmi %%i
)

REM Création du fichier docker-compose.yaml
(
echo version: '3.8'
echo services:
echo   db:
echo     image: mysql
echo     environment:
echo       MYSQL_ROOT_PASSWORD: root
echo       MYSQL_DATABASE: mydatabase
echo     ports:
echo       - '3306:3306'
echo     volumes:
echo       - db-data:/var/lib/mysql
echo       - ../Database/P_Bulle-Docker.sql:/docker-entrypoint-initdb.d/P_Bulle-Docker.sql
echo   dev:
echo     build:
echo       context: .
echo       dockerfile: Dockerfile
echo       target: development
echo     ports:
echo       - '9721:80'
echo     volumes:
echo       - .:/app
echo     depends_on:
echo       - db
echo   test:
echo     build:
echo       context: ..
echo       dockerfile: Dockerfile.test
echo     depends_on:
echo       - db
echo     volumes:
echo       - ../test:/app/test
echo       - ./test_results:/app/test_results
echo volumes:
echo   db-data:
echo networks:
echo   default:
) > docker-compose.yml

REM Vérifier l'existence de fichiers .csproj
if not exist "*.csproj" (
    echo Aucun fichier .csproj trouvé dans ce répertoire.
    exit /b
)

REM Trouver le fichier .csproj
for /F "delims=" %%I in ('dir *.csproj /b /a-d') do (
    set "CSPROJ_NAME=%%I"
    goto read_version
)

:read_version
REM Trouver la version de .NET
for /f "tokens=3 delims=<>" %%a in ('findstr /i "<TargetFramework>" %CSPROJ_NAME%') do (
    set "DOTNET_VERSION=%%a"
    REM enlever le "net" de la version
    for /f "tokens=* delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-" %%v in ("%%a") do set "DOTNET_SDK_VERSION=%%v"
    goto find_exe
)

:find_exe
REM tester s'il y a un .exe
if not exist "bin\Debug\%DOTNET_VERSION%\*.exe" (
    echo Aucun fichier .exe trouvé dans bin\Debug\%DOTNET_VERSION%\. Assurez-vous de compiler le projet.
    exit /b
)

REM Trouver le premier fichier .exe dans le répertoire de sortie pour ensuite trouver le nom du dll
for /F "delims=" %%I in ('dir bin\Debug\%DOTNET_VERSION%\*.exe /b /a-d') do (
    set "EXE_NAME=%%~nI"
    goto build_docker
)
echo Génération du Dockerfile avec .NET SDK version: %DOTNET_VERSION%

:build_docker
REM Générer le Dockerfile pour le conteneur de développement
(
echo # syntax=docker/dockerfile:1
echo # Stage 1: Build the application
echo FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
echo WORKDIR /app
echo # Copy csproj and restore as distinct layers
echo COPY ./P_Bulle_Docker.csproj ./
echo RUN dotnet restore ./P_Bulle_Docker.csproj
echo # Copy everything else and build
echo COPY . .
echo RUN dotnet publish ./P_Bulle_Docker.csproj -c Release -o out
echo # Stage 2: Development environment
echo FROM mcr.microsoft.com/dotnet/sdk:6.0 AS development
echo WORKDIR /app
echo COPY --from=build /app/out .
echo ENTRYPOINT ["dotnet", "watch", "--project", "P_Bulle_Docker.csproj"]
echo # Stage 3: Production environment
echo FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS production
echo WORKDIR /app
echo COPY --from=build /app/out .
echo EXPOSE 80
echo RUN dotnet dev-certs https
echo ENTRYPOINT ["dotnet", "P_Bulle_Docker.dll"]
) > Dockerfile

REM Générer le Dockerfile pour le conteneur de test
(
echo # syntax=docker/dockerfile:1
echo FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
echo WORKDIR /app
echo # Copier les dossiers de l'application et des tests
echo COPY P_Bulle_Docker-ASP.NET/ ./P_Bulle_Docker-ASP.NET/
echo COPY test/ ./test/
echo # Restaurer et construire l'application
echo RUN dotnet restore P_Bulle_Docker-ASP.NET/P_Bulle_Docker.csproj
echo RUN dotnet build P_Bulle_Docker-ASP.NET/P_Bulle_Docker.csproj -c Release
echo # Restaurer et construire les tests
echo RUN dotnet restore test/test.csproj
echo RUN dotnet build test/test.csproj -c Release
echo # Définir le répertoire de travail pour les tests
echo WORKDIR /app/test
echo # Définir la commande pour exécuter les tests et enregistrer les résultats
echo CMD ["dotnet", "test", "test.csproj", "--logger", "trx;LogFileName=test_results.trx", "--results-directory", "/app/test_results"]
) > ../Dockerfile.test

REM Démarrer les services
docker-compose -p %PROJECT_NAME% up -d

set CONTAINER_NAME=%PROJECT_NAME%-dev-1
REM générer le code hexadécimal du conteneur
docker run --rm geircode/string_to_hex bash string_to_hex.bash "%CONTAINER_NAME%" > vscode_remote_hex.txt

REM Lire le contenu hexadécimal dans une variable
set /p VSCODE_REMOTE_HEX=<vscode_remote_hex.txt

REM Ouvrir VS Code avec l'URI du conteneur
for /f "delims=" %%i in ('docker inspect -f "{{.NetworkSettings.Networks.%PROJECT_NAME%_default.IPAddress}}" %PROJECT_NAME%-db-1') do set DB_IP=%%i

echo IP de la DB: %DB_IP%

code --folder-uri=vscode-remote://attached-container+%VSCODE_REMOTE_HEX%/app

REM Nettoyer le fichier temporaire
del vscode_remote_hex.txt

pause

endlocal
```

#### Lancement de l'application

```sh
#!/bin/bash

# Crée un certificat https
dotnet dev-certs https

# Informe et installe sudo
echo ""
echo "Installtion de sudo"
apt-get update
apt-get install sudo
echo ""

# Informe et installe xdg
echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update
sudo apt-get install xdg-utils
echo ""

# xdg-open permet d'ouvrir une page web
xdg-open 'https://localhost:7218'

# Lance l'application ASP.NET
dotnet run
```

