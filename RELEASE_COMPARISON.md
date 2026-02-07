# 🚀 Proceso Completo de Release

## Script Mejorado vs Scripts Antiguos

### ❌ Scripts Antiguos (Windows)
```bat
publish-docker.bat      # Versión hardcodeada: v0.6.27
publish-github.bat      # Versión hardcodeada: v0.6.27
publish-multi.bat       # Versión hardcodeada: v0.6.27
publish-docker.ps1      # Versión hardcodeada: v0.6.27
```

**Problemas:**
- Versión hardcodeada (hay que editar cada vez)
- Solo para Windows (.bat/.ps1)
- No actualiza `constants.py`
- No crea commits ni tags de Git
- Tienes que recordar hacer push manualmente

### ✅ Script Nuevo (Linux)
```bash
./release.sh 0.46.3
```

**Ventajas:**
- ✨ **TODO automático en un solo comando**
- 📝 Actualiza versión en `constants.py`
- 💾 Crea commit con mensaje descriptivo
- 🏷️ Crea tag Git (v0.46.3)
- 🔀 Push a GitHub (opcional, interactivo)
- 🐳 **Build Docker** (opcional, interactivo)
- 📦 **Push Docker** a Docker Hub y/o GitHub CR (interactivo)
- 🎯 Usa la versión que especificas (no hardcodeada)

## 🔄 Flujo Completo del Nuevo Script

### Paso 1: Ejecutar el script
```bash
cd /home/ajcuellar/cuellar/projects/docker-calibre-web
./release.sh 0.46.3 "Nueva funcionalidad: XYZ"
```

### Paso 2: El script pregunta interactivamente

#### 2.1 Push a GitHub?
```
¿Deseas hacer push al repositorio remoto?
Push a GitHub? (s/N): s
```
- Sí: Sube commit y tag a GitHub
- No: Te dice cómo hacerlo manualmente después

#### 2.2 Build Docker?
```
¿Deseas construir y publicar la imagen Docker?
Build & Push Docker? (s/N): s
```
- Sí: Construye la imagen con los tags:
  - `ajcuellar/calibre-web:v0.46.3`
  - `ajcuellar/calibre-web:latest`
- No: Te dice cómo hacerlo manualmente después

#### 2.3 Dónde publicar? (si elegiste build)
```
¿Dónde deseas publicar la imagen?
  1) Docker Hub
  2) GitHub Container Registry (ghcr.io)
  3) Ambos
  4) No publicar (solo construir)
Elige (1-4): 3
```

### Resultado Final
- ✅ Versión actualizada
- ✅ Commit creado
- ✅ Tag creado
- ✅ Push a GitHub
- ✅ Imagen Docker construida
- ✅ Imagen publicada en Docker Hub
- ✅ Imagen publicada en GitHub CR

## 📋 Comparación de Flujos

### Antes (Proceso Manual)
```bash
# 1. Actualizar versión manualmente
nano cps/constants.py  # Cambiar STABLE_VERSION = '0.46.3'

# 2. Editar scripts con nueva versión
nano publish-docker.bat  # Cambiar v0.6.27 a v0.46.3
nano publish-github.bat  # Cambiar v0.6.27 a v0.46.3
nano publish-multi.bat   # Cambiar v0.6.27 a v0.46.3

# 3. Commit manual
git add calibre-web/cps/constants.py
git commit -m "Release 0.46.3 - Nueva funcionalidad"

# 4. Tag manual
git tag -a v0.46.3 -m "Release 0.46.3"

# 5. Push manual
git push origin master
git push origin v0.46.3

# 6. Build Docker (en Windows o WSL)
docker build -t ajcuellar/calibre-web:v0.46.3 -t ajcuellar/calibre-web:latest .

# 7. Login Docker Hub
docker login

# 8. Push Docker
docker push ajcuellar/calibre-web:v0.46.3
docker push ajcuellar/calibre-web:latest

# Total: ~15 minutos, 8 pasos manuales
```

### Ahora (Un Solo Comando)
```bash
./release.sh 0.46.3 "Nueva funcionalidad: XYZ"
# Responder a 3 preguntas interactivas (s/N)
# Total: ~2 minutos, 1 comando + 3 respuestas
```

## 🎯 Casos de Uso

### Caso 1: Release completo (Git + Docker)
```bash
./release.sh 0.47.0 "Bot Telegram v2"
# Pregunta 1: Push GitHub? → s
# Pregunta 2: Build Docker? → s
# Pregunta 3: Dónde publicar? → 3 (Ambos)
```

### Caso 2: Solo actualizar código (sin Docker)
```bash
./release.sh 0.46.4 "Hotfix: Corrección bugs"
# Pregunta 1: Push GitHub? → s
# Pregunta 2: Build Docker? → N
```

### Caso 3: Build local sin publicar
```bash
./release.sh 0.47.0-beta "Testing"
# Pregunta 1: Push GitHub? → N
# Pregunta 2: Build Docker? → s
# Pregunta 3: Dónde publicar? → 4 (No publicar)
```

### Caso 4: Todo manual (como antes)
```bash
./release.sh 0.46.4 "Cambios menores"
# Pregunta 1: Push GitHub? → N
# Pregunta 2: Build Docker? → N
# Luego haces todo manualmente si quieres
```

## 📊 Resumen de Mejoras

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Versión** | Hardcodeada en 4 scripts | Pasada como parámetro |
| **Platform** | Windows (.bat/.ps1) | Linux (.sh) |
| **Actualiza constants.py** | ❌ Manual | ✅ Automático |
| **Git commit** | ❌ Manual | ✅ Automático |
| **Git tag** | ❌ Manual | ✅ Automático |
| **Git push** | ❌ Manual | ✅ Opcional |
| **Docker build** | ❌ Separado | ✅ Integrado |
| **Docker push** | ❌ Separado | ✅ Integrado |
| **Multi-registry** | ❌ 3 scripts | ✅ 1 menú |
| **Tiempo total** | ~15 min | ~2 min |
| **Comandos** | 8+ | 1 |
| **Errores típicos** | Olvidar un paso | Imposible |

## 💡 Recomendación

**Mantén los scripts antiguos** por si alguna vez necesitas usarlos en Windows, pero:

1. **Para releases normales:** Usa `./release.sh` (mucho más rápido y seguro)
2. **Actualiza los .bat** solo si necesitas usarlos en Windows específicamente

## 🔧 Migración de Scripts Antiguos

Si quieres actualizar los scripts .bat con la nueva versión:

```bash
# Actualizar automáticamente todos los .bat y .ps1
sed -i 's/v0\.6\.27/v0.46.2/g' publish-*.bat publish-*.ps1
```

Pero honestamente, con `release.sh` ya no los necesitas. 😊
