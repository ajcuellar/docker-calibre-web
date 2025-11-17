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
echo Publicando en GitHub Container Registry...
echo IMPORTANTE: Necesitas crear un Personal Access Token en GitHub:
echo 1. Ve a https://github.com/settings/tokens
echo 2. Genera un nuevo token con permisos: write:packages, read:packages
echo 3. Copia el token para usarlo como contraseña
echo.
set /p token="Ingresa tu GitHub Personal Access Token: "

echo %token% | docker login ghcr.io -u ajcuellar --password-stdin

echo.
echo Etiquetando imágenes para GitHub CR...
docker tag ajcuellar/calibre-web:v0.6.27 ghcr.io/ajcuellar/calibre-web:v0.6.27
docker tag ajcuellar/calibre-web:latest ghcr.io/ajcuellar/calibre-web:latest

echo.
echo Subiendo imágenes...
docker push ghcr.io/ajcuellar/calibre-web:v0.6.27
docker push ghcr.io/ajcuellar/calibre-web:latest

echo.
echo ¡Publicación completada en GitHub Container Registry!
echo.
echo Tu imagen está disponible en:
echo https://github.com/ajcuellar/docker-calibre-web/pkgs/container/calibre-web
echo.
echo Para usar la imagen:
echo docker pull ghcr.io/ajcuellar/calibre-web:latest
pause