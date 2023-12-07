# Use multi-stage builds for efficient image build and reduce final image size
# Use .Net 8.0 as runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
RUN useradd -ms /bin/bash newuser
USER newuser
WORKDIR /app
EXPOSE 8080


# Use .Net 8.0 sdk for build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["Cryotea.com/Cryotea.com/Cryotea.com.csproj", "Cryotea.com/"]
COPY ["Cryotea.com/Cryotea.com.Client/Cryotea.com.Client.csproj", "Cryotea.com.Client/"]
RUN dotnet restore "Cryotea.com/Cryotea.com.csproj"
RUN dotnet restore "Cryotea.com.Client/Cryotea.com.Client.csproj"
COPY . .
WORKDIR "/src/Cryotea.com"
ARG BUILD_CONFIGURATION=Release
RUN dotnet build "Cryotea.com/Cryotea.com.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Cryotea.com/Cryotea.com.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Cryotea.com.dll"]
CMD ["dotnet", "Cryotea.com.dll"]