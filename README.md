# City Wallet

A context-aware mobile wallet that surfaces relevant local offers in real time based on weather, location, time, and local activity.

## Overview

Instead of generic 10% off coupons, City Wallet delivers the right offer at the right moment. If it's cold outside, it's lunchtime, and a café nearby just got quiet—you get an offer for a warm drink there, now.

### How It Works

**Context Sensing** — Captures weather, location, time, local events, and transaction patterns.

**Offer Generation** — Creates personalized offers based on context. Merchants set rules; the system generates what fits.

**Redemption** — QR code scan completes the transaction.

---

## Project Structure

```
lib/
├── main.dart
├── data/
│   └── get_weather_data.dart
├── models/
│   └── shop_data_hive.dart
├── services/
│   ├── create_message.dart         # Offer generation
│   ├── database_service.dart
│   ├── interruption_service.dart   # Context monitoring
│   ├── notification_service.dart
│   └── ranking_service.dart
└── UI/
    ├── screens/
    ├── merchant/                   # Merchant dashboard
    ├── qr_code_validation/
    └── detail_card/
```

---
