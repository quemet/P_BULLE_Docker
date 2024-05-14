# P_Bulle_Dev_Docker

## Config de docker et des containeurs

Il y a deux façons de faire des containeurs :

### Création avec le devContaineurs de Docker

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

### Création avec un script bat

[Script pour lancer les containeurs et l'application](setup.bat)

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

```

### DockerFile

J'ai fait deux Dockerfile

- Pour mon application web
- Pour mes test (MS Test)

Voici le dockerfile pour mon application web :

[Dockerfile pour mon application Web](Dockerfile)

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app
COPY ./P_Bulle_Docker.csproj ./
RUN dotnet restore ./P_Bulle_Docker.csproj
COPY . .
RUN dotnet publish ./P_Bulle_Docker.csproj -c Release -o out
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS development
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "watch", "--project", "P_Bulle_Docker.csproj"]
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS production
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "P_Bulle_Docker.dll"]
```

Voici le dockerfile pour mes test avec MSTest :

[Dockerfile pour MSTest](../test/Dockerfile)

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app
COPY P_Bulle_Docker-ASP.NET/ ./P_Bulle_Docker-ASp.NET/
COPY test/ ./test/
RUN dotnet restore P_Bulle_Docker-ASP.NET/P_Bulle_Docker.csproj
RUN dotnet build P_Bulle_Docker-ASp.NET/P_Bulle_Docker.csproj -c Release
RUN dotnet restore test/test.csproj
RUN dotnet build test/test.csproj -c Release
WORKDIR /app/test
CMD ["dotnet", "test", "test.csproj", "--logger", "trx;LogFileName=test_results.trx", "--results-directory", "/app/test_results"]
```

### Docker Compose

Voici mon docker-compose pour créer mes 3 containeurs :

[Docker compose](docker-compose.yml)

```YML

# Défini les différents services
services:
  # Défini un service de db
  db:
    build:
      context: ../Database
      dockerfile: Dockerfile
    container_name: mysql
    ports:
      - '3306:3306'
    volumes:
      - my-db:/var/lib/mysql
  webapp:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: application
    depends_on:
      - db
    ports:
      - "8080:80"
  test:
    build:
      context: ../TestUnitaire/test
      dockerfile: Dockerfile
    container_name: test
    depends_on:
      - db
      - webapp
volumes:
  my-db:

```
