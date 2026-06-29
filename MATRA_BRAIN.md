# Matra / StackSense — Product Brain

This is the living product notes for Matra (in-app name) / StackSense (working title). Not a pitch deck. Not API docs. Just how the thing actually works, where the bodies are buried, and what we need to get right before we ship to real users.


---

## What it actually is

Matra is a daily supplement and medication tracker that tries not to feel like a medical app. The core loop is dead simple:

1. User adds supplements with a dose, schedule, and stock count.
2. Each day they open the app, see what's due, and tap a split-capsule icon to mark taken.
3. Stock decrements. When stock hits a threshold, the app nags about refilling.
4. Over time the app builds an adherence score and shows it back to the user.

That's it. Everything else — appointments, measurements, insights, dark mode, dot-matrix charts — exists to make that loop feel good and sticky.

### Why this exists

Most pill trackers are either:
- Ugly clinical tools that make you feel sick
- All-in-one health apps that drown you in features

Matra sits in the middle: health-conscious enough to track properly, but designed like a premium consumer app. The assumption is that people who take 5–15 supplements a day are already sold on the idea; they just need something that doesn't fight them.

---

## The current build

### Stack

**Frontend:** Flutter 3.6.1+, Dart, Riverpod for state, SharedPreferences for local storage. Custom `Artific` font. Golden-ratio spacing system. Light/dark theme.

**Backend:** Python FastAPI with Beanie/Motor on MongoDB. Right now it's a scaffold — models exist but the app isn't actually calling it yet.

### What actually works today

- Add supplement (name, dosage, schedule, stock)
- Daily view with Morning / Afternoon / Evening slots
- Split-capsule checkbox interaction
- Stock decrement on dose, increment on undo
- Dose logging + history
- Weekly adherence display
- Treatment page with quick actions
- Appointment and measurement screens (basic)
- Dark mode + font-size scaling
- Haptics on basically every interaction

### What's still placeholder

- Backend sync is not wired up
- Notifications exist in UI but actual scheduled push logic isn't implemented
- The "Insights" data is mostly demo/mock
- Pharmacy/refill flows are conceptual

---

## The core loop, in detail

### Supplement model

A supplement is:
- `id` (UUID)
- `name` (e.g., "Vitamin D3")
- `dosageText` (e.g., "2000 IU")
- `frequency` (how many per day / interval)
- `timeSlots` (Morning, Afternoon, Evening)
- `stockCount`
- `color` and `icon` for the UI

Schedules are currently represented as time slots, not exact times. This is fine for MVP but will need to become real clock times if we want smart reminders.

### Dose log model

A dose log is:
- `id`
- `supplementId`
- `date` (date only)
- `timestamp` (actual taken time)
- `taken` boolean

The provider stores these as a list and exposes helpers like `isTakenToday(supplementId)`.

### When a user taps the capsule

1. Haptic feedback (success if taking, light if undoing)
2. If marking taken and stock > 0: log dose, decrement stock
3. If marking taken and stock == 0: error haptic + snackbar
4. If undoing: remove log, increment stock

This is the single most important interaction in the app. It has to feel instant and satisfying.

### Adherence score

Currently simple: percentage of expected doses taken over a window. The Treatment page shows 86% as a demo. In production this should be calculated server-side from dose logs, not hardcoded.

Formula that makes sense:
```
adherence = (doses taken / doses expected) × 100
```
Expected doses come from the supplement schedule expanded across the date range.

---

## Screens and flows

### Today

This is the home screen. Day name big on the left, full date on the right. Week strip below. Supplements grouped by time slot.

Tap a day in the strip → selects that day. Re-tap the selected day → opens Day Detail screen with hero animation, full month calendar, and adherence breakdown.

### Treatment

No heading. Big adherence number. Dot-matrix scale. Quick actions (Add Med, Appointment, Measure). Medication list with stock badges.

"My Medications" has a See All that opens the full medication list.

### Insights

Vitamin D card + weekly adherence card. Tapping goes to Progress. Export button goes to Health Dashboard.

### Settings

Notifications, appearance (dark mode), about. Help & Support is currently static/non-interactive.

---

## The design system

### Type

Font: Artific. We use a golden-ratio-ish scale:
- Display: 48px (hero numbers)
- H1: 32px (screen titles)
- H2: 22px (card titles, settings heading)
- H3: 18px (subsections)
- Body: 16px
- Body small: 14px
- Caption: 12px
- Micro: 11px

Font size can scale Small/Normal/Large/Huge via SharedPreferences.

### Color

Light mode:
- Background: #FAFAFA
- Cards: white with #E8E8E8 borders
- Text primary: #1A1A2E
- Accent teal: #00BFA5

Dark mode:
- Background: #0D0D0F
- Cards: #1A1A1E with #2E2E32 borders
- Text primary: #F0F0F5
- Accent teal brightened: #00E5B8

### Spacing

Base unit 8px. Golden ratio scale: xs=4, sm=8, md≈13, lg≈21, xl≈34, xxl≈55.

### Components

`GoldenCard` is the workhorse — white/dark card with subtle border and shadow. Used almost everywhere.

`SplitCapsuleIcon` is the custom checkbox: horizontal pill outline that splits left/right and turns teal when checked.

---

## Backend: current state

FastAPI + MongoDB scaffold exists under `backend/app/`.

What's there:
- FastAPI app structure
- Beanie ODM models (likely User, Supplement, DoseLog, etc.)
- Pydantic schemas
- Basic router structure

What's missing:
- No actual sync from Flutter to API
- No auth flow implemented
- No push notification service integration
- No migrations or data versioning

The plan is to migrate from local SharedPreferences JSON blobs to a proper backend once the product loop is proven.

---

## What the backend needs to become

### The real data model

We should move to PostgreSQL. Mongo was fine for scaffolding, but relational data + reporting + compliance all push toward Postgres.

Core tables:

**users**
- id, email, phone, timezone, created_at, updated_at
- subscription_tier (free/premium/pro)
- onboarding_completed_at

**supplements**
- id, user_id, name, dosage, form, instructions
- schedule_type (interval / daily_times / specific_days / cyclic)
- schedule_json (flexible rules)
- stock_count, stock_unit, low_stock_threshold
- reminder_enabled, refill_reminder_enabled
- color, icon
- archived_at

**dose_logs**
- id, user_id, supplement_id
- scheduled_date, scheduled_time_slot
- taken_at, status (taken / skipped / missed)
- source (manual / reminder / wearable)

**schedules** (optional normalization)
- id, supplement_id, type, interval_hours, times[], days[], cyclic_intake_days, cyclic_pause_days

**stock_events**
- id, supplement_id, amount, event_type (dose / refill / adjustment)
- created_at

**appointments**
- id, user_id, title, doctor_name, specialty, location
- datetime, reminder_minutes_before, status

**measurements**
- id, user_id, metric_type (weight / blood_pressure / heart_rate / etc.)
- value, unit, measured_at, notes

**alerts**
- id, user_id, type (low_stock / refill / dose_reminder / appointment)
- reference_id, message, scheduled_for, sent_at, read_at

**subscriptions**
- id, user_id, plan, status, started_at, expires_at, payment_provider, provider_subscription_id

**organizations** (for B2B)
- id, name, type (employer / clinic / pharmacy)
- admin_user_id, settings

**organization_members**
- id, organization_id, user_id, role, joined_at

**analytics_events**
- id, user_id, event_name, event_json, device_info, created_at

### Indexes that matter

- dose_logs: `(user_id, scheduled_date)` — daily view queries
- dose_logs: `(supplement_id, scheduled_date)` — per-supplement adherence
- supplements: `(user_id, archived_at)` — active supplement list
- alerts: `(user_id, scheduled_for, sent_at)` — notification queue
- analytics_events: `(created_at)` for TTL/partitioning

### API shape (REST, JSON)

Auth:
- POST /auth/register
- POST /auth/login
- POST /auth/refresh
- POST /auth/logout

Supplements:
- GET /supplements
- POST /supplements
- GET /supplements/:id
- PATCH /supplements/:id
- DELETE /supplements/:id
- POST /supplements/:id/refill

Dose logs:
- GET /dose-logs?date=YYYY-MM-DD
- POST /dose-logs (mark taken)
- DELETE /dose-logs/:id (undo)

Insights:
- GET /insights/adherence?from=&to=
- GET /insights/streaks
- GET /insights/weekly

Appointments:
- CRUD /appointments

Measurements:
- CRUD /measurements

User:
- GET /me
- PATCH /me
- DELETE /me

### Business rules the backend should enforce

1. Stock never goes below 0.
2. A dose log for the same supplement + date + time slot can only exist once.
3. Undoing a dose must restore stock atomically.
4. Refill events add to stock and create a stock_event row.
5. Alerts fire based on rules, not UI state.
6. Adherence is computed from scheduled expectations, not just taken count.

---

## Commercial thinking

### Free tier
- Track up to 5 supplements
- Basic daily reminders
- 7-day adherence view
- One measurement type

### Premium ($4.99/mo or $39.99/yr)
- Unlimited supplements
- Advanced scheduling (cyclic, specific days, multiple times)
- Full history and trends
- Export / health reports
- Multiple measurement types
- Family sharing (up to 4 profiles)

### Pro / B2B
- Organizations: clinics, corporate wellness, pharmacies
- Aggregate dashboards (anonymized)
- Prescription refill integration
- SSO and admin controls

### Revenue beyond subscriptions
- **Pharmacy/refill affiliate links**: when stock runs low, suggest refill partners
- **Supplement retailer affiliate**: recommend products based on user stack
- **Health data partnerships**: opt-in anonymized datasets for research (very carefully, with consent)
- **White-label licensing**: sell the platform to telehealth companies

### Why B2B is interesting

Employers already spend money on wellness. Clinics need adherence data. Pharmacies want refill loyalty. Matra's real moat is not the consumer app; it's the clean data model and delightful UI that makes people actually log their doses. That's valuable to anyone who cares about adherence.

---

## Security and compliance notes

This is health-adjacent data. Even if we're not HIPAA-covered today, we should build like we might be.

- Encrypt data at rest (Postgres TDE or cloud equivalent)
- Encrypt sensitive fields (email, phone) at application level where reasonable
- JWT access tokens + refresh tokens
- Row-level security per user (and per organization in B2B)
- Audit log for dose changes and access
- Allow full data export and account deletion
- GDPR deletion + consent tracking
- Push notification tokens stored securely, not in plaintext logs

---

## Migration from local to backend

We can't just flip a switch. Current users have JSON blobs in SharedPreferences. Plan:

1. **Add sync layer**: on login, upload local JSON to backend. Backend validates and merges.
2. **Conflict resolution**: server wins for logged-in users, but keep local copy as fallback.
3. **Offline support**: keep working locally; sync when online.
4. **Gradual**: new installs use backend-first. Existing installs migrate on update.
5. **Once majority are migrated**, deprecate local-only mode.

The local-first architecture is actually an advantage here. The app doesn't break without internet.

---

## Open questions / risks

1. **Notifications**: Flutter local notifications work, but iOS background execution is finicky. We may need a backend scheduler for reliable reminders.

2. **Scheduling complexity**: "Every X hours" and cyclic schedules are hard to render and remind correctly. Keep it simple until users demand it.

3. **Data accuracy**: Users can lie or forget. Adherence is only as good as the logging habit. Gamification might help.

4. **Competition**: Apple Health, Google Health Connect, MyTherapy, Medisafe. Differentiation is UX and design, not feature count.

5. **Monetization timing**: Don't paywall the core loop too early or growth dies. Premium should be genuinely better, not artificially restricted.

---

## What to build next

In rough priority order:

1. Wire up backend auth and supplement sync.
2. Implement reliable dose reminders (local + backend fallback).
3. Compute real adherence server-side.
4. Add refill flow with affiliate link option.
5. Build measurement charting and trends.
6. Add export / health report PDF.
7. Prepare B2B organization structure.

---

## Random product notes

- The dot-matrix visual language is our thing. Use it everywhere: adherence, stock, trends, calendar. It's distinctive.
- Haptics are not optional. They're half the satisfaction of the app.
- Dark mode needs to keep looking premium, not just inverted.
- The Day Detail screen hero animation is the right direction — make the calendar feel alive.
- We should A/B test the week strip vs a full mini-calendar on Today.

---

