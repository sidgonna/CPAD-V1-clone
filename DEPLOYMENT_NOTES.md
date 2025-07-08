# MindDrop Deployment Notes

This document contains notes and reminders for preparing MindDrop for deployment to app stores.

## Android

### Keystore and Signing
- A keystore must be generated for signing release builds.
- Create `android/key.properties` by copying `android/key.properties.template` and fill in the actual credential values:
  - `storePassword`: The password for the keystore.
  - `keyPassword`: The password for the key alias within the keystore.
  - `keyAlias`: The alias name for your key.
  - `storeFile`: Path to your keystore file (e.g., `my-release-key.keystore`). If just a filename, place it in the Flutter project root.
- Ensure `android/key.properties` is **NOT** committed to version control (it should be in `.gitignore`).
- The `android/app/build.gradle.kts` file is configured to use these properties for release signing.
- Application ID: `com.example.minddrop` (Verify this is unique and correct for your Play Store listing).

### Store Listing Information (Google Play)
- **App Title**: Max 50 characters.
- **Short Description**: Max 80 characters.
- **Full Description**: Max 4000 characters.
- **App Icon**: 512x512 px (usually from your source 1024x1024 icon).
- **Feature Graphic**: 1024x500 px (JPEG or 24-bit PNG).
- **Screenshots**: Min 2, Max 8 per device type (phone, 7" tablet, 10" tablet). Various aspect ratios.
- **Promo Video (Optional)**: YouTube URL.
- **Application Type**: App / Game.
- **Category**: e.g., Productivity, Tools.
- **Content Rating**: Via questionnaire in Play Console.
- **Contact Details**: Email (mandatory), website, phone.
- **Privacy Policy URL**: Mandatory for most apps.
- **Pricing & Distribution**: Free/Paid, target countries.

### Build Commands
- **APK**: `flutter build apk --release`
- **App Bundle**: `flutter build appbundle --release` (Recommended for Google Play)

## iOS

### Bundle ID
- The `CFBundleIdentifier` is set in the Xcode project (Runner > Signing & Capabilities). It should be unique, e.g., `com.example.minddrop`. This is typically configured by Flutter based on the `flutter create --org` parameter.

### Versioning
- `CFBundleShortVersionString` (Display Version) and `CFBundleVersion` (Build Number) are automatically sourced from `pubspec.yaml` (`$(FLUTTER_BUILD_NAME)` and `$(FLUTTER_BUILD_NUMBER)` respectively).

### Signing
- iOS app signing is managed through Xcode and requires an active Apple Developer Program membership.
- **Steps**:
  1.  Register the Bundle ID on the Apple Developer portal.
  2.  Create necessary Signing Certificates (Development and Distribution).
  3.  Create necessary Provisioning Profiles (Development and Distribution) linked to the App ID and certificates.
  4.  In Xcode (open `ios/Runner.xcworkspace`):
      - Select the "Runner" target.
      - Go to the "Signing & Capabilities" tab.
      - Select your Team.
      - Xcode can attempt to "Automatically manage signing."
      - If manual signing is preferred/needed, select the appropriate Provisioning Profile and Signing Certificate for Release builds.

### Build Command
- **IPA**: `flutter build ipa --release`

### Store Listing Information (Apple App Store Connect)
- **App Name**: Max 30 characters.
- **Subtitle (Optional)**: Max 30 characters.
- **Bundle ID**: e.g., `com.example.minddrop` (must be unique and registered).
- **App Previews (Optional)**: Short videos (up to 30s, max 3 per localization).
- **Screenshots**: Min 1, Max 10 per device type (e.g., 6.7", 6.5", 5.5", iPad Pro 12.9"). Specific resolutions required.
- **Promotional Text (Optional)**: Max 170 characters.
- **Description**: Max 4000 characters.
- **Keywords**: Max 100 characters total, comma-separated.
- **Support URL**: Mandatory.
- **Marketing URL (Optional)**.
- **Version Information**: Version number (e.g., 1.0.0 from pubspec), "What's New" text.
- **Copyright**: e.g., "© YYYY Your Name/Company".
- **App Store Icon**: 1024x1024 px (JPEG or PNG).
- **Rating**: Determined by content questionnaire.
- **Pricing and Availability**: Price tier, target countries.
- **App Privacy Details**: Answer data usage questions in App Store Connect; requires a Privacy Policy URL.
- **Review Contact Information**: Name, email, phone for Apple's review team.
- **Demo Account (if applicable)**.

## General
- **App Icons**: Replace placeholder icons in `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with your actual app icons (source usually 1024x1024px). Consider using `flutter_launcher_icons`.
- **Splash Screens**: The app is configured to use `flutter_native_splash`. Provide an image at `assets/icons/app_icon_for_splash.png` (or update path in `pubspec.yaml`) and run `flutter pub run flutter_native_splash:create`.
- **Store Assets**: Prepare screenshots, feature graphics, descriptions, etc., as outlined in P5-ASSETS-003.
- **Store Assets**: Prepare screenshots, feature graphics, descriptions, etc., as outlined in P5-ASSETS-003.

## Legal Documentation
- **Privacy Policy (Mandatory)**:
  - A Privacy Policy is required by both Google Play and Apple App Store.
  - It must be accessible via a public URL.
  - For MindDrop (local-first, no tracking):
    - Clearly state that all data (ideas, images, styles) is stored locally on the user's device.
    - Confirm that the app does not collect or transmit any personal data.
    - Explain how users can manage/delete their data (e.g., in-app deletion, app uninstallation).
    - Provide contact information for privacy inquiries.
  - A template `PRIVACY_POLICY.md` is included in the project root as a starting point.
- **Terms of Service (ToS) / EULA (Recommended)**:
  - Consider creating a ToS/EULA to define terms of use, disclaimers, and limitations of liability.
- **GDPR & Regional Compliance**:
  - Be mindful of regulations like GDPR if distributing in relevant regions. For a local-first app, this primarily involves transparency and user control over local data.
- **Content Rating**:
  - Complete the content rating questionnaire accurately in both app stores during submission. This will determine the app's age rating.
