<div align="center">
  <img src="assets/3.png" width="300" />
</div>

---
# **LinkedOut — Privacy-First AI Networking (Without the Corporate Surveillance Tax)**

We built **LinkedOut** because modern networking platforms went… well… off the rails.
Somewhere along the way:

* They started **training AI models on our personal connections**
* Then tried to **sell our own insights back to us at enterprise prices**
* And finally **locked everything behind paywalls thick enough to stop a tank**

So we said: *“What if we made a networking tool that’s actually… yours?”*

LinkedOut is an **offline-first, on-device AI networking app** designed for people who want powerful features **without handing over their entire professional history to the cloud overlords**.
Everything runs locally: your contacts, your embeddings, your search, your memory of *where you met that one guy at that one rooftop thing.*

No servers. No tracking. No creepy AI training on your relationships.

Just your network — **for you.**

---

# 🚀 **Key Features**

## 🧠 **Hybrid AI Engine**

### **Dual-Model Architecture**

* **Vision (OCR):**
  Lightning-fast text extraction from business cards using **Google ML Kit**.

* **Reasoning (Text):**
  Local LLMs via **Cactus SDK** (Qwen/Gemma) process fields, create structured JSON, and generate dense vector embeddings.

### **Parallel Processing**

OCR, GPS capture, and AI model warm-up run in parallel for minimal wait time.

### **Auto-Drafting**

Automatically generates contextual follow-up emails using meeting metadata:
**Event + Location + Notes** → human-sounding draft.

---

## 📍 **Offline Spatial Intelligence**

* **Zero-API Geocoding:**
  Converts GPS → City/Country via a local `geonames.db` SQLite file.
  No Google Maps. No API keys. No data leaks.

* **Auto-Tagging:**
  Every contact is stamped with location context at capture time.

* **Map Visualization:**
  Explore your network spatially — recall people via *place*, not just alphabetically.

---

## 🔍 **Smart RAG Chat (Retrieval-Augmented Generation)**

* **Natural Language Search:**
  Ask things like:

  * “Investors within 50 miles of Denver”
  * “Who did I meet last month?”
  * “Designers I met in NYC who do AI UX”

* **Intent Router:**
  LLM converts your query into structured JSON:

  ```json
  {
    "location": "Denver",
    "concept": "VC",
    "time": "last year"
  }
  ```

* **Hybrid Filtering:**
  Deterministic filters (location/time) + Vector similarity search for concepts/skills.

* **Summarized Output:**
  Search results appear as clean, actionable Contact Cards.

---

# 🏗 **System Architecture**

## 1. **The “Dual-Brain” AI Service (`cactus_service.dart`)**

To balance performance with intelligence:

### **The Eyes**

Lightweight vision layer (ML Kit) handles OCR.

### **The Brain**

A more capable text model (e.g., Qwen 0.6B) performs:

* Parsing messy OCR → structured `Contact` objects
* 1024-dim vector embedding generation
* Chat + semantic reasoning

Lazy-loading ensures fast startup and on-demand heavy lifting.

---

## 2. **Smart Search Pipeline (`advanced_search_service.dart`)**

When a user types a query:

1. **Parse:** LLM extracts structured parameters (location, time, concept).
2. **Spatial Filter:** SQLite search for cities within a radius.
3. **Temporal Filter:** Timestamp-based filtering.
4. **Vector Rank:** Cosine similarity against query embeddings.
5. **Summarize:** Present as Contact Cards in chat.

---

## 3. **Data Layer (Isar + SQLite)**

### **Isar**

Stores:

* Contact objects
* Embeddings
* Relationship metadata

### **SQLite**

Read-only geonames database with ~25k global cities for offline reverse geocoding.

---

# 📂 **Directory Structure**

```
lib/
├── main.dart                  # App Entry & Dependency Injection
├── app.dart                   # Routing & Theme Config
├── core/
│   └── utils/                 # Helpers (Vector Math, Business Card Regex)
├── data/
│   ├── local/                 # Isar Service & Database Logic
│   ├── models/                # Contact Schema (with Embeddings)
│   └── repositories/          # CRUD Ops & Auto-Embedding Logic
├── services/
│   ├── ai/                    # Cactus SDK Wrapper (Model Mgmt)
│   ├── location/              # GPS & Offline Geocoding (SQLite)
│   └── search/                # Advanced Search & Intent Parsing
└── presentation/
    ├── screens/
    │   ├── chat/              # Smart Search & Chat UI
    │   ├── contact/           # Detail & Edit Views
    │   ├── home/              # Dashboard (Alphabetical)
    │   ├── onboaring/         # Model Download & Setup
    │   ├── profile/           # "Me" Card
    │   ├── scan/              # Camera & OCR Review
    │   └── timeline/          # Chronological History View
    └── widgets/               # Reusable UI Components
```

---
<p align="center">
  <img src="assets/Screenshot 2025-11-29 at 09.09.55.png" width="300" />
</p>

# 🔄 **User Flow**

## **1. Onboarding**

* App initializes
* Auto-download required AI models
* `geonames.db` copied from assets → local storage

## **2. Scanning (Input)**

1. User taps **Scan**
2. Parallel execution: camera capture + GPS
3. OCR via ML Kit
4. LLM parses fuzzy fields
5. Offline geocoding → “Denver, USA”
6. Auto-draft email generated
7. User reviews & confirms

## **3. Storage (Memory)**

* Save to Isar
* Generate vector embeddings

## **4. Retrieval (Chat)**

* User asks: “Who are the investors I met in Denver?”
* LLM parses intent
* Spatial → Temporal → Vector ranking
* Display Contact Cards in chat

---

# 🛠 **Setup & Requirements**

## 1. **Assets**

Place the following in `assets/`:

* `geonames.db`
* `cities.csv` (fallback)
* `LinkedOut.svg`

## 2. **Code Generation**

Run after updating models:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

## 3. **Run**

```
flutter pub get
flutter run
```

## 4. **Debugging**

Isar Inspector appears in terminal logs.
On physical devices:

```
adb forward tcp:PORT tcp:PORT
```

---
