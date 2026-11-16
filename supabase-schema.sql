-- ============================================================================
-- YOJANASETU (योजना सेतु) - Supabase PostgreSQL Database Schema & Seed Data
-- Run this entire script in Supabase Dashboard -> SQL Editor -> New Query
-- ============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Drop existing tables if re-running
DROP TABLE IF EXISTS user_checklists CASCADE;
DROP TABLE IF EXISTS saved_schemes CASCADE;
DROP TABLE IF EXISTS document_registry CASCADE;
DROP TABLE IF EXISTS schemes CASCADE;

-- 3. Create 'schemes' table
CREATE TABLE schemes (
    id TEXT PRIMARY KEY,
    name JSONB NOT NULL,
    short_description JSONB NOT NULL,
    ministry JSONB NOT NULL,
    category TEXT NOT NULL,
    benefit_type JSONB NOT NULL,
    benefit_amount JSONB NOT NULL,
    official_url TEXT NOT NULL,
    portal_name TEXT NOT NULL,
    tags JSONB NOT NULL DEFAULT '[]'::jsonb,
    eligibility JSONB NOT NULL,
    criteria_descriptions JSONB NOT NULL,
    documents JSONB NOT NULL DEFAULT '[]'::jsonb,
    application_steps JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create 'document_registry' table
CREATE TABLE document_registry (
    doc_key TEXT PRIMARY KEY,
    name JSONB NOT NULL,
    description JSONB NOT NULL,
    where_to_get JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Create 'saved_schemes' (for users/sessions to bookmark schemes)
CREATE TABLE saved_schemes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id TEXT,
    scheme_id TEXT REFERENCES schemes(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, scheme_id),
    UNIQUE(session_id, scheme_id)
);

-- 6. Create 'user_checklists' (for tracked citizen documents)
CREATE TABLE user_checklists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id TEXT,
    doc_key TEXT NOT NULL,
    is_ready BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, doc_key),
    UNIQUE(session_id, doc_key)
);

-- 7. Configure Row Level Security (RLS)
ALTER TABLE schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_registry ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_checklists ENABLE ROW LEVEL SECURITY;

-- Public read access for schemes and documents (anyone can read schemes)
CREATE POLICY "Allow public read for schemes" ON schemes FOR SELECT USING (true);
CREATE POLICY "Allow public read for document_registry" ON document_registry FOR SELECT USING (true);

-- Public/authenticated access for bookmarks and checklists
CREATE POLICY "Allow all for saved_schemes" ON saved_schemes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for user_checklists" ON user_checklists FOR ALL USING (true) WITH CHECK (true);

-- ============================================================================
-- 8. Seed Document Registry
-- ============================================================================

INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Aadhaar Card', '{"en": "Aadhaar Card", "hi": "आधार कार्ड"}'::jsonb, '{"en": "Primary biometric identity proof. Ensure your current mobile number is linked for OTP verification.", "hi": "प्राथमिक बायोमेट्रिक पहचान पत्र। सुनिश्चित करें कि ओटीपी हेतु आपका मोबाइल नंबर लिंक हो।"}'::jsonb, '{"en": "Any UIDAI Aadhaar Seva Kendra, Post Office, or Bank branch. Can download e-Aadhaar from uidai.gov.in.", "hi": "किसी भी आधार सेवा केंद्र, डाकघर या बैंक शाखा। uidai.gov.in से ई-आधार डाउनलोड किया जा सकता है।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;
INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Ration Card (BPL / Antyodaya / State Food Security)', '{"en": "Ration Card (BPL / Antyodaya / Food Security)", "hi": "राशन कार्ड (बीपीएल / अंत्योदय / खाद्य सुरक्षा)"}'::jsonb, '{"en": "Proof of family composition and economic status for subsidies and welfare entitlement.", "hi": "पारिवारिक सदस्यों और आर्थिक स्थिति का आधिकारिक प्रमाण।"}'::jsonb, '{"en": "District Food and Civil Supplies Department or State e-District portal.", "hi": "जिला खाद्य एवं रसद विभाग या राज्य के ई-डिस्ट्रिक्ट पोर्टल से।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;
INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Income Certificate', '{"en": "Income Certificate (Current Year)", "hi": "आय प्रमाण पत्र (नवीनतम)"}'::jsonb, '{"en": "Official certificate validating total annual household earnings from all sources.", "hi": "परिवार की कुल वार्षिक आय को प्रमाणित करने वाला आधिकारिक राजस्व दस्तावेज।"}'::jsonb, '{"en": "Apply through Tehsil / Taluk office, CSC center, or State e-District portal.", "hi": "तहसील कार्यालय, जन सेवा केंद्र (CSC) या राज्य के ई-डिस्ट्रिक्ट पोर्टल द्वारा।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;
INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Caste Certificate', '{"en": "Caste / Category Certificate (SC/ST/OBC)", "hi": "जाति प्रमाण पत्र (SC/ST/OBC)"}'::jsonb, '{"en": "Official verification of social category for reservation and affirmative scholarships.", "hi": "आरक्षण और छात्रवृत्ति लाभों हेतु सक्षम अधिकारी द्वारा जारी जाति प्रमाण पत्र।"}'::jsonb, '{"en": "Issued by SDM / Tehsildar via State revenue / e-District online portal.", "hi": "उपजिलाधिकारी (SDM) या तहसीलदार द्वारा ई-डिस्ट्रिक्ट पोर्टल के माध्यम से।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;
INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Land Record Documents (Khatauni / RoR / Patta)', '{"en": "Land Records (Khatauni / Jamabandi / RoR)", "hi": "भूमि अभिलेख (खतौनी / जमाबंदी / भू-नक्शा)"}'::jsonb, '{"en": "Proof of agricultural landholding and title ownership.", "hi": "खेती योग्य भूमि के स्वामित्व और रकबे का आधिकारिक सरकारी अभिलेख।"}'::jsonb, '{"en": "State Bhulekh / Land Records portal (e.g. upbhulekh.gov.in, mahabhulekh.maharashtra.gov.in) or Lekhpal/Patwari.", "hi": "राज्य के भूलेख पोर्टल से ऑनलाइन या हल्का पटवारी/लेखपाल से प्राप्त करें।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;
INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Aadhaar-linked Bank Account Passbook', '{"en": "Bank Passbook (Aadhaar & DBT Seeded)", "hi": "बैंक पासबुक (आधार व डीबीटी लिंक खाता)"}'::jsonb, '{"en": "Bank account where DBT welfare subsidies can be directly transferred without middle-men.", "hi": "बैंक खाता जिसमें सरकारी सब्सिडी और छात्रवृत्ति सीधे बिना बिचौलियों के ट्रांसफर हो सके।"}'::jsonb, '{"en": "Any Nationalized Bank, Gramin Bank, or India Post Payments Bank. Ask branch to link Aadhaar for NPCI mapping.", "hi": "किसी भी बैंक या डाकघर बैंक से। बैंक में जाकर खाते को ''NPCI/DBT'' से लिंक करवाएं।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;
INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Unique Disability ID (UDID) Card', '{"en": "Unique Disability ID (UDID) Card", "hi": "दिव्यांगता प्रमाण पत्र (UDID कार्ड)"}'::jsonb, '{"en": "National identity card for persons with disabilities specifying percentage and nature of disability.", "hi": "दिव्यांगजनों के लिए राष्ट्रीय पहचान पत्र, जिसमें दिव्यांगता का प्रतिशत दर्ज होता है।"}'::jsonb, '{"en": "Apply on swavlambancard.gov.in and get assessed at District Chief Medical Officer (CMO) hospital.", "hi": "swavlambancard.gov.in पर आवेदन करें और जिला अस्पताल (CMO) में जांच करवाएं।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;
INSERT INTO document_registry (doc_key, name, description, where_to_get)
VALUES ('Birth Certificate', '{"en": "Birth Certificate", "hi": "जन्म प्रमाण पत्र"}'::jsonb, '{"en": "Official age and parentage proof for children and students.", "hi": "बच्चे की उम्र और माता-पिता के नाम का कानूनी प्रमाण।"}'::jsonb, '{"en": "Municipal Corporation, Nagar Palika, or Gram Panchayat Registrar of Births & Deaths (or crsorgi.gov.in).", "hi": "नगर पालिका, नगर निगम या ग्राम पंचायत जन्म-मृत्यु रजिस्ट्रार कार्यालय से।"}'::jsonb)
ON CONFLICT (doc_key) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, where_to_get = EXCLUDED.where_to_get;

-- ============================================================================
-- 9. Seed 30 Official Government Schemes
-- ============================================================================

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-jay',
    '{"en": "Ayushman Bharat - PM-JAY", "hi": "आयुष्मान भारत - प्रधानमंत्री जन आरोग्य योजना"}'::jsonb,
    '{"en": "World''s largest government-funded healthcare assurance scheme offering secondary and tertiary hospitalization cover.", "hi": "विश्व की सबसे बड़ी सरकारी स्वास्थ्य बीमा योजना, जो द्वितीयक और तृतीयक अस्पताल में भर्ती होने पर मुफ्त कवर प्रदान करती है।"}'::jsonb,
    '{"en": "Ministry of Health and Family Welfare", "hi": "स्वास्थ्य एवं परिवार कल्याण मंत्रालय"}'::jsonb,
    'https://beneficiary.nha.gov.in',
    'beneficiary.nha.gov.in'::jsonb,
    '{"en": "₹5,00,000 per family / year", "hi": "₹5,00,000 प्रति परिवार / वर्ष"}'::jsonb,
    'https://pmjay.gov.in',
    'National Health Authority (NHA)',
    '["Healthcare", "Hospital", "Free Treatment", "Cashless"]'::jsonb,
    '{"minAge": 0, "maxAge": 120, "genders": ["all"], "occupations": ["all"], "maxIncome": 250000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["bpl_or_low_income"]}'::jsonb,
    '{"en": ["Families listed in SECC 2011 deprivation criteria or low-income households (income under ₹2.5 Lakh/yr)", "No limit on family size, age, or gender", "Pre-existing conditions covered from day one"], "hi": ["SECC 2011 अभाव सूची या कम आय वाले परिवार (वार्षिक आय ₹2.5 लाख से कम)", "परिवार के आकार, आयु या लिंग की कोई सीमा नहीं", "पहले से मौजूद बीमारियां पहले दिन से कवर"]}'::jsonb,
    '["Aadhaar Card of all family members", "Ration Card (BPL / Antyodaya / State Food Security)", "Proof of Residence / Domicile Certificate", "Active Mobile Number linked with Aadhaar"]'::jsonb,
    '{"en": ["Check your name in the beneficiary list online at beneficiary.nha.gov.in or call toll-free 14555.", "Visit nearest Ayushman Mitra kiosk at any empanelled public or private hospital, or nearest CSC (Common Service Center).", "Complete biometric e-KYC using Aadhaar card and Ration card.", "Get your Ayushman Card printed or download via the Ayushman Bharat App."], "hi": ["beneficiary.nha.gov.in पर या टोल-फ्री 14555 पर कॉल करके लाभार्थी सूची में अपना नाम जांचें।", "किसी भी संबद्ध अस्पताल के आयुष्मान मित्र केंद्र या नजदीकी CSC (जन सेवा केंद्र) पर जाएं।", "आधार कार्ड और राशन कार्ड का उपयोग करके बायोमेट्रिक ई-केवाईसी पूरा करें।", "अपना आयुष्मान कार्ड प्राप्त करें या आयुष्मान ऐप से डाउनलोड करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-kisan',
    '{"en": "PM Kisan Samman Nidhi", "hi": "प्रधानमंत्री किसान सम्मान निधि"}'::jsonb,
    '{"en": "Direct income support of ₹6,000 annually in three equal installments to landholding farmer families.", "hi": "भूमिधारक किसान परिवारों को ₹6,000 प्रति वर्ष की प्रत्यक्ष आय सहायता, तीन समान किस्तों में।"}'::jsonb,
    '{"en": "Ministry of Agriculture and Farmers Welfare", "hi": "कृषि एवं किसान कल्याण मंत्रालय"}'::jsonb,
    'agriculture',
    '{"en": "Direct Bank Transfer", "hi": "प्रत्यक्ष बैंक अंतरण"}'::jsonb,
    '{"en": "₹6,000 / year (₹2,000 x 3 installments)", "hi": "₹6,000 / वर्ष (₹2,000 x 3 किस्तें)"}'::jsonb,
    'https://pmkisan.gov.in',
    'PM Kisan Portal',
    '["Farmers", "Income Support", "DBT", "Agriculture"]'::jsonb,
    '{"minAge": 18, "maxAge": 100, "genders": ["all"], "occupations": ["farmer"], "maxIncome": 1000000, "categories": ["all"], "areas": ["rural", "urban"], "states": ["all"], "specialConditions": ["owns_cultivable_land"]}'::jsonb,
    '{"en": ["Farmer family owning cultivable land in their name", "Institutional landholders and income-tax payers are excluded", "Aadhaar-seeded bank account with active e-KYC"], "hi": ["किसान परिवार जिसके नाम पर खेती योग्य भूमि दर्ज हो", "संस्थागत भूमिधारक और आयकर दाता अपात्र हैं", "सक्रिय ई-केवाईसी वाला आधार से जुड़ा बैंक खाता"]}'::jsonb,
    '["Aadhaar Card", "Land Ownership Documents (Khatauni / RoR / Patta)", "Aadhaar-linked Bank Account Passbook", "Active Mobile Number"]'::jsonb,
    '{"en": ["Go to pmkisan.gov.in and click on ''New Farmer Registration''.", "Enter Aadhaar number and select Rural or Urban Farmer Registration.", "Fill in land survey number, khata number, and bank account details.", "Submit the application and complete OTP-based e-KYC."], "hi": ["pmkisan.gov.in पर जाएं और ''New Farmer Registration'' पर क्लिक करें।", "आधार नंबर दर्ज करें और ग्रामीण या शहरी किसान पंजीकरण चुनें।", "जमीन का खसरा/खतौनी नंबर और बैंक विवरण भरें।", "आवेदन जमा करें और ओटीपी आधारित ई-केवाईसी पूरा करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-svanidhi',
    '{"en": "PM SVANidhi Scheme", "hi": "पीएम स्वनिधि योजना (स्ट्रीट वेंडर आत्मनिर्भर निधि)"}'::jsonb,
    '{"en": "Micro-credit collateral-free working capital loan up to ₹50,000 with 7% interest subsidy for street vendors.", "hi": "स्ट्रीट वेंडरों के लिए 7% ब्याज सब्सिडी के साथ ₹50,000 तक का संपार्श्विक-मुक्त कार्यशील पूंजी ऋण।"}'::jsonb,
    '{"en": "Ministry of Housing and Urban Affairs", "hi": "आवासन और शहरी कार्य मंत्रालय"}'::jsonb,
    'business',
    '{"en": "Subsidized Loan & Cashbacks", "hi": "सब्सिडी ऋण और कैशबैक"}'::jsonb,
    '{"en": "₹10,000 → ₹20,000 → ₹50,000 (Tranches)", "hi": "₹10,000 → ₹20,000 → ₹50,000 (चरणबद्ध)"}'::jsonb,
    'https://pmsvanidhi.mohua.gov.in',
    'PM SVANidhi Portal',
    '["Street Vendors", "Micro Loan", "Working Capital", "Urban"]'::jsonb,
    '{"minAge": 18, "maxAge": 70, "genders": ["all"], "occupations": ["street_vendor", "small_business"], "maxIncome": 300000, "categories": ["all"], "areas": ["urban", "peri_urban"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Urban street vendors / hawkers operating on or before March 2020 or having Vending Certificate", "Letter of Recommendation (LoR) from Urban Local Body (ULB) if certificate not available", "Prompt repayment qualifies for higher tranche loans and 7% interest subsidy"], "hi": ["शहरी रेहड़ी-पटरी विक्रेता जिनके पास वेंडिंग प्रमाणपत्र या ULB से अनुशंसा पत्र हो", "प्रमाणपत्र न होने पर नगर पालिका/नगर निगम से LoR प्राप्त किया जा सकता है", "समय पर भुगतान करने पर 7% ब्याज सब्सिडी और अगला बड़ा ऋण मिलता है"]}'::jsonb,
    '["Aadhaar Card", "Vending Certificate or ID Card issued by ULB / Municipality (or LoR)", "Bank Account details", "Mobile number linked to Aadhaar"]'::jsonb,
    '{"en": ["Check eligibility on pmsvanidhi.mohua.gov.in using Aadhaar number.", "Select your preferred Lending Institution / Bank.", "Upload identity proof and Vending ID / LoR.", "Track application and receive direct disbursal into your bank account."], "hi": ["pmsvanidhi.mohua.gov.in पर आधार नंबर से पात्रता जांचें।", "अपना पसंदीदा बैंक या ऋण संस्थान चुनें।", "पहचान प्रमाण और वेंडिंग प्रमाणपत्र/LoR अपलोड करें।", "आवेदन ट्रैक करें और सीधे खाते में राशि प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-awas-gramin',
    '{"en": "PMAY - Gramin (Housing for All)", "hi": "प्रधानमंत्री आवास योजना - ग्रामीण"}'::jsonb,
    '{"en": "Financial grant of ₹1.20 Lakh to ₹1.30 Lakh to construct a pucca house with hygienic cooking space in rural areas.", "hi": "ग्रामीण क्षेत्रों में पक्का मकान बनाने के लिए ₹1.20 लाख से ₹1.30 लाख की वित्तीय सहायता अनुदान।"}'::jsonb,
    '{"en": "Ministry of Rural Development", "hi": "ग्रामीण विकास मंत्रालय"}'::jsonb,
    'https://pmayg.dord.gov.in',
    'pmayg.dord.gov.in'::jsonb,
    '{"en": "₹1,20,000 (Plains) / ₹1,30,000 (Hilly/NE)", "hi": "₹1,20,000 (मैदानी) / ₹1,30,000 (पहाड़ी/पूर्वोत्तर)"}'::jsonb,
    'https://pmayg.nic.in',
    'PMAY-G AwaasSoft',
    '["Housing", "Rural", "Pucca Ghar", "Grant"]'::jsonb,
    '{"minAge": 18, "maxAge": 100, "genders": ["all"], "occupations": ["all"], "maxIncome": 200000, "categories": ["all"], "areas": ["rural"], "states": ["all"], "specialConditions": ["houseless_or_kutcha_house"]}'::jsonb,
    '{"en": ["Houseless families or living in kutcha/dilapidated houses in rural areas", "Identified under SECC 2011 and verified by Gram Sabha", "Additional 90-95 days unskilled labor wage support under MGNREGA + ₹12,000 for toilet under SBM"], "hi": ["ग्रामीण क्षेत्र के बेघर परिवार या कच्चे/जर्जर मकानों में रहने वाले", "SECC 2011 सूची में शामिल और ग्राम सभा द्वारा सत्यापित", "मनरेगा के तहत 90-95 दिन का अकुशल मजदूरी सहयोग + शौचालय हेतु ₹12,000 अतिरिक्त"]}'::jsonb,
    '["Aadhaar Card", "Bank Account details (Aadhaar linked)", "MGNREGA Job Card Number", "Affidavit that applicant does not own any pucca house anywhere in India"]'::jsonb,
    '{"en": ["Contact Gram Panchayat / Village Secretary to verify your name in the Awaas+ list.", "Block Development Officer (BDO) registers the beneficiary on AwaasSoft portal.", "Geo-tagging and site inspection of existing kutcha house is conducted.", "Funds are released in 3 milestone installments directly into the beneficiary''s bank account."], "hi": ["आवास+ सूची में नाम जांचने के लिए ग्राम पंचायत या ग्राम प्रधान/सचिव से संपर्क करें।", "खंड विकास अधिकारी (BDO) लाभार्थी को AwaasSoft पोर्टल पर पंजीकृत करता है।", "कच्चे मकान का जियो-टैगिंग और स्थल निरीक्षण किया जाता है।", "निर्माण के 3 चरणों में राशि सीधे बैंक खाते में भेजी जाती है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'post-matric-sc-st',
    '{"en": "Post-Matric Scholarship for SC/ST Students", "hi": "अनुसूचित जाति/जनजाति पोस्ट-मैट्रिक छात्रवृत्ति"}'::jsonb,
    '{"en": "Full non-refundable tuition fee waiver plus monthly maintenance allowance for Class 11 through post-doctoral studies.", "hi": "कक्षा 11 से लेकर पीएचडी तक पूरी शिक्षण फीस माफी और मासिक निर्वाह भत्ता।"}'::jsonb,
    '{"en": "Ministry of Social Justice and Empowerment", "hi": "सामाजिक न्याय और अधिकारिता मंत्रालय"}'::jsonb,
    'education',
    '{"en": "Scholarship & Fee Waiver", "hi": "छात्रवृत्ति एवं फीस माफी"}'::jsonb,
    '{"en": "100% Tuition Fees + Up to ₹13,500/year allowance", "hi": "100% ट्यूशन फीस + ₹13,500/वर्ष तक भत्ता"}'::jsonb,
    'https://scholarships.gov.in',
    'National Scholarship Portal (NSP)',
    '["Students", "SC/ST", "Scholarship", "College"]'::jsonb,
    '{"minAge": 15, "maxAge": 35, "genders": ["all"], "occupations": ["student"], "maxIncome": 250000, "categories": ["sc", "st"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Belong to Scheduled Caste (SC) or Scheduled Tribe (ST) category", "Pursuing post-matriculation or post-secondary courses in recognized institutions", "Total annual household income from all sources does not exceed ₹2,50,000"], "hi": ["अनुसूचित जाति (SC) या अनुसूचित जनजाति (ST) वर्ग से संबंधित हों", "मान्यता प्राप्त संस्थान में 11वीं, 12वीं, कॉलेज, तकनीकी या उच्च शिक्षा ले रहे हों", "परिवार की कुल वार्षिक आय ₹2,50,000 से अधिक न हो"]}'::jsonb,
    '["Aadhaar Card", "Caste Certificate issued by competent authority (Tahsildar/SDM)", "Income Certificate (current financial year)", "Previous Class Marksheet / Passing Certificate", "Fee Receipt & Bonafide Student Certificate from College/Institute", "Aadhaar-seeded Bank Passbook"]'::jsonb,
    '{"en": ["Register on the National Scholarship Portal (scholarships.gov.in) with Aadhaar OTR.", "Fill academic details, choose ''Post-Matric SC/ST Scholarship'', and upload certificates.", "Your institute verifies the application at Level 1 (Nodal Officer).", "State department verifies at Level 2 and scholarship is credited via DBT."], "hi": ["नेशनल स्कॉलरशिप पोर्टल (scholarships.gov.in) पर आधार OTR से पंजीकरण करें।", "शैक्षणिक विवरण भरें, ''पोस्ट-मैट्रिक SC/ST'' चुनें और दस्तावेज अपलोड करें।", "आपका कॉलेज/संस्थान स्तर-1 पर सत्यापन करता है।", "राज्य कल्याण विभाग स्तर-2 पर सत्यापन कर डीबीटी से छात्रवृत्ति भेजता है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'post-matric-obc',
    '{"en": "Post-Matric Scholarship for OBC & EBC Students", "hi": "ओबीसी एवं ईबीसी छात्रों हेतु पोस्ट-मैट्रिक छात्रवृत्ति"}'::jsonb,
    '{"en": "Financial assistance covering mandatory course fees and maintenance stipend for OBC and Economically Backward Class students.", "hi": "अन्य पिछड़ा वर्ग और आर्थिक रूप से पिछड़े वर्ग के छात्रों के लिए अनिवार्य कोर्स फीस और निर्वाह भत्ता सहायता।"}'::jsonb,
    '{"en": "Ministry of Social Justice and Empowerment", "hi": "सामाजिक न्याय और अधिकारिता मंत्रालय"}'::jsonb,
    'education',
    '{"en": "Scholarship & Maintenance", "hi": "छात्रवृत्ति एवं भत्ता"}'::jsonb,
    '{"en": "Course Fee reimbursement + Up to ₹10,000/year stipend", "hi": "कोर्स फीस प्रतिपूर्ति + ₹10,000/वर्ष तक वजीफा"}'::jsonb,
    'https://scholarships.gov.in',
    'National Scholarship Portal (NSP)',
    '["Students", "OBC", "EBC", "College"]'::jsonb,
    '{"minAge": 15, "maxAge": 35, "genders": ["all"], "occupations": ["student"], "maxIncome": 250000, "categories": ["obc"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Belong to Other Backward Classes (OBC) or Economically Backward Classes (EBC)", "Enrolled in recognized post-secondary, degree, diploma, or professional course", "Annual household income limit ≤ ₹2,50,000"], "hi": ["अन्य पिछड़ा वर्ग (OBC) या आर्थिक रूप से पिछड़े वर्ग (EBC) से संबंधित हों", "मान्यता प्राप्त संस्थान में डिग्री, डिप्लोमा या व्यावसायिक कोर्स में नामांकित हों", "परिवार की वार्षिक आय सीमा ₹2,50,000 या उससे कम हो"]}'::jsonb,
    '["Aadhaar Card", "OBC / Non-Creamy Layer Certificate", "Income Certificate (latest)", "Admission Receipt & Bonafide Certificate", "Previous Year Marksheets", "Bank Account details"]'::jsonb,
    '{"en": ["Register on NSP (scholarships.gov.in) with Aadhaar One-Time Registration.", "Select Central/State OBC Post-Matric scheme.", "Submit college admission verification details.", "Track through portal until DBT payment approval."], "hi": ["NSP पोर्टल पर वन-टाइम रजिस्ट्रेशन (OTR) करें।", "ओबीसी पोस्ट-मैट्रिक छात्रवृत्ति योजना का चयन करें।", "संस्थान सत्यापन विवरण और दस्तावेज जमा करें।", "स्वीकृति के बाद राशि सीधे बैंक खाते में प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'sukanya-samriddhi',
    '{"en": "Sukanya Samriddhi Yojana (SSY)", "hi": "सुकन्या समृद्धि योजना"}'::jsonb,
    '{"en": "High-interest government savings scheme (8.2% p.a.) with full tax exemption for a girl child''s future education and marriage.", "hi": "बालिकाओं के उज्ज्वल भविष्य और शिक्षा हेतु 8.2% ब्याज दर और कर-मुक्त सरकारी बचत योजना।"}'::jsonb,
    '{"en": "Ministry of Finance", "hi": "वित्त मंत्रालय"}'::jsonb,
    'women',
    '{"en": "High-Yield Guaranteed Savings", "hi": "उच्च ब्याज सरकारी बचत"}'::jsonb,
    '{"en": "8.2% Compounded Annual Interest + Triple Tax Exemption", "hi": "8.2% चक्रवृद्धि वार्षिक ब्याज + पूर्ण कर छूट (EEE)"}'::jsonb,
    'https://www.indiapost.gov.in',
    'India Post & Authorized Banks',
    '["Girl Child", "Savings", "Tax Free", "Beti Bachao"]'::jsonb,
    '{"minAge": 0, "maxAge": 10, "genders": ["female"], "occupations": ["all"], "maxIncome": 10000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["has_girl_child"]}'::jsonb,
    '{"en": ["Account opened by parents/guardians for a girl child aged 10 or below", "Maximum of two accounts per family (allowed for twins/triplets)", "Minimum deposit ₹250/year up to maximum ₹1,50,000/year"], "hi": ["10 वर्ष या उससे कम उम्र की बालिका के नाम पर माता-पिता/अभिभावक द्वारा खाता", "एक परिवार में अधिकतम दो बालिकाओं के लिए खाता मान्य", "न्यूनतम जमा ₹250 प्रति वर्ष से अधिकतम ₹1,50,000 प्रति वर्ष"]}'::jsonb,
    '["Girl Child''s Birth Certificate", "Parents'' / Guardian''s Aadhaar Card & PAN Card", "Proof of Residence (Electricity bill / Ration card / Aadhaar)", "Passport size photos of child and guardian"]'::jsonb,
    '{"en": ["Collect the SSY account opening form from any Post Office or commercial bank (SBI, PNB, BoB, etc.).", "Fill child details and attach birth certificate and guardian KYC.", "Make initial deposit (minimum ₹250) in cash or cheque.", "Receive the physical passbook to track ongoing contributions and annual interest accrual."], "hi": ["किसी भी डाकघर (Post Office) या अधिकृत बैंक से SSY फॉर्म प्राप्त करें।", "बालिका का विवरण भरें, जन्म प्रमाणपत्र और अभिभावक के KYC संलग्न करें।", "न्यूनतम ₹250 की प्रारंभिक राशि जमा करें।", "खाते की पासबुक प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-vishwakarma',
    '{"en": "PM Vishwakarma Scheme", "hi": "प्रधानमंत्री विश्वकर्मा योजना"}'::jsonb,
    '{"en": "Comprehensive support for 18 traditional artisanal trades: ₹15,000 toolkit e-voucher, subsidized loans up to ₹3 Lakh at 5%, and daily stipend.", "hi": "18 पारंपरिक कारीगर व्यवसायों के लिए: ₹15,000 टूलकिट अनुदान, 5% पर ₹3 लाख तक का ऋण और ₹500/दिन प्रशिक्षण स्टाइपेंड।"}'::jsonb,
    '{"en": "Ministry of Micro, Small and Medium Enterprises", "hi": "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय"}'::jsonb,
    'business',
    '{"en": "Toolkit Grant + 5% Collateral-Free Loan", "hi": "टूलकिट अनुदान + 5% ब्याज पर आसान ऋण"}'::jsonb,
    '{"en": "₹15,000 Toolkit + Loan up to ₹3,00,000 + ₹500/day stipend", "hi": "₹15,000 टूलकिट + ₹3,00,000 तक ऋण + ₹500/दिन भत्ता"}'::jsonb,
    'https://pmvishwakarma.gov.in',
    'PM Vishwakarma Portal',
    '["Artisans", "Craftsmen", "Carpenters", "Tailors", "Blacksmiths", "Toolkits"]'::jsonb,
    '{"minAge": 18, "maxAge": 75, "genders": ["all"], "occupations": ["artisan", "small_business"], "maxIncome": 500000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Working in one of the 18 traditional artisanal trades (Carpenter, Blacksmith, Potter, Sculptor, Cobbler, Tailor, Barber, Washerman, etc.)", "Minimum age 18 years, hands-on family craft practitioner", "Beneficiary has not availed credit under PMEGP or Mudra for same business in last 5 years"], "hi": ["18 पारंपरिक दस्तकारी व्यवसायों (बढ़ई, लोहार, कुम्हार, मोची, दर्जी, नाई, धोबी आदि) में कार्यरत कारीगर", "न्यूनतम आयु 18 वर्ष, हाथों और पारंपरिक औजारों से काम करने वाले", "गत 5 वर्षों में समान व्यवसाय हेतु PMEGP या मुद्रा का बकाया ऋण न हो"]}'::jsonb,
    '["Aadhaar Card", "Mobile number linked to Aadhaar", "Bank Account details", "Ration Card / Family details", "Trade Proof (skill verification by local panchayat / ULB)"]'::jsonb,
    '{"en": ["Visit nearest CSC (Common Service Center) with Aadhaar and bank details.", "Complete biometric authentication and register trade under PM Vishwakarma.", "Gram Panchayat / Urban Local Body conducts field verification.", "Receive Vishwakarma Certificate & ID Card, complete 5-7 days basic training (₹500/day stipend), receive ₹15,000 toolkit voucher."], "hi": ["आधार और बैंक विवरण लेकर नजदीकी जन सेवा केंद्र (CSC) पर जाएं।", "बायोमेट्रिक सत्यापन करवाकर अपने पारंपरिक व्यवसाय का चयन करें।", "ग्राम पंचायत या नगर पालिका द्वारा सत्यापन किया जाएगा।", "विश्वकर्मा आईडी कार्ड प्राप्त करें, 5-7 दिवसीय प्रशिक्षण लें और ₹15,000 टूलकिट ई-वाउचर पाएं।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'atal-pension',
    '{"en": "Atal Pension Yojana (APY)", "hi": "अटल पेंशन योजना"}'::jsonb,
    '{"en": "Government-backed guaranteed monthly pension of ₹1,000 to ₹5,000 starting from age 60 for unorganized workers.", "hi": "असंगठित क्षेत्र के कामगारों के लिए 60 वर्ष की आयु से ₹1,000 से ₹5,000 तक की गारंटीकृत मासिक पेंशन।"}'::jsonb,
    '{"en": "Ministry of Finance", "hi": "वित्त मंत्रालय"}'::jsonb,
    'https://www.jansuraksha.gov.in',
    'jansuraksha.gov.in'::jsonb,
    '{"en": "₹1,000 to ₹5,000 / month for life", "hi": "₹1,000 से ₹5,000 / माह आजीवन"}'::jsonb,
    'https://www.npscra.nsdl.co.in',
    'PFRDA / Protean APY Portal',
    '["Pension", "Unorganized Sector", "Retirement", "Guaranteed"]'::jsonb,
    '{"minAge": 18, "maxAge": 40, "genders": ["all"], "occupations": ["unemployed", "daily_wage", "farmer", "street_vendor", "artisan", "small_business"], "maxIncome": 500000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["not_income_tax_payer"]}'::jsonb,
    '{"en": ["Indian citizen aged between 18 and 40 years", "Have a savings bank account or post office savings account", "Must not be an income-tax payer (effective Oct 2022)"], "hi": ["18 से 40 वर्ष की आयु का कोई भी भारतीय नागरिक", "बचत बैंक खाता या डाकघर बचत खाता होना अनिवार्य", "आयकर दाता नहीं होना चाहिए"]}'::jsonb,
    '["Aadhaar Card", "Savings Bank Account Passbook", "Active Mobile Number", "Nominee details (Aadhaar & relationship)"]'::jsonb,
    '{"en": ["Visit your bank branch or log in to your mobile/internet banking app.", "Fill the APY registration form and choose desired pension slab (₹1,000 - ₹5,000).", "Set auto-debit frequency (monthly, quarterly, or half-yearly).", "Receive PRAN (Permanent Retirement Account Number) card confirmation via SMS."], "hi": ["अपनी बैंक शाखा में जाएं या मोबाइल/इंटरनेट बैंकिंग में लॉगिन करें।", "APY फॉर्म भरें और अपनी पसंद की पेंशन राशि (₹1,000 - ₹5,000) चुनें।", "ऑटो-डेबिट की अनुमति दें (मासिक या त्रैमासिक कटौती)।", "एसएमएस के माध्यम से अपना प्रान (PRAN) कार्ड नंबर प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-mudra',
    '{"en": "PM Mudra Yojana (PMMY)", "hi": "प्रधानमंत्री मुद्रा योजना"}'::jsonb,
    '{"en": "Collateral-free business loans up to ₹10 Lakh (Shishu up to ₹50k, Kishore up to ₹5L, Tarun up to ₹10L) for micro-enterprises.", "hi": "सूक्ष्म उद्यमों के लिए ₹10 लाख तक का संपार्श्विक-मुक्त व्यापार ऋण (शिशु, किशोर और तरुण श्रेणियां)।"}'::jsonb,
    '{"en": "Ministry of Finance", "hi": "वित्त मंत्रालय"}'::jsonb,
    'business',
    '{"en": "Collateral-Free Business Credit", "hi": "बिना गारंटी व्यवसाय ऋण"}'::jsonb,
    '{"en": "Shishu: ₹50K | Kishore: ₹5L | Tarun: ₹10L", "hi": "शिशु: ₹50 हजार | किशोर: ₹5 लाख | तरुण: ₹10 लाख"}'::jsonb,
    'https://www.mudra.org.in',
    'Udyamimitra / MUDRA',
    '["Business Loan", "Startup", "Shopkeeper", "MSME"]'::jsonb,
    '{"minAge": 18, "maxAge": 65, "genders": ["all"], "occupations": ["small_business", "street_vendor", "artisan", "unemployed"], "maxIncome": 2000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Non-corporate, non-farm small/micro enterprises engaged in manufacturing, trading, or service activities", "Applicants should not be defaulters to any bank or financial institution", "No collateral or third-party guarantee required"], "hi": ["विनिर्माण, व्यापार या सेवा क्षेत्र से जुड़े गैर-कॉर्पोरेट और गैर-कृषि लघु उद्यमी", "आवेदक किसी भी बैंक का डिफ़ॉल्टर नहीं होना चाहिए", "किसी भी प्रकार की जमानत या संपत्ति गिरवी रखने की आवश्यकता नहीं"]}'::jsonb,
    '["Aadhaar Card & PAN Card", "Proof of Business Address / Udyam Registration (for Kishore/Tarun)", "Bank Account statement for past 6 months", "Quotation / Machinery estimates or project report for new ventures"]'::jsonb,
    '{"en": ["Apply online via udyamimitra.in or visit any commercial bank/RRB/MFI.", "Choose loan category: Shishu (up to ₹50,000) or Kishore/Tarun.", "Submit project quotation and business details.", "Bank sanctions loan and issues a Mudra RuPay debit card for working capital withdrawals."], "hi": ["udyamimitra.in पर ऑनलाइन आवेदन करें या किसी भी बैंक शाखा में संपर्क करें।", "ऋण श्रेणी चुनें: शिशु (₹50,000 तक), किशोर या तरुण।", "दुकान/व्यवसाय का कोटेशन और योजना रिपोर्ट प्रस्तुत करें।", "ऋण स्वीकृति के बाद कार्यशील पूंजी निकासी हेतु मुद्रा रुपे कार्ड प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-matru-vandana',
    '{"en": "Pradhan Mantri Matru Vandana Yojana (PMMVY)", "hi": "प्रधानमंत्री मातृ वंदना योजना"}'::jsonb,
    '{"en": "Maternity financial assistance of ₹5,000 for the first child and ₹6,000 for second child (if girl) for wage compensation and nutrition.", "hi": "पहले बच्चे के जन्म पर ₹5,000 और दूसरी कन्या संतान पर ₹6,000 की मातृत्व पोषण आर्थिक सहायता।"}'::jsonb,
    '{"en": "Ministry of Women and Child Development", "hi": "महिला एवं बाल विकास मंत्रालय"}'::jsonb,
    'women',
    '{"en": "Direct Cash Incentive", "hi": "प्रत्यक्ष नकद पोषण प्रोत्साहन"}'::jsonb,
    '{"en": "₹5,000 (1st child) / ₹6,000 (2nd girl child)", "hi": "₹5,000 (पहला बच्चा) / ₹6,000 (दूसरी बालिका)"}'::jsonb,
    'https://pmmvy.wcd.gov.in',
    'PMMVY Citizen Portal',
    '["Maternity", "Nutrition", "Pregnant Women", "DBT"]'::jsonb,
    '{"minAge": 19, "maxAge": 45, "genders": ["female"], "occupations": ["all"], "maxIncome": 800000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["pregnant_or_lactating"]}'::jsonb,
    '{"en": ["Pregnant women and lactating mothers for first living child or second girl child", "Excludes regular central/state government employees with paid maternity leave", "Household income under ₹8 Lakh or holder of E-Shram / Ration Card / MGNREGA Job Card"], "hi": ["पहले जीवित बच्चे या दूसरी कन्या संतान के लिए गर्भवती और स्तनपान कराने वाली माताएं", "नियमित सरकारी कर्मचारी जिन्हें सवेतन मातृत्व अवकाश मिलता है, वे अपात्र हैं", "पारिवारिक आय ₹8 लाख से कम या ई-श्रम / राशन कार्ड / मनरेगा जॉब कार्ड धारक"]}'::jsonb,
    '["Mother''s and Husband''s Aadhaar Card", "Mother and Child Protection (MCP) Card from Anganwadi / Health Centre", "Aadhaar-seeded Bank Account Passbook in Mother''s name", "Child Birth Certificate (for 2nd installment)"]'::jsonb,
    '{"en": ["Register pregnancy at nearest Anganwadi Centre (AWC) or Govt Health Centre within 570 days of LMP.", "Apply online via pmmvy.wcd.gov.in or through the Anganwadi Worker (ASHA).", "Receive first installment after ANC checkup and second installment post child immunization.", "Amount credited directly to the mother''s DBT-enabled bank account."], "hi": ["नजदीकी आंगनवाड़ी केंद्र (AWC) में गर्भावस्था का पंजीकरण कराएं और MCP कार्ड बनवाएं।", "pmmvy.wcd.gov.in पर ऑनलाइन आवेदन करें या आशा कार्यकर्ता की सहायता लें।", "प्रसव पूर्व जांच (ANC) और बच्चे के टीकाकरण के चरणों में राशि सीधे बैंक खाते में जमा होती है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-ujjwala',
    '{"en": "Pradhan Mantri Ujjwala Yojana (PMUY 2.0)", "hi": "प्रधानमंत्री उज्ज्वला योजना 2.0"}'::jsonb,
    '{"en": "Free LPG gas connection with deposit-free cylinder, pressure regulator, and free first refill with hotplate stove for women.", "hi": "गरीब परिवारों की महिलाओं को मुफ्त एलपीजी गैस कनेक्शन, पहला सिलेंडर रिफिल एवं चूल्हा मुफ्त।"}'::jsonb,
    '{"en": "Ministry of Petroleum and Natural Gas", "hi": "पेट्रोलियम एवं प्राकृतिक गैस मंत्रालय"}'::jsonb,
    'women',
    '{"en": "Free LPG Connection & Stove", "hi": "मुफ्त गैस कनेक्शन व चूल्हा"}'::jsonb,
    '{"en": "Deposit-free Connection + Free Stove & 1st Refill (~₹3,200)", "hi": "मुफ्त कनेक्शन + पहला रिफिल व गैस चूल्हा मुफ्त (~₹3,200 मूल्य)"}'::jsonb,
    'https://www.pmuy.gov.in',
    'PMUY Official Portal',
    '["Clean Cooking", "LPG", "Women Empowerment", "BPL"]'::jsonb,
    '{"minAge": 18, "maxAge": 90, "genders": ["female"], "occupations": ["all"], "maxIncome": 250000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["bpl_or_low_income"]}'::jsonb,
    '{"en": ["Adult woman belonging to poor household not having any existing LPG connection", "Belong to SC/ST, PMAY beneficiary, Antyodaya Anna Yojana, Forest Dwellers, MBC, or low-income declared household", "Migration proof self-declaration accepted under Ujjwala 2.0 without local address proof"], "hi": ["गरीब परिवार की वयस्क महिला जिसके घर में पहले से कोई एलपीजी कनेक्शन न हो", "SC/ST, अंत्योदय, पीएम आवास लाभार्थी या कम आय श्रेणी के परिवार", "उज्ज्वला 2.0 के तहत प्रवासी कामगारों के लिए स्व-घोषणा पत्र मान्य"]}'::jsonb,
    '["Aadhaar Card of Applicant & all adult family members", "Ration Card or Family Composition proof", "Bank Account details (Aadhaar linked)", "Address Proof (or self-declaration for migrant workers)"]'::jsonb,
    '{"en": ["Apply online at pmuy.gov.in or visit nearest LPG distributor (Indane, Bharatgas, HP Gas).", "Submit filled Ujjwala application with family Aadhaar details.", "OMC verifies de-duplication across all gas agencies.", "Collect free LPG connection, stove, and cylinder from distributor."], "hi": ["pmuy.gov.in पर ऑनलाइन आवेदन करें या नजदीकी गैस एजेंसी (इंडेन/एचपी/भारत गैस) पर जाएं।", "परिवार के आधार कार्ड और राशन कार्ड की प्रति संलग्न करें।", "एजेंसी सत्यापन के बाद मुफ्त गैस कनेक्शन और चूल्हा प्रदान करेगी।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-fasal-bima',
    '{"en": "PM Fasal Bima Yojana (PMFBY)", "hi": "प्रधानमंत्री फसल बीमा योजना"}'::jsonb,
    '{"en": "Comprehensive crop insurance shielding farmers against non-preventable natural calamities with very low farmer premium (1.5% - 2%).", "hi": "प्राकृतिक आपदाओं से फसल नुकसान पर किसानों को व्यापक बीमा सुरक्षा, मात्र 1.5% - 2% प्रीमियम पर।"}'::jsonb,
    '{"en": "Ministry of Agriculture and Farmers Welfare", "hi": "कृषि एवं किसान कल्याण मंत्रालय"}'::jsonb,
    'agriculture',
    '{"en": "Crop Damage Compensation", "hi": "फसल नुकसान क्षतिपूर्ति"}'::jsonb,
    '{"en": "Up to 100% of Sum Insured based on crop yield loss", "hi": "फसल नुकसान के आधार पर बीमित राशि का 100% तक मुआवजा"}'::jsonb,
    'https://pmfby.gov.in',
    'National Crop Insurance Portal',
    '["Crop Insurance", "Drought", "Flood", "Farmers"]'::jsonb,
    '{"minAge": 18, "maxAge": 90, "genders": ["all"], "occupations": ["farmer"], "maxIncome": 2000000, "categories": ["all"], "areas": ["rural"], "states": ["all"], "specialConditions": ["owns_cultivable_land"]}'::jsonb,
    '{"en": ["All farmers including sharecroppers and tenant farmers growing notified crops in notified areas", "Covers pre-sowing to post-harvest losses due to drought, floods, pests, landslides, and unseasonal rains", "Farmer pays only 1.5% for Rabi, 2% for Kharif, 5% for commercial/horticultural crops"], "hi": ["अधिसूचित क्षेत्रों में अधिसूचित फसल उगाने वाले सभी भू-स्वामी, बटाईदार और काश्तकार किसान", "बुवाई से लेकर कटाई के बाद तक सूखा, बाढ़, ओलावृष्टि और कीट हमलों से सुरक्षा", "किसान को रबी हेतु केवल 1.5%, खरीफ हेतु 2% और बागवानी हेतु 5% प्रीमियम देना होता है"]}'::jsonb,
    '["Aadhaar Card", "Land Record Documents (RoR / Khasra / Khatoni) or Tenancy agreement", "Sowing Certificate issued by Patwari / Village Agriculture Officer", "Bank Passbook copy"]'::jsonb,
    '{"en": ["Apply on pmfby.gov.in or through nearest CSC center or your bank before cutoff date.", "Enter land details and crop sown.", "Pay nominal farmer share of premium.", "In case of localized disaster, report within 72 hours via Crop Insurance App or toll-free 14447."], "hi": ["कट-ऑफ तिथि से पूर्व pmfby.gov.in, सीएससी या बैंक शाखा में आवेदन करें।", "जमीन का खसरा नंबर और बोई गई फसल का ब्योरा दर्ज करें।", "न्यूनतम प्रीमियम राशि का भुगतान करें।", "आपदा की स्थिति में 72 घंटे के अंदर ''Crop Insurance'' ऐप पर नुकसान दर्ज करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'nmms-scholarship',
    '{"en": "National Means-cum-Merit Scholarship (NMMSS)", "hi": "राष्ट्रीय साधन-सह-योग्यता छात्रवृत्ति योजना"}'::jsonb,
    '{"en": "₹12,000 per annum scholarship from Class 9 to Class 12 to prevent secondary school dropouts among meritorious poor students.", "hi": "कक्षा 9 से 12 तक ₹12,000 प्रति वर्ष छात्रवृत्ति, ताकि आर्थिक तंगी से होनहार छात्र पढ़ाई न छोड़ें।"}'::jsonb,
    '{"en": "Ministry of Education", "hi": "शिक्षा मंत्रालय"}'::jsonb,
    'education',
    '{"en": "Annual Student Grant", "hi": "वार्षिक छात्रवृत्ति अनुदान"}'::jsonb,
    '{"en": "₹12,000 / year (₹1,000 / month)", "hi": "₹12,000 / वर्ष (₹1,000 / माह)"}'::jsonb,
    'https://scholarships.gov.in',
    'National Scholarship Portal (NSP)',
    '["Merit", "School Students", "Class 9-12", "Scholarship"]'::jsonb,
    '{"minAge": 12, "maxAge": 18, "genders": ["all"], "occupations": ["student"], "maxIncome": 350000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Studying in Government, Local Body, or Govt-aided school with at least 55% marks in Class 7/8", "Parental annual income from all sources does not exceed ₹3,50,000", "Must qualify the State Selection Examination conducted by SCERT/State Education Board"], "hi": ["सरकारी या सहायता प्राप्त स्कूल में अध्ययनरत और कक्षा 7/8 में न्यूनतम 55% अंक प्राप्त", "माता-पिता की सभी स्रोतों से वार्षिक आय ₹3,50,000 से कम हो", "राज्य शिक्षा बोर्ड/SCERT द्वारा आयोजित NMMSS परीक्षा उत्तीर्ण की हो"]}'::jsonb,
    '["Aadhaar Card of Student", "Class 7th / 8th Marksheet", "Parental Income Certificate", "Caste / Category Certificate (if SC/ST/OBC)", "Bank Account details of the student (joint account with parent or individual)"]'::jsonb,
    '{"en": ["Appear for the NMMSS written exam conducted by your State Education Board in Class 8.", "Upon qualifying the merit list, register on scholarships.gov.in.", "Upload marksheet and income certificate for institute verification.", "Receive ₹12,000 annual scholarship directly into the bank account till Class 12."], "hi": ["कक्षा 8 में अपने राज्य द्वारा आयोजित NMMSS छात्रवृत्ति परीक्षा में बैठें।", "मेरिट लिस्ट में चयन के बाद scholarships.gov.in पर पंजीकरण करें।", "स्कूल से सत्यापन करवाएं।", "कक्षा 9 से 12 तक प्रतिवर्ष ₹12,000 सीधे बैंक खाते में प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'standup-india',
    '{"en": "Stand-Up India Scheme", "hi": "स्टैंड-अप इंडिया योजना"}'::jsonb,
    '{"en": "Bank financing between ₹10 Lakh and ₹1 Crore to at least one SC/ST and one Woman borrower per bank branch for greenfield enterprises.", "hi": "प्रति बैंक शाखा कम से कम एक SC/ST और एक महिला उद्यमी को नए उद्यम हेतु ₹10 लाख से ₹1 करोड़ का ऋण।"}'::jsonb,
    '{"en": "Ministry of Finance", "hi": "वित्त मंत्रालय"}'::jsonb,
    'business',
    '{"en": "Enterprise Project Loan", "hi": "बड़ा उद्यम परियोजना ऋण"}'::jsonb,
    '{"en": "₹10 Lakh to ₹1 Crore Composite Loan", "hi": "₹10 लाख से ₹1 करोड़ तक कम्पोजिट लोन"}'::jsonb,
    'https://www.standupmitra.in',
    'Stand-Up Mitra Portal',
    '["Women Entrepreneur", "SC/ST", "Manufacturing", "Big Loan"]'::jsonb,
    '{"minAge": 18, "maxAge": 70, "genders": ["all"], "occupations": ["small_business", "unemployed", "salaried"], "maxIncome": 10000000, "categories": ["sc", "st"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["SC/ST and/or Woman entrepreneur setting up a greenfield enterprise (first-time venture)", "Enterprise in manufacturing, services, trading sector, or agri-allied activities", "In non-individual enterprises, at least 51% shareholding must be held by SC/ST or woman"], "hi": ["अनुसूचित जाति/जनजाति और/या महिला उद्यमी द्वारा स्थापित किया जाने वाला नया (ग्रीनफील्ड) व्यवसाय", "विनिर्माण, सेवा, व्यापार या कृषि-संबद्ध क्षेत्रों में उद्यम", "कंपनी या फर्म होने पर कम से कम 51% हिस्सेदारी SC/ST या महिला की होनी चाहिए"]}'::jsonb,
    '["Aadhaar Card, PAN Card, and Caste Certificate (for SC/ST)", "Detailed Project Report (DPR) showing business model and cash flows", "Proof of Registered Office / Premises lease", "Bank Account statements and promoters'' contribution proof (min 15%)"]'::jsonb,
    '{"en": ["Register on standupmitra.in and fill online loan application.", "Portal matches request with designated bank branch and handholding agencies (SIDBI/NABARD).", "Bank assesses project feasibility and sanctions composite term loan and working capital.", "Disbursement linked to asset creation and business milestones."], "hi": ["standupmitra.in पर पंजीकरण करें और ऑनलाइन ऋण आवेदन भरें।", "पोर्टल आपके आवेदन को नजदीकी बैंक शाखा और मार्गदर्शन एजेंसी से जोड़ता है।", "बैंक परियोजना रिपोर्ट की जांच कर टर्म लोन और कार्यशील पूंजी स्वीकृत करता है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pmsby-insurance',
    '{"en": "Pradhan Mantri Suraksha Bima Yojana (PMSBY)", "hi": "प्रधानमंत्री सुरक्षा बीमा योजना"}'::jsonb,
    '{"en": "Ultra-affordable accidental death and disability insurance cover of ₹2 Lakh for an annual premium of just ₹20.", "hi": "मात्र ₹20 वार्षिक प्रीमियम पर ₹2 लाख का आकस्मिक मृत्यु और पूर्ण दिव्यांगता बीमा कवर।"}'::jsonb,
    '{"en": "Ministry of Finance", "hi": "वित्त मंत्रालय"}'::jsonb,
    'social_security',
    '{"en": "Accident Insurance Cover", "hi": "दुर्घटना बीमा कवर"}'::jsonb,
    '{"en": "₹2,00,000 (Death/Full Disability) / ₹1,00,000 (Partial)", "hi": "₹2,00,000 (मृत्यु/स्थायी अपंगता) / ₹1,00,000 (आंशिक)"}'::jsonb,
    'https://www.jansuraksha.gov.in',
    'Jan Suraksha Portal',
    '["Accident Insurance", "Micro Insurance", "Affordable", "Protection"]'::jsonb,
    '{"minAge": 18, "maxAge": 70, "genders": ["all"], "occupations": ["all"], "maxIncome": 10000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Any Indian citizen aged between 18 and 70 years", "Must have an active savings bank account or post office savings account", "Give auto-debit consent for ₹20 per annum"], "hi": ["18 से 70 वर्ष की आयु का कोई भी भारतीय नागरिक", "बचत बैंक खाता या डाकघर खाता होना आवश्यक", "मात्र ₹20 प्रति वर्ष की ऑटो-डेबिट सहमति"]}'::jsonb,
    '["Aadhaar Card", "Savings Bank Account Passbook", "Nominee Details (Name, relationship, Aadhaar)"]'::jsonb,
    '{"en": ["Enable PMSBY instantly via your mobile banking app or SMS.", "Alternatively, visit your bank branch and submit simple one-page PMSBY enrollment form.", "₹20 is auto-debited annually in May.", "Acknowledgment receipt issued with policy number."], "hi": ["अपने बैंक के मोबाइल ऐप या नेट बैंकिंग से 1-क्लिक में सक्रिय करें।", "या बैंक शाखा में एक साधारण फॉर्म भरकर जमा करें।", "प्रतिवर्ष मई माह में ₹20 स्वतः बैंक खाते से कट जाते हैं और पॉलिसी जारी रहती है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pmjjby-insurance',
    '{"en": "Pradhan Mantri Jeevan Jyoti Bima Yojana (PMJJBY)", "hi": "प्रधानमंत्री जीवन ज्योति बीमा योजना"}'::jsonb,
    '{"en": "Guaranteed life insurance cover of ₹2 Lakh for death due to any cause at a nominal annual premium of ₹436.", "hi": "किसी भी कारण से मृत्यु होने पर परिवार को ₹2 लाख का जीवन बीमा कवर, मात्र ₹436 वार्षिक प्रीमियम पर।"}'::jsonb,
    '{"en": "Ministry of Finance", "hi": "वित्त मंत्रालय"}'::jsonb,
    'social_security',
    '{"en": "Term Life Insurance", "hi": "टर्म जीवन बीमा"}'::jsonb,
    '{"en": "₹2,00,000 on death due to any reason", "hi": "किसी भी कारण से मृत्यु पर ₹2,00,000"}'::jsonb,
    'https://www.jansuraksha.gov.in',
    'Jan Suraksha Portal',
    '["Life Insurance", "Term Plan", "Jan Suraksha", "Family Protection"]'::jsonb,
    '{"minAge": 18, "maxAge": 50, "genders": ["all"], "occupations": ["all"], "maxIncome": 10000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Individuals aged between 18 and 50 years with a bank/post office account", "Covers death due to any reason (illness, natural, accident)", "Risk cover remains active up to age 55 subject to annual renewal"], "hi": ["18 से 50 वर्ष की आयु के बैंक या डाकघर खाताधारक नागरिक", "किसी भी कारण (बीमारी, प्राकृतिक या दुर्घटना) से हुई मृत्यु पर कवर मान्य", "वार्षिक नवीनीकरण के साथ 55 वर्ष की आयु तक सुरक्षा उपलब्ध"]}'::jsonb,
    '["Aadhaar Card", "Savings Bank Account Passbook", "Nominee Details & Declaration of Good Health"]'::jsonb,
    '{"en": ["Activate through mobile banking, internet banking, or visiting bank branch.", "Authorize auto-debit of ₹436 from savings account.", "Policy certificate generated instantly."], "hi": ["मोबाइल बैंकिंग या बैंक शाखा में जाकर PMJJBY फॉर्म भरें।", "₹436 के वार्षिक ऑटो-डेबिट की स्वीकृति दें।", "बीमा प्रमाणपत्र तुरंत जारी हो जाता है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'old-age-pension-ignoaps',
    '{"en": "Indira Gandhi National Old Age Pension (IGNOAPS)", "hi": "इंदिरा गांधी राष्ट्रीय वृद्धावस्था पेंशन योजना"}'::jsonb,
    '{"en": "Monthly pension support for senior citizens aged 60 and above living below poverty line, supplemented by state governments.", "hi": "गरीबी रेखा से नीचे जीवनयापन करने वाले 60 वर्ष या उससे अधिक आयु के वरिष्ठ नागरिकों हेतु मासिक पेंशन।"}'::jsonb,
    '{"en": "Ministry of Rural Development", "hi": "ग्रामीण विकास मंत्रालय"}'::jsonb,
    'https://myscheme.gov.in/schemes/ignoaps',
    'myscheme.gov.in'::jsonb,
    '{"en": "₹1,000 to ₹3,000 / month (Central + State Combined)", "hi": "₹1,000 से ₹3,000 / माह (केंद्र + राज्य सहायता)"}'::jsonb,
    'https://nsap.nic.in',
    'National Social Assistance Programme (NSAP)',
    '["Senior Citizen", "Pension", "Old Age", "Social Welfare"]'::jsonb,
    '{"minAge": 60, "maxAge": 120, "genders": ["all"], "occupations": ["unemployed", "daily_wage", "farmer", "artisan"], "maxIncome": 200000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["bpl_or_low_income"]}'::jsonb,
    '{"en": ["Age 60 years or above", "Applicant must belong to a household living Below Poverty Line (BPL) as per state criteria", "Amount increases significantly at age 80+"], "hi": ["उम्र 60 वर्ष या उससे अधिक", "आवेदक राज्य के गरीबी रेखा से नीचे (BPL) परिवार से होना चाहिए", "80 वर्ष की आयु पूरी होने पर पेंशन राशि बढ़ाई जाती है"]}'::jsonb,
    '["Aadhaar Card (Proof of Age)", "BPL Card / Ration Card", "Income Certificate issued by Revenue Authority", "Bank Account details (DBT active)", "Passport size photograph"]'::jsonb,
    '{"en": ["Apply online via state e-District / Social Welfare portal or submit physical form to Panchayat / Municipality / SDM office.", "Revenue officer verifies age and BPL status.", "Pension order issued and monthly amount credited via DBT."], "hi": ["राज्य के ई-डिस्ट्रिक्ट पोर्टल पर ऑनलाइन आवेदन करें या तहसील/पंचायत कार्यालय में फॉर्म जमा करें।", "राजस्व अधिकारी द्वारा उम्र और आय का सत्यापन।", "पेंशन स्वीकृति के बाद प्रति माह सीधे बैंक खाते में भुगतान।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'widow-pension-ignwps',
    '{"en": "Indira Gandhi National Widow Pension (IGNWPS)", "hi": "इंदिरा गांधी राष्ट्रीय विधवा पेंशन योजना"}'::jsonb,
    '{"en": "Dedicated financial subsistence pension for widows aged 40-79 living below poverty line to ensure dignity and food security.", "hi": "40 से 79 वर्ष की बीपीएल विधवा महिलाओं के सम्मानजनक जीवन और आर्थिक सुरक्षा हेतु मासिक पेंशन।"}'::jsonb,
    '{"en": "Ministry of Rural Development", "hi": "ग्रामीण विकास मंत्रालय"}'::jsonb,
    'https://myscheme.gov.in/schemes/ignwps',
    'myscheme.gov.in'::jsonb,
    '{"en": "₹1,000 to ₹2,500 / month (Central + State Top-up)", "hi": "₹1,000 से ₹2,500 / माह (राज्य अनुसार)"}'::jsonb,
    'https://nsap.nic.in',
    'National Social Assistance Programme',
    '["Widow", "Women", "Pension", "Support"]'::jsonb,
    '{"minAge": 40, "maxAge": 79, "genders": ["female"], "occupations": ["all"], "maxIncome": 200000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["bpl_or_low_income"]}'::jsonb,
    '{"en": ["Widowed woman aged between 40 and 79 years", "Household living Below Poverty Line (BPL)", "Must not have remarried"], "hi": ["40 से 79 वर्ष की आयु वर्ग की विधवा महिला", "परिवार गरीबी रेखा (BPL) के अंतर्गत आता हो", "पुनर्विवाह न किया हो"]}'::jsonb,
    '["Aadhaar Card", "Husband''s Death Certificate", "BPL Ration Card / Income Certificate", "Bank Account details", "Affidavit affirming non-remarriage"]'::jsonb,
    '{"en": ["Submit application on state Social Welfare department portal or visit block development office / Taluk office.", "Attach husband''s death certificate and BPL card.", "Verification by local revenue inspector.", "Monthly pension disbursed via PFMS / DBT."], "hi": ["राज्य के समाज कल्याण पोर्टल पर आवेदन करें या ब्लॉक/तहसील कार्यालय में जमा करें।", "पति का मृत्यु प्रमाण पत्र और राशन कार्ड संलग्न करें।", "सत्यापन उपरांत डीबीटी के माध्यम से मासिक पेंशन प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'divyangjan-swavalamban',
    '{"en": "Divyangjan Swavalamban Scheme (NDFDC)", "hi": "दिव्यांगजन स्वावलंबन योजना"}'::jsonb,
    '{"en": "Concessional loans up to ₹25 Lakh at attractive interest rates (5%-7%) and skill training for differently-abled entrepreneurs.", "hi": "दिव्यांग उद्यमियों के लिए 5%-7% की रियायती ब्याज दर पर ₹25 लाख तक का आसान ऋण और कौशल प्रशिक्षण।"}'::jsonb,
    '{"en": "Ministry of Social Justice and Empowerment", "hi": "सामाजिक न्याय और अधिकारिता मंत्रालय"}'::jsonb,
    'https://www.swavlambancard.gov.in',
    'swavlambancard.gov.in'::jsonb,
    '{"en": "Up to ₹25,00,000 Loan at 5%-7% interest", "hi": "₹25,00,000 तक ऋण मात्र 5%-7% ब्याज पर"}'::jsonb,
    'https://www.nhfdc.nic.in',
    'National Divyangjan Finance and Development Corp',
    '["Disability", "PwD", "Divyangjan", "Self-Employment"]'::jsonb,
    '{"minAge": 18, "maxAge": 65, "genders": ["all"], "occupations": ["all"], "maxIncome": 1000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["differently_abled"]}'::jsonb,
    '{"en": ["Indian citizen with disability of 40% or more (UDID Card)", "Age 18 years and above", "For setting up small business, agriculture, service activity, or higher education"], "hi": ["40% या उससे अधिक दिव्यांगता वाले भारतीय नागरिक (UDID कार्ड धारक)", "आयु 18 वर्ष या उससे अधिक", "स्वरोजगार, व्यापार, कृषि कार्य या उच्च शिक्षा शुरू करने हेतु"]}'::jsonb,
    '["Aadhaar Card", "Unique Disability ID (UDID) Card or Disability Certificate", "Educational qualification proof", "Project feasibility outline", "Bank Account details"]'::jsonb,
    '{"en": ["Register on nhfdc.nic.in or approach State Channelising Agency (SCA) / partner bank.", "Submit project proposal along with UDID card.", "Sanctioned loan released with 0.5% - 1% interest rebate for women with disabilities.", "Repayment tenure up to 7-10 years."], "hi": ["nhfdc.nic.in पर पंजीकरण करें या राज्य चैनलिंग एजेंसी/बैंक से संपर्क करें।", "UDID कार्ड और परियोजना प्रस्ताव जमा करें।", "रियायती ब्याज पर ऋण स्वीकृत कर बैंक खाते में वितरित किया जाता है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'kisan-credit-card',
    '{"en": "Kisan Credit Card (KCC) Scheme", "hi": "किसान क्रेडिट कार्ड (केसीसी) योजना"}'::jsonb,
    '{"en": "Short-term credit up to ₹3 Lakh at an effective subsidized interest rate of just 4% per year for farm inputs, seeds, and equipment.", "hi": "खेती की लागत, बीज, खाद और मशीनरी हेतु मात्र 4% प्रभावी ब्याज दर पर ₹3 लाख तक का अल्पकालिक ऋण।"}'::jsonb,
    '{"en": "Ministry of Agriculture and Farmers Welfare", "hi": "कृषि एवं किसान कल्याण मंत्रालय"}'::jsonb,
    'agriculture',
    '{"en": "Low-Interest Credit Line", "hi": "अल्पकालिक सस्ता ऋण"}'::jsonb,
    '{"en": "Up to ₹3,00,000 at 4% effective interest (with prompt pay)", "hi": "₹3,00,000 तक ऋण (समय पर चुकाने पर मात्र 4% ब्याज)"}'::jsonb,
    'https://myscheme.gov.in/schemes/kcc',
    'NABARD & Commercial Banks',
    '["KCC", "Farmers", "Low Interest", "Crop Loan"]'::jsonb,
    '{"minAge": 18, "maxAge": 75, "genders": ["all"], "occupations": ["farmer"], "maxIncome": 2000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["owns_cultivable_land"]}'::jsonb,
    '{"en": ["Owner cultivators, tenant farmers, oral lessees, and sharecroppers", "Also extended to dairy, animal husbandry, and fisheries farmers", "Covers crop production, post-harvest expenses, and farm maintenance"], "hi": ["भूस्वामी किसान, बटाईदार और मौखिक पट्टेदार", "पशुपालन, डेयरी और मत्स्य पालन करने वाले किसानों के लिए भी मान्य", "फसल उत्पादन, खाद, बीज व खेती की मरम्मत खर्च हेतु"]}'::jsonb,
    '["Aadhaar Card and PAN Card", "Land Record documents (Khasra/Khatauni copy)", "Cropping pattern proof / Patwari report", "Passport photos and no-dues certificate"]'::jsonb,
    '{"en": ["Download simplified 1-page KCC form from pmkisan.gov.in or bank portal.", "Submit at bank branch where PM-Kisan account is maintained.", "Bank issues KCC RuPay card within 14 days without processing fees up to ₹1.6 Lakh."], "hi": ["pmkisan.gov.in से 1-पेज का सरल KCC फॉर्म डाउनलोड करें।", "अपने बैंक शाखा में जमा करें।", "14 दिनों के भीतर KCC रुपे कार्ड जारी किया जाता है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-kvy-skill',
    '{"en": "PM Kaushal Vikas Yojana 4.0 (PMKVY)", "hi": "प्रधानमंत्री कौशल विकास योजना 4.0"}'::jsonb,
    '{"en": "Industry-aligned free skill development training, NSQF certification, assessment, and placement support for youth.", "hi": "युवाओं के लिए उद्योग-उन्मुख मुफ्त कौशल प्रशिक्षण, सरकारी प्रमाणपत्र और रोजगार सहायता।"}'::jsonb,
    '{"en": "Ministry of Skill Development and Entrepreneurship", "hi": "कौशल विकास एवं उद्यमिता मंत्रालय"}'::jsonb,
    'https://www.skillindiadigital.gov.in',
    'skillindiadigital.gov.in'::jsonb,
    '{"en": "100% Free Training + NSQF Certificate + Placement assistance", "hi": "100% मुफ्त ट्रेनिंग + सरकारी प्रमाण पत्र + नौकरी सहयोग"}'::jsonb,
    'https://www.pmkvyofficial.org',
    'Skill India Digital Hub',
    '["Skill Training", "Youth", "Jobs", "Vocational"]'::jsonb,
    '{"minAge": 15, "maxAge": 45, "genders": ["all"], "occupations": ["unemployed", "student", "daily_wage"], "maxIncome": 1000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Indian youth aged 15-45 looking for employment or skill enhancement", "School/college dropouts or unemployed individuals", "Courses available across AI, robotics, healthcare, construction, tourism, electronics, etc."], "hi": ["15 से 45 वर्ष के भारतीय युवा जो रोजगार या नया कौशल सीखना चाहते हैं", "स्कूल/कॉलेज छोड़ चुके या बेरोजगार युवा", "एआई, कोडिंग, इलेक्ट्रॉनिक्स, सोलर, हेल्थकेयर आदि में आधुनिक कोर्स"]}'::jsonb,
    '["Aadhaar Card", "Educational qualification certificates (Class 8/10/12 if applicable)", "Bank Account details", "Passport size photo"]'::jsonb,
    '{"en": ["Register on skillindiadigital.gov.in.", "Search nearby Pradhan Mantri Kaushal Kendra (PMKK) and select your course.", "Complete practical training hours and pass assessment.", "Receive Skill India digital badge and attend job fairs."], "hi": ["skillindiadigital.gov.in पर अपना खाता बनाएं।", "नजदीकी कौशल केंद्र (PMKK) और अपनी पसंद का कोर्स चुनें।", "प्रशिक्षण पूरा कर परीक्षा पास करें और डिजिटल सर्टिफिकेट पाएं।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'ladli-behna-state',
    '{"en": "Mukhyamantri Ladli Behna / Mahila Samman Scheme", "hi": "मुख्यमंत्री लाडली बहना / महिला सम्मान योजना"}'::jsonb,
    '{"en": "Direct monthly financial support of ₹1,250 to ₹1,500 transferred to married, widowed, and divorced women for financial self-reliance.", "hi": "विवाहित, विधवा और परित्यक्ता महिलाओं को ₹1,250 से ₹1,500 प्रति माह सीधे बैंक खाते में आर्थिक आत्मनिर्भरता हेतु।"}'::jsonb,
    '{"en": "Department of Women and Child Development (State Governments)", "hi": "महिला एवं बाल विकास विभाग (राज्य सरकार)"}'::jsonb,
    'women',
    '{"en": "Direct Monthly Cash Allowance", "hi": "मासिक प्रत्यक्ष नकद अंतरण"}'::jsonb,
    '{"en": "₹1,250 to ₹1,500 / month (₹15,000 - ₹18,000 / year)", "hi": "₹1,250 से ₹1,500 / माह (₹15,000 - ₹18,000 / वर्ष)"}'::jsonb,
    'https://cmladlibahna.mp.gov.in',
    'State Women Welfare Portal',
    '["Women", "State Scheme", "Monthly Cash", "Empowerment"]'::jsonb,
    '{"minAge": 21, "maxAge": 60, "genders": ["female"], "occupations": ["all"], "maxIncome": 250000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Resident woman of the state aged 21 to 60 years", "Combined family annual income does not exceed ₹2,50,000", "Family should not have any income tax payer or government employee"], "hi": ["संबंधित राज्य की निवासी महिला, उम्र 21 से 60 वर्ष", "परिवार की कुल वार्षिक आय ₹2.5 लाख से अधिक न हो", "परिवार का कोई सदस्य आयकर दाता या सरकारी नौकरी में न हो"]}'::jsonb,
    '["Aadhaar Card", "Family ID / Samagra ID / Ration Card", "Individual Bank Account linked with Aadhaar & DBT active", "Mobile number"]'::jsonb,
    '{"en": ["Camp organized at village Panchayat / Municipal Ward.", "Submit form with photo captured live and biometric e-KYC.", "List published for public review.", "Amount credited automatically on the 10th of every month."], "hi": ["ग्राम पंचायत या नगर पालिका वार्ड शिविर में जाएं।", "आधार ई-केवाईसी और लाइव फोटो के साथ फॉर्म भरवाएं।", "सत्यापन के बाद हर महीने की 10 तारीख को सीधे खाते में पैसा प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'pm-kusum-solar',
    '{"en": "PM-KUSUM (Solar Agricultural Pumps)", "hi": "पीएम कुसुम योजना (सोलर कृषि पंप व ऊर्जा)"}'::jsonb,
    '{"en": "Up to 60% government subsidy for installing solar water pumps for irrigation, cutting diesel costs and earning by selling surplus power.", "hi": "सिंचाई हेतु सोलर पंप लगाने पर 60% तक सरकारी सब्सिडी, डीजल खर्च समाप्त और अतिरिक्त बिजली बेचकर कमाई।"}'::jsonb,
    '{"en": "Ministry of New and Renewable Energy", "hi": "नवीन और नवीकरणीय ऊर्जा मंत्रालय"}'::jsonb,
    'agriculture',
    '{"en": "Solar Pump Capital Subsidy", "hi": "सोलर पंप पर 60% तक भारी सब्सिडी"}'::jsonb,
    '{"en": "60% Subsidy (30% Central + 30% State) + 30% Bank Loan", "hi": "60% सब्सिडी (30% केंद्र + 30% राज्य) + 30% आसान बैंक ऋण"}'::jsonb,
    'https://pmkusum.mnre.gov.in',
    'PM-KUSUM National Portal',
    '["Solar Pump", "Renewable Energy", "Farmers", "Irrigation"]'::jsonb,
    '{"minAge": 18, "maxAge": 75, "genders": ["all"], "occupations": ["farmer"], "maxIncome": 2000000, "categories": ["all"], "areas": ["rural"], "states": ["all"], "specialConditions": ["owns_cultivable_land"]}'::jsonb,
    '{"en": ["Individual farmers, farmer groups, cooperatives, and water user associations", "Must have agricultural land and an existing or proposed irrigation source", "Farmer needs to contribute only 10% of total system cost"], "hi": ["व्यक्तिगत किसान, किसान समूह, सहकारी समितियां और जल उपभोक्ता संघ", "खेती योग्य भूमि और सिंचाई का जल स्रोत होना आवश्यक", "किसान को कुल लागत का केवल 10% अंशदान देना होता है"]}'::jsonb,
    '["Aadhaar Card", "Land Record (Jamabandi / Khasra / Khatoni)", "Bank Account details", "Passport photo & mobile number"]'::jsonb,
    '{"en": ["Apply on state renewable energy agency portal (e.g. UPNEDA, MEDA, HAREDA).", "Select pump capacity (3 HP, 5 HP, 7.5 HP) based on land size.", "Pay 10% farmer share after verification.", "Authorized vendor installs solar panels and pump with 5-year warranty."], "hi": ["राज्य ऊर्जा विकास एजेंसी के पोर्टल पर आवेदन करें।", "भूमि के अनुसार पंप की क्षमता (3, 5 या 7.5 एचपी) चुनें।", "सत्यापन के बाद अपना 10% अंशदान जमा करें।", "अधिकृत एजेंसी द्वारा 5 साल की वारंटी के साथ सोलर पंप स्थापित किया जाएगा।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'national-apprenticeship',
    '{"en": "National Apprenticeship Promotion Scheme (NAPS)", "hi": "राष्ट्रीय शिक्षुता संवर्धन योजना (NAPS)"}'::jsonb,
    '{"en": "25% government stipend support (up to ₹1,500/month) alongside industrial on-the-job training for diploma holders, ITI, and graduates.", "hi": "आईटीआई, डिप्लोमा और स्नातकों के लिए उद्योगों में हैंड्स-ऑन ट्रेनिंग और सरकार द्वारा ₹1,500/माह स्टाइपेंड सहयोग।"}'::jsonb,
    '{"en": "Ministry of Skill Development and Entrepreneurship", "hi": "कौशल विकास एवं उद्यमिता मंत्रालय"}'::jsonb,
    'education',
    '{"en": "Industrial Apprenticeship & Stipend", "hi": "औद्योगिक प्रशिक्षण एवं मासिक स्टाइपेंड"}'::jsonb,
    '{"en": "Monthly Stipend ₹8,000 - ₹15,000 + Govt Certification", "hi": "₹8,000 - ₹15,000 मासिक स्टाइपेंड + सरकारी कार्य अनुभव"}'::jsonb,
    'https://www.apprenticeshipindia.gov.in',
    'Apprenticeship India Portal',
    '["Apprenticeship", "Jobs", "Graduates", "ITI", "Engineering"]'::jsonb,
    '{"minAge": 14, "maxAge": 35, "genders": ["all"], "occupations": ["student", "unemployed"], "maxIncome": 1000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Candidate minimum age 14 years (18 for hazardous occupations)", "Completed 5th, 8th, 10th, 12th, ITI, Diploma, or Degree", "Looking for formal industry apprentice contracts"], "hi": ["उम्मीदवार की न्यूनतम आयु 14 वर्ष", "10वीं, 12वीं, आईटीआई, डिप्लोमा या डिग्री धारक", "औद्योगिक कंपनियों में ऑन-द-जॉब ट्रेनिंग के इच्छुक युवा"]}'::jsonb,
    '["Aadhaar Card", "Educational certificates and marksheet", "Bank Account details", "Resume / Profile"]'::jsonb,
    '{"en": ["Create profile on apprenticeshipindia.gov.in.", "Search apprenticeship opportunities by trade and company location.", "Apply online; companies issue digital contracts.", "Receive monthly stipend via DBT."], "hi": ["apprenticeshipindia.gov.in पर प्रोफाइल बनाएं।", "अपनी योग्यता अनुसार कंपनी और ट्रेड चुनें।", "कंपनी से अनुबंध मिलने पर प्रशिक्षण शुरू करें और मासिक स्टाइपेंड पाएं।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'senior-citizen-savings',
    '{"en": "Senior Citizen Savings Scheme (SCSS)", "hi": "वरिष्ठ नागरिक बचत योजना"}'::jsonb,
    '{"en": "Sovereign guaranteed 8.2% quarterly interest income on deposits up to ₹30 Lakh for senior citizens with Section 80C tax deduction.", "hi": "वरिष्ठ नागरिकों के लिए ₹30 लाख तक की जमा पर 8.2% त्रैमासिक ब्याज, पूर्ण सरकारी सुरक्षा और धारा 80C कर छूट।"}'::jsonb,
    '{"en": "Ministry of Finance", "hi": "वित्त मंत्रालय"}'::jsonb,
    'pension',
    '{"en": "High-Return Sovereign Income", "hi": "सरकारी गारंटीकृत सुरक्षित आय"}'::jsonb,
    '{"en": "8.2% Annual Interest (Paid Quarterly) up to ₹30,00,000", "hi": "8.2% वार्षिक ब्याज (त्रैमासिक भुगतान) ₹30 लाख तक की जमा पर"}'::jsonb,
    'https://www.indiapost.gov.in',
    'Post Office & Banks',
    '["Senior Citizen", "Safe Investment", "Retirement", "Quarterly Interest"]'::jsonb,
    '{"minAge": 60, "maxAge": 120, "genders": ["all"], "occupations": ["all"], "maxIncome": 10000000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Individual aged 60 years or above (or 55+ for retired under VRS)", "Tenure of 5 years, extendable by 3 more years", "Maximum deposit limit ₹30 Lakh per individual"], "hi": ["60 वर्ष या उससे अधिक आयु के नागरिक (VRS लेने वालों के लिए 55 वर्ष)", "5 वर्ष की अवधि, जिसे 3 वर्ष और बढ़ाया जा सकता है", "अधिकतम ₹30 लाख तक जमा करने की सुविधा"]}'::jsonb,
    '["Aadhaar Card and PAN Card", "Proof of Age", "Retirement & terminal benefit proof (if opening before age 60 under VRS)", "Two passport-sized photographs"]'::jsonb,
    '{"en": ["Visit any Post Office branch or authorized public/private commercial bank.", "Fill Form-1 and submit with PAN and Aadhaar copies.", "Deposit amount via cheque or transfer.", "Receive passbook and quarterly interest directly in savings account."], "hi": ["किसी भी डाकघर या बैंक शाखा में Form-1 भरें।", "आधार, पैन और सेवानिवृत्ति दस्तावेज प्रस्तुत करें।", "चेक द्वारा राशि जमा करें और हर तीन महीने पर ब्याज का लाभ लें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'free-coaching-sc-obc',
    '{"en": "Free Coaching Scheme for SC & OBC Students", "hi": "एससी और ओबीसी छात्रों के लिए मुफ्त कोचिंग योजना"}'::jsonb,
    '{"en": "100% free coaching for UPSC, State PSC, Banking, JEE, and NEET along with a monthly living stipend of ₹4,000.", "hi": "यूपीएससी, राज्य लोक सेवा, बैंकिंग, जेईई और नीट प्रतियोगी परीक्षाओं हेतु 100% मुफ्त कोचिंग और ₹4,000/माह वजीफा।"}'::jsonb,
    '{"en": "Ministry of Social Justice and Empowerment", "hi": "सामाजिक न्याय और अधिकारिता मंत्रालय"}'::jsonb,
    'https://socialjustice.gov.in',
    'socialjustice.gov.in'::jsonb,
    '{"en": "Full Course Fees Covered + ₹4,000 / month living stipend", "hi": "पूरी कोचिंग फीस + ₹4,000 प्रति माह रहने का खर्च"}'::jsonb,
    'https://coaching.dosje.gov.in',
    'Coaching Portal (MoSJE)',
    '["UPSC Coaching", "NEET", "JEE", "SC/OBC", "Stipend"]'::jsonb,
    '{"minAge": 18, "maxAge": 35, "genders": ["all"], "occupations": ["student", "unemployed"], "maxIncome": 800000, "categories": ["sc", "obc"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Belong to Scheduled Caste (SC) or Other Backward Class (OBC)", "Annual total family income not exceeding ₹8,00,000", "Preparing for national/state level competitive exams"], "hi": ["अनुसूचित जाति (SC) या अन्य पिछड़ा वर्ग (OBC) से संबंधित", "परिवार की कुल वार्षिक आय ₹8,00,000 से कम", "राष्ट्रीय या राज्य स्तरीय प्रतियोगी परीक्षाओं की तैयारी कर रहे छात्र"]}'::jsonb,
    '["Aadhaar Card", "Caste Certificate (SC/OBC)", "Income Certificate issued by Revenue Authority", "Class 10th & 12th / Graduation Marksheets", "Bank Account details"]'::jsonb,
    '{"en": ["Register on coaching.dosje.gov.in during annual notification window.", "Upload entrance exam score / academic marksheets.", "Merit list published; selected candidates join empanelled premier coaching institutes.", "Monthly stipend of ₹4,000 credited through DBT."], "hi": ["coaching.dosje.gov.in पर ऑनलाइन आवेदन करें।", "शैक्षणिक अंक और जाति/आय प्रमाणपत्र अपलोड करें।", "मेरिट में आने पर प्रतिष्ठित कोचिंग में प्रवेश और ₹4,000 मासिक भत्ता प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'national-family-benefit',
    '{"en": "National Family Benefit Scheme (NFBS)", "hi": "राष्ट्रीय परिवार लाभ योजना"}'::jsonb,
    '{"en": "Lump-sum cash assistance of ₹20,000 to ₹30,000 provided to a BPL family upon the death of the primary breadwinner.", "hi": "गरीबी रेखा से नीचे के परिवार में मुख्य कमाऊ सदस्य की मृत्यु होने पर परिवार को ₹20,000 से ₹30,000 की एकमुश्त आर्थिक मदद।"}'::jsonb,
    '{"en": "Ministry of Rural Development", "hi": "ग्रामीण विकास मंत्रालय"}'::jsonb,
    'https://myscheme.gov.in/schemes/nfbs',
    'myscheme.gov.in'::jsonb,
    '{"en": "₹20,000 to ₹30,000 One-time direct transfer", "hi": "₹20,000 से ₹30,000 एकमुश्त डीबीटी सहायता"}'::jsonb,
    'https://nsap.nic.in',
    'National Social Assistance Programme',
    '["Emergency Relief", "Breadwinner Death", "BPL", "Family Security"]'::jsonb,
    '{"minAge": 18, "maxAge": 59, "genders": ["all"], "occupations": ["all"], "maxIncome": 200000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": ["bpl_or_low_income"]}'::jsonb,
    '{"en": ["Family living Below Poverty Line (BPL)", "Death of primary breadwinner (male or female) aged between 18 and 59 years", "Application submitted within 1 year of death"], "hi": ["परिवार गरीबी रेखा (BPL) से नीचे जीवनयापन कर रहा हो", "परिवार के मुख्य कमाऊ सदस्य (18 से 59 वर्ष आयु) की आकस्मिक मृत्यु", "मृत्यु के 1 वर्ष के भीतर आवेदन अनिवार्य"]}'::jsonb,
    '["Aadhaar Card of Applicant (Head of household)", "Official Death Certificate of the deceased breadwinner", "Age proof of deceased (Aadhaar / Voter ID / School cert showing age 18-59)", "BPL Ration Card / Income Certificate", "Bank Account details"]'::jsonb,
    '{"en": ["Apply through state e-District portal or submit hardcopy at Tehsil/Block office.", "Revenue Inspector conducts on-ground inquiry.", "Sub-Divisional Magistrate (SDM) sanctions one-time relief fund into nominee''s bank account."], "hi": ["राज्य के ई-डिस्ट्रिक्ट पोर्टल पर आवेदन करें या तहसील कार्यालय में जमा करें।", "राजस्व निरीक्षक द्वारा मौके पर सत्यापन।", "एसडीएम द्वारा स्वीकृति के बाद राशि सीधे बैंक खाते में भेजी जाती है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'handloom-weavers-mudra',
    '{"en": "Weavers Mudra Scheme & Margin Money Assistance", "hi": "बुनकर मुद्रा योजना एवं मार्जिन मनी सहायता"}'::jsonb,
    '{"en": "Concessional credit up to ₹2 Lakh at 6% interest subvention along with up to ₹10,000 margin money grant for handloom weavers.", "hi": "हथकरघा बुनकरों के लिए 6% ब्याज छूट पर ₹2 लाख तक का ऋण और ₹10,000 तक मार्जिन मनी सरकारी अनुदान।"}'::jsonb,
    '{"en": "Ministry of Textiles", "hi": "वस्त्र मंत्रालय"}'::jsonb,
    'business',
    '{"en": "Subsidized Credit & Margin Grant", "hi": "रियायती ऋण एवं मार्जिन अनुदान"}'::jsonb,
    '{"en": "Up to ₹2,00,000 Loan (6% Interest Subvention) + ₹10,000 Margin Grant", "hi": "₹2,00,000 तक ऋण (6% ब्याज छूट) + ₹10,000 मार्जिन मनी"}'::jsonb,
    'https://handlooms.nic.in',
    'Development Commissioner for Handlooms',
    '["Weavers", "Textiles", "Artisans", "Handloom", "Margin Money"]'::jsonb,
    '{"minAge": 18, "maxAge": 70, "genders": ["all"], "occupations": ["artisan", "small_business"], "maxIncome": 400000, "categories": ["all"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Handloom weavers and allied workers involved in weaving activities", "Possessing Handloom Weaver Photo Identity Card / Pehchan Card", "Not a defaulter with any financial institution"], "hi": ["हथकरघा बुनाई और संबंधित कार्यों में लगे पारंपरिक बुनकर", "हथकरघा बुनकर पहचान पत्र (पहचान कार्ड) धारक", "किसी भी बैंक या वित्तीय संस्थान के डिफॉल्टर न हों"]}'::jsonb,
    '["Aadhaar Card", "Weaver Pehchan Card / Identity Proof issued by Textile Dept", "Bank Passbook copy", "Passport size photos"]'::jsonb,
    '{"en": ["Contact nearest Weavers'' Service Centre (WSC) or lead district bank.", "Fill Weavers Mudra loan application.", "Ministry disburses margin money assistance up to ₹10,000 to margin account.", "Credit limit sanctioned via RuPay Weavers Card."], "hi": ["नजदीकी बुनकर सेवा केंद्र (WSC) या बैंक शाखा से संपर्क करें।", "बुनकर मुद्रा आवेदन पत्र भरें।", "सरकार मार्जिन मनी के ₹10,000 अनुदान सीधे खाते में भेजती है।", "बुनकर कार्ड से ऋण की सुविधा प्राप्त करें।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;

INSERT INTO schemes (
    id, name, short_description, ministry, category, benefit_type, benefit_amount, 
    official_url, portal_name, tags, eligibility, criteria_descriptions, documents, application_steps
) VALUES (
    'national-overseas-scholarship',
    '{"en": "National Overseas Scholarship for SC / Landless Laborers", "hi": "राष्ट्रीय विदेशी छात्रवृत्ति योजना (एससी/भूमिहीन खेतिहर)"}'::jsonb,
    '{"en": "Full overseas tuition fees, maintenance allowance ($15,400+ USD), visa fees, and airfare for Master''s and PhD in top world universities.", "hi": "विश्व के शीर्ष विश्वविद्यालयों में मास्टर्स और पीएचडी हेतु पूरी ट्यूशन फीस, वीजा, विमान किराया और $15,400+ वार्षिक निर्वाह खर्च।"}'::jsonb,
    '{"en": "Ministry of Social Justice and Empowerment", "hi": "सामाजिक न्याय और अधिकारिता मंत्रालय"}'::jsonb,
    'https://socialjustice.gov.in',
    'socialjustice.gov.in'::jsonb,
    '{"en": "100% Tuition Fees + $15,400 / £9,900 Annual Allowance + Airfare", "hi": "100% विदेशी कॉलेज फीस + $15,400 वार्षिक भत्ता + हवाई टिकट"}'::jsonb,
    'https://nosmsje.gov.in',
    'National Overseas Scholarship Portal',
    '["Abroad Studies", "Masters", "PhD", "SC Students", "Full Scholarship"]'::jsonb,
    '{"minAge": 20, "maxAge": 35, "genders": ["all"], "occupations": ["student", "unemployed", "salaried"], "maxIncome": 800000, "categories": ["sc"], "areas": ["all"], "states": ["all"], "specialConditions": []}'::jsonb,
    '{"en": ["Belong to Scheduled Castes, Denotified Nomadic Tribes, or traditional artisans/landless agricultural labourers", "Secured admission in top 500 QS ranked foreign universities for Master''s or Ph.D.", "Total family income ≤ ₹8,00,000 per annum with minimum 60% marks in qualifying degree"], "hi": ["अनुसूचित जाति (SC), विमुक्त घुमंतू जनजाति या भूमिहीन कृषि मजदूर वर्ग से हों", "शीर्ष 500 QS रैंकिंग वाले विदेशी विश्वविद्यालय में मास्टर्स या पीएचडी में प्रवेश", "परिवार की वार्षिक आय ₹8,00,000 से कम और पिछली डिग्री में कम से कम 60% अंक"]}'::jsonb,
    '["Aadhaar Card and Valid Passport", "Caste Certificate issued by competent authority", "Family Income Certificate and ITRs of parents", "Unconditional Offer Letter from Top 500 Foreign University", "Degree marksheets and transcripts"]'::jsonb,
    '{"en": ["Apply online on nosmsje.gov.in portal during application window.", "Upload unconditional admission offer letter from QS top 500 university.", "Selection committee reviews applications on merit.", "Disbursement of visa, airfare, and direct fee payment to foreign university."], "hi": ["nosmsje.gov.in पर ऑनलाइन आवेदन करें।", "शीर्ष 500 विश्वविद्यालय का ऑफर लेटर और दस्तावेज अपलोड करें।", "चयन उपरांत विदेशी यूनिवर्सिटी की पूरी फीस और रहने का खर्च सीधे भेजा जाता है।"]}'::jsonb
) ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    short_description = EXCLUDED.short_description,
    ministry = EXCLUDED.ministry,
    category = EXCLUDED.category,
    benefit_type = EXCLUDED.benefit_type,
    benefit_amount = EXCLUDED.benefit_amount,
    official_url = EXCLUDED.official_url,
    portal_name = EXCLUDED.portal_name,
    tags = EXCLUDED.tags,
    eligibility = EXCLUDED.eligibility,
    criteria_descriptions = EXCLUDED.criteria_descriptions,
    documents = EXCLUDED.documents,
    application_steps = EXCLUDED.application_steps;
