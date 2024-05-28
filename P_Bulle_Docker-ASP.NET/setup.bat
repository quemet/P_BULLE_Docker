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
