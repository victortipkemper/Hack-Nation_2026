# NUDGE: Hyperlocal Retail Revitalization Through Intelligent Context

**NUDGE** is a privacy-first, AI-powered platform that reconnects urban customers with independent local merchants at the precise moment both sides need each other—using real-time anomaly detection, on-device machine learning, and merchant-triggered demand signals to solve the retail invisibility crisis in Germany's urban centers.

## Creators

This project was created by:

- Dibbo-Mrinmoy Saha
- Moritz Soppe
- Richard Oehmichen
- Victor Tipkemper


## The Problem

Local retail in Germany is disappearing not because consumers stopped spending, but because small merchants lack the infrastructure to compete with billions in corporate marketing spend. Meanwhile, customers default to the same two or three familiar venues out of habit, not preference—entirely unaware of the undiscovered café around the corner or the specialty retailer within walking distance. Small independent businesses (cafés, retail, food) operate with idle capacity they cannot fill and no real-time infrastructure to reach nearby customers. The market inefficiency is structural: neither side possesses timely, relevant information about the other's availability.

**NUDGE solves this by connecting both sides at the exact moment both sides need it.** When a customer's routine breaks—a delayed bus, an unexpected gap in the day, weather shifts—the app surfaces a single, relevant local merchant offer nearby. When a merchant's transaction volume drops or external signals suggest low foot traffic, offers activate automatically. No browsing. No static coupons. Pure signal-to-action.

---

## Core Architecture

### Three-Layer System

**Backend (Firebase)**
- Central orchestration, merchant management, data aggregation
- Minimal personal data storage (privacy-by-design)
- APIs for real-time context exchange

**Frontend (Flutter)**
- Single codebase for iOS & Android
- Unified user and merchant apps with role-based interfaces

**On-Device Processing**
- Gemma 3 270M (local SLM) for personalized message generation
- All personal data stays on the device; no transmission to backend

---


### Key Processing Components

**Interruption Detection Service** (`services/interruption_service.dart`)
- Monitors device signals continuously
- Compares current state against learned routine baseline
- Fires interruption event when anomaly threshold exceeded

**Ranking Engine** (`services/ranking_service.dart`)
- Scores nearby merchants based on:
  - User preference history
  - Distance (from detected anomaly location)
  - Merchant capacity state (from Payone demand signal)
  - Time-of-day relevance
  - Weather applicability
- Returns ranked list for offer generation

**Notification Service** (`services/notification_service.dart`)
- Manages local notification delivery
- On-device SLM (Gemma 3 270M) generates personalized message

**Message Creation Engine** (`services/create_message.dart`)
- Local SLM invocation: Gemma 3 270M
- Converts context + merchant profile → natural language offer

**QR Code Validation** (`UI/qr_code_validation/`)
- In-store redemption verification
- Coupon application in simulated checkout

**Detail Card UI** (`UI/detail_card/`)
- Offer presentation: discount, merchant, distance, expiry
- Redemption flow visualization

---

## Privacy & Security Philosophy

**Core Principle**: Personal behavioral data is an asset that belongs to the user, not the platform.

- **Zero data transmission**: Device-side anomaly detection and ranking never transmit location history, notification logs, or routine patterns to backend
- **Aggregation only**: Backend receives only anonymized signals (e.g., "anomaly detected and offer triggered at lat/long X")
- **On-device SLM**: Message generation happens locally; no user context sent to LLM API
- **User control**: Widget-based activation lets users opt-in when they want engagement
- **Merchant trust**: Merchants see only aggregated metrics (new customer count, ROI), not individual user profiles

**GDPR Compliance**:
- Data minimization (only what's needed)
- Purpose limitation (no repurposing signals)
- User rights (export, delete, control)
- Local processing (no unnecessary transmission)

---

## Technology Stack

### Frontend
- **Flutter**: Single codebase iOS/Android
- **Architecture**: MVVM with reactive state management
- **Local SLM**: Gemma 3 270M (quantized, on-device)

### Backend
- **Firebase**: Firestore (merchant data), Cloud Functions (orchestration), Authentication
- **APIs**: Weather (OpenWeatherMap or similar), Payone integration

### DevOps
- **Mobile CI/CD**: GitHub Actions (Flutter build & test)
- **Backend**: Firebase managed services

---

## Competitive Moat

1. **Timing-as-a-feature**: Activates offers at the exact moment anomaly occurs—competitors activate on convenience, not signal
2. **Privacy-first design**: Users trust device-local processing; regulatory advantage over data-hoarding competitors
3. **Generative offers**: No pre-computed inventory; scales without coupon explosion
4. **Payone integration**: Payment-level demand signals create self-adjusting system (technical barrier)
5. **Behavioral loop**: Feedback accumulation improves ranking over time; cold-start solvable with user preferences

---


## How to Run

### Requirements
- Flutter 3.x
- Firebase CLI configured
- Gemma 3 270M model (included in `assets/`)

### Setup
```bash
flutter pub get
flutter run
```

### Project Structure
- `lib/main.dart`: App entry point (user + merchant role selection)
- `lib/services/`: Core engines (interruption detection, ranking, notifications)
- `lib/UI/`: User and merchant interfaces
- `lib/data/`: External data fetching (weather, etc.)
- `assets/gemma-3-270m-it-Q4_K_M.gguf`: On-device SLM

---

## Vision

NUDGE is not a coupon app. It's a **real-time market-making engine** that fills the gap between supply (merchant idle capacity) and demand (customer routine breaks) in the hyperlocal retail space. By combining anomaly detection, generative AI, privacy-first architecture, and payment-level signals, NUDGE creates a system where both customers and merchants win—no waste, no spam, just relevance.

Local retail doesn't need to disappear. It needs better visibility. NUDGE provides it.

