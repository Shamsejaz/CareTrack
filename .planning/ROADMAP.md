# Roadmap

## Phase 8: Anti-Mock Architecture Enforcement (Completed)
**Goal:** Remove all client-side mocks and static dummy data (when not in Demo mode).
- [x] Remove `Future.delayed` from `meal_tracker_screen.dart` and `prescription_upload_screen.dart` and connect to Edge Functions.
- [x] Wire `dashboard_provider.dart` and `vitals_dashboard_screen.dart` to a real `health_logs` query.
- [x] Connect `voice_overlay.dart` to the real speech-to-text pipeline instead of the 3-second timer mock.

## Phase 9: Caregiver Support (Completed)
**Goal:** Build functional remote monitoring and multi-user access.
- [x] Caregiver linking via invite codes in the app.
- [x] RLS policies to allow caregivers to view linked patient dashboards.

## Phase 10: IoT Device Integration (Completed)
**Goal:** Sync real data from Apple Health and Google Fit.
- [x] Integrate `health` package for cross-platform pedometer/vitals syncing.
- [x] Wire up `WalkTrackerScreen` to pull native health data.
- [ ] Create a "Connected Devices" toggle screen in the profile.

## Phase 11: Home Robotics Integration (Completed)
**Goal:** Dispatch physical assistive tasks to home robots.
- [x] Build `robotics-dispatch` webhook Edge Function via Gemini for intent classification.
- [x] Add Robotics UI panel to dashboard for one-tap commands (e.g., "Bring water").
- [ ] Add Robotics UI panel in the CareTrack app for dispatching tasks.
- [ ] Add robotics status tracking to the Caregiver web dashboard.
