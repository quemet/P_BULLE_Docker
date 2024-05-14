@echo off
setlocal
REM script permettant de créer des conteneurs docker dynamiquement, les versions et noms de fichiers ne sont pas codés en dur pour détecter ce que vous avez et ce dont vous avez besoin

REM Définir le nom du projet
set "PROJECT_NAME=myprojectdocker"

REM Vérifier si le répertoire test_results existe, sinon le créer
if not exist "test_results" (
    mkdir test_results
)

REM Création du fichier docker-compose.yaml
(
echo version: '3.8'
echo services:
echo   db:
echo     image: mysql:latest
echo     environment:
echo       MYSQL_ROOT_PASSWORD: root
echo       MYSQL_DATABASE: mydatabase
echo     ports:
echo       - '3306:3306'
echo     volumes:
echo       - db-data:/var/lib/mysql
echo   dev:
echo     build:
echo       context: .
echo       dockerfile: Dockerfile
echo       target: development
echo     ports:
echo       - '9721:80'  
echo       - '443:443'
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
echo FROM mcr.microsoft.com/dotnet/sdk:%DOTNET_SDK_VERSION% AS build
echo WORKDIR /app
echo # Copy csproj and restore as distinct layers
echo COPY ./%CSPROJ_NAME% ./
echo RUN dotnet restore ./%CSPROJ_NAME%
echo # Copy everything else and build
echo COPY . .
echo RUN dotnet publish ./%CSPROJ_NAME% -c Release -o out
echo # Stage 2: Development environment
echo FROM mcr.microsoft.com/dotnet/sdk:%DOTNET_SDK_VERSION% AS development
echo WORKDIR /app
echo COPY --from=build /app/out .
echo ENTRYPOINT ["dotnet", "watch", "--project", "%CSPROJ_NAME%"]
echo # Stage 3: Production environment
echo FROM mcr.microsoft.com/dotnet/aspnet:%DOTNET_SDK_VERSION% AS production
echo WORKDIR /app
echo COPY --from=build /app/out .
echo EXPOSE 80
echo ENTRYPOINT ["dotnet", "%EXE_NAME%.dll"]
) > Dockerfile

REM Générer le Dockerfile pour le conteneur de test
(
echo # syntax=docker/dockerfile:1
echo FROM mcr.microsoft.com/dotnet/sdk:%DOTNET_SDK_VERSION% AS build
echo WORKDIR /app
echo # Copier les dossiers de l'application et des tests
echo COPY %EXE_NAME%/ ./%EXE_NAME%/
echo COPY test/ ./test/
echo # Restaurer et construire l'application
echo RUN dotnet restore %EXE_NAME%/%EXE_NAME%.csproj
echo RUN dotnet build %EXE_NAME%/%EXE_NAME%.csproj -c Release
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

start http://localhost:5025/

code --folder-uri=vscode-remote://attached-container+%VSCODE_REMOTE_HEX%/app

REM Nettoyer le fichier temporaire
del vscode_remote_hex.txt

pause

endlocal
