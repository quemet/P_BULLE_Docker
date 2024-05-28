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
