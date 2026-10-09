@echo off
cd /d "%~dp0"

echo.
echo === 1/3  Adding any missing platform folders (android, web, windows)
echo          Your lib\ code is not touched.
call flutter create . --platforms=android,web,windows --project-name trivet --org com.trivet
if errorlevel 1 goto fail

if exist test\widget_test.dart (
  findstr /c:"MyApp" test\widget_test.dart >nul && del test\widget_test.dart
)

echo.
echo === 2/3  Allowing internet and links on Android
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\patch_android.ps1"

echo.
echo === 3/3  Getting packages
call flutter pub get
if errorlevel 1 goto fail

echo.
echo Setup done. Start the app with:  run.bat
echo (or press F5 in VS Code)
pause
exit /b 0

:fail
echo.
echo Setup stopped because of the error above. Copy it and ask for help.
pause
exit /b 1
