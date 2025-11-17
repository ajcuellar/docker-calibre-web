@echo off
echo Construyendo imagen Docker...
docker build --no-cache --pull -t ajcuellar/calibre-web:v0.6.27 -t ajcuellar/calibre-web:latest .

echo.
echo Verificando que la imagen se creó correctamente...
docker images ajcuellar/calibre-web

echo.
echo Si las imágenes se ven bien, presiona Enter para continuar con el login...
pause

echo.
echo Hacer login en Docker Hub...
docker login

echo.
echo Subiendo imagen v0.6.27...
docker push ajcuellar/calibre-web:v0.6.27

echo.
echo Subiendo imagen latest...
docker push ajcuellar/calibre-web:latest

echo.
echo ¡Publicación completada!
echo Tu imagen está disponible en: https://hub.docker.com/r/ajcuellar/calibre-web
pause