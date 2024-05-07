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
