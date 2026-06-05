# StackSense — Supplement Tracker App
## Pitch Deck & Sprint Plan

---

## Project Overview

**StackSense** is a premium mobile application for tracking daily supplement intake, managing inventory, and maintaining consistent health routines. Built with a clean, minimalist healthcare aesthetic featuring liquid glass UI, smooth animations, and haptic feedback.

**Client Quote:** ₹1,85,000 (One Lakh Eighty-Five Thousand)
**Timeline:** 20 Days (15 Days Development + 5 Days Testing)
**Platforms:** iOS, Android, Web Admin Panel

---

## Tech Stack

### Mobile Application
| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.27 (Dart) |
| State Management | Riverpod |
| Animations | flutter_animate |
| Charts | fl_chart |
| Local Storage | shared_preferences |
| HTTP Client | dio |
| Date Handling | intl |
| UUID Generation | uuid |

### Backend API
| Layer | Technology |
|-------|-----------|
| Framework | FastAPI (Python) |
| Database | MongoDB |
| ODM | Beanie |
| Driver | Motor (async MongoDB) |
| Validation | Pydantic v2 |
| Server | Uvicorn |

### Admin Panel
| Layer | Technology |
|-------|-----------|
| Framework | Flutter Web |
| State Management | Riverpod |
| Charts | fl_chart |

### DevOps & Tools
- **Version Control:** Git + GitHub
- **CI/CD:** GitHub Actions
- **Testing:** flutter_test, pytest
- **Design:** Figma
- **Project Management:** Linear / Notion

---

## Sprint 1: Foundation (Days 1–10)
**Cost Allocation:** ₹92,500 (50%)

### Week 1: Core UI & Local-First Architecture

#### Day 1–2: Project Setup & Design System
- [x] Flutter project initialization with Riverpod
- [x] Artific font family integration (5 weights)
- [x] Color palette & spacing tokens
- [x] Theme configuration (light mode)
- [x] App icon & splash screen

#### Day 3–4: Navigation & Screens
- [x] Floating pill bottom navigation (Home / My Stack / Settings)
- [x] Today screen with week calendar strip
- [x] My Stack (supplements list) screen
- [x] Settings screen
- [x] Screen transitions & animations

#### Day 5–6: Supplement Management
- [x] Add supplement form (name, dosage, frequency, stock, time slots)
- [x] Edit supplement functionality
- [x] Delete with confirmation dialog
- [x] Supplement detail view with stats
- [x] Local storage persistence (SharedPreferences)

#### Day 7–8: Daily Tracking
- [x] Checkbox toggle for dose logging
- [x] Time slot grouping (Morning / Afternoon / Evening)
- [x] Staggered list animations
- [x] Day change transitions (header + calendar)
- [x] Stock decrement on dose log

#### Day 9–10: Polish & Charts
- [x] Weekly bar chart (last 7 days)
- [x] Low stock badge (static, no animation)
- [x] Haptic feedback on all interactions
- [x] Empty states & error handling
- [x] Dummy data seeding for demo

### Sprint 1 Deliverables
- ✅ iOS & Android builds
- ✅ Local-first data persistence
- ✅ Complete CRUD for supplements
- ✅ Daily dose tracking
- ✅ Weekly analytics chart
- ✅ Smooth animations & haptics

---

## Sprint 2: Cloud Sync & Admin (Days 11–20)
**Cost Allocation:** ₹92,500 (50%)

### Week 3: Backend & Cloud Sync

#### Day 11–12: FastAPI Backend
- [ ] MongoDB Atlas setup
- [ ] FastAPI project scaffold
- [ ] Supplement model (Beanie ODM)
- [ ] Dose log model
- [ ] CRUD REST endpoints
- [ ] CORS & error handling

#### Day 13–14: Authentication
- [ ] Anonymous auth (device ID)
- [ ] Optional email/password signup
- [ ] JWT token management
- [ ] Secure API headers

#### Day 15–16: Sync Engine
- [ ] Offline-first architecture
- [ ] Queue for pending syncs
- [ ] Conflict resolution (last-write-wins)
- [ ] Background sync on connectivity
- [ ] Sync status indicators

### Week 4: Admin Panel & Testing

#### Day 17–18: Web Admin Panel
- [ ] Flutter Web scaffold
- [ ] Dashboard with user stats
- [ ] Supplement management table
- [ ] Dose log analytics
- [ ] User management
- [ ] Export to CSV

#### Day 19–20: Testing & Deployment
- [ ] Unit tests (models, services)
- [ ] Widget tests (screens, components)
- [ ] Integration tests (full flows)
- [ ] iOS TestFlight deployment
- [ ] Android Play Console upload
- [ ] Backend deployment (Render / AWS)
- [ ] Admin panel hosting (Firebase Hosting)

### Sprint 2 Deliverables
- ✅ FastAPI backend with MongoDB
- ✅ Cloud sync with offline support
- ✅ Web admin panel
- ✅ iOS TestFlight build
- ✅ Android internal testing build
- ✅ Test coverage > 80%

---

## Cost Breakdown

| Component | Amount (₹) | Percentage |
|-----------|-----------|------------|
| Sprint 1: Mobile App Foundation | 92,500 | 50% |
| Sprint 2: Backend + Admin + Testing | 92,500 | 50% |
| **Total** | **₹1,85,000** | **100%** |

### Detailed Cost Allocation

| Item | Days | Rate/Day | Amount |
|------|------|----------|--------|
| Flutter Development | 12 | ₹8,000 | ₹96,000 |
| FastAPI Backend | 4 | ₹8,000 | ₹32,000 |
| Flutter Web Admin | 2 | ₹8,000 | ₹16,000 |
| Testing & QA | 5 | ₹5,000 | ₹25,000 |
| DevOps & Deployment | 2 | ₹8,000 | ₹16,000 |
| **Subtotal** | **25** | — | **₹1,85,000** |

*Note: 20 working days + 5 testing days = 25 total days*

---

## Payment Milestones

| Milestone | Amount | Trigger |
|-----------|--------|---------|
| Kickoff (45%) | ₹83,250 | Project start — Sprint 1 commitment |
| Sprint 1 Complete (25%) | ₹46,250 | iOS/Android builds delivered |
| Sprint 2 Complete (20%) | ₹37,000 | Backend + Admin deployed |
| Final Delivery (10%) | ₹18,500 | App store submission + handover |

---

## Team Composition

| Role | Count | Responsibility |
|------|-------|---------------|
| Flutter Developer | 1 | Mobile app (iOS + Android) |
| Backend Developer | 1 | FastAPI + MongoDB |
| QA Engineer | 1 | Testing & bug fixes |
| DevOps | Shared | Deployment & CI/CD |

---

## Key Features

### Sprint 1 (Local-First)
- 📅 Week calendar with day selector
- ✅ Checkbox dose tracking
- 📊 Weekly bar chart analytics
- ⚠️ Low stock alerts
- 💾 Offline data persistence
- 🎨 Liquid glass UI design
- 📳 Haptic feedback

### Sprint 2 (Cloud + Admin)
- ☁️ Cloud sync with MongoDB
- 🔐 Anonymous + email auth
- 🌐 Web admin dashboard
- 📈 Advanced analytics
- 📤 Data export
- 🚀 App store deployment

---

## Why This Stack?

| Technology | Reason |
|-----------|--------|
| Flutter | Single codebase for iOS + Android + Web |
| Riverpod | Type-safe, testable state management |
| FastAPI | High-performance Python async framework |
| MongoDB | Flexible schema for supplement data |
| Beanie | Modern Python ODM for MongoDB |
| flutter_animate | Declarative, performant animations |

---

## Contact

**StackSense Development Team**
- Email: dev@stacksense.app
- GitHub: github.com/stacksense
- Figma: figma.com/@stacksense

---

*Document Version: 1.0*
*Last Updated: June 1, 2026*
*Valid for 30 days from date of issue*
