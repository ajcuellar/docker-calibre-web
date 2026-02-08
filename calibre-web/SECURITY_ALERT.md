# 🔒 ALERTA DE SEGURIDAD: Credenciales Expuestas Corregidas

## Fecha: 8 de febrero de 2026

GitGuardian detectó credenciales SMTP expuestas en este repositorio. Se han tomado las siguientes medidas:

## ✅ Correcciones Aplicadas

### 1. Sanitización de Documentación
- ❌ Eliminadas credenciales de ejemplo de `CONFIGURACION_NOTIFICACIONES.md`
- ✅ Reemplazadas con placeholders genéricos
- ✅ Añadidas advertencias de seguridad

### 2. Variables de Entorno
- ✅ Creado `.env.example` con plantilla segura
- ✅ Añadido `.env` a `.gitignore`
- ✅ Documentado uso de variables de entorno

### 3. Documentación de Seguridad
- ✅ Creado `SECURITY_SETUP.md` con guía completa
- ✅ Añadidas advertencias en README_NOTIFICACIONES.md
- ✅ Explicado cómo usar el panel de administración

### 4. .gitignore Actualizado
```gitignore
# Archivos sensibles añadidos
.env
.env.local
.env.*.local
settings.yaml
gdrive_credentials
client_secrets.json
```

## 🔐 Acción Requerida (Usuario)

### Si subiste credenciales reales a Git:

1. **CAMBIAR INMEDIATAMENTE las credenciales:**
   - Nueva contraseña de Gmail
   - Nuevo API Key de Evolution API
   - Nuevo Token de Telegram Bot

2. **Limpiar el historial de Git:**
   ```bash
   # Usando BFG Repo-Cleaner (recomendado)
   bfg --delete-files CONFIGURACION_NOTIFICACIONES.md
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   
   # O usando git filter-branch
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch CONFIGURACION_NOTIFICACIONES.md" \
     --prune-empty --tag-name-filter cat -- --all
   
   git push origin --force --all
   git push origin --force --tags
   ```

3. **Verificar en GitHub:**
   - Ve a Settings → Secrets → Actions
   - Revoca cualquier token expuesto
   - Ve al historial de commits y verifica que las credenciales no estén

## 📋 Checklist de Seguridad

- [ ] Credenciales cambiadas (Gmail, Evolution API, Telegram)
- [ ] Historial de Git limpiado
- [ ] Push forzado realizado
- [ ] `.env` creado localmente (NO subir a Git)
- [ ] `.env` verificado en `.gitignore`
- [ ] Configuración migrada al panel de administración
- [ ] GitGuardian confirmado sin alertas

## 🔍 Verificación

```bash
# Verificar que .env no está en Git
git status | grep .env
# Debe estar vacío

# Verificar que .env está ignorado
git check-ignore .env
# Debe mostrar: .env

# Buscar credenciales en el historial
git log --all --full-history --source --pretty=format:'%h %s' -- "*password*"
git log --all --full-history --source --pretty=format:'%h %s' -- "*secret*"
```

## 📚 Documentos de Referencia

- [SECURITY_SETUP.md](SECURITY_SETUP.md) - Guía completa de configuración segura
- [.env.example](.env.example) - Plantilla de variables de entorno
- [README_NOTIFICACIONES.md](README_NOTIFICACIONES.md) - Documentación del sistema

## 🚨 Prevención Futura

### Para Desarrolladores:

1. **Antes de commit:**
   ```bash
   # Escanear archivos
   git diff --cached | grep -i "password\|secret\|key\|token"
   ```

2. **Instalar git-secrets:**
   ```bash
   brew install git-secrets  # macOS
   apt-get install git-secrets  # Linux
   
   git secrets --scan
   git secrets --install
   ```

3. **Pre-commit hook:**
   ```bash
   # .git/hooks/pre-commit
   #!/bin/sh
   git secrets --pre_commit_hook -- "$@"
   ```

### Para Usuarios:

1. **Usa SIEMPRE el panel de administración** para configurar:
   - Admin → Edit Basic Configuration
   - Credenciales guardadas de forma segura

2. **Si usas .env localmente:**
   - Verifica que esté en `.gitignore`
   - Nunca lo subas a Git
   - No lo compartas

3. **Usa secretos de Docker/Kubernetes en producción**

## ✉️ Contacto

Si tienes dudas sobre esta alerta de seguridad, contacta al administrador del repositorio.

---

**Estado:** Corregido ✅  
**Última actualización:** 8 de febrero de 2026
