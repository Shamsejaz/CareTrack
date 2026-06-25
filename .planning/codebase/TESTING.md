# Testing Patterns

**Analysis Date:** 2026-06-25

## Test Framework

**Runner:**
- Flutter Mobile: `flutter_test` (built-in Flutter SDK test framework).
- React Web: No automated testing library is currently configured.

**Assertion Library:**
- Dart/Flutter: standard `flutter_test` matchers (e.g. `expect(finder, matcher)`).
- Matchers: `findsOneWidget`, `findsNothing`, `findsNWidgets`, `equals`.

**Run Commands:**
```bash
# Run all mobile tests
cd mobile_app
flutter test

# Run a specific test file
flutter test test/widget_test.dart
```

## Test File Organization

**Location:**
- Mobile App: All tests reside under the `mobile_app/test/` directory.
- Web App: No test directory or configuration exists.

**Naming:**
- Mobile: `{scope}_test.dart` (e.g. `widget_test.dart`).

**Structure:**
```
mobile_app/
└── test/
    └── widget_test.dart       # Basic app widget test
```

## Test Structure

**Suite Organization (Mobile):**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:care_track/main.dart';

void main() {
  testWidgets('Welcome Screen test', (WidgetTester tester) async {
    // Build app and trigger rendering
    await tester.pumpWidget(const ProviderScope(child: CareTrackApp()));

    // Verify UI components existence
    expect(find.text('CareTrack'), findsOneWidget);
  });
}
```

## Mocking

- **State Providers:** `ProviderScope` is configured with overrides where necessary to mock remote API states or local providers.
- **Demo Mode:** `auth_provider.dart` uses `isDemoProvider` to return a static `User` mock when demo mode is active.

## Coverage

- **Mobile:** Test coverage can be checked via `flutter test --coverage` generating an LCOV format coverage report.
- **Enforcement:** No automated coverage gates are set up in version control.

---

*Testing analysis: 2026-06-25*
*Update when test patterns change*
