# ZUNIQ - Understand Anything.

Flutter, Riverpod, GoRouter. Status: M0-M1 plus scan > OCR > AI explanation > local library.
See SETUP_AI.md to enable AI explanations.

## Build the APK with GitHub Actions (from Termux)
1. `pkg install git unzip` then `unzip zuniq_m0_m1.zip && cd zuniq`
2. Create an empty repo on github.com, then:
   `git init && git add . && git commit -m "ZUNIQ M0+M1" && git branch -M main`
   `git remote add origin https://github.com/<you>/<repo>.git && git push -u origin main`
   (use a personal access token as the password)
3. GitHub > Actions > "Build ZUNIQ APK" > latest run > Artifacts > zuniq-apk. Download, install.
4. If a step fails, copy the red error lines to Claude.

The workflow generates the android/ folder and launcher/splash PNGs at build time (scripts/setup_android.sh).
Local build needs the Flutter SDK, `librsvg2-bin`, then `bash scripts/setup_android.sh && flutter run`.
