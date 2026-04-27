# Быстрый старт StartAPon

## Шаг 1: Установка зависимостей

```bash
cd backend
pip install -r ../requirements.txt
```

## Шаг 2: Создание базы данных и миграций

```bash
python manage.py makemigrations
python manage.py migrate
```

## Шаг 3: Создание суперпользователя

```bash
python manage.py createsuperuser
```

Введите имя пользователя (например: admin), email и пароль.

## Шаг 4: Загрузка примеров данных (опционально)

```bash
python manage.py load_startup_ideas
```

Это загрузит 12 примеров идей стартапов в базу данных.

## Шаг 5: Запуск сервера

```bash
python manage.py runserver
```

Сервер запустится на `http://localhost:8000`

## Доступ к приложению

- **Главная страница**: http://localhost:8000
- **Админ-панель**: http://localhost:8000/admin (используйте учетные данные суперпользователя)

## Конфигурация API ключа OpenAI

Отредактируйте файл `.env`:

```env
AI_API_KEY=your-openai-api-key
```

Получить API ключ можно на https://platform.openai.com/api-keys

## Структура папок

```
startapon/
├── backend/
│   ├── startapon_config/        # Django конфигурация
│   ├── startapon_app/           # Основное приложение
│   │   ├── migrations/          # Миграции БД
│   │   ├── management/
│   │   │   └── commands/        # Django команды
│   │   ├── models.py            # Модели БД
│   │   ├── views.py             # API представления
│   │   ├── urls.py              # URL маршруты
│   │   ├── serializers.py        # Сериализаторы
│   │   ├── ai_service.py         # ИИ интеграция
│   │   ├── test_questions.py     # Тестовые вопросы
│   │   ├── subscription_utils.py  # Утилиты подписок
│   │   └── tests.py              # Тесты
│   └── manage.py
├── frontend/                    # Фронтенд
│   ├── static/
│   │   ├── css/style.css        # Стили
│   │   └── js/app.js            # JavaScript приложение
│   └── templates/
│       └── index.html           # HTML страница
├── requirements.txt             # Зависимости Python
├── .env                         # Переменные окружения
├── README.md                    # Документация
└── QUICKSTART.md               # Этот файл
```

## Основные функции

### 1. Психологический тест
- 20 вопросов для определения типа предпринимателя
- Анализ результатов ИИ
- Рекомендации на основе профиля

### 2. Диалог с ИИ
- Интерактивное общение для уточнения идеи
- Последние 5 сообщений сохраняются в контексте
- Профиль пользователя учитывается при ответах

### 3. Анализ идей
- Оценка жизнеспособности
- Выявление возможных ошибок
- Рекомендации по улучшению

### 4. Финансовые расчеты
- Расчет стартового капитала
- Прогноз срока окупаемости
- Анализ затрат

### 5. Помощь с бюрократией
- Информация о регистрации
- Налоговые требования
- Необходимые лицензии

### 6. Рекомендации идей
- Подборка стартапов на основе профиля
- Процент совпадения
- Описание почему подходит именно эта идея

## API Endpoints

### Тест (Test)
- `GET /api/test/questions/` - Получить вопросы теста
- `POST /api/test/submit/` - Отправить результаты

### Профиль (Profile)
- `GET /api/profile/` - Получить профиль пользователя

### Сообщения (Messages)
- `POST /api/message/` - Отправить сообщение ИИ

### Идеи (Ideas)
- `POST /api/idea/create/` - Создать новую идею
- `GET /api/idea/list/` - Список всех идей пользователя
- `POST /api/idea/analyze/` - Анализировать идею
- `POST /api/idea/costs/` - Рассчитать капитал
- `POST /api/idea/bureaucracy/` - Получить помощь с бюрократией

### Рекомендации (Recommendations)
- `GET /api/recommendations/` - Получить рекомендации

### Подписки (Subscriptions)
- `GET /api/subscription/` - Информация о подписках

## Тарифные планы

| План | Цена | Основные функции |
|------|------|------------------|
| **Бесплатная** | $0.1 за сообщение | Базовый тест, диалог (платно), ограниченный анализ |
| **Премиум** | $5/месяц | Неограниченный диалог, рекомендации, помощь с бюрократией |
| **Pro** | $10/месяц | ВСЕ функции + персональный консультант + приоритет поддержка |

## Решение проблем

### Ошибка "ModuleNotFoundError: No module named 'django'"

Убедитесь что установили зависимости:
```bash
pip install -r requirements.txt
```

### Ошибка "No such table"

Запустите миграции:
```bash
python manage.py migrate
```

### AI не отвечает

Проверьте что установлен правильный API ключ в `.env`:
```env
AI_API_KEY=sk-your-actual-key
```

## Развертывание на production

Для развертывания на production:

1. Измените DEBUG на False в settings.py
2. Установите безопасный SECRET_KEY
3. Используйте production database (PostgreSQL рекомендуется)
4. Настройте ALLOWED_HOSTS
5. Используйте HTTPS
6. Рассмотрите использование Celery для асинхронных задач
7. Используйте production WSGI server (Gunicorn)

## Требования

- Python 3.9+
- Django 4.2+
- OpenAI API key
- SQLite 3+ (для development)

## Контакты и поддержка

- Email: support@startapon.com
- GitHub: https://github.com/yourusername/startapon
- Документация: Смотри README.md

## Лицензия

MIT License - Смотри LICENSE файл
