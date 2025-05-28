@echo off
echo Building and Running Vakeel Flutter App...

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Flutter is not installed or not in the PATH.
    echo Please run setup_flutter.bat first, then restart your terminal and try again.
    echo Alternatively, you can open the HTML preview:
    echo.
    echo start frontend\preview.html
    echo.
    pause
    exit /b 1
)

cd frontend
echo Installing Flutter dependencies...
flutter pub get

echo Running the Flutter application...
flutter run
