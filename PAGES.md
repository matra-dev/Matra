# StackSense — App Pages & Features Tracking

> **Last Updated:** 2026-07-15  
> **Flutter Version:** 3.27.2  
> **Backend:** FastAPI + MongoDB (Beanie ODM)  
> **Architecture:** Offline-First (API优先，本地降级)

---

## 📱 FLUTTER SCREENS (18 Total)

### 1. LandingScreen
| | |
|---|---|
| **File** | `lib/screens/landing_screen.dart` |
| **Purpose** | App entry point — animated logo, brand intro, auth check |
| **Data** | Hardcoded animations |
| **Features** | • Rotating rings animation (20s loop)  
• Pulse breathing effect  
• Staggered text entrance (2500ms)  
• Auto-checks auth on load → routes to MainNavigation or AuthScreen |
| **Offline** | ✅ Works without backend |
| **Backend API** | `GET /auth/me` (token validation) |

---

### 2. AuthScreen
| | |
|---|---|
| **File** | `lib/screens/auth_screen.dart` |
| **Purpose** | User login & registration |
| **Data** | User input only |
| **Features** | • Toggle between Login / Register  
• Email + password validation  
• Optional name field (register)  
• Loading spinner on submit  
• Error message with shake animation  
• Staggered entrance animations  
• Auto-navigates to MainNavigation on success |
| **Offline** | ❌ Requires backend for auth |
| **Backend API** | `POST /auth/register`  
`POST /auth/login` |

---

### 3. MainNavigationScreen
| | |
|---|---|
| **File** | `lib/screens/main_navigation_screen.dart` |
| **Purpose** | Bottom navigation host for 4 tabs |
| **Data** | Hardcoded nav config |
| **Features** | • 4 tabs: Today, Insights, Treatment, Settings  
• AnimatedSwitcher with fade transition (250ms)  
• Custom bottom nav bar with haptic feedback  
• KeyedSubtree for proper state preservation |
| **Offline** | ✅ Works without backend |
| **Backend API** | None |

---

### 4. TodayScreen
| | |
|---|---|
| **File** | `lib/screens/today_screen.dart` |
| **Purpose** | Daily supplement dose tracker |
| **Data** | Supplements + DoseLogs (Riverpod + LocalStorage + API fallback) |
| **Features** | • 7-day horizontal strip (selectable)  
• Time-slot grouping: Morning / Afternoon / Evening  
• Toggle dose taken (animated checkbox)  
• Stock check — blocks if out of stock  
• Haptic feedback (light/success/error)  
• Empty state when no supplements  
• Navigates to DayDetailScreen on day tap |
| **Offline** | ✅ Full offline support (LocalStorage fallback) |
| **Backend API** | `GET /supplements`  
`GET /dose-logs/today/{date}`  
`POST /dose-logs` (toggle on)  
`DELETE /dose-logs/{supp_id}/{date}` (toggle off) |

---

### 5. InsightsScreen
| | |
|---|---|
| **File** | `lib/screens/insights_screen.dart` |
| **Purpose** | Analytics dashboard with 3 tabs |
| **Data** | Hardcoded demo data (needs API integration) |
| **Features** | **Tab 1 — Overview:**  
• Swipeable supplement carousel (PageController, viewportFraction 0.88)  
• Staggered text animations on swipe (ValueKey forces rebuild)  
• Supplement name, dosage, value, status pill, week strip  
• "View All" + Share buttons → HealthDashboardScreen  
**Tab 2 — Trends:**  
• Gradient area chart (16-day adherence trend)  
• Weekly dot matrix (Mon-Sun, 5 dots each, adherence %)  
• 30-day streak grid (5×6 layout, 32px cells)  
• Summary stats: Perfect days / Missed doses / Adherence  
**Tab 3 — History:**  
• Collapsible calendar (month view)  
• Per-day dose log list with icons  
• Expandable time slots |
| **Offline** | ⚠️ Currently hardcoded (needs API wiring) |
| **Backend API** | `GET /insights/dashboard`  
`GET /insights/trends`  
`GET /insights/supplement/{id}` |

---

### 6. TreatmentScreen
| | |
|---|---|
| **File** | `lib/screens/treatment_screen.dart` |
| **Purpose** | Medication management hub |
| **Data** | Hardcoded (3 medications) |
| **Features** | • Card list with icon backgrounds  
• Stock progress bars  
• Adherence circular rings  
• "Add Medication" button → AddMedicationScreen  
• Entrance animations (1800ms)  
• Dot matrix animation (1600ms) |
| **Offline** | ✅ Works without backend |
| **Backend API** | None (currently hardcoded) |

---

### 7. SettingsScreen
| | |
|---|---|
| **File** | `lib/screens/settings_screen.dart` |
| **Purpose** | App preferences & configuration |
| **Data** | LocalStorage (SharedPreferences) |
| **Features** | **Notifications:**  
• Daily Reminders toggle  
• Reminder Time picker (TimePicker)  
• Low Stock Alerts toggle  
**Appearance:**  
• Dark Mode toggle (system-wide)  
• Font Size picker (Small/Normal/Large/Huge)  
**Account:**  
• Admin Panel button → AdminScreen  
• Sign Out button (clears JWT, returns to AuthScreen)  
**About:**  
• Version, Build info  
• Privacy Policy (coming soon)  
• Help & Support |
| **Offline** | ✅ Full offline support |
| **Backend API** | `POST /auth/logout` (local only) |

---

### 8. AddMedicationScreen
| | |
|---|---|
| **File** | `lib/screens/add_medication_screen.dart` |
| **Purpose** | Multi-step medication onboarding |
| **Data** | Hardcoded medication list + user input |
| **Features** | **Step 1 — Search:**  
• Searchable medication list (9 pre-defined)  
• Real-time filter  
**Step 2 — Schedule:**  
• Time slot chips (Morning/Afternoon/Evening)  
• Custom time picker  
**Step 3 — Details:**  
• Stock count slider  
• Threshold setting  
• Refill reminder toggle  
• Dose amount + unit picker (capsules/tablets/etc)  
• Critical alerts toggle  
• Single "Next" button at bottom |
| **Offline** | ✅ Works without backend |
| **Backend API** | None (currently local only) |

---

### 9. MedicationListScreen
| | |
|---|---|
| **File** | `lib/screens/medication_list_screen.dart` |
| **Purpose** | Full medication inventory |
| **Data** | Hardcoded (6 medications) |
| **Features** | • Card-based list items  
• Icon with background circle (teal tint if taken)  
• Stock progress bar (4px height)  
• Adherence circular indicator  
• "Taken today" / "Not taken yet" status pill  
• Detail bottom sheet with:  
  - Entrance animations  
  - Stat cards  
  - Action buttons (Edit, Mark Taken)  
• Add (+) button in header |
| **Offline** | ✅ Works without backend |
| **Backend API** | None (currently hardcoded) |

---

### 10. SupplementFormScreen
| | |
|---|---|
| **File** | `lib/screens/supplement_form_screen.dart` |
| **Purpose** | CRUD form for supplements |
| **Data** | Riverpod + LocalStorage + API fallback |
| **Features** | • Form validation  
• Name input  
• Dosage amount + unit (mg/mcg/IU/g/ml)  
• Frequency selector  
• Stock count input  
• Time slot chips (multi-select)  
• Create / Edit modes  
• Submit with loading state  
• Animate entrance (600ms) |
| **Offline** | ✅ Full offline support |
| **Backend API** | `POST /supplements` (create)  
`PUT /supplements/{id}` (update) |

---

### 11. MySupplementsScreen
| | |
|---|---|
| **File** | `lib/screens/my_supplements_screen.dart` |
| **Purpose** | Supplement inventory with filters |
| **Data** | Riverpod + LocalStorage + API fallback |
| **Features** | • Filter tabs: All / Active / Low Stock  
• Search bar (real-time filter)  
• List with swipe actions  
• Navigates to SupplementDetailScreen  
• Navigates to SupplementFormScreen (edit)  
• Entrance animations (900ms) |
| **Offline** | ✅ Full offline support |
| **Backend API** | `GET /supplements`  
`DELETE /supplements/{id}` |

---

### 12. SupplementDetailScreen
| | |
|---|---|
| **File** | `lib/screens/supplement_detail_screen.dart` |
| **Purpose** | Single supplement analytics |
| **Data** | Riverpod + LocalStorage + API fallback |
| **Features** | • Weekly adherence chart (fl_chart)  
• Total doses taken count  
• 7-day history dots  
• Edit / Delete actions  
• Chart animation (1800ms)  
• Page entrance animation (800ms) |
| **Offline** | ✅ Full offline support |
| **Backend API** | `GET /dose-logs/supplement/{id}`  
`GET /insights/supplement/{id}` |

---

### 13. DayDetailScreen
| | |
|---|---|
| **File** | `lib/screens/day_detail_screen.dart` |
| **Purpose** | Calendar day drill-down |
| **Data** | Hardcoded demo data |
| **Features** | • Expandable time slots (Morning/Afternoon/Evening)  
• Pill breakdown per slot (name, dosage, time, taken status)  
• Mini month calendar  
• Dot matrix for adherence visualization  
• 3 animation controllers (entrance, dots, calendar) |
| **Offline** | ✅ Works without backend |
| **Backend API** | None (currently hardcoded) |

---

### 14. HealthDashboardScreen
| | |
|---|---|
| **File** | `lib/screens/health_dashboard_screen.dart` |
| **Purpose** | Full analytics dashboard (from ProgressScreen) |
| **Data** | Hardcoded demo data |
| **Features** | • **Hero morph animation** — card shrinks from full-width to 56%  
• Count-up animation (+94%)  
• Sparkline chart (custom painter)  
• **9 tappable cards** opening bottom sheets:  
  1. Adherence (dot matrix + mini bars)  
  2. Calendar (31-day grid)  
  3. Streak (3 stats + dot matrix)  
  4. Supplements (7 rows with status pills)  
  5. Week (7 daily bars + checkmarks)  
  6. Consistency (7 monthly trend bars)  
  7. Schedule (3 time slots with lists)  
  8. Stock (7 items with progress bars + warnings)  
• Staggered animations throughout  
• Haptic feedback on all interactions |
| **Offline** | ✅ Works without backend |
| **Backend API** | `GET /insights/dashboard` (✅ wired — uses real data when API available)  
`GET /insights/trends` (✅ wired)  
`GET /insights/supplement/{id}` |

---

### 15. ProgressScreen
| | |
|---|---|
| **File** | `lib/screens/progress_screen.dart` |
| **Purpose** | Health metrics overview |
| **Data** | Hardcoded demo data |
| **Features** | • Toggle: Charts view / Cards view  
• Stat cards with mini sparklines  
• "View Full Dashboard" button → HealthDashboardScreen  
• Entrance animations (1800ms)  
• Chart animations (2200ms) |
| **Offline** | ✅ Works without backend |
| **Backend API** | None |

---

### 16. MeasurementListScreen
| | |
|---|---|
| **File** | `lib/screens/measurement_list_screen.dart` |
| **Purpose** | Health measurements tracker |
| **Data** | Hardcoded (10 measurement types) |
| **Features** | • 10 measurement types with monochrome icons:  
  Blood Pressure, Heart Rate, Weight, Blood Sugar,  
  Temperature, Oxygen, Sleep, Steps, Vitamin D  
• Search filter  
• Navigates to MetricDetailScreen  
• Entrance animations (1600ms) |
| **Offline** | ✅ Works without backend |
| **Backend API** | `GET /measurements` (needs wiring) |

---

### 17. MetricDetailScreen
| | |
|---|---|
| **File** | `lib/screens/metric_detail_screen.dart` |
| **Purpose** | Single metric history & logging |
| **Data** | Hardcoded demo data |
| **Features** | • Trend chart (gradient area)  
• Dot matrix for daily tracking  
• History list (last 7 readings)  
• "Add Reading" button  
• 3 animation controllers (entrance, dots, trend) |
| **Offline** | ✅ Works without backend |
| **Backend API** | `POST /measurements` (needs wiring) |

---

### 18. AppointmentScreen
| | |
|---|---|
| **File** | `lib/screens/appointment_screen.dart` |
| **Purpose** | Doctor appointment scheduler |
| **Data** | Hardcoded doctors + user input |
| **Features** | • Doctor picker (4 pre-defined)  
• Date picker (calendar)  
• Time picker  
• Reason input  
• Confirmation card  
• Entrance animations (1600ms) |
| **Offline** | ✅ Works without backend |
| **Backend API** | `POST /appointments` (needs wiring) |

---

### 19. AdminScreen
| | |
|---|---|
| **File** | `lib/screens/admin_screen.dart` |
| **Purpose** | Platform admin dashboard |
| **Data** | API only (no local fallback) |
| **Features** | • Stats grid: Users, Supplements, Dose Logs, Measurements  
• User list with avatar initials  
• Per-user badge: supplement count, log count  
• Staggered entrance animations  
• Logout button (returns to AuthScreen) |
| **Offline** | ❌ Requires backend |
| **Backend API** | `GET /admin/stats`  
`GET /admin/users` |

---

## 🔧 BACKEND API ENDPOINTS

### Auth (`/auth`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | ❌ | Create account + return JWT |
| POST | `/auth/login` | ❌ | Login + return JWT |
| GET | `/auth/me` | ✅ | Get current user |

### Supplements (`/supplements`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/supplements` | ✅ | Create supplement |
| GET | `/supplements` | ✅ | List user's supplements |
| GET | `/supplements/{id}` | ✅ | Get one supplement |
| PUT | `/supplements/{id}` | ✅ | Update supplement |
| DELETE | `/supplements/{id}` | ✅ | Delete + cascade logs |

### Dose Logs (`/dose-logs`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/dose-logs` | ✅ | Log dose (auto-decrements stock) |
| DELETE | `/dose-logs/{supp_id}/{date}` | ✅ | Remove log (restores stock) |
| GET | `/dose-logs/supplement/{id}` | ✅ | Get logs for supplement |
| GET | `/dose-logs/today/{date}` | ✅ | Get today's logs |

### Insights (`/insights`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/insights/dashboard` | ✅ | Full dashboard metrics |
| GET | `/insights/supplement/{id}` | ✅ | Per-supplement analytics |
| GET | `/insights/trends` | ✅ | 16-day adherence trend |

### Measurements (`/measurements`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/measurements` | ✅ | Record measurement |
| GET | `/measurements` | ✅ | List measurements |
| GET | `/measurements/{id}` | ✅ | Get one |
| PUT | `/measurements/{id}` | ✅ | Update |
| DELETE | `/measurements/{id}` | ✅ | Delete |

### Appointments (`/appointments`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/appointments` | ✅ | Schedule appointment |
| GET | `/appointments` | ✅ | List appointments |
| GET | `/appointments/{id}` | ✅ | Get one |
| PUT | `/appointments/{id}` | ✅ | Update |
| DELETE | `/appointments/{id}` | ✅ | Cancel |

### Admin (`/admin`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/admin/stats` | ✅ | Platform-wide stats |
| GET | `/admin/users` | ✅ | List all users with counts |
| DELETE | `/admin/users/{id}` | ✅ | Delete user + all data |
| GET | `/admin/supplements` | ✅ | List all supplements |

---

## 🔄 OFFLINE-FIRST ARCHITECTURE

```
┌─────────────────┐
│   User Action   │
└────────┬────────┘
         ▼
┌─────────────────┐     ┌──────────────┐
│  Try API First  │────►│  Dio + JWT   │
│  (ApiService)   │     │  Bearer Token│
└────────┬────────┘     └──────────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐  ┌──────────┐
│Success│  │  Failed  │
│       │  │(Offline)  │
└───┬───┘  └────┬─────┘
    │           │
    ▼           ▼
┌───────┐  ┌──────────────┐
│ Update│  │ Use LocalStorage│
│  API  │  │ (SharedPrefs)  │
│ Data  │  │                 │
└───┬───┘  └───────┬────────┘
    │              │
    ▼              ▼
┌──────────────────────┐
│  Update Riverpod State │
│  (UI re-renders)      │
└──────────────────────┘
```

### Local Storage Keys
| Key | Data |
|-----|------|
| `@stacksense/token` | JWT auth token |
| `@stacksense/supplements` | JSON array of supplements |
| `@stacksense/dose_logs` | JSON array of dose logs |
| `@stacksense/dark_mode` | Bool — dark mode preference |
| `@stacksense/font_size` | String — font size level |

---

## 📊 DATA MODELS

### Supplement
```dart
{
  id: String,
  name: String,
  dosageAmount: double,
  dosageUnit: String,      // mg | mcg | IU | g | ml
  frequency: int,          // 1-10
  stockCount: int,
  timeSlots: List<String>, // ["Morning", "Evening"]
  startDate: String,       // "YYYY-MM-DD"
  createdAt: int,          // timestamp ms
}
```

### DoseLog
```dart
{
  id: String,
  supplementId: String,
  date: String,            // "YYYY-MM-DD"
  timestamp: int,          // timestamp ms
  takenAt: DateTime?,      // nullable
}
```

### User (Backend)
```python
{
  email: EmailStr,
  name: Optional[str],
  hashed_password: str,
  created_at: int,
  is_active: bool = True
}
```

---

## 🎨 DESIGN SYSTEM

### Colors (Monochrome + Teal)
| Token | Light | Dark |
|-------|-------|------|
| `bg` | `#FFFFFF` | `#0F0F0F` |
| `cardBg` | `#FFFFFF` | `#1A1A1A` |
| `surface` | `#F5F5F5` | `#2A2A2A` |
| `textPrimary` | `#1A1A1A` | `#FFFFFF` |
| `textSecondary` | `#666666` | `#AAAAAA` |
| `textMuted` | `#999999` | `#666666` |
| `border` | `#E5E5E5` | `#333333` |
| `accent` | `#00BFA5` | `#00BFA5` |
| `accentDark` | `#00897B` | `#4DB6AC` |
| `accentBg` | `#E0F7F4` | `#1A3C34` |

### Typography (Artific Font)
| Style | Size | Weight |
|-------|------|--------|
| Display | 48px | 300 |
| H1 | 32px | 700 |
| H2 | 22px | 700 |
| H3 | 18px | 600 |
| Body | 16px | 400 |
| BodySmall | 14px | 400 |
| Caption | 12px | 500 |
| Micro | 11px | 500 |

### Spacing (Golden Ratio φ = 1.618)
| Token | Value |
|-------|-------|
| `xs` | 4px |
| `sm` | 8px |
| `md` | 13px |
| `lg` | 21px |
| `xl` | 34px |
| `xxl` | 55px |

### Animation Patterns
| Element | Pattern | Duration | Curve |
|---------|---------|----------|-------|
| Cards | fadeIn + slideY | 400-700ms | easeOutCubic |
| Dots | fadeIn + scale | 180-200ms | easeOutBack |
| Bars | fadeIn + scaleY | 350ms | easeOutBack |
| Text | fadeIn + slideY | 350ms | easeOutCubic |
| Stagger | delay index × 60-80ms | — | — |

---

## ✅ BUILD STATUS

```
✓ Flutter analyze: 0 errors, 0 warnings (4 minor info-level suggestions)
✓ Flutter debug APK: Built successfully
✓ All 20 screen files: Compile cleanly
✓ Backend imports: OK
✓ Backend models: All registered
✓ Backend routers: All mounted
⚠ MongoDB: Not running locally (expected — use Atlas for production)
```

### Screen Compile Status (All Pass)
```
✅ add_medication_screen.dart
✅ admin_screen.dart
✅ appointment_screen.dart
✅ auth_screen.dart
✅ day_detail_screen.dart
✅ health_dashboard_screen.dart
✅ insights_screen.dart
✅ landing_screen.dart
✅ main_navigation_screen.dart
✅ measurement_list_screen.dart
✅ medication_list_screen.dart
✅ metric_detail_screen.dart
✅ my_supplements_screen.dart
✅ progress_screen.dart
✅ settings_screen.dart
✅ supplement_detail_screen.dart
✅ supplement_form_screen.dart
✅ support_screen.dart
✅ today_screen.dart
✅ treatment_screen.dart
```

---

## 🚀 NEXT STEPS

1. **Deploy MongoDB** — MongoDB Atlas free tier
2. **Deploy Backend** — Railway / Render / Fly.io
3. **Update API base URL** — Change `localhost:8000` to production URL
4. **Add Push Notifications** — Firebase Cloud Messaging
5. **Add Tests** — Unit tests for providers, widget tests for screens
6. **App Store Release** — iOS App Store + Google Play Store

---

*Built with ❤️ by Matra@DEV*
