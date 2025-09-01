# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . ./
RUN dotnet restore
RUN dotnet publish -c Release -o /app

# Run
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
# Note: set envs at runtime: KEYRING_MASTER_KEY, Jwt__SigningKey, ConnectionStrings__Default, OpenAI__DefaultModel
ENTRYPOINT ["dotnet", "health_api.dll"]
