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

## User Acceptance Testing (UAT) Guidelines

Before full public launch, it's highly recommended to conduct User Acceptance Testing (UAT) with a small group of representative users.

**1. Identify Target Users/Personas:**
   - Consider who MindDrop is for. Examples:
     - *Alex, the Student*: Uses MindDrop to quickly jot down lecture notes, research ideas, and visual inspirations for projects. Values speed and simplicity.
     - *Sam, the Creative Professional*: Uses MindDrop for brainstorming, mood boarding with images, and organizing different creative project ideas. Values visual organization and quick capture.
     - *Jamie, the Everyday Thinker*: Uses MindDrop for random thoughts, to-do lists with a visual flair, and personal reminders. Values ease of use and a pleasant interface.

**2. Define Key UAT Tasks:**
   Based on personas, define 5-7 core tasks for testers to perform. Examples:
   - "Imagine you just had a brilliant idea for a personal project. Open MindDrop and capture this idea with a title, some details, and a relevant image from your gallery."
   - "You're looking for an idea you saved last week about 'sustainable gardening'. Use the search feature to find it."
   - "You have several important ideas. Mark at least three of them as favorites. Then, filter your view to see only your favorite ideas."
   - "You want to change the look of the app. Go to settings and switch to the dark theme (or light, if already dark)."
   - "You want to back up one of your important ideas. Share it via email to yourself."
   - "You've decided an old idea is no longer relevant. Find it and delete it."
   - "Explore the app freely for 10 minutes and try to use various features you discover."

**3. Feedback Collection Methods:**
   - **Think Aloud Protocol (if possible)**: Ask users to speak their thoughts as they perform tasks.
   - **Simple Survey**: After testing, provide a short survey with questions like:
     - "How easy was it to create a new idea?" (Scale 1-5)
     - "Were you able to easily find the search feature?" (Yes/No)
     - "What did you like most about the app?" (Open text)
     - "What did you find confusing or difficult?" (Open text)
     - "Any bugs or issues you encountered?" (Open text)
     - "Any suggestions for improvement?" (Open text)
   - **Informal Interviews**: Have a brief chat with testers after their session.

**4. Focus Areas for UAT Feedback:**
   - **Usability**: Is the app intuitive and easy to navigate?
   - **Functionality**: Do all features work as expected?
   - **Clarity**: Are icons, labels, and messages clear?
   - **Performance**: Does the app feel responsive? (Subjective feedback)
   - **Overall Satisfaction**: Would they use this app?

UAT provides invaluable insights into how real users interact with the app, helping to identify issues and areas for improvement before a wider release.

## Final Build Checklist & Procedures

This checklist should be followed before generating the final builds for store submission.

**1. Versioning (`pubspec.yaml`):**
   - [ ] **Verify `version`**: Ensure the `version: x.y.z+b` in `pubspec.yaml` is correct for the release.
     - `x.y.z` is the user-facing version name (e.g., `1.0.0`).
     - `b` is the build number (integer, e.g., `1`). Increment for each new build submitted to the stores.
   - Example for initial release: `version: 1.0.0+1`

**2. Android Release Preparation:**
   - [ ] **Application ID**: Confirm `applicationId` in `android/app/build.gradle.kts` is correct and unique (e.g., `com.example.minddrop`).
   - [ ] **Keystore & `key.properties`**:
     - Ensure your release keystore file (e.g., `my-release-key.keystore`) is accessible.
     - Ensure `android/key.properties` exists (copied from `key.properties.template`) and contains the correct `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` path.
     - **CRITICAL**: Double-check that `android/key.properties` is listed in `.gitignore` and has NOT been committed.
   - [ ] **Build Command (App Bundle - Recommended for Play Store):**
     ```bash
     flutter build appbundle --release
     ```
     - Output located at: `build/app/outputs/bundle/release/app-release.aab`
   - [ ] **Build Command (APK - Optional, for direct distribution or other stores):**
     ```bash
     flutter build apk --release --split-per-abi
     ```
     - (Using `--split-per-abi` generates smaller, architecture-specific APKs. Alternatively, a universal APK can be built without it, but it's larger.)
     - Output located at: `build/app/outputs/flutter-apk/app-release.apk` (or multiple if split)

**3. iOS Release Preparation:**
   - [ ] **Bundle ID**: Confirm `PRODUCT_BUNDLE_IDENTIFIER` in Xcode (Runner target > Signing & Capabilities) is correct and unique (e.g., `com.example.minddrop`). This is usually set from `flutter create` and `pubspec.yaml` but verify in Xcode.
   - [ ] **Versioning**: Confirm `Version` (CFBundleShortVersionString) and `Build` (CFBundleVersion) in Xcode match `pubspec.yaml` values. Flutter build process usually handles this.
   - [ ] **Signing (Xcode)**:
     - Open `ios/Runner.xcworkspace` in Xcode.
     - Select "Runner" target, go to "Signing & Capabilities".
     - Ensure the correct "Team" is selected.
     - Verify that "Release" configuration uses the correct Distribution Certificate and Provisioning Profile. "Automatically manage signing" should handle this if set up, otherwise select manually.
   - [ ] **App Icons & Launch Screen**: Visually verify they appear correct in Xcode and on a test build. (flutter_native_splash should have handled this if `flutter pub run flutter_native_splash:create` was run).
   - [ ] **Build Command (IPA):**
     ```bash
     flutter build ipa --release
     ```
     - Output typically found in `build/ios/archive/Runner.xcarchive` (the archive) and then exported as an IPA from Xcode Organizer or via command line (e.g., using Fastlane). The `flutter build ipa` command often guides through this.

**4. General Pre-Build Checks:**
   - [ ] **All Code Committed**: Ensure all latest changes are committed to version control.
   - [ ] **Dependencies Updated**: Run `flutter pub get` one last time (locally by developer).
   - [ ] **Code Generation**: Run `flutter pub run build_runner build --delete-conflicting-outputs` (locally by developer) for Hive adapters, etc.
   - [ ] **Native Splash**: Run `flutter pub run flutter_native_splash:create` (locally by developer) if splash assets changed.
   - [ ] **Clean Build (Recommended)**:
     ```bash
     flutter clean
     flutter pub get
     # (then build_runner and native_splash if applicable)
     ```
   - [ ] **Test on Physical Devices**: Perform final smoke tests of the release build on actual Android and iOS devices.

**5. Post-Build:**
   - [ ] Locate the generated build artifacts (`.aab` or `.apk` for Android, `.ipa` for iOS via Xcode archive/export).
   - [ ] Keep a record of the build number and associated commit hash for this release.

## Store Submission Checklist

Once final builds are generated and tested, follow this checklist for store submission.

**General (For both stores):**
- [ ] **Access Developer Consoles**: Ensure you have access to Google Play Console and Apple App Store Connect.
- [ ] **Final Review of Store Assets**: Double-check all screenshots, feature graphics, app icons, and promotional text/videos against store requirements and for quality.
- [ ] **Privacy Policy URL**: Confirm the Privacy Policy is live at a public URL and this URL is ready to be entered.
- [ ] **App Pricing & Availability**: Decide on pricing (free/paid) and target countries/regions for distribution.

**Google Play Console (Android):**
- [ ] **Create/Select App**: Create a new app listing or select the existing one.
- [ ] **Store Listing**:
    - [ ] Fill in/update App Title, Short Description, Full Description.
    - [ ] Upload App Icon (512x512).
    - [ ] Upload Feature Graphic (1024x500).
    - [ ] Upload Screenshots for phone, 7-inch tablet, 10-inch tablet.
    - [ ] Add Promo Video URL (optional).
    - [ ] Select Category and Application Type.
    - [ ] Provide Contact Details.
- [ ] **App Content**:
    - [ ] Complete Content Rating questionnaire.
    - [ ] Declare target audience and content.
    - [ ] Provide Privacy Policy URL.
    - [ ] Address any other sections like "Ads," "App access," "Data safety." (MindDrop: No ads, full app access, review data safety section carefully based on local storage).
- [ ] **Release**:
    - [ ] Go to "Production" or desired release track (e.g., "Internal testing," "Closed testing," "Open testing").
    - [ ] Create a new release.
    - [ ] Upload the Android App Bundle (`.aab`).
    - [ ] Enter Release Name (e.g., `1.0.0 (1)`).
    - [ ] Write "What's new in this version?" release notes.
    - [ ] Review and roll out the release (e.g., to 100% of users or staged rollout).

**Apple App Store Connect (iOS):**
- [ ] **Create/Select App**: Create a new app version or select the existing one.
- [ ] **App Information**:
    - [ ] Fill in/update App Name, Subtitle, Bundle ID.
    - [ ] Select Primary Language, Category.
- [ ] **Pricing and Availability**: Set price tier and availability.
- [ ] **App Privacy**:
    - [ ] Fill out the "App Privacy" questionnaire regarding data collection (MindDrop: should be minimal, "Data Not Collected" for most types if true to its local-first nature).
    - [ ] Provide Privacy Policy URL.
- [ ] **Version Information (for the new version being submitted)**:
    - [ ] Upload App Store Icon (1024x1024 via App Store Connect web interface or ensure it's in the binary).
    - [ ] Upload App Previews (optional).
    - [ ] Upload Screenshots for required device sizes (e.g., 6.7", 6.5", 5.5", iPad).
    - [ ] Enter Promotional Text (optional).
    - [ ] Enter Description.
    - [ ] Enter Keywords.
    - [ ] Enter Support URL, Marketing URL (optional).
    - [ ] Enter "What's New in this Version".
    - [ ] Set Copyright information.
- [ ] **Build**:
    - [ ] Upload the IPA build using Transporter app or Xcode Organizer.
    - [ ] Select the uploaded build for the version you are submitting.
- [ ] **Review Information**:
    - [ ] Provide App Review Contact Information.
    - [ ] Provide Demo Account credentials if the app has a login (Not applicable for MindDrop).
    - [ ] Add any notes for the reviewer.
- [ ] **Submit for Review**: Submit the version to Apple for review.
- [ ] **Post-Review**: Address any feedback or rejections from Apple.

**Post-Submission (Both Stores):**
- [ ] Monitor review status.
- [ ] Prepare for app to go live once approved.

## Post-Launch Monitoring & Initial Support

After the app is live, ongoing monitoring and user support are crucial.

**1. Monitoring (Focus on Store-Provided Tools):**
   Given MindDrop's principle of "no analytics or tracking" and "zero network requests" (by the app itself), third-party analytics/crash reporting SDKs (like Firebase Crashlytics/Analytics, Sentry, etc.) are **not** integrated. Monitoring will primarily rely on the tools provided by the app stores:

   *   **Google Play Console:**
        - **Crashes and ANRs (Application Not Responding):** Regularly check the "Crashes and ANRs" section. Analyze stack traces to identify and prioritize bugs.
        - **Ratings and Reviews:** Monitor user reviews for feedback, bug reports, and feature requests. Respond to reviews where appropriate.
        - **Statistics (Limited):** Play Console provides some aggregated, anonymized statistics on installs, uninstalls, etc., which do not rely on in-app SDKs.
   *   **Apple App Store Connect:**
        - **Analytics:** App Store Connect provides analytics on sales, usage (e.g., active devices, sessions - opt-in by users), and crashes.
        - **App Crashes:** Review crash reports available in "Xcode Organizer" (for symbolicated crashes from users who opted to share diagnostics) and in "App Store Connect > TestFlight (for beta build crashes) or App Analytics".
        - **Ratings and Reviews:** Monitor and respond to user reviews.

   *   **Key Actions:**
        - [ ] Set up regular checks (e.g., daily for the first week, then weekly) of Play Console and App Store Connect for new crash reports and reviews.
        - [ ] Prioritize fixing critical crashes reported.
        - [ ] Engage with user reviews constructively.

**2. Initial User Support:**
   - [ ] **Support Email**: Ensure the support email address provided in the store listings is actively monitored.
   - [ ] **FAQ (Frequently Asked Questions) - Proactive:**
     - Based on app functionality, anticipate common questions users might have.
     - Prepare a simple FAQ document or a section on a support webpage (if one exists).
     - Example questions for MindDrop:
       - "Where is my data stored?" (Answer: Locally on your device)
       - "How do I back up my ideas?" (Answer: Use the Export Data feature)
       - "Can I sync my ideas across devices?" (Answer: Currently, MindDrop is local-only. Export/Import can be used manually.)
   - [ ] **Update Strategy (Initial Thoughts):**
     - Plan for quick bug-fix releases if critical issues are found post-launch.
     - Gather user feedback for future feature enhancements. Schedule periodic updates.

**3. (Optional) Minimalistic In-App Feedback Channel:**
    - While avoiding full analytics, a very simple, user-initiated "Send Feedback" option (e.g., composing an email to the support address) could be considered for future versions if direct feedback channels are desired beyond store reviews. This would still be user-opt-in for sending data.
