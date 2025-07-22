#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================="
echo -e "AmneziaWG Easy - Диагностика сетевых интерфейсов"
echo -e "=========================================${NC}"
echo

# Автоматическое определение основного интерфейса
echo -e "${YELLOW}🔍 Автоматическое определение сетевого интерфейса...${NC}"
AUTO_DEVICE=$(ip route get 8.8.8.8 | awk 'NR==1 {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
if [[ -z "$AUTO_DEVICE" ]]; then
    AUTO_DEVICE=$(ip route | grep default | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)
fi

if [[ -n "$AUTO_DEVICE" ]]; then
    echo -e "${GREEN}✅ Рекомендуемый интерфейс для WG_DEVICE: $AUTO_DEVICE${NC}"
else
    echo -e "${RED}❌ Не удалось автоматически определить интерфейс${NC}"
fi

echo

# Показать все активные интерфейсы
echo -e "${BLUE}📋 Все активные сетевые интерфейсы:${NC}"
echo -e "${YELLOW}Интерфейс       Статус    IP адрес${NC}"
echo "----------------------------------------"
ip -br addr show | while read IFACE STATE ADDR; do
    if [[ "$STATE" == "UP" || "$STATE" == "UNKNOWN" ]]; then
        # Выделяем рекомендуемый интерфейс
        if [[ "$IFACE" == "$AUTO_DEVICE" ]]; then
            echo -e "${GREEN}$IFACE${NC}\t\t$STATE\t$ADDR ${GREEN}← рекомендуется${NC}"
        else
            echo -e "$IFACE\t\t$STATE\t$ADDR"
        fi
    fi
done

echo

# Показать маршруты
echo -e "${BLUE}🛣️  Маршруты по умолчанию:${NC}"
ip route | grep default | while read ROUTE; do
    echo "   $ROUTE"
done

echo

# Показать публичные IP адреса
echo -e "${BLUE}🌐 Проверка публичных IP адресов интерфейсов:${NC}"
ip -br addr show | grep -E "UP|UNKNOWN" | while read IFACE STATE ADDR; do
    if [[ "$STATE" == "UP" || "$STATE" == "UNKNOWN" ]]; then
        # Извлекаем IP адрес без маски
        IP=$(echo $ADDR | cut -d'/' -f1)
        if [[ -n "$IP" && "$IP" != "127.0.0.1" ]]; then
            # Проверяем, является ли IP публичным
            if [[ "$IP" =~ ^10\. ]] || [[ "$IP" =~ ^192\.168\. ]] || [[ "$IP" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
                echo -e "   $IFACE: $IP ${YELLOW}(приватный)${NC}"
            else
                echo -e "   $IFACE: $IP ${GREEN}(публичный)${NC}"
            fi
        fi
    fi
done

echo

# Проверить текущий .env файл
if [[ -f ".env" ]]; then
    CURRENT_DEVICE=$(grep "^WG_DEVICE=" .env 2>/dev/null | cut -d'=' -f2)
    if [[ -n "$CURRENT_DEVICE" ]]; then
        echo -e "${BLUE}⚙️  Текущая настройка в .env:${NC}"
        echo "   WG_DEVICE=$CURRENT_DEVICE"
        
        if [[ "$CURRENT_DEVICE" == "$AUTO_DEVICE" ]]; then
            echo -e "   ${GREEN}✅ Настройка корректна${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Рекомендуется изменить на: $AUTO_DEVICE${NC}"
            echo -e "   ${BLUE}💡 Запустите: ./fix-env.sh для автоматического исправления${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  Файл .env не найден${NC}"
    echo -e "${BLUE}💡 Запустите: ./setup-env.sh для создания конфигурации${NC}"
fi

echo

# Тест связности
echo -e "${BLUE}🔌 Тест сетевой связности:${NC}"
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo -e "   ${GREEN}✅ Интернет соединение работает${NC}"
else
    echo -e "   ${RED}❌ Проблемы с интернет соединением${NC}"
fi

if ping -c 1 1.1.1.1 >/dev/null 2>&1; then
    echo -e "   ${GREEN}✅ DNS резолвинг работает${NC}"
else
    echo -e "   ${YELLOW}⚠️  Проблемы с DNS${NC}"
fi

echo
echo -e "${GREEN}🎯 Рекомендация: используйте WG_DEVICE=$AUTO_DEVICE${NC}" 