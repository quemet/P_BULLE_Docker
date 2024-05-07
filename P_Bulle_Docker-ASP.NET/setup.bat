echo off
setlocal

docker stop myprojectdocker-dev-1 myprojectdocker-test-1 myprojectdocker-db-1

docker rm myprojectdocker-dev-1 myprojectdocker-test-1 myprojectdocker-db-1

docker rmi myprojectdocker_db myprojectdocker_test myprojectdocker_dev
 
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
 
code --folder-uri=vscode-remote://attached-container+%VSCODE_REMOTE_HEX%/app -d
 
 
REM Nettoie le fichier temporaire
del vscode_remote_hex.txt

dotnet dev-certs https --trust

dotnet run

start https://localhost:7218
 
pause
 
endlocal