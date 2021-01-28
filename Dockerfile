FROM mcr.microsoft.com/dotnet/aspnet:5.0-alpine AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine AS build
WORKDIR /src
COPY ./net5_starter.csproj ./
RUN dotnet restore "./net5_starter.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "net5_starter.csproj" -c Release -o /app/build

FROM build AS publish

# optimize dotnet publish
RUN dotnet publish "net5_starter.csproj" -c Release -o /app/publish \
    --runtime alpine-x64 \
    --self-contained true \
    /p:PublishTrimmed=true \
    /p:PublishSingleFile=true

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
# new ENTRYPOINT (no more .dll is generated)
ENTRYPOINT ["./net5_starter"]