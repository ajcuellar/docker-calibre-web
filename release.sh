#!/bin/bash
# Script para crear un nuevo release de Docker Calibre-Web
# Uso: ./release.sh 0.46.2 "Descripción del release"

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar uso
show_usage() {
    echo -e "${BLUE}Uso:${NC}"
    echo "  ./release.sh <versión> [descripción]"
    echo ""
    echo -e "${BLUE}Ejemplos:${NC}"
    echo "  ./release.sh 0.46.2"
    echo "  ./release.sh 0.46.2 \"Telegram Bot integration and improvements\""
    echo ""
    echo -e "${BLUE}Nota:${NC} Si no se proporciona descripción, se usará una por defecto"
    exit 1
}

# Verificar argumentos
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Se requiere al menos la versión${NC}"
    show_usage
fi

VERSION=$1
DESCRIPTION=${2:-"Telegram Bot integration and improvements"}

# Validar formato de versión (X.Y.Z)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Formato de versión inválido${NC}"
    echo "Formato esperado: X.Y.Z (ejemplo: 0.46.2)"
    exit 1
fi

# Verificar que estamos en un repositorio git limpio
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Advertencia: Hay cambios sin commitear${NC}"
    git status --short
    echo ""
    read -p "¿Deseas continuar? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${RED}Operación cancelada${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📦 Creando Release v${VERSION} (Docker)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Paso 1: Actualizar versión en calibre-web/constants.py
echo -e "${BLUE}1.${NC} Actualizando versión en calibre-web..."
cd calibre-web
python3 update_version.py "$VERSION"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error actualizando versión${NC}"
    exit 1
fi
cd ..
echo -e "${GREEN}✓${NC} Versión actualizada"
echo ""

# Paso 2: Commitear cambio de versión
echo -e "${BLUE}2.${NC} Creando commit..."
git add calibre-web/cps/constants.py
git commit -m "Release ${VERSION} - ${DESCRIPTION}"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error creando commit${NC}"
    exit 1
fi
COMMIT_HASH=$(git rev-parse --short HEAD)
echo -e "${GREEN}✓${NC} Commit creado: ${COMMIT_HASH}"
echo ""

# Paso 3: Crear tag
echo -e "${BLUE}3.${NC} Creando tag v${VERSION}..."
git tag -a "v${VERSION}" -m "Release ${VERSION} - ${DESCRIPTION}"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error creando tag${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Tag creado: v${VERSION}"
echo ""

# Paso 4: Mostrar resumen
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Release creado exitosamente${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📝 Resumen:${NC}"
echo "  Versión:     v${VERSION}"
echo "  Commit:      ${COMMIT_HASH}"
echo "  Descripción: ${DESCRIPTION}"
echo ""

# Paso 5: Preguntar si hacer push
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}¿Deseas hacer push al repositorio remoto?${NC}"
echo "  Esto subirá el commit y el tag"
read -p "Push? (s/N): " -n 1 -r
echo
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${BLUE}5.${NC} Haciendo push..."
    git push origin master
    git push origin "v${VERSION}"
    echo -e "${GREEN}✓${NC} Push completado"
    echo ""
    echo -e "${GREEN}🚀 Release v${VERSION} publicado en GitHub${NC}"
    echo ""
    echo -e "${YELLOW}💡 Siguiente paso:${NC}"
    echo "  Construir y publicar imagen Docker con:"
    echo "  docker build -t ajcuellar/calibre-web:${VERSION} ."
    echo "  docker push ajcuellar/calibre-web:${VERSION}"
else
    echo -e "${YELLOW}ℹ️  Para hacer push manualmente:${NC}"
    echo "  git push origin master"
    echo "  git push origin v${VERSION}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}¡Listo! 🎉${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
