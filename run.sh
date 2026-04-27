#!/bin/bash

# StartAPon Project - Linux/Mac Startup Script
# Этот скрипт автоматически настраивает и запускает проект

echo "========================================="
echo "StartAPon - Запуск проекта"
echo "========================================="

# Проверяем Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 не найден. Пожалуйста, установите Python 3.9 или выше"
    exit 1
fi

echo "✓ Python найден: $(python3 --version)"

# Создаем виртуальное окружение если его нет
if [ ! -d "venv" ]; then
    echo ""
    echo "📦 Создаю виртуальное окружение..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "❌ Ошибка при создании виртуального окружения"
        exit 1
    fi
    echo "✓ Виртуальное окружение создано"
fi

# Активируем виртуальное окружение
echo "🔌 Активирую виртуальное окружение..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при активации виртуального окружения"
    exit 1
fi

# Устанавливаем зависимости
echo ""
echo "📚 Устанавливаю зависимости..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при установке зависимостей"
    exit 1
fi
echo "✓ Зависимости установлены"

# Проверяем .env файл
echo ""
if [ ! -f ".env" ]; then
    echo "⚠️  Файл .env не найден"
    echo ""
    echo "Создаю .env из примера..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✓ .env файл создан из .env.example"
        echo ""
        echo "⚠️  ВАЖНО: Отредактируйте файл .env и добавьте:"
        echo "   - GEMINI_API_KEY (получите на https://makersuite.google.com/app/apikey)"
        echo "   - OPENROUTER_API_KEY (если нужен OpenRouter)"
        echo ""
        echo "Откройте .env в редакторе и добавьте ключи перед запуском сервера"
        echo "Нажмите Enter когда готово..."
        read
    else
        echo "❌ Файл .env.example не найден"
        echo "Создаю .env с пустыми значениями..."
        cat > .env << 'EOF'
DEBUG=True
SECRET_KEY=your-secret-key-change-in-production
GEMINI_API_KEY=your-gemini-api-key-here
OPENROUTER_API_KEY=your-openrouter-key-here
ALLOWED_HOSTS=localhost,127.0.0.1
EOF
        echo "✓ Создан базовый .env файл"
        echo "❌ ВАЖНО: Добавьте GEMINI_API_KEY перед запуском!"
    fi
else
    echo "✓ Файл .env найден"
fi

# Переходим в папку backend
cd backend

# Применяем миграции
echo ""
echo "🗄️  Применяю миграции базы данных..."
python manage.py migrate
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при применении миграций"
    exit 1
fi
echo "✓ Миграции применены"

# Собираем статические файлы
echo ""
echo "📦 Собираю статические файлы..."
python manage.py collectstatic --noinput 2>/dev/null || true
echo "✓ Готово"

# Запускаем сервер
echo ""
echo "========================================="
echo "🚀 Запускаю развитие сервер"
echo "========================================="
echo ""
echo "🌐 Сервер доступен на: http://localhost:8000"
echo "🔓 Админ панель: http://localhost:8000/admin"
echo ""
echo "Нажмите Ctrl+C для остановки сервера"
echo ""

python manage.py runserver
python manage.py runserver
