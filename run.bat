@echo off
cd /d "%~dp0"
if not exist dart_defines.json (
  echo dart_defines.json is missing. Copy dart_defines.example.json and put your proxy URL in it.
  pause
  exit /b 1
)
call flutter run --dart-define-from-file=dart_defines.json %*
