# YojanaSetu (योजना सेतु) 🇮🇳
### Civic Welfare & Government Scheme Eligibility Finder
> *"Bridging the Information Gap: Helping Every Indian Claim the Benefits They Deserve"*

---

## 🌟 Overview & Problem Statement
Every year, tens of thousands of crores in government welfare allocations (scholarships, maternity benefits, pensions, low-interest micro-loans, healthcare coverage) go unclaimed. The fundamental bottleneck is not lack of government intent or funding, but an **information asymmetry**:
- Welfare guidelines are buried inside 60-page PDF gazettes.
- Citizens do not know whether they qualify based on age, income, caste, or land ownership.
- Middlemen / informal brokers charge exorbitant cuts to "fill forms".

**YojanaSetu** solves this with a **zero-middleman, mobile-first, bilingual civic web application**. A citizen answers 5 intuitive questions, and the rule-matching engine instantly filters official schemes, breaks down why they qualify, aggregates all required documents into a unified checklist, and generates a printable application dossier for submission at a Common Service Center (CSC).

---

## 🎨 Visual Design Philosophy: "Human-Crafted, Not AI-Made"
Many AI-generated mockups suffer from recognizable clichés: neon purple gradients, blurred glassmorphism with unreadable text, and distorted cartoonish 3D icons.

YojanaSetu is purposefully designed with **authentic, human-centered civic design standards** (modeled after *GOV.UK*, *DigiLocker*, and *LifeSG*):
1. **Precision Vector Iconography**: Uses clean geometric line icons with an exact 1.75px stroke, rounded terminals, and clear semantic purpose (Stethoscope for Ayushman Bharat, Sprout for PM-Kisan, Graduation Cap for Scholarships, Landmark for Pensions).
2. **Civic Color Hierarchy**: 
   - Primary: Deep Emerald Forest (`#065F46` / `#047857`) — communicates trust, growth, and sovereign stability.
   - Accent: Warm Saffron / Amber (`#D97706`) — high-visibility callout for financial benefits and action milestones.
   - Canvas: Warm eggshell paper (`#FBFBFA`) — eliminates digital eye strain compared to harsh `#FFFFFF`.
3. **Bilingual Polish (English & हिन्दी)**: Full native translations for every button, question, category tag, and official scheme description.
4. **Printable Citizen Dossier (`@media print`)**: Specialized stylesheet that transforms the on-screen checklist into a physical A4 document with tick-boxes and instructions to carry to a CSC or Panchayat office.

---

## 🚀 Key Features

### 1. Step-by-Step Interactive Profile Wizard
- **Step 1: Personal Profile** (Age slider with lifecycle milestones, Gender selection).
- **Step 2: Domicile & Location** (All 36 States/UTs, Rural vs. Urban classification).
- **Step 3: Occupation** (Farmer, Student, Street Vendor, Artisan, Small Business, Daily Wage, Unemployed).
- **Step 4: Socio-Economic Category** (Income brackets, Social Category: General, OBC, SC, ST, EWS, BPL Card holder).
- **Step 5: Special Circumstances** (Persons with Disabilities / UDID, Girl child under 10, Pregnant/Lactating mothers, Agricultural landholders).
- **Live Match Counter**: Shows real-time scheme counts adjusting as you answer each step!

### 2. Instant Rule-Matching Engine (`app.js`)
- Runs multi-variable logic evaluating age thresholds, gender rules, income ceilings, occupation targets, and prerequisite conditions.
- Transparent "Why You Qualify" breakdown chips on every card (e.g. `✓ Age 24 fits 18-35 limit`, `✓ OBC category qualifies`, `✓ Income under ₹2.5L limit`).

### 3. Consolidated Document Checklist
- When a citizen qualifies for multiple schemes (e.g., 6 schemes), they often need the same documents (Aadhaar, Income Certificate, Bank Passbook, Land RoR).
- The **Checklist Tab** automatically de-duplicates these requirements, displays which schemes require which document, and offers practical guidance on how/where to obtain them.
- Users can check off documents they already possess.

### 4. Direct Official Portal Integration
- Every scheme card includes verified direct links to official government portals (`pmjay.gov.in`, `pmkisan.gov.in`, `pmsvanidhi.mohua.gov.in`, `scholarships.gov.in`, etc.).

---

## 📂 Project Architecture

```
yojana-setu/
├── index.html           # Civic single-page web app with cloud status & modal
├── style.css            # Bespoke civic design tokens & @media print stylesheet
├── app.js               # State management, rule-matching engine, UI reactive renders
├── schemes-data.js      # Built-in offline database of 30 Indian welfare schemes
├── translations.js      # Bilingual English & Hindi language dictionary
├── supabase-client.js   # Supabase v2 JS integration, PostgreSQL mappers & fallback
├── supabase-schema.sql  # Complete PostgreSQL schema, RLS policies, & 30-scheme seed data
├── bundle.py            # Generates self-contained standalone HTML artifact
├── server.py            # Local preview server with phone Wi-Fi IP display
└── README.md            # Comprehensive project architecture & launch guide
```

---

## 🏃 How to Run the Prototype

### Option 1: Using the Included Python Server
Open PowerShell in this folder and execute:
```powershell
python server.py
```
This automatically launches `http://localhost:8000` in your default browser.

### Option 2: Direct Double-Click
Simply double-click `index.html` to open it in Chrome, Edge, Brave, or Firefox. The prototype has **zero build steps** and **zero npm dependencies**.

---

---

## ⚡ Cloud Database & Supabase Architecture

YojanaSetu is configured for **dual-mode persistence**:
1. **Local Mode (Default)**: Runs 100% offline with zero dependencies using client-side memory and browser `localStorage`.
2. **Supabase Cloud Mode**: Connects directly to a live PostgreSQL database on Supabase using `@supabase/supabase-js`, with Row-Level Security (RLS) enabled.

### Database Tables:
- `schemes`: Complete catalog of 30+ government schemes with multilingual JSONB metadata, eligibility rules, and document requirements.
- `document_registry`: Canonical directory of official identity, income, and caste certificates with issuance instructions.
- `saved_schemes`: User bookmarks persisted by session or user identifier.
- `user_checklists`: User document preparation progress and verification records.

### 3-Step Supabase Setup:
1. **Create Free Project**: Go to [supabase.com](https://supabase.com) and create a project (takes ~1 minute).
2. **Run Schema Script**: In the Supabase Dashboard, click **SQL Editor**, open or paste the contents of `supabase-schema.sql`, and click **Run**. This creates the tables, indices, RLS security policies, and inserts all 30 schemes and document entries.
3. **Connect in App**:
   - In your Supabase Dashboard, go to **Project Settings > API**.
   - Copy your **Project URL** and **anon public key**.
   - Open YojanaSetu, click the **Connect Cloud DB** button in the header, paste your credentials, and click **Save & Connect**.
   - The indicator turns green (**Supabase Live**), and all schemes sync in real-time with PostgreSQL!

---

## 🚀 Public Launch & Hosting (Frontend + Backend)

Since Supabase handles the backend (PostgreSQL database and REST APIs), the frontend can be hosted for free with 1 click on any modern static host:

### Option A: Vercel (Recommended)
1. Push this folder to a GitHub repository or drag-and-drop the folder in the [Vercel Dashboard](https://vercel.com).
2. Framework preset: **Other** / Root Directory: `./`.
3. Click **Deploy**. Your app will be live on `https://your-project.vercel.app` with instant worldwide CDN and HTTPS.

### Option B: Netlify
1. Go to [app.netlify.com/drop](https://app.netlify.com/drop).
2. Drag and drop the `yojana-setu` folder.
3. It deploys instantly with a free `.netlify.app` domain.

### Option C: GitHub Pages
1. Push this directory to a GitHub repository.
2. Go to **Settings > Pages > Source**, select branch `main` and root `/`, then click **Save**.

---

## 📋 Cataloged Schemes Sample
- **Healthcare**: Ayushman Bharat (PM-JAY) - ₹5,00,000 Free Hospitalization Cover
- **Agriculture**: PM-Kisan Samman Nidhi (₹6,000/yr), Kisan Credit Card (4% interest), PM Fasal Bima Yojana, PM-KUSUM Solar Pumps
- **Education**: Post-Matric SC/ST & OBC Scholarships, National Means-cum-Merit (NMMSS), Free Coaching for SC/OBC, National Overseas Scholarship
- **Business & MSME**: PM SVANidhi (₹50,000 Street Vendor Loan), PM Mudra Yojana (Up to ₹10 Lakh), PM Vishwakarma Scheme (₹15,000 Toolkit + 5% Loan), Stand-Up India
- **Women & Child**: Sukanya Samriddhi Yojana (8.2% Tax-Free), PM Matru Vandana Yojana (₹6,000 Maternity Grant), PM Ujjwala 2.0 (Free LPG), Ladli Behna / Mahila Samman
- **Social Security & Pensions**: Atal Pension Yojana (Guaranteed ₹5,000/mo), PMSBY (₹2 Lakh Accident Cover for ₹20/yr), PMJJBY (₹2 Lakh Life Cover for ₹436/yr), Old Age Pension (IGNOAPS), Widow Pension (IGNWPS), Divyangjan Swavalamban
