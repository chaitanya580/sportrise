# SportRise Flutter App

India's First Student Athlete Discovery Platform

## File Structure

```
lib/
├── main.dart                          ← Entry point + routing
├── theme/
│   └── sr_theme.dart                  ← Brand colors, typography, component styles
├── services/
│   └── sr_service.dart                ← All Supabase database operations + XP Engine
├── widgets/
│   └── shared_widgets.dart            ← Reusable components (buttons, cards, XP bar)
└── screens/
    ├── welcome_screen.dart            ← Screen 1: Role selection
    ├── student_registration_screen.dart ← Screen 2: 3-step registration
    ├── student_dashboard_screen.dart  ← Screen 3: Dashboard with XP + quick actions
    ├── coach_discovery_screen.dart    ← Screen 4: Coach search with filters
    ├── tournament_screen.dart         ← Screen 5: Tournament list + registration
    ├── xp_level_screen.dart           ← Screen 6: XP history + level ladder
    ├── scout_dashboard_screen.dart    ← Screen 7: Scout athlete search
    └── profile_screen.dart            ← Screen 8: My profile
```

## Setup Instructions

### Step 1 — Prerequisites
- Flutter SDK installed: https://flutter.dev/docs/get-started/install
- Android Studio installed (for Android emulator)
- VS Code with Flutter extension (recommended)

### Step 2 — Install dependencies
```bash
cd sportrise_flutter
flutter pub get
```

### Step 3 — Run on emulator or device
```bash
flutter run
```

### Step 4 — Your Supabase credentials
Already wired in `lib/services/sr_service.dart`:
```
URL:     https://zmgmcnkfiwxtpweopckh.supabase.co
Key:     eyJhbGci... (your anon key)
```

### Step 5 — Run the database SQL
Go to Supabase → SQL Editor and run the full CREATE TABLE script
(provided in the FlutterFlow setup guide).

## How the XP Engine Works

Every XP-awarding action calls `SRService.awardXP()`:
1. Inserts an immutable record in `xp_transactions`
2. Reads the student's current XP
3. Calculates new level using `LevelSystem.fromXP()`
4. Checks if National Prospect badge should be awarded
5. Updates `student_profiles` with new XP, level, and NP status

## To Use in FlutterFlow

### Option A — Custom Actions
Copy each function from `sr_service.dart` into FlutterFlow's Custom Code → Custom Actions.
The Dart code is written to be compatible with FlutterFlow's Supabase integration.

### Option B — Direct Copy
Copy the entire `lib/` folder into your Flutter project created by FlutterFlow (File → Download Code).

## Screen Navigation Map

```
/                    → WelcomeScreen
/register/student    → StudentRegistrationScreen
/otp                 → OTP verification (placeholder — wire real SMS)
/dashboard           → StudentDashboardScreen (requires userId)
/coaches             → CoachDiscoveryScreen
/tournaments         → TournamentScreen (requires userId)
/xp                  → XPLevelScreen (requires userId)
/scout/dashboard     → ScoutDashboardScreen
/profile             → ProfileScreen (requires userId)
```

## Brand Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Deep Space Blue | #0D1B2A | All backgrounds |
| Electric Orange | #FF6B2B | Primary CTA, buttons, accents |
| Champion Gold   | #FFB830 | XP, levels, National Prospect |
| Success Green   | #1E8449 | Verified badges, success states |

## What's Not Implemented (Next Steps)

- Real OTP via MSG91 — replace `_OTPPlaceholder` with `pinput` widget + SMS API
- Coach profile detail screen — full profile, calendar booking
- Athlete detail screen for scouts — full performance history
- Admin verification flow — approve/reject coaches
- Push notifications via OneSignal

## Parental Consent (under-18 athletes)

Student registration now inserts a "Parental Consent" step between personal
details and sport selection whenever the entered age is under 18. It collects
guardian name + mobile and requires an explicit consent checkbox before
continuing. Before deploying this, run `supabase/migrations/0001_parental_consent.sql`
in Supabase → SQL Editor — it adds the `is_minor`, `guardian_name`,
`guardian_mobile`, `parental_consent`, and `consent_given_at` columns to
`users`, plus a check constraint that blocks any minor row from being saved
without `parental_consent = true`.
