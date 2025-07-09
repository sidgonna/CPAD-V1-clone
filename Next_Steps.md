# Next Steps for MindDrop Development & Deployment

This document outlines the steps a developer should take after cloning the MindDrop repository to their local machine, including setting up the project, running tests, and building release versions.

## 1. Initial Project Setup

After cloning the repository, navigate to the project's root directory (`minddrop`) in your terminal.

### 1.1. Ensure Flutter Environment is Ready
   - Run `flutter doctor -v` to verify your Flutter installation and ensure all necessary components (Android toolchain, Xcode for iOS, etc.) are correctly set up. Address any issues reported.

### 1.2. Get Flutter Dependencies
   - Fetch all the project dependencies defined in `pubspec.yaml`:
     ```bash
     flutter pub get
     ```

### 1.3. Generate Code (Hive Adapters, Mocks)
   - The project uses Hive for local storage and Mockito for generating mocks for unit tests. Run the build_runner to generate necessary files:
     ```bash
     flutter pub run build_runner build --delete-conflicting-outputs
     ```
   - This command needs to be run whenever:
     - Hive model classes (`Idea`, `RandomStyle`) are changed.
     - `@GenerateMocks` annotations are added or modified in test files.

### 1.4. Generate Native Splash Screens
   - The project is configured to use `flutter_native_splash`. After `flutter pub get`, ensure your splash screen assets (e.g., `assets/icons/app_icon_for_splash.png`) are in place and then run:
     ```bash
     flutter pub run flutter_native_splash:create
     ```
   - Run this command if you change splash screen configurations in `pubspec.yaml` or update the splash image assets.

## 2. Running Tests

The project includes unit and widget tests.

### 2.1. Run All Tests
   - To execute all tests (unit and widget tests located in the `test/` directory):
     ```bash
     flutter test
     ```
   - Review the output in the terminal. Address any failing tests.

### 2.2. Run Specific Test Files (Optional)
   - To run tests in a specific file:
     ```bash
     flutter test path/to/your_test_file.dart
     ```
     Example: `flutter test test/controllers/ideas_controller_test.dart`

### 2.3. Test Coverage (Optional)
   - To generate a test coverage report:
     ```bash
     flutter test --coverage
     ```
   - The coverage report will be generated in the `coverage/` directory (e.g., `coverage/lcov.info`). You can use tools like `genhtml` (part of LCOV) to view this as an HTML report.

## 3. Running the Application

### 3.1. Run in Debug Mode
   - To run the app on a connected device or emulator/simulator in debug mode:
     ```bash
     flutter run
     ```
   - Select the target device/emulator when prompted if multiple are available.

### 3.2. Run in Profile or Release Mode (Locally)
   - To test performance or release behavior locally:
     ```bash
     flutter run --profile
     flutter run --release
     ```
   - Note: Running in `--release` mode locally will use debug signing keys unless your Android build is configured to use release keys by default (which is not typical without `key.properties` set up).

## 4. Building Release APK (Android)

Refer to `DEPLOYMENT_NOTES.md` for more details on signing.

### 4.1. Set Up Release Signing (One-time setup)
   - **Generate a Keystore**: If you haven't already, create a Java Keystore (JKS) file for signing your app.
     ```bash
     keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
     ```
     (Place `my-release-key.keystore` in a secure location, e.g., project root or `android/app/`.)
   - **Create `key.properties`**:
     - In the `android/` directory of your project, copy `key.properties.template` to `key.properties`.
     - Edit `android/key.properties` and fill in your keystore password, key alias, key password, and the path to your keystore file (e.g., `storeFile=../my-release-key.keystore` if the keystore is in the project root, or `storeFile=my-release-key.keystore` if it's in `android/app/`).
     - **Ensure `android/key.properties` is in your `.gitignore` file and NOT committed to version control.**

### 4.2. Build the APK
   - To build a release APK (typically a universal APK, or use `--split-per-abi` for smaller, architecture-specific APKs):
     ```bash
     flutter build apk --release
     ```
     or for split APKs:
     ```bash
     flutter build apk --release --split-per-abi
     ```
   - The output APK(s) will be located in `build/app/outputs/flutter-apk/`. For example, `app-release.apk`.

### 4.3. Build Android App Bundle (AAB - Recommended for Google Play)
   - To build an Android App Bundle for uploading to the Google Play Store:
     ```bash
     flutter build appbundle --release
     ```
   - The output AAB will be located at `build/app/outputs/bundle/release/app-release.aab`.

## 5. Building Release IPA (iOS)

Refer to `DEPLOYMENT_NOTES.md` for more details on iOS signing setup (requires an Apple Developer account and Xcode configuration).

### 5.1. Set Up iOS Signing (One-time setup in Xcode)
   - Open the iOS module in Xcode: `open ios/Runner.xcworkspace`.
   - Select "Runner" in the project navigator.
   - Go to the "Signing & Capabilities" tab.
   - Select your Team from the dropdown.
   - Ensure "Automatically manage signing" is checked, or manually configure your provisioning profiles and signing certificates for the "Release" configuration.

### 5.2. Build the IPA
   - To build a release IPA:
     ```bash
     flutter build ipa --release
     ```
   - This command will create an Xcode archive (`.xcarchive`) in `build/ios/archive/`.
   - After archiving, Xcode Organizer typically opens, or you can open it manually. From Organizer, you can distribute the app (e.g., upload to App Store Connect, or export the IPA for ad-hoc distribution).
   - Alternatively, you can use tools like Fastlane to automate this process.

## 6. Further Steps
   - Refer to `TESTING_CHECKLIST.md` for manual testing guidelines.
   - Refer to `DEPLOYMENT_NOTES.md` for comprehensive information on store listing preparation, final build procedures, and post-launch activities.
   - The `PRIVACY_POLICY.md` template should be reviewed, customized, and hosted at a public URL for store submission.
