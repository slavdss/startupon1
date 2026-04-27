@echo off
REM StartAPon - скрипт запуска на Windows

echo ===================================
echo StartAPon - запуск приложения
echo ===================================

cd /d %~dp0

REM Создаем виртуальное окружение если его нет
if not exist "venv\Scripts\activate.bat" (
    echo Создаю виртуальное окружение...
    python -m venv venv
)

echo Активирую виртуальное окружение...
call venv\Scripts\activate.bat

echo Устанавливаю зависимости...
pip install -r requirements.txt

cd backend

REM Проверяем .env файл
if not exist ".env" (
    echo.
    echo ВАЖНО: Создайте .env файл!
    copy .env.example .env
    echo Создан .env файл. Отредактируйте его и добавьте GEMINI_API_KEY
    echo.
)

echo Применяю миграции...
python manage.py migrate

echo.
echo ===================================
echo Сервер запускается по адресу:
echo http://localhost:8000
echo ===================================
echo.

python manage.py runserver

pause
