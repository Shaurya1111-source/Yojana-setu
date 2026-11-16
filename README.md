# YojanaSetu (योजना सेतु) 🇮🇳
### Civic Welfare & Government Scheme Eligibility Finder

[![Status](https://img.shields.io/badge/Status-Live%20Production-059669?style=flat-square)](#)
[![Stack](https://img.shields.io/badge/Stack-HTML5%20%7C%20TailwindCSS%20%7C%20Vanilla%20JS-047857?style=flat-square)](#)
[![Database](https://img.shields.io/badge/Database-Supabase%20(PostgreSQL)-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](#)
[![Security](https://img.shields.io/badge/Security-Row%20Level%20Security%20(RLS)-blue?style=flat-square)](#)
[![Language](https://img.shields.io/badge/Bilingual-English%20%7C%20%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80-amber?style=flat-square)](#)

> **"Bridging the Information Gap: Helping Every Indian Discover & Claim the Government Welfare Benefits They Deserve."**

---

## 📌 Problem Statement

Every year, tens of thousands of crores in central and state welfare budgets (scholarships, farmer cash transfers, maternity benefits, subsidized loans, healthcare coverage) go unclaimed. 

The fundamental bottleneck is **information asymmetry**:
- Welfare guidelines are locked inside complex 50-page gazette PDF notifications.
- Citizens do not know which schemes they qualify for based on age, income, caste, landholding, or occupation.
- Middlemen and informal touts exploit citizens by charging high commissions to "check eligibility" and fill forms.

**YojanaSetu** solves this with a **zero-middleman, mobile-first, bilingual civic web platform**. A citizen answers 5 quick questions, and the rule-matching engine instantly filters official schemes, explains *why* they qualify, aggregates all required documents into a single checklist, and generates a printable application dossier for submission at Common Service Centers (CSC) or Tehsil offices.

---

## 🌟 Key Features

### 1. 5-Step Interactive Eligibility Wizard
- **Step 1: Personal Profile** — Age slider with lifecycle milestones (Minor, Youth, Adult, Senior Citizen) & Gender.
- **Step 2: Domicile & Location** — All 36 States/UTs + Central schemes with Rural vs. Urban classification.
- **Step 3: Occupation** — Targeted schemes for Farmers, Students, Street Vendors, Artisans, Entrepreneurs, Daily Wage workers, and Unemployed youth.
- **Step 4: Socio-Economic Category** — Annual household income brackets, Social Category (General, OBC, SC, ST, EWS), and BPL Card verification.
- **Step 5: Special Circumstances** — Persons with Disabilities (UDID), Girl Child under 10, Pregnant/Lactating mothers, and Landowners.
- **Live Match Counter**: Shows real-time scheme counts dynamically updating as the user answers.

### 2. Instant Rule-Matching Engine
- Transparent, deterministic evaluation of multi-variable criteria.
- **"Why You Qualify" Chips**: Every scheme card clearly shows the specific criteria met (e.g., `✓ Age 24 fits 18-35 limit`, `✓ OBC category qualifies`, `✓ Income under ₹2.5L ceiling`).
- Filter by category (Healthcare, Agriculture, Education, Business, Women & Child, Pensions) and search by keywords.

### 3. Consolidated Document Checklist
- When a citizen qualifies for multiple schemes, they often need the same documents.
- The **Checklist Tab** automatically de-duplicates requirements across all qualified schemes.
- Explains **where and how** to obtain each document (e.g., Tehsil office, UIDAI portal, CSC kiosk, District CMO).
- Interactive checkboxes allow citizens to mark off documents they already possess.

### 4. Direct Official Portal Integration
- Every scheme card includes verified, direct links to official government portals (`pmjay.gov.in`, `pmkisan.gov.in`, `pmsvanidhi.mohua.gov.in`, `scholarships.gov.in`, etc.).
- Direct application links prevent citizens from falling victim to phishing or third-party fee scams.

### 5. Printable Citizen Application Dossier (`@media print`)
- Integrated print stylesheet transforms the digital checklist into an official physical A4 paper dossier.
- Formatted specifically for citizens to hand carry to CSC kiosks, Panchayat secretariats, or bank branches.

### 6. Bilingual Native Localization (English & हिन्दी)
- Instant 1-click language toggle between English and Hindi.
- Translates everything: wizard questions, scheme titles, descriptions, criteria chips, and document requirements.

---

## 🏗️ Technical Architecture

YojanaSetu follows a modern **JAMstack + BaaS (Backend-as-a-Service)** architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                       Client Browser                        │
│   (Mobile-Responsive HTML5 + TailwindCSS + Vanilla ES6+)    │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼ (Live Sync)                  ▼ (Offline Fallback)
┌──────────────────────────────┐ ┌────────────────────────────┐
│      Supabase Cloud DB       │ │    Local Memory / Cache    │
│  - Hosted PostgreSQL Engine  │ │  - Built-in 30 Schemes     │
│  - Row Level Security (RLS)  │ │  - LocalStorage State      │
│  - JSONB Criteria Documents  │ │  - Zero Dependency Run     │
└──────────────────────────────┘ └────────────────────────────┘
```

### Dual-Mode Data Layer:
1. **Supabase Cloud Mode (Live)**: Connects to a cloud PostgreSQL database using the `@supabase/supabase-js` v2 library. All scheme criteria, benefits, and documents are fetched in real-time from the database.
2. **Offline Fallback Mode**: If network connectivity drops or the database is unconfigured, the app falls back seamlessly to the local dataset with zero downtime.

---

## 🗄️ Database Schema (PostgreSQL)

The database is built on **Supabase PostgreSQL** with Row Level Security (RLS) enabled:

| Table | Purpose | Key Columns |
| :--- | :--- | :--- |
| `schemes` | Catalog of 30+ government welfare schemes | `id` (PK), `name` (JSONB), `category`, `benefit_amount` (JSONB), `eligibility` (JSONB), `documents` (JSONB), `official_url` |
| `document_registry` | Directory of official certificates & guidelines | `doc_key` (PK), `name` (JSONB), `description` (JSONB), `where_to_get` (JSONB) |
| `saved_schemes` | Bookmarks saved by users / sessions | `id` (UUID), `user_id`, `session_id`, `scheme_id` (FK) |
| `user_checklists` | Document readiness tracking | `id` (UUID), `user_id`, `session_id`, `doc_key`, `is_ready` |

---

## 🎨 Civic Design System

Unlike generic templates, YojanaSetu adheres to authentic **human-centered civic design standards** (modeled after *GOV.UK*, *DigiLocker*, and *India.gov.in*):
- **Civic Color Palette**: Sovereign Emerald (`#065F46`), National Saffron/Amber (`#D97706`), Warm Paper Background (`#FBFBFA`).
- **Clean Vector Iconography**: Bespoke 1.75px stroke SVG icons for intuitive visual recognition.
- **Micro-Interactions**: Subtle status indicators, animated matching pills, and responsive touch-first navigation.
- **Accessibility**: High-contrast typography and screen-reader friendly semantic markup.

---

## 📋 Flagship Schemes Cataloged (Sample)

| Category | Flagship Schemes Included | Key Entitlement / Benefit |
| :--- | :--- | :--- |
| 🏥 **Healthcare** | Ayushman Bharat (PM-JAY) | ₹5,00,000 / year cashless hospital treatment |
| 🌾 **Agriculture** | PM-KISAN, Kisan Credit Card, PM Fasal Bima, PM-KUSUM | ₹6,000 / yr DBT, 4% credit, solar pump subsidy |
| 🎓 **Education** | Post-Matric Scholarships, NMMSS, Free Coaching | Full tuition + maintenance allowance |
| 💼 **Business & MSME** | PM SVANidhi, PM Mudra Yojana, PM Vishwakarma | ₹50,000 collateral-free loans, toolkit grants |
| 👩 **Women & Child** | Sukanya Samriddhi, PM Matru Vandana, PM Ujjwala | 8.2% tax-free savings, ₹6,000 maternity aid |
| 🛡️ **Social Security** | Atal Pension Yojana, PMSBY, PMJJBY, Senior Pension | ₹5,000 / mo pension, ₹2 Lakh insurance cover |

---

## 📂 Repository File Structure

```
yojana-setu/
├── index.html           # Main Single Page Application (SPA) entry point
├── style.css            # Bespoke civic design tokens & @media print styles
├── app.js               # State management, eligibility matching logic & UI renders
├── schemes-data.js      # Built-in offline database of 30 welfare schemes
├── translations.js      # Bilingual English & Hindi translation dictionaries
├── supabase-client.js   # Supabase client integration layer & data mapper
├── supabase-schema.sql  # Complete PostgreSQL DDL, RLS security & seed script
└── README.md            # Project documentation & presentation guide
```

---

## 🚀 Quick Start / Local Setup

Because YojanaSetu has **zero build dependencies**, you can run it instantly without installing Node.js:

1. **Clone or Download** this repository:
   ```bash
   git clone https://github.com/your-username/yojana-setu.git
   cd yojana-setu
   ```

2. **Open the App**:
   - Simply double-click `index.html` to open it in any web browser.
   - Or start a local server using Python:
     ```bash
     python -m http.server 8000
     ```
     Visit `http://localhost:8000`.

3. **(Optional) Connect to Supabase**:
   - Run `supabase-schema.sql` in your Supabase SQL Editor.
   - Click **Connect Cloud DB** in the top navigation bar of YojanaSetu.
   - Enter your **Project URL** and **anon public key**.

---

## 📄 License
This project is open-source under the [MIT License](LICENSE). Built for empowering Indian citizens through transparent digital public infrastructure.
