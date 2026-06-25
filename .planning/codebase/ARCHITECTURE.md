# Architecture

**Analysis Date:** 2026-06-25

## Pattern Overview

**Overall:** Client-Server Architecture utilizing Backend-as-a-Service (Supabase) for authentication, data persistence, and secure file storage, alongside client-side logic execution and Gemini AI services.

**Key Characteristics:**
- **BAAS-Driven:** Bypasses custom backend servers; clients directly query Supabase database and storage layers using client SDKs.
- **Shared DB Schema:** A common database structure serves both the mobile client and the web client.
- **Client-Executed Business Logic:** Core functions (such as vital analysis and threshold warning triggers) are handled by client services (`CommonService` / `commonService.ts`).
- **Feature-First Structure:** Client projects are organized by domains/features (e.g. tracking, dashboard, auth) to keep related views and logic grouped together.

## Layers

### Entry / Routing Layer:
- **Purpose:** Directs the user to the correct screens based on authentication status and navigation actions.
- **Contains:** GoRouter configuration on mobile (`mobile_app/lib/main.dart`), React Router on web (`web_app/src/main.tsx` & `web_app/src/App.tsx`).
- **Depends on:** UI Pages / Presentation Layer.

### Presentation Layer (UI):
- **Purpose:** Renders the application views, receives user input, and manages page layout.
- **Contains:** Widget screens and page components (e.g. `DashboardScreen`, `SugarTrackerScreen`, `Patients.tsx`, `Alerts.tsx`).
- **Depends on:** State Management, Logic / Service Layer.

### State Management & Controllers:
- **Purpose:** Synchronizes state across screens, manages async data requests, and responds to DB stream changes.
- **Contains:** Riverpod providers on mobile (`auth_provider.dart`, `dashboard_provider.dart`), React Hooks and local states on web.
- **Depends on:** Service Layer.

### Logic / Service Layer:
- **Purpose:** Runs calculations, initiates database operations, schedules reminders, and calls external services.
- **Contains:** Client-side helpers (`CommonService`, `AIService`, `NotificationService`, `commonService.ts`).
- **Depends on:** Database/API Client SDKs.

### Data Storage & API Layer:
- **Purpose:** Communicates with database tables and cloud servers.
- **Contains:** Supabase client SDK instances and generic HTTP client configurations (`api_client.dart`).

## Data Flow

### Health Reading Flow (e.g. Saving Sugar Level):
1. **User Input:** User taps reading values on the keypad of the `SugarTrackerScreen` and clicks Save.
2. **Database Insert:** The screen sends an insert request to the `health_logs` table via the `supabaseProvider` client.
3. **Immediate Analysis:** The screen invokes `CommonService.analyzeHealthLog(logId, 'Sugar', value)` immediately after saving.
4. **Alert Triggering:** `CommonService` checks if the sugar value is critical (> 180 mg/dL or < 70 mg/dL). If yes:
   - Inserts a warning notification row into the `notifications` table.
   - Updates the corresponding `health_logs` record with the warning details in the `intervention_alert` column.
5. **Dashboard Refresh:** The screen calls `ref.invalidate(dashboardDataProvider)` to reload dashboard metrics.
6. **UI Transition:** If the sugar value is $\ge$ 200 mg/dL, the router redirects the patient to `SugarAiAlertScreen` for AI-generated care recommendations; otherwise, it closes the tracker sheet.

### State Management:
- **Mobile:** Riverpod notifier classes listen to streams or execute async states. `currentUserProvider` and `isDemoProvider` control authentication flow.
- **Web:** Active state is fetched dynamically using local component queries directly through the Supabase client.

## Key Abstractions

### Service:
- **Purpose:** Encapsulates business processes, AI integrations, or local operating system alerts.
- **Examples:** `NotificationService` (`mobile_app/lib/core/services/notification_service.dart`), `AIService` (`mobile_app/lib/core/services/ai_service.dart`), `CommonService` (`mobile_app/lib/core/services/common_service.dart`).
- **Pattern:** Singleton/Static classes or shared providers.

### Providers:
- **Purpose:** Exposes dependency instances and app states reactively.
- **Examples:** `supabaseProvider` (`auth_provider.dart`), `apiClientProvider` (`api_client.dart`), `dashboardDataProvider` (`dashboard_provider.dart`).
- **Pattern:** Riverpod global final declarations.

## Entry Points

### Mobile Application:
- **Location:** `mobile_app/lib/main.dart`
- **Triggers:** App launch.
- **Responsibilities:** Initializes notifications, configures global Supabase client, starts the Riverpod provider scope, and boots the Material Router.

### Web Application:
- **Location:** `web_app/src/main.tsx`
- **Triggers:** Web browser page load.
- **Responsibilities:** Renders the React DOM, wraps screens in routers, and configures the default layout.

## Error Handling

**Strategy:** Exceptions bubble up to UI controllers where they are caught inside `try/catch` wrappers. The UI informs the user via `ScaffoldMessenger` snackbars (mobile) or inline alert widgets (web). Services log execution details to debugging consoles (`debugPrint`).

## Cross-Cutting Concerns

**Authentication:**
- Users sign in using email/password. Protected routes monitor active token changes.

**Row Level Security (RLS):**
- Configured in the PostgreSQL database layer (`supabase_schema.sql`). Policies verify `auth.uid() = patient_id` or query `care_links` to confirm caregiver permission.

**Local Notifications:**
- `NotificationService` handles timezone-aware medication schedules using local system alarms.

---

*Architecture analysis: 2026-06-25*
*Update when major patterns change*
