# P_Bulle_Dev_Docker

## Sommaire des fichiers importants

- [Dockerfile pour l'application](Dockerfile)
- [Dockerfile pour les tests](../Dockerfile.test)
- [Script pour la création des containeurs](setup.bat)
- [Script pour lancer l'application (Façon n°1)](build.sh)
- [Script pour lancer l'application (Façon n°2)](launch.sh)
- [Dump pour la créationde la base de données](../Database/P_Bulle-Docker.sql)
- [Fichier source pour les tests unitaires](../test/UnitTest1.cs)

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

Je lance mon programme avec un script en [bash](./build.sh).
Avec la commande suivante :

```sh
# permet de dire de modifier le fichier pour changer les fin de ligne
sed -i 's/\r//' build.sh
# Lance le script
./build.sh
```

```sh
#!/bin/bash
# Défini un tableau avec les containers
containers=('myprojectdocker_test_1' 'myprojectdocker_dev_1' 'myprojectdocker_db_1')

# Défini un tableau avec les images
images=('mysql' 'myprojectdocker_dev' 'myprojectdocker_test' 'geircode/string_to_hex')

# Informet l'utilisateur du début du script
echo ""
echo "Supprimer les conteneurs..."
echo ""

# Défini les variables pour un meilleur interaction utilisateurs
count=1
total_step=6

# Boucle sur le tableau des containers
for container in "${containers[@]}"
do
    # Informe, stoppe et supprimme les containers dans le tableau
    echo ""
    echo "[Step $count/$total_step] En train de supprimer le conteneur $container..."
    sudo docker stop $container
    sudo docker rm $container
    echo "Conteneur $container a été supprimé"
    echo ""
    # Incrémente la variable count pour avoir un suivi
    ((count++))
done

# Boucle sur le tableau des images
for image in "${images[@]}"
do
    # Informe et supprimme les images dans le tableau
    echo ""
    echo "[Step $count/$total_step] En train de supprimer l'image $image..."
    sudo docker rmi $image
    echo "Image $image a été supprimée"
    echo ""
    # Incrémente la variable count pour avoir un suivi
    ((count++))
done

# Informe l'utilisateur que toute à réussi
echo ""
echo "Tous les conteneurs et images ont été supprimés."
echo ""

# Informe l'utilisateur du démarrage des services
echo ""
echo "Démarrage des services avec docker-compose..."
echo ""

# Informe et installe la librairie xdg
echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y xdg-utils
echo ""

# Lance la création des services
docker-compose up -d
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

REM Stoppe tout les containeurs
docker stop %PROJECT_NAME%_dev_1
docker stop %PROJECT_NAME%_db_1
docker stop %PROJECT_NAME%_test_1

REM Supprimme les containeurs
docker rm %PROJECT_NAME%_dev_1
docker rm %PROJECT_NAME%_db_1
docker rm %PROJECT_NAME%_test_1

REM Supprimme les images
docker rmi %PROJECT_NAME%_dev
docker rmi %PROJECT_NAME%_test
docker rmi mysql:latest

REM Vérifier si le répertoire test_results existe, sinon le créer
if not exist "test_results" (
    mkdir test_results
)

REM Création du fichier docker-compose.yml
(
echo # Défini la version de docker-compose
echo version: '3.8'
echo # Défini les services
echo services:
echo   # Défini un service de db
echo   db:
echo     # Défini l'image du containeur
echo     image: mysql:latest
echo     # Défini des variables d'environment
echo     environment:
echo       MYSQL_ROOT_PASSWORD: root
echo       MYSQL_DATABASE: mydatabase
echo     # Défini les ports du containeur
echo     ports:
echo       - '3306:3306'
echo     # Défini un volume de db-data
echo     volumes:
echo       - db-data:/var/lib/mysql
echo   # Défini un service de développement
echo   dev:
echo     # Défini le build de l'image
echo     build:
echo       # Défini le chemin jusqu'au Dockerfile
echo       context: .
echo       # Défini le nom du dockerfile
echo       dockerfile: Dockerfile
echo       # Défini quel étape prendre
echo       target: development
echo     # Défini les ports
echo     ports:
echo       - '9721:80'
echo       - '443:443'
echo     # Défini un volume
echo     volumes:
echo       - .:/app
echo     # Dépends de certain service
echo     depends_on:
echo       - db
echo   # Défini un service de test
echo   test:
echo     # Défini le build de l'image
echo     build:
echo       # Défini le chemin du dockerfile
echo       context: ..
echo       # Défini le nom du dockerfile
echo       dockerfile: Dockerfile.test
echo     # Défini les dépendances du containeur
echo     depends_on:
echo       - db
echo     # Défini les volumes
echo     volumes:
echo       - ../test:/app/test
echo       - ./test_results:/app/test_results
echo # Défini les volumes
echo volumes:
echo   db-data:
echo # Défini le réseau
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
echo # Fais le build de l'application
echo FROM mcr.microsoft.com/dotnet/sdk:%DOTNET_SDK_VERSION% AS build
echo # Défini le dossier de travail
echo WORKDIR /app
echo # Copie le csproj
echo COPY ./%CSPROJ_NAME% ./
echo # restore les librairies du csproj
echo RUN dotnet restore ./%CSPROJ_NAME%
echo # Copie tout les fichiers du dossier
echo COPY . .
echo # Comile l'application et met le résultat dans un dossier
echo RUN dotnet publish ./%CSPROJ_NAME% -c Release -o out
echo # Fais l'environment de developement
echo FROM mcr.microsoft.com/dotnet/sdk:%DOTNET_SDK_VERSION% AS development
echo # Défini le dossier de travail
echo WORKDIR /app
echo # Copie tout depui l'étape de build
echo COPY --from=build /app/out .
echo # Permet de relancer l'application lors qu'on change un fichier
echo ENTRYPOINT ["dotnet", "watch", "--project", "%CSPROJ_NAME%"]
echo # L'environment de production
echo FROM mcr.microsoft.com/dotnet/aspnet:%DOTNET_SDK_VERSION% AS production
echo # Défini le dossier de travail
echo WORKDIR /app
echo # Copie depuis l'étape de build
echo COPY --from=build /app/out .
echo # Expose le port 80
echo EXPOSE 80
echo # Run l'application au lancement du containeur
echo ENTRYPOINT ["dotnet", "%EXE_NAME%.dll"]
) > Dockerfile

REM Générer le Dockerfile pour le conteneur de test
(
echo # Fais le build des tests
echo FROM mcr.microsoft.com/dotnet/sdk:%DOTNET_SDK_VERSION% AS build
echo # Défini le dossier de travail
echo WORKDIR /app
echo # Copie le dossier de l'application
echo COPY P_Bulle_Docker-ASP.NET/ ./P_Bulle_Docker-ASP.NET/
echo # Copie le dossier des tests
echo COPY test/ ./test/
echo # Restaurer les libraires de l'application
echo RUN dotnet restore P_Bulle_Docker-ASP.NET/%EXE_NAME%.csproj
echo # Build l'application
echo RUN dotnet build P_Bulle_Docker-ASP.NET/%EXE_NAME%.csproj -c Release
echo # Restaurer les libraires des tests
echo RUN dotnet restore test/test.csproj
echo # Build les tests
echo RUN dotnet build test/test.csproj -c Release
echo # Définir le répertoire de travail pour les tests
echo WORKDIR /app/test
echo # Définir la commande pour exécuter les tests et enregistrer les résultats
echo CMD ["dotnet", "test", "test.csproj", "--logger", "trx;LogFileName=test_results.trx", "--results-directory", "/app/test_results"]
) > ../Dockerfile.test

REM Démarrer les services
docker-compose -p %PROJECT_NAME% up -d

set CONTAINER_NAME=%PROJECT_NAME%_dev_1

REM générer le code hexadécimal du conteneur
docker run --rm geircode/string_to_hex bash string_to_hex.bash "%CONTAINER_NAME%" > vscode_remote_hex.txt

REM Lire le contenu hexadécimal dans une variable
set /p VSCODE_REMOTE_HEX=<vscode_remote_hex.txt

REM Ouvrir VS Code avec l'URI du conteneur
for /f "delims=" %%i in ('docker inspect -f "{{.NetworkSettings.Networks.%PROJECT_NAME%_default.IPAddress}}" %PROJECT_NAME%_db_1') do set DB_IP=%%i

echo IP de la DB: %DB_IP%

start http://localhost:5025/

code --folder-uri=vscode-remote://attached-container+%VSCODE_REMOTE_HEX%/app

REM Nettoyer le fichier temporaire
del vscode_remote_hex.txt

pause

endlocal
```

#### Lancement de l'application

Script [bash](./launch.sh) pour lancer l'application.
Avec la commande suivante :

```sh
# permet de dire de modifier le fichier pour changer les fin de ligne
sed -i 's/\r//' launch.sh
# Lance le script
./launch.sh
```

```sh
#!/bin/bash
dotnet dev-certs https

# Informe et installe sudo
echo ""
echo "Installtion de sudo"
apt-get update -y
apt-get install sudo -y
echo ""

# Informe et installe xdg
echo ""
echo "Installer les dépendances nécessaires à xdg"
sudo apt-get update -y
sudo apt-get install xdg-utils -y
echo ""

# Lance une page web avec l'url suivante
xdg-open 'https://localhost:7218'

# lance l'application .NET
dotnet run
```

### Dockerfile

- #### Dockerfile pour l'application

Dockerfile pour l'image de mon [application](./Dockerfile)

```dockerfile
# Fais le build de l'application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
# Défini le dossier de travail
WORKDIR /app
# Copie le csproj
COPY ./P_Bulle_Docker.csproj ./
# restore les librairies du csproj
RUN dotnet restore ./P_Bulle_Docker.csproj
# Copie tout les fichiers du dossier
COPY . .
# Comile l'application et met le résultat dans un dossier
RUN dotnet publish ./P_Bulle_Docker.csproj -c Release -o out
# Fais l'environment de developement
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS development
# Défini le dossier de travail
WORKDIR /app
# Copie tout depui l'étape de build
COPY --from=build /app/out .
# Permet de relancer l'application lors qu'on change un fichier
ENTRYPOINT ["dotnet", "watch", "--project", "P_Bulle_Docker.csproj"]
# L'environment de production
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS production
# Défini le dossier de travail
WORKDIR /app
# Copie depuis l'étape de build
COPY --from=build /app/out .
# Expose le port 80
EXPOSE 80
# Run l'application au lancement du containeur
ENTRYPOINT ["dotnet", "P_Bulle_Docker.dll"]
```

- #### Dockerfile pour les tests

Dockerfile pour l'image de mes [tests](../Dockerfile.test)

```dockerfile
# Fais le build des tests
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
# Défini le dossier de travail
WORKDIR /app
# Copie le dossier de l'application
COPY P_Bulle_Docker-ASP.NET/ ./P_Bulle_Docker-ASP.NET/
# Copie le dossier des tests
COPY test/ ./test/
# Restaurer les libraires de l'application
RUN dotnet restore P_Bulle_Docker-ASP.NET/P_Bulle_Docker.csproj
# Build l'application
RUN dotnet build P_Bulle_Docker-ASP.NET/P_Bulle_Docker.csproj -c Release
# Restaurer les libraires des tests
RUN dotnet restore test/test.csproj
# Build les tests
RUN dotnet build test/test.csproj -c Release
# Définir le répertoire de travail pour les tests
WORKDIR /app/test
# Définir la commande pour exécuter les tests et enregistrer les résultats
CMD ["dotnet", "test", "test.csproj", "--logger", "trx;LogFileName=test_results.trx", "--results-directory", "/app/test_results"]
```

### Docker-compose

Fichier de [docker-compose](./docker-compose.yml)

```yml
# Défini la version de docker-compose
version: "3.8"
# Défini les services
services:
  # Défini un service de db
  db:
    # Défini l'image du containeur
    image: mysql:latest
    # Défini des variables d'environment
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: mydatabase
    # Défini les ports du containeur
    ports:
      - "3306:3306"
    # Défini un volume de db-data
    volumes:
      - db-data:/var/lib/mysql
  # Défini un service de développement
  dev:
    # Défini le build de l'image
    build:
      # Défini le chemin jusqu'au Dockerfile
      context: .
      # Défini le nom du dockerfile
      dockerfile: Dockerfile
      # Défini quel étape prendre
      target: development
    # Défini les ports
    ports:
      - "9721:80"
      - "443:443"
    # Défini un volume
    volumes:
      - .:/app
    # Dépends de certain service
    depends_on:
      - db
  # Défini un service de test
  test:
    # Défini le build de l'image
    build:
      # Défini le chemin du dockerfile
      context: ..
      # Défini le nom du dockerfile
      dockerfile: Dockerfile.test
    # Défini les dépendances du containeur
    depends_on:
      - db
    # Défini les volumes
    volumes:
      - ../test:/app/test
      - ./test_results:/app/test_results
# Défini les volumes
volumes:
  db-data:
# Défini le réseau
networks:
  default:
```
