#!/bin/bash
# Flutter Build Script for Android (Linux/macOS/Git Bash)
# Usage: ./build.sh [apk|aab] [dart-define-key dart-define-value...]
# Examples:
#   ./build.sh apk
#   ./build.sh apk API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1
#   ./build.sh aab API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1

set -e

BUILD_TYPE=${1:-apk}
shift || true

DART_DEFINES=()
while [ $# -gt 0 ]; do
    DART_DEFINES+=("--dart-define=$1=$2")
    shift
    shift
done

if [ "$BUILD_TYPE" == "apk" ]; then
    echo "🔨 Building Release APK..."
    flutter build apk \
        --release \
        --obfuscate \
        --split-debug-info=build/debug-info \
        --split-per-abi \
        "${DART_DEFINES[@]}"
    echo ""
    echo "✅ APK built successfully!"
    echo "📦 Output: build/app/outputs/flutter-apk/app-release.apk"
elif [ "$BUILD_TYPE" == "aab" ]; then
    echo "🔨 Building Release AAB (App Bundle)..."
    flutter build appbundle \
        --release \
        --obfuscate \
        --split-debug-info=build/debug-info \
        "${DART_DEFINES[@]}"
    echo ""
    echo "✅ AAB built successfully!"
    echo "📦 Output: build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ Invalid build type. Use 'apk' or 'aab'"
    echo ""
    echo "Usage: ./build.sh [apk|aab] [dart-define-key dart-define-value...]"
    echo ""
    echo "Examples:"
    echo "  ./build.sh apk"
echo "  ./build.sh apk API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1"
echo "  ./build.sh aab API_BASE_URL=https://cvbuilder.kidsgrow.com.bd/api/v1"
    exit 1
fi

echo ""
echo "📋 Post-build checklist:"
echo "  1. Verify version in pubspec.yaml (increment for each release)"
echo "  2. Test the built APK/AAB on a physical device"
echo "  3. Upload to Google Play Console (AAB recommended)"
echo "  4. Update changelog / release notes"
