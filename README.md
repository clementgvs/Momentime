# Momentime

<p align="center">
  <img src="assets/images/logo.jpg" alt="Momentime logo" width="160">
</p>

<p align="center">
  <a href="https://github.com/clementgvs/Momentime/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/clementgvs/Momentime?style=for-the-badge" alt="License: MIT">
  </a>
  <!--
  <a href="https://github.com/clementgvs/Momentime/releases">
    <img src="https://img.shields.io/github/v/release/clementgvs/Momentime?style=for-the-badge" alt="Latest release">
  </a>
  <a href="https://github.com/clementgvs/Momentime/stargazers">
    <img src="https://img.shields.io/github/stars/clementgvs/Momentime?style=for-the-badge" alt="GitHub stars">
  </a>
</p>
-->

**Momentime** is a Flutter mobile app for planning activities and comparing availability with friends. It combines a personal calendar with shared group calendars and real-time group conversations.

## Features

- Personal calendar with device calendar synchronization
- Firebase authentication and account management
- Shared groups with member management
- Group calendars based on member availability
- Real-time group messaging
- Android and iOS support

## Built with

- Flutter & Dart
- Firebase Authentication
- Cloud Firestore
- Syncfusion Flutter Calendar
- `device_calendar`

## Getting started

### Prerequisites

- Flutter SDK 3.10 or newer
- Firebase project
- Android Studio or Xcode

### Installation

```bash
git clone https://github.com/clementgvs/Momentime.git
cd Momentime
flutter pub get
flutter run
```

Before running the app, configure Firebase for the target platforms:

1. Create or select a Firebase project.
2. Enable Firebase Authentication and Cloud Firestore.
3. Add Android and iOS apps to the Firebase project.
4. Place `google-services.json` under `android/app/` and `GoogleService-Info.plist` under `ios/Runner/`.
5. Update the platform options in `lib/backend/firebase_options.dart` if needed.

## Project structure

```text
lib/
  backend/   Firebase and device-calendar services
  models/    Event, group, and message models
  pages/     Application screens
assets/      Application resources
test/        Flutter tests
```

## License

Momentime is available under the [MIT License](LICENSE).
