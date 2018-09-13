
FROM microsoft/dotnet:2.1-sdk-alpine AS build-env

WORKDIR /app

COPY DockerTest.csproj ./

RUN dotnet restore ./DockerTest.csproj 

COPY . ./
RUN dotnet add package ILLink.Tasks -v 0.1.5-preview-1841731 -s https://dotnet.myget.org/F/dotnet-core/api/v3/index.json
RUN dotnet publish -c Release -r linux-musl-x64 -o published /p:ShowLinkerSizeComparison=true /p:CrossGenDuringPublish=false /p:LinkerTrimNativeDeps=false

FROM microsoft/dotnet:2.1-runtime-deps-alpine AS runtime

WORKDIR /app
COPY --from=build-env /app/published ./
ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000/tcp
CMD ["./DockerTest"]