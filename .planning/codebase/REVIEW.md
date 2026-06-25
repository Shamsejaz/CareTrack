---
status: issues_found
files_reviewed: 5
critical: 1
warning: 2
info: 1
total: 4
files_reviewed_list:
  - mobile_app/lib/core/services/notification_service.dart
  - mobile_app/lib/features/tracking/medicine_tracker_screen.dart
  - mobile_app/lib/features/tracking/meal_tracker_screen.dart
  - mobile_app/android/app/build.gradle.kts
  - mobile_app/test/widget_test.dart
---

# Code Review: CareTrack Mobile Core & Tracking Files

## Overview
This review covers recent files modified to fix compile errors and make platform checks web-safe.

## Summary of Findings

### CR-01: Web-safety Crash in AIService.analyzeMeal
* **File:** `mobile_app/lib/core/services/ai_service.dart` (referenced by `mobile_app/lib/features/tracking/meal_tracker_screen.dart`)
* **Severity:** Critical
* **Description:** The `AIService.analyzeMeal` method takes a `String imagePath` and tries to load the image using `File(imagePath).readAsBytes()`. Because `dart:io`'s `File` is not supported on web runtimes, this will trigger an `Unsupported operation: File` runtime crash when users capture/select a photo on web browsers (Chrome/Edge).
* **Fix:** Change the method signature of `AIService.analyzeMeal` to accept `Uint8List imageBytes` directly, or pass an `XFile` object and load it cross-platform using `await photo.readAsBytes()`.

### WR-01: Missing Scheduled Notification Boot Receivers
* **File:** `mobile_app/android/app/src/main/AndroidManifest.xml`
* **Severity:** Warning
* **Description:** While `uses-permission` for notifications is declared, the receivers `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver` are missing inside the `<application>` tag of `AndroidManifest.xml`. Without these, scheduled notifications will not fire on Android, and all active notification schedules will be lost if the user restarts their phone.
* **Fix:** Add the required `<receiver>` tags and intent-filters for `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver` in `AndroidManifest.xml` as specified by the `flutter_local_notifications` plugin guidelines.

### WR-02: Hardcoded Database Credentials in Source Control
* **File:** `mobile_app/lib/main.dart`
* **Severity:** Warning
* **Description:** Active Supabase connection URL and Anon Publishable key are hardcoded in the `main` method bootstrap logic.
* **Fix:** Move keys to a configuration profile or inject them at build-time using `--dart-define` parameters.

### IF-01: Platform-Specific Camera Source Selection
* **File:** `mobile_app/lib/features/tracking/meal_tracker_screen.dart` and `mobile_app/lib/features/tracking/medicine_tracker_screen.dart`
* **Severity:** Info
* **Description:** ImagePicker chooses `ImageSource.gallery` when `Platform.isWindows` is true, and `ImageSource.camera` otherwise. On web targets, `ImageSource.camera` may request camera permissions which the user can block.
* **Fix:** For web browser runtimes, fall back to standard file selection dialog.
