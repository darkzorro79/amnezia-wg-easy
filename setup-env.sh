#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================="
echo -e "AmneziaWG Easy - Настройка .env"
echo -e "=================================${NC}"
echo

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не найден! Установите Docker и повторите попытку.${NC}"
    exit 1
fi

# Проверка доступности образа
echo -e "${YELLOW}🔍 Проверка доступности образа Docker...${NC}"
if ! docker pull ghcr.io/w0rng/amnezia-wg-easy:latest &> /dev/null; then
    echo -e "${RED}❌ Не удалось загрузить образ ghcr.io/w0rng/amnezia-wg-easy${NC}"
    echo -e "${YELLOW}💡 Попробуйте выполнить: docker pull ghcr.io/w0rng/amnezia-wg-easy${NC}"
    exit 1
fi

# Запрос IP сервера или доменного имени
echo -e "${BLUE}🌐 Введите IP адрес вашего сервера или доменное имя:${NC}"
read -p "WG_HOST: " WG_HOST

if [[ -z "$WG_HOST" ]]; then
    echo -e "${RED}❌ IP адрес или доменное имя обязательны!${NC}"
    exit 1
fi

# Запрос пароля администратора
echo
echo -e "${BLUE}🔐 Введите пароль для веб-интерфейса администратора:${NC}"
echo -e "${YELLOW}💡 Пароль должен быть надежным (рекомендуется минимум 8 символов)${NC}"
read -s -p "Пароль: " ADMIN_PASSWORD
echo

if [[ -z "$ADMIN_PASSWORD" ]]; then
    echo -e "${RED}❌ Пароль обязателен!${NC}"
    exit 1
fi

# Генерация bcrypt хеша
echo
echo -e "${YELLOW}🔄 Генерация bcrypt хеша пароля...${NC}"

# Генерируем хеш с помощью Docker контейнера
PASSWORD_HASH=$(docker run --rm ghcr.io/w0rng/amnezia-wg-easy wgpw "$ADMIN_PASSWORD" 2>/dev/null | grep "PASSWORD_HASH=" | cut -d"'" -f2)

if [[ -z "$PASSWORD_HASH" ]]; then
    echo -e "${RED}❌ Не удалось сгенерировать хеш пароля!${NC}"
    exit 1
fi

# Замена $ на $$ для docker-compose
PASSWORD_HASH_ESCAPED=$(echo "$PASSWORD_HASH" | sed 's/\$/\$\$/g')

echo -e "${GREEN}✅ Хеш пароля сгенерирован успешно!${NC}"

# Запрос дополнительных параметров
echo
echo -e "${BLUE}⚙️  Дополнительные настройки (нажмите Enter для значения по умолчанию):${NC}"

read -p "Порт веб-интерфейса [51821]: " PORT
PORT=${PORT:-51821}

read -p "Порт WireGuard [51820]: " WG_PORT
WG_PORT=${WG_PORT:-51820}

read -p "Язык интерфейса [ru]: " LANG
LANG=${LANG:-ru}

read -p "DNS серверы для клиентов [1.1.1.1]: " WG_DEFAULT_DNS
WG_DEFAULT_DNS=${WG_DEFAULT_DNS:-1.1.1.1}

read -p "Диапазон IP для клиентов [10.8.0.x]: " WG_DEFAULT_ADDRESS
WG_DEFAULT_ADDRESS=${WG_DEFAULT_ADDRESS:-10.8.0.x}

echo
echo -e "${BLUE}🛡️  AmneziaWG настройки обфускации:${NC}"

# Функция генерации случайных чисел
generate_random_jc() { echo $((RANDOM % 10 + 1)); }
generate_random_size() { echo $((RANDOM % 100 + 50)); }
generate_random_header() { echo $((RANDOM % 1000000000 + 1000000000)); }

read -p "Количество junk пакетов [auto-generate]: " JC
if [[ -z "$JC" ]]; then
    JC=$(generate_random_jc)
    echo "Сгенерировано: JC=$JC"
fi

read -p "Минимальный размер junk пакета [50]: " JMIN
JMIN=${JMIN:-50}

read -p "Максимальный размер junk пакета [1000]: " JMAX
JMAX=${JMAX:-1000}

read -p "Размер junk в init пакете [auto-generate]: " S1
if [[ -z "$S1" ]]; then
    S1=$(generate_random_size)
    echo "Сгенерировано: S1=$S1"
fi

read -p "Размер junk в response пакете [auto-generate]: " S2
if [[ -z "$S2" ]]; then
    S2=$(generate_random_size)
    echo "Сгенерировано: S2=$S2"
fi

read -p "Magic header H1 [auto-generate]: " H1
if [[ -z "$H1" ]]; then
    H1=$(generate_random_header)
    echo "Сгенерировано: H1=$H1"
fi

read -p "Magic header H2 [auto-generate]: " H2
if [[ -z "$H2" ]]; then
    H2=$(generate_random_header)
    echo "Сгенерировано: H2=$H2"
fi

read -p "Magic header H3 [auto-generate]: " H3
if [[ -z "$H3" ]]; then
    H3=$(generate_random_header)
    echo "Сгенерировано: H3=$H3"
fi

read -p "Magic header H4 [auto-generate]: " H4
if [[ -z "$H4" ]]; then
    H4=$(generate_random_header)
    echo "Сгенерировано: H4=$H4"
fi

# Создание .env файла
echo
echo -e "${YELLOW}📝 Создание .env файла...${NC}"

cat > .env << EOF
# =================================
# AmneziaWG Easy Configuration
# Создано автоматически $(date)
# =================================

# Основные настройки
WG_HOST=$WG_HOST
PASSWORD_HASH=$PASSWORD_HASH_ESCAPED
PORT=$PORT
WG_PORT=$WG_PORT
LANG=$LANG

# Сетевые настройки
WEBUI_HOST=0.0.0.0
WG_DEVICE=eth0
WG_DEFAULT_ADDRESS=$WG_DEFAULT_ADDRESS
WG_DEFAULT_DNS=$WG_DEFAULT_DNS
WG_ALLOWED_IPS=0.0.0.0/0, ::/0
WG_PERSISTENT_KEEPALIVE=0

# Дополнительные возможности
UI_TRAFFIC_STATS=false
ENABLE_PROMETHEUS_METRICS=false
MAX_AGE=0
UI_ENABLE_SORT_CLIENTS=false
WG_ENABLE_ONE_TIME_LINKS=false
WG_ENABLE_EXPIRES_TIME=false

# AmneziaWG обфускация
JC=$JC
JMIN=$JMIN
JMAX=$JMAX
S1=$S1
S2=$S2
H1=$H1
H2=$H2
H3=$H3
H4=$H4
EOF

# Добавление .env в .gitignore если его там нет
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo ".env" >> .gitignore
    echo -e "${GREEN}✅ Добавлен .env в .gitignore${NC}"
fi

echo -e "${GREEN}✅ Файл .env создан успешно!${NC}"
echo
echo -e "${BLUE}🚀 Теперь вы можете запустить AmneziaWG Easy:${NC}"
echo -e "${YELLOW}   docker-compose up -d${NC}"
echo
echo -e "${BLUE}📱 Веб-интерфейс будет доступен по адресу:${NC}"
echo -e "${YELLOW}   http://$WG_HOST:$PORT${NC}"
echo
echo -e "${BLUE}📊 Метрики Prometheus (если включены):${NC}"
echo -e "${YELLOW}   http://$WG_HOST:$PORT/metrics${NC}"
echo
echo -e "${GREEN}🎉 Настройка завершена!${NC}"
