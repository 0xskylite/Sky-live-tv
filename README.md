# Sky Live TV

Flutter Android live-TV app. The repository includes a GitHub Actions workflow that generates the Android platform folder when it is absent, checks the Dart code, and builds a release APK and Android App Bundle.

## Build on GitHub

1. Extract this ZIP and create a GitHub repository.
2. Upload/commit **all files and folders**, including the hidden `.github/workflows/android-build.yml` file.
3. Push to `main` or `master`, or open **Actions → Android APK Build → Run workflow**.
4. Wait for the workflow to finish successfully.
5. Open the completed workflow run and download **Artifacts → `skylivetv-android-release`**. It contains:
   - `app-release.apk` — install on Android
   - `app-release.aab` — Google Play upload format

The workflow uses Java 17 and the stable Flutter channel. It generates Android project files in the runner if they are missing, adds Android internet permission, and enables cleartext traffic for legacy `http://` stream URLs. HTTPS streams are preferred.

## Build locally

Install Flutter and Android SDK, then run:

```bash
flutter create --platforms=android --org com.skylivetv --project-name skylivetv .
flutter pub get
flutter analyze
flutter build apk --release
flutter build appbundle --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`
AAB output: `build/app/outputs/bundle/release/app-release.aab`

## Features

- Dark cinematic UI with Sky-blue accents
- Featured channels and category browsing
- Search (with clear button) and favorites (persisted on device)
- Continue Watching rail (persisted recents)
- Kids Mode with parental gate (math question to switch off)
- Pulsing LIVE badge, per-category card gradients/emoji
- Player: channel info card, related channels, retry button
- Responsive grids (more columns on tablets)
- Custom launcher icon + native splash (generated in CI)
- HLS (`.m3u8`) and MP4 playback
- M3U playlist import (group-title with "kid" → visible in Kids Mode)

## Stream source note

A channel plays only when its stream URL is reachable and valid. Use only stream sources you own or are authorized to distribute. Stream availability, geo-restrictions, and provider-side changes are outside the app's control.
