#!/bin/bash
# Pre-flight check for Docker deployment

echo "🔍 E-commerce Docker Pre-flight Check"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CHECKS_PASSED=0
CHECKS_FAILED=0

# Check 1: Docker installed
echo -n "1. Checking if Docker is installed... "
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "   Please install Docker Desktop"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 2: Docker running
echo -n "2. Checking if Docker is running... "
if docker info &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "   Please start Docker Desktop"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 3: Docker Compose installed
echo -n "3. Checking if Docker Compose is installed... "
if docker-compose version &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "   Please install Docker Compose"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 4: Port 3000 available
echo -n "4. Checking if port 3000 is available... "
if lsof -Pi :3000 -sTCP:LISTEN -t &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo "   Port 3000 is in use. You may need to stop the service or change the port"
else
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 5: Port 8080 available
echo -n "5. Checking if port 8080 is available... "
if lsof -Pi :8080 -sTCP:LISTEN -t &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo "   Port 8080 is in use. You may need to stop the service or change the port"
else
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 6: Port 8081 available
echo -n "6. Checking if port 8081 is available... "
if lsof -Pi :8081 -sTCP:LISTEN -t &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo "   Port 8081 is in use. You may need to stop the service or change the port"
else
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 7: Port 8082 available
echo -n "7. Checking if port 8082 is available... "
if lsof -Pi :8082 -sTCP:LISTEN -t &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo "   Port 8082 is in use. You may need to stop the service or change the port"
else
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 8: Port 5432 available
echo -n "8. Checking if port 5432 is available... "
if lsof -Pi :5432 -sTCP:LISTEN -t &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo "   Port 5432 is in use. You may need to stop PostgreSQL or change the port"
else
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 9: Port 5433 available
echo -n "9. Checking if port 5433 is available... "
if lsof -Pi :5433 -sTCP:LISTEN -t &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo "   Port 5433 is in use. You may need to stop the service or change the port"
else
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# Check 10: Docker Compose file exists
echo -n "10. Checking if docker-compose.yml exists... "
if [ -f "docker-compose.yml" ]; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "   docker-compose.yml not found"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 11: Docker Compose file is valid
echo -n "11. Checking if docker-compose.yml is valid... "
if docker-compose config --quiet 2> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "   docker-compose.yml has errors"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 12: Dockerfile for product-service exists
echo -n "12. Checking if product-service/Dockerfile exists... "
if [ -f "product-service/Dockerfile" ]; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 13: Dockerfile for order-service exists
echo -n "13. Checking if order-service/Dockerfile exists... "
if [ -f "order-service/Dockerfile" ]; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 14: Dockerfile for api-gateway exists
echo -n "14. Checking if api-gateway/Dockerfile exists... "
if [ -f "api-gateway/Dockerfile" ]; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 15: Dockerfile for webapp exists
echo -n "15. Checking if webapp/Dockerfile exists... "
if [ -f "webapp/Dockerfile" ]; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 16: Nginx config for webapp exists
echo -n "16. Checking if webapp/nginx.conf exists... "
if [ -f "webapp/nginx.conf" ]; then
    echo -e "${GREEN}✓${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# Check 17: Available disk space
echo -n "17. Checking available disk space... "
AVAILABLE=$(df -h . | awk 'NR==2 {print $4}' | sed 's/[^0-9.]//g')
if [ -n "$AVAILABLE" ]; then
    echo -e "${GREEN}✓${NC} ($AVAILABLE GB available)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    echo -e "${YELLOW}⚠${NC} (Could not determine)"
fi

echo ""
echo "======================================"
echo -e "Checks Passed: ${GREEN}${CHECKS_PASSED}${NC}"
echo -e "Checks Failed: ${RED}${CHECKS_FAILED}${NC}"
echo "======================================"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! You're ready to deploy with Docker.${NC}"
    echo ""
    echo "To start the application, run:"
    echo "  docker-compose up -d --build"
    echo ""
    echo "Or use the management script:"
    echo "  ./docker-manage.sh start"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please fix the issues above before deploying.${NC}"
    exit 1
fi

