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

Je lance mon programme avec un script en [bash](./build.sh)

```sh
#!/bin/bash
# Défini un tableau avec les contianers
containers=('myprojectdocker-test-1' 'myprojectdocker-dev-1' 'myprojectdocker-db-1')

# Défini un tableau avec les images
images=('mysql' 'myprojectdocker_dev' 'myprojectdocker_test', 'geircode/string_to_hex')

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
sudo apt-get upgrade
sudo apt-get install xdg-utils
echo ""

# Lance la création des services
sudo docker-compose up -d

# Ouvre une page web à l'url suivante.
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

REM Défini un tableau avec les containers
set "containers=myprojectdocker-db-1,myprojectdocker-dev-1,myprojectdocker-test-1"

REM Défini un tableau avec les images
set "images=geircode/string_to_hex,myprojectdocker_dev,myprojectdocker_test,mysql"

REM Boucle sur le tableau des containers et stoppe et supprimme le container
for %%c in (%containers%) do (
    docker stop %%c
    docker rm %%c
)

REM Boucle sur le tableau des images et supprimme l'image
for %%i in (%images%) do (
    docker rmi %%i
)

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

REM Démarrer les services
docker-compose -p %PROJECT_NAME% up -d

REM Défini le nom du containeur
set CONTAINER_NAME=%PROJECT_NAME%-dev-1

REM générer le code hexadécimal du conteneur
docker run --rm geircode/string_to_hex bash string_to_hex.bash "%CONTAINER_NAME%" > vscode_remote_hex.txt

REM Lire le contenu hexadécimal dans une variable
set /p VSCODE_REMOTE_HEX=<vscode_remote_hex.txt

REM Ouvrir VS Code avec l'URI du conteneur
for /f "delims=" %%i in ('docker inspect -f "{{.NetworkSettings.Networks.%PROJECT_NAME%_default.IPAddress}}" %PROJECT_NAME%-db-1') do set DB_IP=%%i

REM Afficher l'IP de la DB
echo IP de la DB: %DB_IP%

REM Ouvre VSCode
code --folder-uri=vscode-remote://attached-container+%VSCODE_REMOTE_HEX%/app

REM Nettoyer le fichier temporaire
del vscode_remote_hex.txt

pause

endlocal
```

#### Lancement de l'application

Script [bash](./launch.sh) pour lancer l'application

```sh
#!/bin/bash
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

# Lance une page web avec l'url suivante
xdg-open 'https://localhost:7218'

# lance l'application .NET
dotnet run
```
