# StartAPon Deployment Guide

Документация по развертыванию StartAPon на production серверах.

## Содержание
1. [Pre-deployment checklist](#pre-deployment-checklist)
2. [Environment Variables для Production](#environment-variables-для-production)
3. [Heroku Deployment](#heroku-deployment)
4. [DigitalOcean Deployment](#digitalocean-deployment)
5. [PythonAnywhere Deployment](#pythonanywhere-deployment)
6. [Self-hosted на VPS](#self-hosted-на-vps)
7. [Troubleshooting](#troubleshooting)

---

## Pre-deployment Checklist

Перед развертыванием убедитесь, что:

- [ ] Django SECRET_KEY установлен и безопасен (не коммитьте в git!)
- [ ] DEBUG = False в production
- [ ] ALLOWED_HOSTS правильно настроен для вашего домена
- [ ] Database настроена (PostgreSQL рекомендуется для production)
- [ ] Статические файлы собраны (`collectstatic`)
- [ ] SSL/HTTPS сертификат готов
- [ ] GEMINI_API_KEY и другие ключи защищены
- [ ] Backup strategy планируется
- [ ] Logs configured
- [ ] Error monitoring (Sentry) настроен опционально

---

## Environment Variables для Production

Создайте `.env` файл с production переменными:

```env
# Django Settings
DEBUG=False
SECRET_KEY=your-very-secure-random-secret-key-here-min-50-chars
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,your-app.herokuapp.com

# Database (если используете PostgreSQL вместо SQLite)
DATABASE_URL=postgresql://user:password@hostname:5432/dbname

# AI Services
GEMINI_API_KEY=your-gemini-api-key
OPENROUTER_API_KEY=your-openrouter-key

# CORS & Security
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
CSRF_TRUSTED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Logging & Monitoring
SENTRY_DSN=https://key@sentry.io/projectid  # Optional
LOG_LEVEL=INFO

# Email (для нотификаций)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

### Как сгенерировать безопасный SECRET_KEY:

```python
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

---

## Heroku Deployment

### Шаг 1: Подготовка

```bash
# Установите Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# Логинитесь в Heroku
heroku login

# Создайте новое приложение
heroku create your-app-name

# Или используйте существующее
heroku apps:create your-app-name --region eu
```

### Шаг 2: Конфигурация Environment Variables

```bash
# Установите переменные окружения
heroku config:set DEBUG=False
heroku config:set SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
heroku config:set GEMINI_API_KEY=your-key
heroku config:set OPENROUTER_API_KEY=your-key
heroku config:set ALLOWED_HOSTS=your-app-name.herokuapp.com

# Проверьте конфиг
heroku config
```

### Шаг 3: Настройка Database

Heroku рекомендует PostgreSQL:

```bash
# Добавьте бесплатный Postgres
heroku addons:create heroku-postgresql:hobby-dev

# Проверьте DATABASE_URL
heroku config:get DATABASE_URL
```

Обновите `settings.py` чтобы использовать DATABASE_URL:

```python
import dj_database_url

if os.getenv('DATABASE_URL'):
    DATABASES['default'] = dj_database_url.config(
        default=os.getenv('DATABASE_URL'),
        conn_max_age=600
    )
```

### Шаг 4: Deployment

```bash
# Добавьте Procfile (уже есть в проекте)
# Убедитесь что requirements-prod.txt есть

# Коммитьте изменения
git add .
git commit -m "Prepare for production deployment"

# Установите remote
heroku git:remote -a your-app-name

# Развертните
git push heroku main

# Смотрите логи
heroku logs --tail
```

### Шаг 5: Первичная настройка

```bash
# Создайте суперюзера
heroku run python backend/manage.py createsuperuser

# Проверьте приложение
heroku open
```

### Обновление Production

```bash
# После изменений просто пушьте
git push heroku main
```

---

## DigitalOcean Deployment

### Шаг 1: Создайте VPS

1. Создайте новый Droplet на DigitalOcean
2. Выберите Ubuntu 22.04
3. Выберите minimum size ($5-6/месяц достаточно)
4. Добавьте SSH ключ

### Шаг 2: Базовая настройка сервера

```bash
# Подключитесь к серверу
ssh root@your-droplet-ip

# Обновите систему
apt update && apt upgrade -y

# Установите зависимости
apt install -y python3 python3-pip python3-venv git
apt install -y postgresql postgresql-contrib
apt install -y nginx

# Создайте пользователя для приложения
useradd -m startapon
su - startapon
```

### Шаг 3: Deploy приложения

```bash
# В папке /home/startapon/
git clone your-repo-url startapon-app
cd startapon-app

# Создайте venv
python3 -m venv venv
source venv/bin/activate

# Установите зависимости
pip install -r requirements-prod.txt

# Создайте .env с production переменными
nano .env

# Примените миграции
cd backend
python manage.py migrate
python manage.py collectstatic --noinput
```

### Шаг 4: Настройка Gunicorn

Создайте `/home/startapon/startapon-app/gunicorn_config.py`:

```python
import multiprocessing

bind = "127.0.0.1:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2
max_requests = 1000
max_requests_jitter = 50
```

### Шаг 5: Systemd Service

Создайте `/etc/systemd/system/startapon.service`:

```ini
[Unit]
Description=StartAPon Django Application
After=network.target postgresql.service

[Service]
Type=notify
User=startapon
WorkingDirectory=/home/startapon/startapon-app
Environment="PATH=/home/startapon/startapon-app/venv/bin"
ExecStart=/home/startapon/startapon-app/venv/bin/gunicorn \
    --config gunicorn_config.py \
    -c gunicorn_config.py \
    startapon_config.wsgi:application
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Разрешите и запустите сервис
sudo systemctl daemon-reload
sudo systemctl enable startapon
sudo systemctl start startapon
sudo systemctl status startapon
```

### Шаг 6: Nginx конфигурация

Создайте `/etc/nginx/sites-available/startapon`:

```nginx
upstream startapon_app {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    client_max_body_size 10M;

    location /static/ {
        alias /home/startapon/startapon-app/backend/staticfiles/;
    }

    location / {
        proxy_pass http://startapon_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
}
```

```bash
# Активируйте сайт
sudo ln -s /etc/nginx/sites-available/startapon /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Шаг 7: SSL с Let's Encrypt

```bash
# Установите Certbot
apt install -y certbot python3-certbot-nginx

# Получите сертификат
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Автоматическое обновление
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

---

## PythonAnywhere Deployment

### Шаг 1: Создайте аккаунт

1. Зарегистрируйтесь на https://www.pythonanywhere.com
2. Выберите тариф (Beginner подойдет для начала)

### Шаг 2: Clone репозитория

В консоли PythonAnywhere:

```bash
cd /home/your-username

# Клонируйте репо
git clone your-repo-url

# Создайте venv
mkvirtualenv --python=/usr/bin/python3.9 startapon
pip install -r startapon/requirements-prod.txt
```

### Шаг 3: Django конфигурация

В файле `startapon/backend/startapon_config/wsgi.py`:

```python
import os
import sys

path = '/home/your-username/startapon/backend'
if path not in sys.path:
    sys.path.append(path)

os.environ['DJANGO_SETTINGS_MODULE'] = 'startapon_config.settings'

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
```

### Шаг 4: Web App конфигурация

1. Идите в "Web" tab
2. Создайте новый Web App (Manual configuration)
3. Выберите Python 3.9
4. В WSGI configuration file установите путь к wsgi.py
5. Добавьте virtualenv path: `/home/your-username/.virtualenvs/startapon`

### Шаг 5: Static files

В PythonAnywhere Web конфиге добавьте:

```
URL: /static/
Directory: /home/your-username/startapon/backend/staticfiles
```

### Шаг 6: Environment variables

В файле `/home/your-username/startapon/.env` установите переменные.

---

## Self-hosted на VPS

Основные шаги аналогичны DigitalOcean:

1. Арендуйте VPS (Linode, Vultr, AWS, Scaleway и т.д.)
2. Установите Ubuntu/CentOS
3. Следуйте шагам DigitalOcean guide выше
4. Используйте supervisor вместо systemd если нужно
5. Настройте firewall и security rules

---

## Troubleshooting

### 1. "DisallowedHost" ошибка

**Проблема**: `DisallowedHost at /` when accessing site

**Решение**:
```bash
# Убедитесь что ALLOWED_HOSTS правильно установлен
heroku config:set ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
# или на DigitalOcean - отредактируйте .env файл
```

### 2. Static files не загружаются

**Проблема**: CSS/JS файлы возвращают 404

**Решение**:
```bash
# Пересоберите static files
python manage.py collectstatic --noinput

# Убедитесь что STATIC_ROOT правильный
# settings.py должен иметь:
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
```

### 3. Database connection ошибка

**Проблема**: `OperationalError: could not connect to server`

**Решение**:
```bash
# Проверьте DATABASE_URL
heroku config:get DATABASE_URL

# Убедитесь что settings.py использует dj_database_url
pip install dj-database-url
```

### 4. API ключи не работают

**Проблема**: "Invalid API key" при использовании Gemini

**Решение**:
```bash
# Убедитесь что GEMINI_API_KEY установлена
heroku config:get GEMINI_API_KEY

# Проверьте что ключ валидный на https://makersuite.google.com/app/apikey
# Убедитесь что Generative Language API включен
```

### 5. Logs смотрите здесь:

```bash
# Heroku
heroku logs --tail

# DigitalOcean / VPS
sudo journalctl -u startapon -f

# PythonAnywhere
Идите в "Files" -> "/var/log/startapon.error.log"
```

---

## Production Checklist

Перед go-live:

- [ ] Все API ключи добавлены в .env
- [ ] DEBUG = False
- [ ] ALLOWED_HOSTS включает production домен
- [ ] Database бэкапится
- [ ] SSL/HTTPS настроен
- [ ] Error monitoring (Sentry) настроен
- [ ] Rate limiting включен для API
- [ ] CORS настроен правильно
- [ ] Logs настроены
- [ ] Database миграции applied
- [ ] Static files собраны
- [ ] Тест всех основных features

---

## Performance Tips

1. **Database optimization**:
   ```python
   # Используйте select_related и prefetch_related
   ideas = StartupIdea.objects.select_related('user').all()
   ```

2. **Caching**:
   ```python
   from django.core.cache import cache
   cache.set('key', value, 3600)
   ```

3. **CDN для static files**:
   - Используйте CloudFlare или AWS CloudFront
   - Укажите domain в settings.py

4. **Database indexes**:
   ```python
   class Meta:
       indexes = [
           models.Index(fields=['user', 'created_at']),
       ]
   ```

---

## Support & Resources

- Django Deployment: https://docs.djangoproject.com/en/4.2/howto/deployment/
- Gunicorn: https://gunicorn.org/
- Heroku PostgreSQL: https://devcenter.heroku.com/articles/heroku-postgresql
- Let's Encrypt: https://letsencrypt.org/
- Sentry: https://sentry.io/ (error tracking)

---

Успехов с развертыванием! 🚀
