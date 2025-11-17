# ajcuellar/calibre-web

[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/ajcuellar/calibre-web?label=latest)](https://hub.docker.com/r/ajcuellar/calibre-web)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/ajcuellar/calibre-web)](https://hub.docker.com/r/ajcuellar/calibre-web)
[![Docker Pulls](https://img.shields.io/docker/pulls/ajcuellar/calibre-web)](https://hub.docker.com/r/ajcuellar/calibre-web)

Contenedor Docker para [Calibre-Web](https://github.com/ajcuellar/calibre-web), una aplicación web que proporciona una interfaz limpia para navegar, leer y descargar eBooks usando una base de datos existente de Calibre.

## 🚀 Inicio Rápido

```bash
docker run -d \
  --name=calibre-web \
  -p 8083:8083 \
  -v /ruta/a/tu/biblioteca/calibre:/config \
  ajcuellar/calibre-web:latest
```

Accede a la aplicación en: http://localhost:8083

## 📋 Requisitos

- Una base de datos de Calibre existente (`metadata.db`)
- Puerto 8083 disponible

## 🏷️ Tags Disponibles

- `latest` - Última versión estable
- `v0.6.27` - Versión específica con mejoras

## 📁 Volúmenes

- `/config` - Directorio donde se encuentra tu base de datos de Calibre

## 🔧 Variables de Entorno

- Ninguna requerida para uso básico

## 📖 Uso

1. **Primera ejecución**: La aplicación se iniciará con credenciales de administrador por defecto:
   - Usuario: `admin`
   - Contraseña: `admin123`

2. **Configuración**: Ve a la interfaz de administración y configura la ruta a tu base de datos de Calibre.

## 🆕 Mejoras en esta versión

Esta imagen incluye mejoras sobre la versión original:
- Dependencias actualizadas
- Mejor manejo de errores
- Soporte extendido para formatos DOCX y RTF
- Corrección de varios TODOs pendientes

## 📄 Licencia

GPL v3 License

## 🔗 Enlaces

- [Código fuente](https://github.com/ajcuellar/calibre-web)
- [Repositorio Docker](https://github.com/ajcuellar/docker-calibre-web)
- [Imagen en Docker Hub](https://hub.docker.com/r/ajcuellar/calibre-web)