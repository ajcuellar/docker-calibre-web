# Script para publicar imagen Docker de Calibre-Web
Write-Host "Construyendo imagen Docker..." -ForegroundColor Green
docker build --no-cache --pull -t ajcuellar/calibre-web:v0.6.27 -t ajcuellar/calibre-web:latest .

Write-Host "`nVerificando que la imagen se creó correctamente..." -ForegroundColor Green
docker images ajcuellar/calibre-web

Write-Host "`nSi las imágenes se ven bien, presiona Enter para continuar..." -ForegroundColor Yellow
Read-Host

Write-Host "`nHacer login en Docker Hub..." -ForegroundColor Green
docker login

Write-Host "`nSubiendo imagen v0.6.27..." -ForegroundColor Green
docker push ajcuellar/calibre-web:v0.6.27

Write-Host "`nSubiendo imagen latest..." -ForegroundColor Green
docker push ajcuellar/calibre-web:latest

Write-Host "`n¡Publicación completada!" -ForegroundColor Green
Write-Host "Tu imagen está disponible en: https://hub.docker.com/r/ajcuellar/calibre-web" -ForegroundColor Cyan
Read-Host "Presiona Enter para salir"