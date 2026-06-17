@echo off
echo ============================================
echo   BarberTurno - Script de Configuracion
echo ============================================
echo.

:: Verificar Flutter
echo [1/6] Verificando Flutter...
flutter --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter no esta instalado.
    echo Descargalo de: https://docs.flutter.dev/get-started/install/windows/mobile
    echo Agrega C:\flutter\bin al PATH del sistema.
    pause
    exit /b 1
)
flutter --version
echo.

:: Verificar Android Studio
echo [2/6] Verificando licencias de Android...
call flutter doctor --android-licenses 2>nul
echo.

:: Verificar Node.js (para Firebase CLI)
echo [3/6] Verificando Node.js...
node --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Node.js no esta instalado. Necesario para Firebase CLI.
    echo Descargalo de: https://nodejs.org
) else (
    node --version
)
echo.

:: Instalar Firebase CLI
echo [4/6] Instalando Firebase CLI y FlutterFire...
call npm install -g firebase-tools 2>nul
call dart pub global activate flutterfire_cli 2>nul
echo.

:: Instalar dependencias Flutter
echo [5/6] Instalando dependencias del proyecto...
call flutter pub get
echo.

:: Diagnostico final
echo [6/6] Diagnostico del entorno...
call flutter doctor
echo.

echo ============================================
echo   Configuracion completada!
echo ============================================
echo.
echo SIGUIENTES PASOS:
echo 1. Crear proyecto en https://console.firebase.google.com
echo 2. Ejecutar: flutterfire configure --project=TU_PROJECT_ID
echo 3. Activar Authentication y Firestore en Firebase Console
echo 4. Ejecutar: flutter run
echo.
pause
