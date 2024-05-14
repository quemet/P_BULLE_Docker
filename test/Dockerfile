FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app
COPY ./test.csproj ./
RUN dotnet restore ./test.csproj
COPY . .
RUN dotnet publish ./test.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS development
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "watch", "--project", "test.csproj"]

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS production
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 79

CMD ["sh", "-c", "dotnet test && while true; do sleep 3600; done"]
