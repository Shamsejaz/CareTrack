# Technology Stack

**Analysis Date:** 2026-06-25

## Languages

**Primary:**
- Dart 3.x - Used for all mobile application code (`mobile_app/lib/`)
- TypeScript 5.9 - Used for all web application code (`web_app/src/`)
- SQL - Used for database schema definitions and migrations (`supabase/migrations/`, `supabase_schema.sql`, `create_admin_user.sql`)

**Secondary:**
- JavaScript - Configuration files and build scripts (e.g. `web_app/eslint.config.js`, `web_app/vite.config.ts`)
- HTML5 / CSS3 - Web application UI structure and vanilla CSS styling (`web_app/index.html`, `web_app/src/index.css`)

## Runtime

**Environment:**
- Flutter SDK (with Dart VM runtime for development and compiled native/web code for production)
- Node.js (Vite bundler, TypeScript compilation, and ESLint execution)
- Supabase CLI (database engine virtualization and edge environments)

**Package Manager:**
- pub (Dart Package Manager) - Managed via `mobile_app/pubspec.yaml` and `mobile_app/pubspec.lock`
- npm (Node Package Manager) - Managed via `web_app/package.json`, root `package.json`, and lock files

## Frameworks

**Core:**
- Flutter SDK - Main cross-platform UI framework for the mobile app
- React 19.2 - Core UI library for the web client application

**Routing:**
- go_router 17.1 - Declarative routing framework for the Flutter mobile application
- react-router-dom 7.14 - Routing library for the React web application

**State Management:**
- flutter_riverpod 3.3 - Reactive caching and state management library for Dart/Flutter

**Testing:**
- flutter_test (Flutter SDK) - Widget and unit testing framework for mobile

**Build/Dev:**
- Vite 7.3 - Bundling and development server for the web app
- TypeScript Compiler - Type safety compilation for web app code
- ESLint 9.39 - Linter for JavaScript and TypeScript code style

## Key Dependencies

**Critical:**
- `supabase_flutter` 2.12 - Supabase client SDK for Flutter (Auth, Database, Storage integration)
- `@supabase/supabase-js` 2.103 - Supabase client SDK for JavaScript/TypeScript
- `google_generative_ai` 0.4.6 - Google Gemini client SDK for Dart (AI Meal Analysis)
- `flutter_local_notifications` 21.0 - Scheduled alarms and medication reminders on mobile
- `timezone` 0.11 - Timestamps and local timezone conversions for scheduling
- `lucide-react` 1.8 - Modern icon library for React web application

**Infrastructure:**
- `http` 1.6 - HTTP client library for custom edge API calls on mobile

## Configuration

**Environment:**
- Web App: `.env` and `.env.example` configurations (Supabase URL, anon key)
- Mobile App: Dart environment definitions (e.g., `GEMINI_API_KEY`) and hardcoded credentials in `main.dart`

**Build:**
- `mobile_app/pubspec.yaml` - Flutter project configuration and assets
- `mobile_app/analysis_options.yaml` - Dart static analyzer lint rules
- `web_app/tsconfig.json` - TypeScript compiler parameters
- `web_app/vite.config.ts` - Vite build configurations
- `supabase/config.toml` - Supabase local development server config

## Platform Requirements

**Development:**
- Flutter SDK & Dart SDK installed locally
- Node.js (LTS version) & npm
- Supabase CLI for database simulation

**Production:**
- Android: Min SDK version 21 (configured in `mobile_app/pubspec.yaml` launcher icons options)
- iOS: Modern iOS devices (standard target)
- Web: Static hosting (Vercel, Netlify, etc.) for `web_app` output build

---

*Stack analysis: 2026-06-25*
*Update after major dependency changes*
