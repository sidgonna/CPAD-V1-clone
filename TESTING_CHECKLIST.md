# MindDrop Testing Checklist

This document outlines manual testing procedures to ensure MindDrop's quality and stability across different devices and scenarios.

## I. Device Testing Matrix

Testing should be performed on a diverse range of devices where possible. Prioritize based on target audience and available hardware/emulators.

**Device Categories to Cover:**

*   **Android:**
    *   **Recent Flagship Android:** (e.g., Google Pixel latest, Samsung Galaxy S latest) - Tests latest OS features, performance benchmarks.
    *   **Mid-Range Android:** (e.g., Google Pixel 'a' series, Samsung A series, popular Xiaomi/OnePlus models) - Represents a common user device.
    *   **Older/Budget Android:** (e.g., A device running Android 2-3 major versions older, lower RAM/CPU) - Tests compatibility and performance on less powerful hardware.
    *   **Android Tablet (Optional, if tablet UI is a focus):** (e.g., Samsung Galaxy Tab, Lenovo Tab) - Tests layout responsiveness.
*   **iOS:**
    *   **Recent iPhone:** (e.g., Latest iPhone model) - Tests latest iOS features.
    *   **Older iPhone (still supported):** (e.g., iPhone 2-3 generations back) - Tests compatibility on older but supported hardware.
    *   **iPad (Optional, if tablet UI is a focus):** (e.g., iPad, iPad Air, iPad Pro) - Tests layout responsiveness.

**Emulators/Simulators:**
While physical devices are preferred for final testing, emulators (Android Studio) and simulators (Xcode) are crucial for:
*   Testing various screen sizes and resolutions.
*   Testing different OS versions easily.
*   Initial debugging and feature verification.

## II. Key Functionalities to Test (Per Device/Category)

For each device/category selected, perform the following tests:

**1. App Lifecycle & Basic Navigation:**
    *   [ ] **Installation**: Clean install from (simulated) store or build.
    *   [ ] **App Launch (Cold Start)**: Launch app after it's been closed completely. Check startup time (perceptual).
    *   [ ] **App Launch (Warm Start)**: Launch app after it's been backgrounded.
    *   [ ] **Backgrounding & Resuming**: Send app to background, then bring to foreground. Verify state is maintained.
    *   [ ] **Screen Rotation**: Test on key screens (Home, Detail, Add/Edit) in portrait and landscape. Verify UI adapts correctly.
    *   [ ] **Navigation**: Smoothly navigate between all screens (Home, Add/Edit Idea, Detail, Settings). Verify page transitions.

**2. Core Idea Management:**
    *   [ ] **Create Idea (Text Only - No Visual)**: Attempt to save (should be prevented by mandatory visual).
    *   [ ] **Create Idea (with Image from Camera)**:
        *   [ ] Permission request for Camera (if first time).
        *   [ ] Take photo, confirm.
        *   [ ] Image preview shown.
        *   [ ] Enter title & content, save. Verify on Home screen.
    *   [ ] **Create Idea (with Image from Gallery)**:
        *   [ ] Permission request for Photos (if first time).
        *   [ ] Select image from gallery.
        *   [ ] Image preview shown.
        *   [ ] Enter title & content, save. Verify on Home screen.
    *   [ ] **Create Idea (with Random Style)**:
        *   [ ] Generate random style.
        *   [ ] Style preview shown.
        *   [ ] Enter title & content, save. Verify on Home screen.
    *   [ ] **View Idea List (Home Screen)**:
        *   [ ] Scroll through a list of 10+ ideas. Check for smooth scrolling.
        *   [ ] Card animations on entry.
        *   [ ] Correct display of title, content preview, visual (image/style).
    *   [ ] **View Idea Detail**:
        *   [ ] Tap an idea card, navigate to detail screen.
        *   [ ] Correct display of full title, content, visual, dates.
    *   [ ] **Edit Idea**:
        *   [ ] Navigate from Detail screen to Edit screen.
        *   [ ] Verify data pre-population.
        *   [ ] Change title. Save. Verify update.
        *   [ ] Change content. Save. Verify update.
        *   [ ] Change visual from Image to Random Style. Save. Verify.
        *   [ ] Change visual from Random Style to Image. Save. Verify.
        *   [ ] Change from one image to another. Save. Verify.
    *   [ ] **Delete Idea**:
        *   [ ] From Detail screen, tap delete.
        *   [ ] Verify confirmation dialog.
        *   [ ] Confirm. Verify idea removed from Home screen and navigation back.
        *   [ ] (Conceptual) If possible, verify associated image/style cleanup (harder in manual test).

**3. Search & Filter:**
    *   [ ] **Search**:
        *   [ ] Activate search bar.
        *   [ ] Type query matching existing idea(s). Verify results and count.
        *   [ ] Type query not matching any idea. Verify "No results" message.
        *   [ ] Clear search query. Verify list returns to normal.
        *   [ ] Exit search mode.
    *   [ ] **Filter by Favorites**:
        *   [ ] Favorite an idea from Home or Detail screen.
        *   [ ] Toggle "Filter by Favorites" on. Verify only favorited idea(s) show.
        *   [ ] Verify "No favorite ideas found" message if applicable.
        *   [ ] Toggle filter off. Verify all ideas (or current search results) show.

**4. Settings Screen:**
    *   [ ] **Theme Change**:
        *   [ ] Select Light, Dark, System themes. Verify immediate UI update.
        *   [ ] Close and reopen app. Verify selected theme persists.
    *   [ ] **Export Data**:
        *   [ ] Export as JSON. Verify file save dialog appears and (if possible) inspect file.
        *   [ ] Export as Text. Verify file save dialog and file.
    *   [ ] **Clean Up Storage**:
        *   [ ] (Requires setup with orphaned images if possible) Trigger cleanup. Verify loading and success/error message.
    *   [ ] **About**: View About dialog.

**5. Sharing:**
    *   [ ] **Share Idea (Text Only)**: Share an idea that has no image. Verify sharing dialog and text content.
    *   [ ] **Share Idea (With Image)**: Share an idea with an image. Verify image and text are in share intent.

**6. Error States & Edge Cases:**
    *   [ ] Attempt to save idea with no title/content (validation messages).
    *   [ ] Image picking: Cancel image selection.
    *   [ ] Image picking: Select problematic image (if possible to simulate, though mock handles this).
    *   [ ] (If applicable) Test with no network connection (should work fine as it's local-first).
    *   [ ] Interruptions: e.g., receive a call during an operation (OS usually handles state).

## III. Performance Validation (Manual using DevTools)

This section outlines key performance metrics from the project's success criteria and how to conceptually validate them using Flutter DevTools on physical devices.

*   **Target Devices**: Perform these checks on a representative mid-range physical device if possible, in addition to emulators/simulators.

1.  **METRIC-001: App loads in <1 second (cold start)**
    *   **Test**: Close the app completely (remove from recent apps). Launch it fresh.
    *   **Observation**:
        *   Use a stopwatch for a rough estimate from tapping icon to `HomeScreen` being interactive.
        *   Use `flutter run --profile` and analyze DevTools Timeline for "Framework" and "Engine" startup phases. Note time for `HiveService.init()` and initial `HomeScreen` data load.
    *   **Goal**: Total time from launch to interactive < 1000ms.

2.  **METRIC-002: Add new idea in ≤2 taps (UX Flow)**
    *   **Test**: From `HomeScreen`, count taps to successfully save a new idea (e.g., Tap FAB -> (Enter Title) -> (Enter Content) -> (Select Visual) -> Tap Save). This metric is more about UI flow efficiency than raw speed of one operation.
    *   **Observation**: Manually count taps for the quickest path. Current flow:
        1. Tap FAB (to AddIdeaScreen)
        2. (Input data)
        3. Tap Save button.
        *This is already 2 main interaction taps for saving. The "input data" part involves more taps.*
        *The metric likely means "from the point of having data ready, it's quick to save" or "navigating to save screen and saving is minimal taps". The flow to get to AddIdeaScreen and tap save is 2 taps.*
    *   **Goal**: ≤2 primary action taps to initiate and confirm save.

3.  **METRIC-003: Search responds in <200ms**
    *   **Test**: With a moderate number of ideas (e.g., 50-100), type a search query in `HomeScreen`.
    *   **Observation**:
        *   Perceptual: Does the list update feel instant after typing stops (considering the 300ms debounce)?
        *   DevTools: Use CPU Profiler while searching. Measure time from end of debounce to results displayed / `SearchController.onSearchQueryChanged` completion.
    *   **Goal**: Search logic execution + UI update < 200ms after debounce period.

4.  **METRIC-005: Smooth animations at 60fps**
    *   **Test**:
        *   Scroll through `HomeScreen` idea list (especially with images).
        *   Trigger page transitions (navigating between screens).
        *   Observe `IdeaCard` entry animations.
    *   **Observation**:
        *   Enable "Performance Overlay" in DevTools. Look for red bars (jank) in UI and Raster threads.
        *   Aim for consistent green bars (target 60fps, or higher if device supports it).
    *   **Goal**: Animations should be visually smooth without noticeable stutters.

5.  **METRIC-006: Memory usage <100MB for 1000+ ideas**
    *   **Test Setup**: Requires populating the database with 1000+ ideas. This might need a utility script or significant manual data entry for testing. Some ideas should have images, some styles.
    *   **Test**:
        *   Launch the app with the large dataset.
        *   Navigate through the app: scroll lists, open details, perform searches.
    *   **Observation**:
        *   Use DevTools Memory tab. Monitor "Dart Heap" size and overall app "RSS" (Resident Set Size).
        *   Observe memory after various actions and after triggering Dart VM garbage collection.
    *   **Goal**: RSS ideally stays below or around 100MB during typical usage with this dataset. Dart Heap should be significantly less. (Note: "Memory usage" can be interpreted in different ways; RSS is a common one for overall footprint).

## IV. Feature Completeness Validation (Against Success Metrics)

This section maps specific feature success metrics from the project checklist to manual test/verification steps.

1.  **FEATURE-001: ✅ Mandatory visual element for all ideas**
    *   **Test**: On `AddIdeaScreen` or `EditIdeaScreen`, fill in title and content but do not select an image or generate a random style. Attempt to save.
    *   **Expected**: Save is prevented, and a message prompts to select a visual element.

2.  **FEATURE-002: ✅ Image upload and compression**
    *   **Test**: Create a new idea, choose "Image," select a moderately large image from gallery/camera. Save.
    *   **Verification**:
        *   Image is displayed correctly in `IdeaCard` and `IdeaDetailScreen`.
        *   (Conceptual/Dev Check) If possible to inspect the saved image file in the app's data directory, verify its file size is reasonably smaller than the original (if the original was uncompressed or very large). Visually check that image quality is acceptable after compression.

3.  **FEATURE-003: ✅ Random style generation**
    *   **Test**: Create a new idea, choose "Style." A random gradient and icon should appear in the preview. Save.
    *   **Verification**: The generated style is displayed correctly in `IdeaCard` and `IdeaDetailScreen`. Each generation produces a different style.

4.  **FEATURE-004: ✅ Real-time fuzzy search**
    *   **Test**: On `HomeScreen`, type a partial or slightly misspelled query related to existing idea titles or content.
    *   **Verification**: Relevant ideas appear in search results after a short debounce, sorted by likely relevance. Results update as typing continues.

5.  **FEATURE-005: ✅ Favorites system**
    *   **Test**: Mark an idea as favorite from `IdeaCard` or `IdeaDetailScreen`. Activate "Filter by Favorites."
    *   **Verification**: Only favorited ideas are shown. Toggle favorite off; idea disappears from filtered list. Clear filter; all ideas (or current search results) reappear. Favorite status persists after app restart.

6.  **FEATURE-006: ✅ Theme switching (system/light/dark)**
    *   **Test**: In `SettingsScreen`, switch between Light, Dark, and System themes.
    *   **Verification**: UI updates immediately to reflect the selected theme. Selected theme preference persists after app restart.

7.  **FEATURE-007: ✅ Data export (JSON/text)**
    *   **Test**: In `SettingsScreen`, use "Export Data" for both JSON and Text options.
    *   **Verification**: File save dialog appears. (Conceptual/Dev Check) Inspect the content of saved files to ensure correct formatting and data inclusion.

8.  **FEATURE-008: ✅ Share functionality**
    *   **Test**:
        *   Share an idea with only text.
        *   Share an idea with an image.
    *   **Verification**: Native OS share dialog appears. For text, content is correct. For image, both image and text are included in the share intent.

9.  **FEATURE-009: ✅ Offline functionality**
    *   **Test**: Disable all network connections (WiFi, mobile data). Use all app features (create, view, edit, delete, search, filter, settings - excluding external sharing if it requires network).
    *   **Verification**: All core app functionalities work correctly without network access, as expected for a local-first app.

10. **FEATURE-010: ✅ Zero network requests (by the app itself)**
    *   **Test (Conceptual/Dev Check)**: While using the app for various functions, use a network monitoring tool (e.g., Charles Proxy, OS network activity monitor).
    *   **Verification**: No unexpected outbound network requests are made by the MindDrop application itself. (Note: OS services or other apps might still use network).

This checklist provides a good starting point for manual testing.
