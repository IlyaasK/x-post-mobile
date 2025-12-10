# x-post-mobile

A "Write-Only" X (Twitter) client that reimagines posting as a private chat with your homies.
Built with Flutter.

## Inspiration
![Treating this app like a group chat is the way to go I think](assets/images/inspiration.png)

> "Treating this app like a group chat is the way to go I think"
> — [@levelsio](https://twitter.com/levelsio/status/1992210699846877646)

Inspired by the idea that posting to X should feel as low-friction as a group chat.

## Key Features
-   **Group Chat Vibe**: Tweet like you're in a group chat with the homies.
-   **Distraction Free**: A "write-only" interface where you don't see others' tweets, keeping you focused.
-   **Thread Support**: Easily create threads by replying to your own tweets.
-   **Secure Storage**: API keys are stored in the system's secure keystore (Android Keystore / Linux Keyring).
-   **Dark Mode**: Signal-like dark theme.

## Setup

### 1. Get X API Keys
You need a developer account on X.
-   Consumer Key
-   Consumer Secret
-   Access Token
-   Access Token Secret

### 2. Run the App
On the first launch, the app will ask you to enter these keys. They are saved securely on your device.

## Building

### Android (APK)
Since the Android SDK is large, we use **GitHub Actions** to build the APK automatically.
1.  Push this code to GitHub.
2.  Go to **Actions** tab.
3.  Download the `app-release-apk` artifact.

### Linux (Desktop)
```bash
flutter pub get
flutter run -d linux
```

## Security Note
This app uses `flutter_secure_storage` to save your API keys.
-   **Android**: Uses EncryptedSharedPreferences / Keystore.
-   **Linux**: Uses `libsecret` (requires a keyring like gnome-keyring).
-   **Rooted Devices**: Security cannot be guaranteed on rooted devices.

## License
MIT
# x-post-mobile
