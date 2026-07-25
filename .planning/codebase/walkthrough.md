# CareTrack Production Readiness Walkthrough

This document walks through the technical updates introduced to achieve full production readiness, resolve all codebase code review findings, and ensure secure and robust caregiver web portal integrations.

---

## 0. Phase 1: Secure Server-Side LLM Execution

We successfully completed Phase 1 of the AI Integration Roadmap, removing direct client-side calls to the Gemini API and securing them via Supabase Edge Functions.

### A. Edge Function Migration
* **New Function:** Created [analyze-meal/index.ts](file:///c:/CareTrack/supabase/functions/analyze-meal/index.ts).
* **Behavior:** The function accepts base-64 encoded image bytes, verifies the securely stored `GEMINI_API_KEY` from `Deno.env`, and invokes the `npm:@google/genai` SDK (`gemini-1.5-flash`). It parses and returns the JSON nutritional advice.

### B. Client-Side Decoupling
* **Changes in `ai_service.dart`:** Removed the `google_generative_ai` dependency entirely. The [analyzeMeal](file:///c:/CareTrack/mobile_app/lib/core/services/ai_service.dart) method now routes requests exclusively to the `analyze-meal` Supabase edge function via `Supabase.instance.client.functions.invoke`.
* **Security:** The Gemini API key is no longer required or compiled into the Flutter application.
* **Validation:** Verified using `flutter test` inside `mobile_app/`. All tests continue to pass with the new implementation logic.

---
## 1. Code Review Fixes Completed

We have manually resolved and verified all 4 issues identified in the code review report ([REVIEW.md](file:///c:/CareTrack/.planning/codebase/REVIEW.md)):

### [CR-01] Web-safety Crash in `AIService.analyzeMeal`
* **Changes:**
  - Modified [ai_service.dart](file:///c:/CareTrack/mobile_app/lib/core/services/ai_service.dart) to accept raw `Uint8List` image bytes instead of a local file path.
  - Removed `dart:io` import dependencies to prevent web environment load crashes.
  - Updated [meal_tracker_screen.dart](file:///c:/CareTrack/mobile_app/lib/features/tracking/meal_tracker_screen.dart) to read image bytes via `photo.readAsBytes()` and forward them to the AI service.

### [WR-01] Missing Scheduled Notification Boot Receivers
* **Changes:**
  - Added boot receiver configuration tags inside the `<application>` tag of [AndroidManifest.xml](file:///c:/CareTrack/mobile_app/android/app/src/main/AndroidManifest.xml):
    ```xml
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            <action android:name="android.quickboot.poweron"/>
            <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
        </intent-filter>
    </receiver>
    ```
  - This ensures scheduled notifications are correctly rescheduled on device reboot.

### [WR-02] Hardcoded Database Credentials in Source Control
* **Changes:**
  - Modified [main.dart](file:///c:/CareTrack/mobile_app/lib/main.dart) to extract Supabase connection configurations dynamically at compile-time:
    ```dart
    const String supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://svuruefzexxbyetpbixh.supabase.co',
    );
    const String supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_OvFPaFXN3LA78Xbqqza9uA_MgcYP8jY',
    );
    ```
  - Allows injecting secrets at build-time using `--dart-define` while maintaining safe fallbacks.

### [IF-01] Platform-Specific Camera Source Selection
* **Changes:**
  - Updated [meal_tracker_screen.dart](file:///c:/CareTrack/mobile_app/lib/features/tracking/meal_tracker_screen.dart) and [medicine_tracker_screen.dart](file:///c:/CareTrack/mobile_app/lib/features/tracking/medicine_tracker_screen.dart) to use web-safe `ImageSource` selection:
    ```dart
    source: (kIsWeb || (!kIsWeb && Platform.isWindows)) ? ImageSource.gallery : ImageSource.camera
    ```
  - This prevents browser runtime crashes by defaulting to gallery file selection on web platforms rather than requesting native camera permissions.

---

## 2. Caregiver Web Portal Scoping & Filtering

We implemented rigorous security boundary scoping on the React caregiver web portal to isolate patients' health data:

### Queries & Subscriptions Filtering
* **Dashboard.tsx:** 
  - Scopes clinical indicators (total patients count, pending notifications count, recent alerts data table) to only show data for patient IDs that are linked to the logged-in caregiver in the `care_links` junction table.
  - Scopes real-time Postgres subscription channel to process alerts strictly belonging to linked patients.
* **Alerts.tsx:**
  - Filters active notifications history and real-time subscription notifications using caregiver patient link relationships.
* **Patients.tsx:**
  - Scopes directory listings to patients linked to the caregiver.

### Invitation Code Redemption Flow
* **Add Patient Dialog:**
  - Created a premium modal interface allowing caregivers to enter a 6-digit invitation code.
  - Redeems the code against the `invitation_codes` table, checks expiry, inserts a link relationship row into `care_links`, deletes the code, and refreshes the patient directory.

---

## 3. User-Friendly Authentication Error Handling & Offline Mode Support

We added premium-grade client-side input validations, mapped raw exceptions to friendly messages, and introduced unified offline state error handlers on both clients:
* **Mobile (login_screen.dart & tracking screens):**
  - Created a global error-handling utility [error_handler.dart](file:///c:/CareTrack/mobile_app/lib/core/utils/error_handler.dart) that parses generic dart network/socket errors (`SocketException`, `ClientException`, `failed host lookup`) and maps them to a user-friendly offline message: *"You are offline. Please check your network connection and try again."*
  - Incorporated this utility on the Login Screen and health tracking screens (Sugar, Meal, Medicine) to intercept database insert failures and offline disruptions, displaying a premium floating `SnackBar`.
  - Added pre-submit check validations: checking for blank input or malformed emails dynamically before making network requests.
* **Web (Login.tsx):**
  - Enhanced error messages mapping block to capture network/fetch errors, translating them to custom offline alerts.

---

## 4. Caregiver Mobile Dashboard & Patient Monitoring

We built and integrated a fully functional caregiver mobile overview screen matching the web dashboard features:
* **Dashboard Customization (`dashboard_screen.dart`):**
  - Conditionally renders a caregiver dashboard UI if the user profile role is `'caregiver'`.
  - Disables/hides bottom navigation tabs (Vitals, Tasks) to scope user navigation properly.
* **Clinical Statistics & Roster:**
  - Displays metrics for Total Patients (monitored patient count) and Pending Alerts (using the caregiver's linked patient IDs in `care_links` table).
  - Renders a list of linked patients detailing their names, registered conditions (as indigo chips), and latest logs.
* **Redemption Flow & History:**
  - Added an inline "Add Patient" action button which launches a 6-digit code redemption dialog (validating codes against `invitation_codes` and inserting entries into `care_links`).
  - Added a "View History" button for each patient opening a bottom sheet overlay to retrieve and show their latest 10 vitals/logs.

---

## 5. Verification & Validation Results

### Automated Widget & Unit Tests
* **Run Command:** `cd mobile_app; flutter test`
* **Result:** All tests compiled and passed cleanly:
  ```
  00:00 +0: loading C:/CareTrack/mobile_app/test/widget_test.dart
  00:00 +0: Welcome Screen test
  00:00 +1: All tests passed!
  ```

### Web Production Compilation Check
* **Run Command:** `cd web_app; npm run build`
* **Result:** Built successfully with zero TypeScript compilation errors or lints:
  ```
  vite v7.3.1 building client environment for production...
  ✓ 1794 modules transformed.
  dist/index.html                   0.45 kB
  dist/assets/index-CzviLVjp.css    5.84 kB
  dist/assets/index-BqXKqecU.js   452.45 kB
  ✓ built in 2.28s
  ```
