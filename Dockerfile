# Multi-stage build
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# Stage 1: Build    
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["Shoestore.csproj", "./"]
RUN dotnet restore "Shoestore.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "Shoestore.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Shoestore.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: runtime
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Shoestore.dll"]
