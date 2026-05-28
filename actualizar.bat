@echo off
title GastoSmart - Actualizador
color 0B
cls
echo.
echo  ==========================================
echo   GastoSmart - Actualizador Automatico
echo  ==========================================
echo.

git --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo  ERROR: Git no instalado. Descarga en git-scm.com
    pause ^& exit /b 1
)

if not exist "%~dp0index.html" (
    color 0C
    echo  ERROR: No se encontro index.html
    pause ^& exit /b 1
)

if not exist "%~dp0vercel.json" (
    color 0E
    echo  AVISO: No se encontro vercel.json en esta carpeta.
    echo  El control de cache NO se desplegara. Copialo aqui y vuelve a correr.
    echo.
)

echo  [1/3] Verificando archivos... OK

cd /d "%~dp0"
git config user.email "pemoang@hotmail.com" >nul 2>&1
git config user.name "Pedro Molina" >nul 2>&1
git branch -m master main >nul 2>&1
git branch --set-upstream-to=origin/main main >nul 2>&1

REM Timestamp unico YYYYMMDDHHMMSS para versionar el deploy
set TS=%date:~6,4%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
set TS=%TS: =0%

REM Inyecta la version en la meta tag (acepta cualquier longitud, preserva UTF-8)
powershell -NoProfile -Command "(Get-Content '%~dp0index.html' -Raw) -replace 'name=\"app-version\" content=\"[0-9]+\"','name=\"app-version\" content=\"%TS%\"' | Set-Content '%~dp0index.html' -NoNewline -Encoding UTF8"

echo  Version inyectada: %TS%
echo  [2/3] Subiendo a GitHub...
git fetch origin main >nul 2>&1
git checkout main >nul 2>&1
git add -A
git commit --allow-empty -m "GastoSmart v%TS%"
git push origin main --force

if %errorlevel% neq 0 (
    echo  Autenticando...
    git push origin main --force
)

color 0A
echo.
echo  [3/3] Listo!
echo  ==========================================
echo   App actualizada - version %TS%
echo  ==========================================
echo.
echo  https://gasto-smart-six.vercel.app
echo.
timeout /t 30 /nobreak >nul
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" "https://gasto-smart-six.vercel.app" 2>nul || start https://gasto-smart-six.vercel.app
exit /b 0
