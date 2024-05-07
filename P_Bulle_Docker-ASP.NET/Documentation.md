# P_Bulle_Dev_Docker

## Config de docker et des containeurs

### Création des containeurs

[Script pour lancer les containeurs et l'application](setup.bat)

```bat
echo off
setlocal

REM Définir le nom du projet
set "PROJECT_NAME=myprojectdocker"

REM Vérifier l'existence de fichiers .csproj dans le répertoire du projet
if not exist "*.csproj" (
    echo Aucun fichier .csproj trouvé dans ce répertoire.
    exit /b
)

REM Trouver le premier fichier .csproj dans le répertoire
for /F "delims=" %%I in ('dir *.csproj /b /a-d') do (
    set "CSPROJ_NAME=%%I"
    goto find_exe
)

:find_exe
REM Vérifier l'existence du dossier de sortie pour les fichiers .exe
if not exist "bin\Debug\net6.0\*.exe" (
    echo Aucun fichier .exe trouvé dans bin\Debug\net7.0\. Assurez-vous de compiler le projet.
    exit /b
)

REM Trouver le premier fichier .exe dans le répertoire de sortie
for /F "delims=" %%I in ('dir bin\Debug\net6.0\*.exe /b /a-d') do (
    set "EXE_NAME=%%~nI"
)

REM Démarrer uniquement les services nécessaires à la base de données et aux tests
docker-compose -p %PROJECT_NAME% up -d

set CONTAINER_NAME=%PROJECT_NAME%-dev-1
REM Exécute le conteneur et génère le code hexadécimal du nom du conteneur
docker run --rm geircode/string_to_hex bash string_to_hex.bash "%CONTAINER_NAME%" > vscode_remote_hex.txt


REM Lit le contenu hexadécimal dans une variable
set /p VSCODE_REMOTE_HEX=<vscode_remote_hex.txt

REM Ouvre VS Code avec l'URI du conteneur
for /f "delims=" %%i in ('docker inspect -f "{{.NetworkSettings.Networks.myprojectdocker_default.IPAddress}}" myprojectdocker-db-1') do set DB_IP=%%i

echo IP de la DB: %DB_IP%


start http://localhost:5025/


code --folder-uri=vscode-remote://attached-container+%VSCODE_REMOTE_HEX%/app


REM Nettoie le fichier temporaire
del vscode_remote_hex.txt


pause

endlocal
```

### DockerFile

J'ai fait trois Dockerfile

- Pour la base de données
- Pour mon application web
- Pour mes test (MS Test)

Voici le dockerfile pour mon base de données MySQL :

[Dockerfile pour MySQL](../Database/Dockerfile)

```dockerfile
# Prend l'image de base de MySQL
FROM mysql

# Défini le mote de passe de root
ENV MYSQL_ROOT_PASSWORD=root

# Copie le dump dans le dossier /docker-entrypoint-initdb.d
COPY P_Bulle-Docker.sql /docker-entrypoint-initdb.d/

# Expose le port 3306
EXPOSE 3306
```

Voici le dockerfile pour mon application web :

[Dockerfile pour mon application Web](Dockerfile)

```dockerfile
# Cet image est utilisé comme base pour éxecuter des application ASP.NET CORE
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base

# Défini le dossier de travaille à /app
WORKDIR /app

# Expose le port 80 en HTTP
EXPOSE 80

# Expose le port 443 en HTTPS
EXPOSE 443

# Prend l'image de sdk pour compiler l'application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Défini le dossier de travail à /src
WORKDIR /src

# Copie le fichier .csproj
COPY ["P_Bulle_Docker.csproj", "."]

# Execute cette commande pour restaurer les dépendances
RUN dotnet restore "./P_Bulle_Docker.csproj"

# Copie tout les fichiers dans le répertoire sur la machine dans le containeur
COPY . .

# Défini l'endroit ou seront copié les fichiers
WORKDIR "/src/."

# Execute dotnet build pour faire une release dans le dossier /app/build
RUN dotnet build "P_Bulle_Docker.csproj" -c Release -o /app/build

# Défini une nouvelle étape depuis la précedente
FROM build AS publish

# Execute dotnet publish pour publier l'application et mettre dans le dossier
RUN dotnet publish "P_Bulle_Docker.csproj" -c Release -o /app/publish

# Défini une nouvelle étape depuis la précedante
FROM base AS final

# Change le répertoire de travail à /app
WORKDIR /app

# copie les fichiers depuis le step précedente dans le repo actuelle
COPY --from=publish /app/publish .

# Défini une commande qui sera effecué au moment du lancement du containeur
ENTRYPOINT ["dotnet", "P_Bulle_Docker.dll"]
```

Voici le dockerfile pour mes test avec MSTest :

[Dockerfile pour MSTest](../test/Dockerfile)

```dockerfile
# Prend l'image de sdk pour compiler l'application
FROM mcr.microsoft.com/dotnet/sdk:6.0

# Défini le dossier de travail à /app
WORKDIR /app

# Copie le fichier .csproj dans le dossier courant
COPY *.csproj ./

# Restore les dépendances
RUN dotnet restore

# Copie tout les fichiers du local au containeur
COPY . ./

# Publie et mets la dans le dossier out
RUN dotnet publish -c Release -o out

# Au moment de l'éxecution du containeur éxecute dotnet test
ENTRYPOINT [ "dotnet", "test" ]
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
