# 🚀 Инструкция по установке и запуску StartAPon

## Требования
- Python 3.9+
- pip (пакетный менеджер Python)
- Git (опционально)

## Пошаговая установка

### 1. Клонируйте или распакуйте проект
```bash
# Если получили zip:
unzip startapon.zip
cd startapon

# Или если клонируете из git:
git clone <repository-url>
cd startapon
```

### 2. Создайте виртуальное окружение
```bash
# На Windows:
python -m venv venv
venv\Scripts\activate

# На macOS/Linux:
python3 -m venv venv
source venv/bin/activate
```

### 3. Установите зависимости
```bash
pip install -r requirements.txt
```

### 4. Настройте переменные окружения
```bash
# Скопируйте пример .env файла
cd backend

# На Windows:
copy .env.example .env

# На macOS/Linux:
cp .env.example .env
```

Откройте `backend/.env` и добавьте:
- `GEMINI_API_KEY` - получите на https://makersuite.google.com/app/apikey
- (опционально) `OPENROUTER_API_KEY` - получите на https://openrouter.ai

Пример:
```
GEMINI_API_KEY=sk-...your-key...
DEBUG=False
SECRET_KEY=django-insecure-your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1
```

### 5. Инициализируйте базу данных
```bash
# Находясь в папке backend/
python manage.py migrate
```

### 6. Создайте суперпользователя (опционально)
```bash
python manage.py createsuperuser
```

### 7. Запустите сервер
```bash
# Убедитесь что вы в папке backend/
python manage.py runserver
```

Сервер запустится по адресу: **http://localhost:8000**

## Использование

1. Откройте http://localhost:8000 в браузере
2. Зарегистрируйтесь или войдите
3. Пройдите тест
4. Используйте функции приложения

## Структура проекта
```
startapon/
├── backend/                 # Django приложение
│   ├── startapon_app/      # Основное приложение
│   ├── startapon_config/   # Конфигурация Django
│   ├── templates/          # HTML шаблоны
│   ├── db.sqlite3          # База данных (создается автоматически)
│   ├── manage.py           # Django управление
│   └── .env.example        # Пример переменных окружения
├── frontend/               # Статические файлы (CSS, JS)
│   └── static/
├── requirements.txt        # Зависимости Python
└── README.md              # Описание проекта
```

## Решение типичных проблем

### Ошибка: "ModuleNotFoundError: No module named 'django'"
```bash
# Убедитесь что виртуальное окружение активировано и установлены зависимости
pip install -r requirements.txt
```

### Ошибка: "Port 8000 is already in use"
```bash
# Используйте другой порт:
python manage.py runserver 8001
```

### Ошибка: "No such table"
```bash
# Запустите миграции:
python manage.py migrate
```

### Ошибка: "API key is invalid"
```bash
# Проверьте что .env файл содержит правильный GEMINI_API_KEY
# Создайте новый ключ на https://makersuite.google.com/app/apikey
```

## Развертывание на хостинге

### Для Heroku:
1. Создайте файл `Procfile`:
```
web: gunicorn startapon_config.wsgi
```

2. Установите gunicorn:
```bash
pip install gunicorn
```

3. Создайте `runtime.txt`:
```
python-3.11.0
```

### Для других хостингов (PythonAnywhere, Digital Ocean и т.д.):
1. Загрузите все файлы проекта
2. Создайте виртуальное окружение
3. Установите зависимости: `pip install -r requirements.txt`
4. Скопируйте `.env.example` в `.env` и добавьте реальные ключи
5. Запустите миграции: `python manage.py migrate`
6. Для production обновите в `settings.py`:
   - `DEBUG = False`
   - Сгенерируйте новый `SECRET_KEY`
   - Добавьте ваш домен в `ALLOWED_HOSTS`

## Полезные команды

```bash
# Создать новое приложение Django
python manage.py startapp app_name

# Создать миграции
python manage.py makemigrations

# Применить миграции
python manage.py migrate

# Собрать статические файлы
python manage.py collectstatic

# Очистить базу данных и пересоздать
python manage.py flush

# Создать резервную копию БД
sqlite3 db.sqlite3 ".dump" > backup.sql
```

## Поддержка

Если у вас есть проблемы:
1. Проверьте что Python версия 3.9+
2. Убедитесь что виртуальное окружение активировано
3. Переустановите зависимости: `pip install -r requirements.txt --force-reinstall`
4. Проверьте файл `.env` на наличие ошибок
5. Посмотрите логи ошибок в терминале

Успехов! 🎉
