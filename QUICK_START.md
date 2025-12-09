# 🚀 Inicio Rápido - Calibre-Web + Telegram Bot

Guía de 5 minutos para tener todo funcionando.

## 📋 Pre-requisitos

- Docker instalado
- Docker Compose instalado
- Credenciales del bot de Telegram

## ⚡ Pasos Rápidos

### 1. Configurar el Bot de Telegram (2 minutos)

```bash
# Navegar al directorio
cd docker-calibre-web/telegram-book-bot

# Copiar ejemplo de configuración
cp config.json.example config.json

# Editar con tus credenciales
nano config.json  # o tu editor favorito
```

**Mínimo necesario** en `config.json`:
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
    "password": "admin123"
  },
  "search_sources": [
    {
      "name": "Z-Library",
      "type": "bot",
      "username": "zlibrary_bot",
      "search_command": "/search",
      "enabled": true
    }
  ]
}
```

**Importante**: La URL debe ser `http://calibre-web:8083` (nombre del contenedor, no localhost)

### 2. Iniciar Todo (1 minuto)

```bash
# Volver al directorio docker-calibre-web
cd ..

# Iniciar ambos servicios
docker-compose up -d
```

### 3. Verificar (1 minuto)

```bash
# Ver que los contenedores estén corriendo
docker-compose ps

# Ver logs si hay problemas
docker-compose logs -f
```

Deberías ver:
- ✅ `calibre-web` corriendo en puerto 8084
- ✅ `telegram-book-bot` corriendo

### 4. Usar el Bot (1 minuto)

1. Abre Telegram
2. Busca tu bot (el nombre que le diste en BotFather)
3. Envía: `/start`
4. Escribe: `El Quijote`
5. ¡Selecciona y descarga!

## 🎯 Acceso a los Servicios

- **Calibre-Web**: http://localhost:8084
  - Usuario: `admin`
  - Contraseña: La que configuraste

- **Telegram Bot**: Busca tu bot en Telegram

## 🔧 Configuración con Variables de Entorno (Opcional)

Si prefieres no editar `config.json`:

```bash
# Crear archivo .env
cp .env.example .env

# Editar .env
nano .env
```

Agrega:
```env
BOT_TOKEN=tu_token
TELEGRAM_API_ID=12345
TELEGRAM_API_HASH=tu_hash
CALIBRE_WEB_USER=admin
CALIBRE_WEB_PASSWORD=tu_password
```

## 🐛 Solución Rápida de Problemas

### Bot no inicia
```bash
# Ver logs del bot
docker-compose logs telegram-book-bot

# Verificar config.json
cat telegram-book-bot/config.json
```

### No se conecta a Calibre-Web
```bash
# Verificar que ambos contenedores estén en la misma red
docker network inspect docker-calibre-web_calibre-network

# Probar conectividad
docker exec -it telegram-book-bot ping calibre-web
```

### No encuentra libros
- Verifica que tengas fuentes configuradas en `search_sources`
- Comprueba que los usernames sean correctos (sin @)
- Asegúrate de tener `api_id` y `api_hash` configurados

## 📊 Comandos Útiles

```bash
# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f

# Reiniciar servicios
docker-compose restart

# Detener todo
docker-compose down

# Reconstruir imágenes
docker-compose build --no-cache
docker-compose up -d
```

## 📚 Próximos Pasos

Una vez que todo funciona:

1. **Agrega más fuentes** de búsqueda en `config.json`
2. **Configura usuarios permitidos** en `allowed_users`
3. **Personaliza límites** de tamaño de archivo
4. **Lee la documentación completa** en [TELEGRAM_BOT_INTEGRATION.md](TELEGRAM_BOT_INTEGRATION.md)

## 🆘 ¿Necesitas Ayuda?

1. Revisa [TELEGRAM_BOT_INTEGRATION.md](TELEGRAM_BOT_INTEGRATION.md) - Guía completa
2. Consulta [telegram-book-bot/README.md](telegram-book-bot/README.md) - Documentación del bot
3. Revisa los logs: `docker-compose logs`
4. Abre un issue en GitHub

## ✅ Checklist de Configuración

- [ ] Docker y Docker Compose instalados
- [ ] Bot token obtenido de @BotFather
- [ ] API credentials obtenidas de my.telegram.org
- [ ] config.json creado y editado
- [ ] URL de Calibre-Web es `http://calibre-web:8083`
- [ ] Al menos una fuente de búsqueda configurada
- [ ] `docker-compose up -d` ejecutado
- [ ] Ambos contenedores corriendo
- [ ] Bot responde en Telegram
- [ ] Primera búsqueda exitosa

## 🎉 ¡Listo!

Si todos los pasos anteriores funcionaron, tu sistema está completamente operativo.

**Disfruta de tu biblioteca automatizada con Telegram! 📚🤖**

---

**Tiempo total estimado**: 5-10 minutos
