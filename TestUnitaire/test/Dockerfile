FROM mcr.microsoft.com/dotnet/sdk:6.0

WORKDIR /test

COPY . ./
RUN dotnet restore

WORKDIR /app

COPY /com.docker.devenvironments.code/P_Bulle_Docker-ASP.NET/Pages/*.cs ./P_Bulle_Docker-ASP.NET/
RUN dotnet restore

CMD ["sh", "-c", "dotnet test && while true; do sleep 1000; done"]