# On utilise le sdk avec net 6.0
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /appsproj
COPY ./P_Bulle_Docker.csproj ./
RUN dotnet restore ./P_Bulle_Docker.csproj
COPY . .
RUN dotnet publish ./P_Bulle_Docker.csproj -c Release -o out
# On utilise le sdk avec net6.0
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS development
# On défini le dossier de travail comme /app
WORKDIR /app
# Copie tout du build
COPY --from=build /app/out .
# Au moment du lancement du container on effectue la commande suivante
ENTRYPOINT ["dotnet", "watch", "--project", "P_Bulle_Docker.csproj"]
# On utilise ASP.NET avec net6.0
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS production
# On défini le dossier de travail comme /app
WORKDIR /app
# Copie tout du build
COPY --from=build /app/out .
# On expose le port 80
EXPOSE 80
# On lance le programme
ENTRYPOINT ["dotnet", "P_Bulle_Docker.dll"]
