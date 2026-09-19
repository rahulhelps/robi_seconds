@echo off
REM Flutter Build Script for Android (Windows)
REM Usage: build.bat [apk|aab] [dart-define-key dart-define-value...]
REM Examples:
REM   build.bat apk
REM   build.bat apk API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1
REM   build.bat aab API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1

setlocal enabledelayedexpansion

set BUILD_TYPE=%1
set DART_DEFINES=

REM Parse dart-define arguments (skip the first argument which is build type)
:parse_args
if "%2"=="" goto :build
if "%3"=="" goto :build
set DART_DEFINES=!DART_DEFINES! --dart-define=%2=%3
shift
shift
goto :parse_args

:build
if "%BUILD_TYPE%"=="apk" (
    echo 🔨 Building Release APK...
    flutter build apk ^
        --release ^
        --obfuscate ^
        --split-debug-info=build\debug-info ^
        --split-per-abi ^
        !DART_DEFINES!
    echo.
    echo ✅ APK built successfully!
    echo 📦 Output: build\app\outputs\flutter-apk\app-release.apk
) else if "%BUILD_TYPE%"=="aab" (
    echo 🔨 Building Release AAB (App Bundle)...
    flutter build appbundle ^
        --release ^
        --obfuscate ^
        --split-debug-info=build\debug-info ^
        !DART_DEFINES!
    echo.
    echo ✅ AAB built successfully!
    echo 📦 Output: build\app\outputs\bundle\release\app-release.aab
) else (
    echo ❌ Invalid build type. Use 'apk' or 'aab'
    echo.
    echo Usage: build.bat [apk^|aab] [dart-define-key dart-define-value...]
    echo.
    echo Examples:
    echo   build.bat apk
    echo   build.bat apk API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1
    echo   build.bat aab API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1
    exit /b 1
)

echo.
echo 📋 Post-build checklist:
echo   1. Verify version in pubspec.yaml (increment for each release)
echo   2. Test the built APK/AAB on a physical device
echo   3. Upload to Google Play Console (AAB recommended)
echo   4. Update changelog / release notes

endlocal
