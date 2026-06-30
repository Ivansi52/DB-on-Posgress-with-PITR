@echo off
setlocal enabledelayedexpansion
set PGPASSWORD=root

set BASE_DIR=D:\course_proj_DB\base_backup
set LOG_FILE=D:\course_proj_DB\scripts\backup_log.txt

:: Получаем дату-время через PowerShell (формат ГГГГ-ММ-ДД_ЧЧ-ММ)
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm"') do set TIMESTAMP=%%i

set BACKUP_DIR=%BASE_DIR%\%TIMESTAMP%

echo Создаю папку версии: %BACKUP_DIR%
mkdir "%BACKUP_DIR%"

"D:\postgresql\bin\pg_basebackup.exe" -D "%BACKUP_DIR%" -Ft -z -P -U postgres

if %errorlevel%==0 (
    echo %date% %time% УСПЕХ: Backup создан в %TIMESTAMP% >> %LOG_FILE%
    echo --- БЭКАП ЗАВЕРШЕН ---
) else (
    echo %date% %time% ОШИБКА: Код %errorlevel% >> %LOG_FILE%
    echo --- ОШИБКА БЭКАПА ---
    rmdir "%BACKUP_DIR%"
)
pause