@echo off
echo Construyendo imagen Docker...
docker build --no-cache --pull -t ajcuellar/calibre-web:v0.6.27 -t ajcuellar/calibre-web:latest .

echo.
echo Verificando que la imagen se creó correctamente...
docker images ajcuellar/calibre-web

echo.
echo Si las imágenes se ven bien, presiona Enter para continuar...
pause

echo.
echo Elige el método de publicación:
echo 1. Docker Hub
echo 2. GitHub Container Registry (ghcr.io)
echo 3. Ambos
set /p choice="Ingresa tu elección (1, 2 o 3): "

if "%choice%"=="1" goto dockerhub
if "%choice%"=="2" goto ghcr
if "%choice%"=="3" goto both

:dockerhub
echo.
echo Publicando en Docker Hub...
docker login
docker push ajcuellar/calibre-web:v0.6.27
docker push ajcuellar/calibre-web:latest
goto end

:ghcr
echo.
echo Publicando en GitHub Container Registry...
echo Necesitas un Personal Access Token de GitHub con permisos de write:packages
docker login ghcr.io -u ajcuellar
docker tag ajcuellar/calibre-web:v0.6.27 ghcr.io/ajcuellar/calibre-web:v0.6.27
docker tag ajcuellar/calibre-web:latest ghcr.io/ajcuellar/calibre-web:latest
docker push ghcr.io/ajcuellar/calibre-web:v0.6.27
docker push ghcr.io/ajcuellar/calibre-web:latest
goto end

:both
echo.
echo Publicando en ambos registros...
docker login
docker push ajcuellar/calibre-web:v0.6.27
docker push ajcuellar/calibre-web:latest
echo Necesitas un Personal Access Token de GitHub con permisos de write:packages
docker login ghcr.io -u ajcuellar
docker tag ajcuellar/calibre-web:v0.6.27 ghcr.io/ajcuellar/calibre-web:v0.6.27
docker tag ajcuellar/calibre-web:latest ghcr.io/ajcuellar/calibre-web:latest
docker push ghcr.io/ajcuellar/calibre-web:v0.6.27
docker push ghcr.io/ajcuellar/calibre-web:latest
goto end

:end
echo.
echo ¡Publicación completada!
echo.
echo URLs de tus imágenes:
echo - Docker Hub: https://hub.docker.com/r/ajcuellar/calibre-web
echo - GitHub CR: https://github.com/ajcuellar/docker-calibre-web/pkgs/container/calibre-web
pause