@echo off
title Installation - Rapports CVC
cd /d "%~dp0"

echo ============================================
echo  1/3  Paquets Python
echo ============================================
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
if errorlevel 1 (
  echo.
  echo ECHEC de l'installation des paquets Python.
  echo Verifiez la connexion Internet et que Python est installe, puis relancez.
  pause
  exit /b 1
)

echo.
echo Verification des paquets...
python -c "import flask, waitress, docx, faster_whisper, requests, tzdata; print('Paquets Python : OK')"
if errorlevel 1 (
  echo.
  echo Un paquet ne s'importe pas correctement. Copiez le message ci-dessus pour le diagnostic.
  pause
  exit /b 1
)

echo.
echo ============================================
echo  2/3  Ollama (IA de reformulation locale)
echo ============================================
where ollama >nul 2>nul
if %errorlevel%==0 goto ollama_path
if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" goto ollama_local

echo Installation d'Ollama avec winget...
winget install -e --id Ollama.Ollama --accept-package-agreements --accept-source-agreements
timeout /t 8 >nul
if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" goto ollama_local

echo.
echo Ollama n'a pas pu etre installe automatiquement.
echo Installez-le a la main depuis https://ollama.com puis relancez ce script.
pause
exit /b 1

:ollama_local
set "OLL=%LOCALAPPDATA%\Programs\Ollama\ollama.exe"
goto pull

:ollama_path
set "OLL=ollama"

:pull
echo.
echo ============================================
echo  3/3  Modele de langue mistral (environ 4 Go)
echo ============================================
"%OLL%" pull mistral
if errorlevel 1 (
  echo.
  echo Le telechargement du modele a echoue.
  echo Lancez Ollama depuis le menu Demarrer ^(icone pres de l'horloge^), puis relancez ce script.
  pause
  exit /b 1
)

echo.
echo ============================================
echo  Installation terminee.
echo  Prochaines etapes :
echo    - python setup.py   ^(une seule fois : creer le mot de passe^)
echo    - demarrer-rapports.bat
echo ============================================
pause
