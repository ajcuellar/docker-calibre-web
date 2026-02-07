#!/bin/bash
# Script para configurar credenciales de Docker registries
# Guarda las credenciales de forma segura

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔐 Configuración de Docker Registries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}¿Qué registro quieres configurar?${NC}"
echo "  1) Docker Hub (docker.io)"
echo "  2) GitHub Container Registry (ghcr.io)"
echo "  3) Ambos"
read -p "Elige (1-3): " choice
echo ""

case $choice in
    1|3)
        echo -e "${BLUE}━━━ Docker Hub ━━━${NC}"
        echo "Usuario: ajcuellar"
        echo "Contraseña: Tu contraseña de Docker Hub"
        echo ""
        docker login
        echo -e "${GREEN}✓ Docker Hub configurado${NC}"
        echo ""
        ;;
esac

case $choice in
    2|3)
        echo -e "${BLUE}━━━ GitHub Container Registry ━━━${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
        echo "  No uses tu contraseña de GitHub"
        echo "  Necesitas un Personal Access Token (PAT)"
        echo ""
        echo -e "${BLUE}Cómo obtener tu token:${NC}"
        echo "  1. Ve a: ${CYAN}https://github.com/settings/tokens${NC}"
        echo "  2. Click 'Generate new token (classic)'"
        echo "  3. Selecciona permisos: write:packages, read:packages"
        echo "  4. Copia el token generado"
        echo ""
        read -p "¿Ya tienes tu token? (s/N): " has_token
        
        if [[ ! $has_token =~ ^[Ss]$ ]]; then
            echo ""
            echo -e "${YELLOW}Obtén tu token primero y luego vuelve a ejecutar este script${NC}"
            exit 0
        fi
        
        echo ""
        echo "Usuario: ajcuellar"
        read -sp "Token (no se mostrará al escribir): " token
        echo ""
        echo ""
        
        echo "$token" | docker login ghcr.io -u ajcuellar --password-stdin
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ GitHub Container Registry configurado${NC}"
            echo ""
            echo -e "${BLUE}💡 Tip:${NC} Tus credenciales están guardadas en ~/.docker/config.json"
            echo "  No necesitarás volver a hacer login (hasta que expire el token)"
        else
            echo -e "${RED}✗ Error al configurar GitHub CR${NC}"
            echo "  Verifica que el token tenga los permisos correctos"
            exit 1
        fi
        ;;
esac

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Configuración completada${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Ahora puedes usar los scripts de release sin que te pidan credenciales"
echo ""
