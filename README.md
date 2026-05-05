# FileFlow

Securely sync your workflow anywhere.

FileFlow is a Flutter application that allows users to securely upload, manage, and share files across devices. It features authentication via mobile OTP, file categorization (images, videos, audios, documents), and cloud storage integration with Firebase.

## Features

- **Authentication**: Sign in with mobile number using OTP verification.
- **File Management**: Upload and organize files into categories like images, videos, audios, and documents.
- **Secure Storage**: Files are stored securely using Firebase Firestore and Storage.
- **Cross-Platform**: Built with Flutter for iOS and Android.
- **Connectivity Checks**: Monitors network status for online/offline functionality.

## Prerequisites

- Flutter SDK (^3.11.0)
- Dart SDK
- Firebase project setup

## Setup

1. Clone the repository:
   ```
   git clone <repository-url>
   cd fileflow
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure Firebase:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Enable Authentication (Phone), Firestore, and Storage.
   - Download `google-services.json` for Android and place it in `android/app/`.
   - For iOS, configure the GoogleService-Info.plist accordingly.
   - Update `lib/firebase_options.dart` with your Firebase configuration (or regenerate using `flutterfire configure`).

4. Run the app:
   ```
   flutter run
   ```

## Building

For Android APK:
```
flutter build apk --release
```

For iOS:
```
flutter build ios --release
```

## Project Structure

- `lib/core/`: Core utilities, dependency injection, routes, resources.
- `lib/features/`: Feature modules including auth, dashboard, home, splash, upload.
- `assets/`: Images, icons, and fonts.

## Dependencies

Key dependencies include:
- Firebase (Core, Auth, Firestore, Analytics, Crashlytics)
- Flutter Bloc for state management
- Go Router for navigation
- File Picker for selecting files
- And more...

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License.
