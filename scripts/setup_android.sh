#!/usr/bin/env bash
# Generates the Android platform folder (not committed), patches it, and renders brand PNGs.
set -euo pipefail
if [ ! -d android ]; then
  flutter create --platforms=android --org com.zuniq --project-name zuniq --no-pub .
fi
M=android/app/src/main/AndroidManifest.xml
sed -i 's/android:label="[^"]*"/android:label="ZUNIQ"/' "$M"
# Release builds need INTERNET for AI calls
grep -q 'android.permission.INTERNET' "$M" || \
  sed -i '0,/<application/s//<uses-permission android:name="android.permission.INTERNET"\/>\n    <application/' "$M"
grep -q 'android.permission.INTERNET' "$M" || { echo 'ERROR: INTERNET permission missing in manifest'; exit 1; }
# ML Kit needs a recent minSdk
for f in android/app/build.gradle.kts android/app/build.gradle; do
  [ -f "$f" ] && sed -i -e 's/minSdk = flutter.minSdkVersion/minSdk = 24/' -e 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 24/' "$f"
done
# Disable R8 minify: ML Kit text recognition references optional language modules that R8 rejects
for f in android/app/build.gradle.kts; do
  [ -f "$f" ] && sed -i '/signingConfig = signingConfigs.getByName("debug")/a\            isMinifyEnabled = false\n            isShrinkResources = false' "$f"
done
for f in android/app/build.gradle; do
  [ -f "$f" ] && sed -i '/signingConfig signingConfigs.debug/a\            minifyEnabled false\n            shrinkResources false' "$f"
done
grep -n -i "minify" android/app/build.gradle* || { echo "ERROR: could not disable minify"; exit 1; }
# Android lint crashed inside the release build (tool bug, not app code): skip lint for release builds
for f in android/app/build.gradle.kts; do
  [ -f "$f" ] && sed -i '/^android {/a\    lint {\n        checkReleaseBuilds = false\n        abortOnError = false\n    }' "$f"
done
for f in android/app/build.gradle; do
  [ -f "$f" ] && sed -i '/^android {/a\    lint {\n        checkReleaseBuilds false\n        abortOnError false\n    }' "$f"
done
grep -n "checkReleaseBuilds" android/app/build.gradle* || { echo "ERROR: could not disable lint"; exit 1; }
mkdir -p assets/brand/png
rsvg-convert -w 432  -h 432  assets/brand/launcher_foreground.svg -o assets/brand/png/launcher_foreground.png
rsvg-convert -w 432  -h 432  assets/brand/launcher_monochrome.svg -o assets/brand/png/launcher_monochrome.png
rsvg-convert -w 1024 -h 1024 assets/brand/app_icon.svg           -o assets/brand/png/app_icon.png
rsvg-convert -w 960  -h 960  assets/brand/splash_symbol.svg      -o assets/brand/png/splash_symbol.png
rm -f test/widget_test.dart
echo "Android setup complete."
