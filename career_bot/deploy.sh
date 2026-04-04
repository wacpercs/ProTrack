#!/bin/bash
# Деплой на VPS — career.say-my-name.ru
set -e

SERVER="root@89.125.118.57"
REMOTE_DIR="/opt/career_bot"

echo "=== 1. Собираю фронтенд ==="
cd frontend
npm install
npm run build
cd ..

echo "=== 2. Копирую файлы на сервер ==="
ssh $SERVER "mkdir -p $REMOTE_DIR/frontend"

rsync -avz \
  --exclude 'frontend/node_modules' \
  --exclude 'frontend/.vite' \
  --exclude '__pycache__' \
  --exclude '*.pyc' \
  --exclude 'career_bot.db' \
  ./ $SERVER:$REMOTE_DIR/

echo "=== 3. Настраиваю сервер ==="
ssh $SERVER << 'ENDSSH'
set -e
cd /opt/career_bot

# Python venv + зависимости
apt-get update -qq
apt-get install -y -qq python3-pip python3-venv certbot python3-certbot-nginx > /dev/null 2>&1
[ -d venv ] || python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt -q

# Nginx — добавляем конфиг для career.say-my-name.ru (не трогаем основной сайт)
cp nginx-career.conf /etc/nginx/sites-available/career-bot
ln -sf /etc/nginx/sites-available/career-bot /etc/nginx/sites-enabled/career-bot
nginx -t && systemctl reload nginx

# SSL через certbot (не трогает другие конфиги)
certbot --nginx -d career.say-my-name.ru --non-interactive --agree-tos --email admin@say-my-name.ru --redirect || echo "Certbot не смог получить сертификат — проверь DNS A-запись"

# Systemd сервис
cat > /etc/systemd/system/career-bot.service << 'EOF'
[Unit]
Description=Career Bot (FastAPI + Telegram)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/career_bot
Environment=PATH=/opt/career_bot/venv/bin:/usr/bin
ExecStart=/opt/career_bot/venv/bin/python -m uvicorn main:app --host 127.0.0.1 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable career-bot
systemctl restart career-bot
sleep 2

echo ""
echo "=== Статус ==="
systemctl status career-bot --no-pager -l
ENDSSH

echo ""
echo "=== Деплой завершён ==="
echo "Mini App: https://career.say-my-name.ru/app"
echo "API:      https://career.say-my-name.ru/api/profile"
echo ""
echo "НЕ ЗАБУДЬ: A-запись career.say-my-name.ru -> 89.125.118.57"
