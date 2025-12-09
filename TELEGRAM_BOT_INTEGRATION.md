# 🤖 Integración del Bot de Telegram con Calibre-Web

Este documento explica cómo usar el Bot de Telegram integrado con Calibre-Web en Docker.

## 📋 Descripción

El Telegram Book Bot está completamente integrado en el stack de Docker de Calibre-Web, permitiendo:
- 🔍 Buscar libros desde Telegram
- 📥 Descargar automáticamente
- 📚 Agregar directamente a tu biblioteca de Calibre-Web
- 🔄 Comunicación directa entre contenedores

## 🚀 Inicio Rápido

### 1. Configurar el Bot

Antes de iniciar los contenedores, crea el archivo de configuración:

```bash
cd docker-calibre-web/telegram-book-bot
cp config.json.example config.json
```

Edita `config.json` con tus credenciales:

```json
{
  "bot_token": "TU_BOT_TOKEN",
  "telegram_api": {
    "api_id": "TU_API_ID",
    "api_hash": "TU_API_HASH"
  },
  "calibre_web": {
    "url": "http://calibre-web:8083",
    "username": "admin",
    "password": "tu_password",
    "upload_enabled": true
  },
  "search_sources": [
    {
      "name": "Z-Library Bot",
      "type": "bot",
      "username": "zlibrary_bot",
      "search_command": "/search",
      "enabled": true
    }
  ]
}
```

**Importante**:
- La URL de Calibre-Web debe ser `http://calibre-web:8083` (nombre del servicio Docker)
- No uses `localhost` o `127.0.0.1`

### 2. Configurar Variables de Entorno (Opcional)

Puedes usar un archivo `.env` en el directorio `docker-calibre-web`:

```bash
# .env
BOT_TOKEN=tu_bot_token_aqui
TELEGRAM_API_ID=12345678
TELEGRAM_API_HASH=tu_api_hash_aqui
CALIBRE_WEB_USER=admin
CALIBRE_WEB_PASSWORD=tu_password
```

### 3. Iniciar los Servicios

```bash
cd docker-calibre-web
docker-compose up -d
```

Esto iniciará:
- ✅ Calibre-Web en el puerto 8084
- ✅ Telegram Book Bot conectado a Calibre-Web

### 4. Verificar que Funciona

```bash
# Ver logs de Calibre-Web
docker-compose logs -f calibre-web

# Ver logs del bot
docker-compose logs -f telegram-book-bot
```

## 🔧 Configuración Detallada

### Arquitectura de Red

Los contenedores se comunican a través de una red Docker compartida llamada `calibre-network`:

```
┌─────────────────────┐
│  Telegram Users     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Telegram Bot       │
│  (telegram-book-bot)│
└──────────┬──────────┘
           │
           │ http://calibre-web:8083
           ▼
┌─────────────────────┐
│  Calibre-Web        │
│  (calibre-web:8084) │
└─────────────────────┘
```

### Volúmenes Montados

El bot utiliza los siguientes volúmenes:

```yaml
volumes:
  - ./telegram-book-bot/config.json:/app/config.json:ro  # Configuración (read-only)
  - ./telegram-book-bot/data:/app/data                   # Estadísticas
  - ./telegram-book-bot/downloads:/app/downloads         # Descargas temporales
  - ./telegram-book-bot/logs:/app/logs                   # Logs del bot
  - ./telegram-book-bot/bot_session.session:/app/bot_session.session  # Sesión de Telegram
```

### Variables de Entorno

El bot acepta estas variables de entorno:

| Variable | Descripción | Requerido |
|----------|-------------|-----------|
| `BOT_TOKEN` | Token del bot de Telegram | ✅ |
| `TELEGRAM_API_ID` | API ID de Telegram | ✅ |
| `TELEGRAM_API_HASH` | API Hash de Telegram | ✅ |
| `CALIBRE_WEB_URL` | URL interna de Calibre-Web | ✅ |
| `CALIBRE_WEB_USER` | Usuario de Calibre-Web | ✅ |
| `CALIBRE_WEB_PASSWORD` | Contraseña de Calibre-Web | ✅ |
| `PUID` | User ID para permisos | ❌ (default: 1000) |
| `PGID` | Group ID para permisos | ❌ (default: 1000) |
| `TZ` | Zona horaria | ❌ (default: Europe/Madrid) |

## 📱 Uso del Bot

Una vez que los contenedores están corriendo:

1. **Abre Telegram** y busca tu bot
2. **Envía** `/start`
3. **Escribe** el nombre de un libro
4. **Selecciona** el resultado que quieres
5. **Confirma** la descarga
6. ✨ **¡El libro se agrega automáticamente a Calibre-Web!**

## 🔍 Comandos Disponibles

- `/start` - Iniciar el bot
- `/buscar <título>` - Buscar libros
- `/config` - Ver fuentes configuradas
- `/stats` - Ver tus estadísticas
- `/help` - Mostrar ayuda
- `/cancel` - Cancelar operación

## 🛠️ Gestión de Contenedores

### Ver Estado
```bash
docker-compose ps
```

### Ver Logs en Tiempo Real
```bash
# Ambos servicios
docker-compose logs -f

# Solo el bot
docker-compose logs -f telegram-book-bot

# Solo Calibre-Web
docker-compose logs -f calibre-web
```

### Reiniciar Servicios
```bash
# Reiniciar todo
docker-compose restart

# Solo el bot
docker-compose restart telegram-book-bot
```

### Detener Servicios
```bash
docker-compose down
```

### Reconstruir Imágenes
```bash
# Reconstruir todo
docker-compose build --no-cache

# Solo el bot
docker-compose build --no-cache telegram-book-bot
```

## 🔄 Actualizar el Bot

Cuando hagas cambios en el código del bot:

```bash
# En el directorio principal
.\release.ps1 patch

# O manualmente en docker-calibre-web
docker-compose down
docker-compose build --no-cache telegram-book-bot
docker-compose up -d
```

## 🐛 Troubleshooting

### El bot no se conecta a Calibre-Web

**Problema**: "Error connecting to Calibre-Web"

**Solución**:
1. Verifica que la URL sea `http://calibre-web:8083` (no localhost)
2. Asegúrate de que ambos contenedores estén en la misma red
3. Verifica credenciales de Calibre-Web

```bash
# Verificar red
docker network inspect docker-calibre-web_calibre-network

# Probar conexión desde el bot
docker exec -it telegram-book-bot ping calibre-web
```

### El bot no inicia

**Problema**: El contenedor se detiene inmediatamente

**Solución**:
1. Verifica que `config.json` exista y sea válido
2. Revisa los logs:
```bash
docker-compose logs telegram-book-bot
```

3. Verifica las credenciales de Telegram

### Error "No bot token found"

**Problema**: Falta el token del bot

**Solución**:
1. Asegúrate de que `config.json` tenga el campo `bot_token`
2. O configura la variable de entorno `BOT_TOKEN`

### No se encuentran libros

**Problema**: El bot no devuelve resultados

**Solución**:
1. Verifica que haya al menos una fuente habilitada en `search_sources`
2. Comprueba que los usernames sean correctos (sin @)
3. Asegúrate de tener las credenciales de API de Telegram configuradas

### Permisos de archivo

**Problema**: "Permission denied" al descargar

**Solución**:
```bash
# Ajustar permisos en el host
cd docker-calibre-web/telegram-book-bot
chmod -R 777 data downloads logs
```

O ajusta `PUID` y `PGID` en docker-compose.yml según tu usuario.

## 📊 Monitoreo

### Ver Estadísticas del Bot

Las estadísticas se guardan en `telegram-book-bot/data/`:

```bash
# Ver estadísticas de un usuario
cat docker-calibre-web/telegram-book-bot/data/stats_123456789.json
```

### Ver Logs

Los logs se guardan en `telegram-book-bot/logs/`:

```bash
# Ver logs del bot
tail -f docker-calibre-web/telegram-book-bot/logs/bot.log
```

### Espacio en Disco

El bot limpia automáticamente los archivos descargados después de subirlos a Calibre-Web (si está habilitado en config).

Para verificar espacio:
```bash
du -sh docker-calibre-web/telegram-book-bot/downloads/
```

## 🔒 Seguridad

### Mejores Prácticas

1. **No expongas el puerto del bot**: El bot no necesita puertos expuestos
2. **Usa secretos**: Considera usar Docker secrets en producción
3. **Limita usuarios**: Configura `allowed_users` en `config.json`
4. **Backups**: Respalda `config.json` y `data/` regularmente
5. **Actualiza**: Mantén las imágenes actualizadas

### Archivo .env

Si usas `.env`, asegúrate de que esté en `.gitignore`:

```bash
echo ".env" >> .gitignore
chmod 600 .env
```

## 📚 Recursos Adicionales

- [README del Bot](telegram-book-bot/README.md) - Documentación completa del bot
- [QUICKSTART](telegram-book-bot/QUICKSTART.md) - Guía de inicio rápido
- [EXAMPLES](telegram-book-bot/EXAMPLES.md) - Ejemplos de uso
- [DOCKER](telegram-book-bot/DOCKER.md) - Guía específica de Docker

## 🆘 Soporte

Si tienes problemas:

1. ✅ Revisa esta documentación
2. ✅ Consulta los logs: `docker-compose logs telegram-book-bot`
3. ✅ Verifica la configuración: `cat telegram-book-bot/config.json`
4. ✅ Prueba la conectividad: `docker exec -it telegram-book-bot ping calibre-web`
5. ✅ Revisa el [README del bot](telegram-book-bot/README.md)
6. ✅ Abre un issue en GitHub

## 🎉 Características

- ✅ Integración completa con Calibre-Web
- ✅ Comunicación entre contenedores
- ✅ Configuración flexible (JSON + variables de entorno)
- ✅ Logs persistentes
- ✅ Estadísticas por usuario
- ✅ Limpieza automática de archivos
- ✅ Soporte para múltiples fuentes de búsqueda
- ✅ Interfaz en español

---

**¡Disfruta de tu biblioteca automatizada! 📚🤖**
