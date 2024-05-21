# syntax=docker/dockerfile:1
# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app
# Copy csproj and restore as distinct layers
COPY ./P_Bulle_Docker.csproj ./
RUN dotnet restore ./P_Bulle_Docker.csproj
# Copy everything else and build
COPY . .
RUN dotnet publish ./P_Bulle_Docker.csproj -c Release -o out
# Stage 2: Development environment
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS development
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "watch", "--project", "P_Bulle_Docker.csproj"]
# Stage 3: Production environment
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS production
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
RUN dotnet dev-certs https
ENTRYPOINT ["dotnet", "P_Bulle_Docker.dll"]
