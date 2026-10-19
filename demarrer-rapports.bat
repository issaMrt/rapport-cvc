@echo off
title Rapports CVC - serveur
cd /d "%~dp0"

if not exist data\config.json (
  echo Mot de passe non configure. Lancez d'abord : python setup.py
  echo.
  pause
  exit /b 1
)

if exist venv\Scripts\activate.bat call venv\Scripts\activate.bat

echo Publication sur le reseau prive Tailscale...
set "TS=tailscale"
where tailscale >nul 2>nul || set "TS=C:\Program Files\Tailscale\tailscale.exe"
"%TS%" serve --bg 8000
if errorlevel 1 (
  echo.
  echo Attention : Tailscale n'a pas repondu. Verifiez qu'il est installe et connecte.
  echo Le site reste utilisable sur ce PC : http://127.0.0.1:8000
)

echo.
echo Demarrage du serveur. Laissez cette fenetre ouverte pendant l'utilisation.
echo Pour arreter : fermez la fenetre ou faites Ctrl+C.
echo.
python app.py
echo.
echo Le serveur s'est arrete.
pause
