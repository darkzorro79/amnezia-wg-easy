#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================="
echo -e "AmneziaWG Easy - Исправление .env"
echo -e "=================================${NC}"
echo

# Проверка наличия .env файла
if [[ ! -f ".env" ]]; then
    echo -e "${RED}❌ Файл .env не найден!${NC}"
    echo -e "${YELLOW}💡 Запустите ./setup-env.sh для создания нового файла${NC}"
    exit 1
fi

# Проверка наличия проблемных значений
if ! grep -q "=random" .env; then
    echo -e "${GREEN}✅ В файле .env не найдено проблемных значений 'random'${NC}"
    exit 0
fi

echo -e "${YELLOW}🔍 Найдены проблемные значения 'random' в .env файле${NC}"
echo -e "${BLUE}🔧 Исправляем значения...${NC}"

# Создаем резервную копию
cp .env .env.backup
echo -e "${GREEN}✅ Создана резервная копия: .env.backup${NC}"

# Функции генерации случайных чисел
generate_random_jc() { echo $((RANDOM % 10 + 1)); }
generate_random_size() { echo $((RANDOM % 100 + 50)); }
generate_random_header() { echo $((RANDOM % 1000000000 + 1000000000)); }

# Проверяем и исправляем WG_DEVICE
echo -e "${BLUE}🔍 Проверка сетевого интерфейса...${NC}"
CURRENT_WG_DEVICE=$(grep "^WG_DEVICE=" .env | cut -d'=' -f2)
AUTO_WG_DEVICE=$(ip route get 8.8.8.8 | awk 'NR==1 {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')

if [[ -z "$AUTO_WG_DEVICE" ]]; then
    AUTO_WG_DEVICE=$(ip route | grep default | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)
fi

if [[ -n "$AUTO_WG_DEVICE" && "$CURRENT_WG_DEVICE" != "$AUTO_WG_DEVICE" ]]; then
    echo -e "${YELLOW}⚠️  Текущий WG_DEVICE: $CURRENT_WG_DEVICE${NC}"
    echo -e "${GREEN}🔍 Обнаружен активный интерфейс: $AUTO_WG_DEVICE${NC}"
    echo -e "${BLUE}💡 Доступные сетевые интерфейсы:${NC}"
    ip -br addr show | grep -E "UP|UNKNOWN" | awk '{print "   " $1 " - " $3}' | head -5
    
    read -p "Обновить WG_DEVICE на $AUTO_WG_DEVICE? [y/N]: " UPDATE_DEVICE
    if [[ "$UPDATE_DEVICE" =~ ^[Yy]$ ]]; then
        sed -i "s/^WG_DEVICE=.*/WG_DEVICE=$AUTO_WG_DEVICE/" .env
        echo -e "${GREEN}✅ WG_DEVICE: $CURRENT_WG_DEVICE → $AUTO_WG_DEVICE${NC}"
    fi
else
    echo -e "${GREEN}✅ WG_DEVICE корректен: $CURRENT_WG_DEVICE${NC}"
fi

# Исправляем каждый параметр
if grep -q "^JC=random" .env; then
    JC=$(generate_random_jc)
    sed -i "s/^JC=random/JC=$JC/" .env
    echo -e "${GREEN}✅ JC: random → $JC${NC}"
fi

if grep -q "^S1=random" .env; then
    S1=$(generate_random_size)
    sed -i "s/^S1=random/S1=$S1/" .env
    echo -e "${GREEN}✅ S1: random → $S1${NC}"
fi

if grep -q "^S2=random" .env; then
    S2=$(generate_random_size)
    sed -i "s/^S2=random/S2=$S2/" .env
    echo -e "${GREEN}✅ S2: random → $S2${NC}"
fi

if grep -q "^H1=random" .env; then
    H1=$(generate_random_header)
    sed -i "s/^H1=random/H1=$H1/" .env
    echo -e "${GREEN}✅ H1: random → $H1${NC}"
fi

if grep -q "^H2=random" .env; then
    H2=$(generate_random_header)
    sed -i "s/^H2=random/H2=$H2/" .env
    echo -e "${GREEN}✅ H2: random → $H2${NC}"
fi

if grep -q "^H3=random" .env; then
    H3=$(generate_random_header)
    sed -i "s/^H3=random/H3=$H3/" .env
    echo -e "${GREEN}✅ H3: random → $H3${NC}"
fi

if grep -q "^H4=random" .env; then
    H4=$(generate_random_header)
    sed -i "s/^H4=random/H4=$H4/" .env
    echo -e "${GREEN}✅ H4: random → $H4${NC}"
fi

echo
echo -e "${GREEN}🎉 Файл .env успешно исправлен!${NC}"
echo
echo -e "${BLUE}🚀 Теперь перезапустите контейнер:${NC}"
echo -e "${YELLOW}   docker-compose down && docker-compose up -d${NC}"
echo
echo -e "${BLUE}📋 Для просмотра изменений:${NC}"
echo -e "${YELLOW}   diff .env.backup .env${NC}" 