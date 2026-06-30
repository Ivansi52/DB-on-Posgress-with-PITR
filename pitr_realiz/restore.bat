@echo off
setlocal enabledelayedexpansion

set PGPASSWORD=root
set BASE_DIR=D:\course_proj_DB\base_backup
set DATA_DIR=D:\postgresql\data
set WAL_ARCHIVE=D:\course_proj_DB\wal_archive
set LOG_FILE=D:\course_proj_DB\scripts\restore_log.txt

echo ============================== >> %LOG_FILE%
echo %date% %time% Начало восстановления >> %LOG_FILE%

REM Ищем последний backup
for /f "delims=" %%i in ('dir %BASE_DIR% /b /ad /o-n') do (
    set LAST_BACKUP=%%i
    goto found
)

:found
if "!LAST_BACKUP!"=="" (
    echo Ошибка: нет доступных backup >> %LOG_FILE%
    exit /b
)

set FULL_PATH=%BASE_DIR%\!LAST_BACKUP!
echo Используется backup: %FULL_PATH% >> %LOG_FILE%

REM Проверка наличия архива
if not exist "%FULL_PATH%\base.tar.gz" (
    echo Ошибка: файл backup не найден >> %LOG_FILE%
    exit /b
)

REM Остановка PostgreSQL
net stop postgresql-x64-18
if %errorlevel% neq 0 (
    echo Ошибка остановки PostgreSQL >> %LOG_FILE%
    exit /b
)

REM Очистка data
rmdir /s /q %DATA_DIR%
mkdir %DATA_DIR%

REM Распаковка
"D:\postgresql\bin\tar" -xzf %FULL_PATH%\base.tar.gz -C %DATA_DIR%
if %errorlevel% neq 0 (
    echo Ошибка распаковки backup >> %LOG_FILE%
    exit /b
)

REM recovery
echo. > %DATA_DIR%\recovery.signal
del %DATA_DIR%\postgresql.auto.conf 2>nul
echo restore_command = 'copy "D:\\course_proj_DB\\wal_archive\\%%f" "%%p"' > %DATA_DIR%\postgresql.auto.conf

REM запуск PostgreSQL
net start postgresql-x64-18
if %errorlevel% neq 0 (
    echo Ошибка запуска PostgreSQL >> %LOG_FILE%
    exit /b
)

echo %date% %time% Восстановление завершено >> %LOG_FILE%