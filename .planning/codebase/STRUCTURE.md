# Codebase Structure

**Analysis Date:** 2026-06-25

## Directory Layout

```
CareTrack/
├── create_admin_user.sql          # DB script to setup first admin account
├── package.json                   # Root package containing Supabase dev CLI
├── pull_log.txt                   # Local build environment synchronization history
├── supabase_schema.sql            # Master database tables & RLS policies definitions
├── mobile_app/                    # Flutter cross-platform mobile application
│   ├── android/                   # Android-specific build and manifest scripts
│   ├── assets/                    # Shared image assets and launcher icons
│   ├── ios/                       # iOS-specific build configs
│   ├── lib/                       # Mobile application source code
│   │   ├── core/                  # Core modules (API, providers, services, widgets)
│   │   ├── features/              # Feature-driven screen and UI directories
│   │   └── theme/                 # Global colors and theme styles definitions
│   └── test/                      # Unit and widget test files
├── supabase/                      # Local database virtualization resources
│   ├── config.toml                # Supabase project settings
│   └── migrations/                # Database migrations list
└── web_app/                       # React TypeScript web application
    ├── public/                    # Static assets
    └── src/                       # Web application source code
        ├── components/            # Layouts and reusable widgets
        ├── lib/                   # Supabase clients and shared business logic
        └── pages/                 # Routing pages (Dashboard, Alerts, Patients)
```

## Directory Purposes

**mobile_app/lib/core/**
- Purpose: Shared utility and infrastructure modules.
- Contains: API client (`api/api_client.dart`), authentication provider (`providers/auth_provider.dart`), system utilities (`services/notification_service.dart`, `services/ai_service.dart`, `services/common_service.dart`), and shared layout controls (`widgets/custom_bottom_nav.dart`).

**mobile_app/lib/features/**
- Purpose: Feature-driven screens, keeping modules cohesive.
- Subdirectories:
  - `auth/`: User log-in views (`login_screen.dart`).
  - `chat/`: Communication screens for care team messaging (`chat_screen.dart`).
  - `dashboard/`: Application health dashboards and task pages (`dashboard_screen.dart`, `vitals_dashboard_screen.dart`, `tasks_screen.dart`).
  - `onboarding/`: Welcome flows, settings setup, and prescription uploads (`welcome_screen.dart`, `role_selection_screen.dart`, `conditions_setup_screen.dart`, `prescription_upload_screen.dart`).
  - `profile/`: Account settings, subscription page, and team configuration views.
  - `tracking/`: Screen forms for vitals tracking (`sugar_tracker_screen.dart`, `meal_tracker_screen.dart`, `medicine_tracker_screen.dart`).

**supabase/migrations/**
- Purpose: Sequenced SQL migration scripts.
- Contains: Database tables creation, constraints, index settings, and RLS policies (`20260423000000_initial_schema.sql`).

**web_app/src/pages/**
- Purpose: Views for the web application interface.
- Contains: Patient rosters, dashboards, alerts, and registration portals (`Dashboard.tsx`, `Alerts.tsx`, `Patients.tsx`, `Login.tsx`, `Signup.tsx`).

## Key File Locations

**Entry Points:**
- `mobile_app/lib/main.dart` - Entry point and router configuration for the mobile client.
- `web_app/src/main.tsx` - Initial runtime rendering bootstrap for the web client.

**Configuration:**
- `web_app/package.json` - Web client dependency manifest.
- `mobile_app/pubspec.yaml` - Flutter packages, assets, and metadata configurations.
- `web_app/vite.config.ts` - Vite asset bundler configuration.
- `web_app/.env` - Environment credentials for local web API communication.
- `supabase/config.toml` - Supabase dockerized service mappings.

**Core Logic:**
- `mobile_app/lib/core/services/common_service.dart` - Shared logic (alert processing, notifications logging) on mobile.
- `web_app/src/lib/commonService.ts` - Equivalent business logic library on the web client.

## Naming Conventions

**Files:**
- Mobile App: `snake_case.dart` for all filenames (e.g. `walk_tracker_screen.dart`).
- Web App: `PascalCase.tsx` for views and UI components (e.g. `ChatOverlay.tsx`). `camelCase.ts` for logic utilities (e.g. `commonService.ts`).
- Migrations: `timestamp_description.sql` (e.g. `20260423000000_initial_schema.sql`).

**Directories:**
- Mobile features: `snake_case` directories matching their scope (e.g. `features/tracking`).
- Web App: `camelCase` for directories (e.g. `src/components`, `src/lib`).

## Where to Add New Code

**New Tracker (Mobile):**
- Screen: Add under `mobile_app/lib/features/tracking/` (e.g. `weight_tracker_screen.dart`).
- Service logic: Add logic rules to `CommonService.analyzeHealthLog`.
- Route: Register under `routerProvider` in `mobile_app/lib/main.dart`.

**New Web Page:**
- Screen: Create component under `web_app/src/pages/` (e.g. `Analytics.tsx`).
- Route: Map paths inside `web_app/src/App.tsx` and standard navigation panels.

**Database Schema Update:**
- Script: Write a new sequential `.sql` migration file inside `supabase/migrations/`.

---

*Structure analysis: 2026-06-25*
*Update when directory structure changes*
