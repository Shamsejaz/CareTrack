# Coding Conventions

**Analysis Date:** 2026-06-25

## Naming Patterns

**Files:**
- Mobile App: `snake_case.dart` for all files (e.g. `welcome_screen.dart`).
- Web App: `PascalCase.tsx` for pages and component files (e.g. `Patients.tsx`, `Layout.tsx`). `camelCase.ts` for logic scripts (e.g. `commonService.ts`).
- Database: `snake_case.sql` (e.g. `20260423000000_initial_schema.sql`).

**Classes & Types:**
- Dart/TS Classes: `PascalCase` (e.g. `SugarTrackerScreen`, `CommonService`).
- TypeScript Interfaces: `PascalCase` without `I` prefixes (e.g. `PatientRecord`).

**Functions & Variables:**
- Functions/Methods: `camelCase` (e.g. `signIn`, `analyzeHealthLog`, `processPrescription`).
- Variables: `camelCase` (e.g. `sugarValue`, `detectedMeds`).
- Private Variables (Dart): `_` prefix (e.g. `_sugarValueStr`, `_isSaving`).
- Constants: `UPPER_SNAKE_CASE` or `camelCase` depending on framework.

## Code Style

**Formatting:**
- Flutter Mobile: standard Dart formatter via `dart format` (using 2-space indentation, trailing commas).
- React Web: standard Prettier styling, 2-space indentation.

**Linting:**
- Mobile: Configured in `analysis_options.yaml` extending `flutter_lints`.
- Web: ESLint configuration inside `eslint.config.js` running `typescript-eslint`.

## Import Organization

**Dart / Flutter:**
1. Flutter core packages (e.g. `import 'package:flutter/material.dart';`).
2. Flutter plugins and third-party packages (e.g. `import 'package:flutter_riverpod/flutter_riverpod.dart';`).
3. App package references (e.g. `import 'package:care_track/...';`).
4. Relative imports (e.g. `import 'theme/app_theme.dart';`).

**React / TypeScript:**
1. External npm packages (e.g. `import React, { useState } from 'react';`).
2. Internal absolute path aliases (if configured) or relative package references (e.g. `import { CommonService } from '../lib/commonService';`).
3. Stylesheets and asset references.

## Error Handling

**Strategy:** Exception catching occurs primarily at the UI controller level to show appropriate visual notifications to the user without crashing.

**Patterns:**
- Mobile: Wrap asynchronous operations (e.g. Supabase insertions) inside `try/catch` blocks. On success, pop routes or clear state. On exception, print logs to console and display a `SnackBar`:
```dart
try {
  // DB Operation
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```
- Web: Try/catch blocks handle API interactions. Result notifications use UI labels.

## Logging

**Strategy:** Console debugging outputs are written using `debugPrint` or simple print methods in local test sessions. Production builds block verbose logging outputs.

---

*Convention analysis: 2026-06-25*
*Update when patterns change*
