// Translations dictionary for bilingual support (English & Hindi)

const TRANSLATIONS = {
  en: {
    appTitle: "YojanaSetu",
    appSubTitle: "Civic Welfare & Scheme Finder",
    tagline: "Which government benefits are you actually eligible for?",
    heroLead: "Find every scholarship, pension, health cover, and business subsidy you qualify for in under 2 minutes. No paperwork headaches, no middlemen.",
    badgeVerified: "Verified Official Central & State Schemes",
    statsSchemesCount: "25+ Cataloged Schemes",
    statsDirectBenefit: "₹5L+ Max Individual Cover",
    statsAccuracy: "100% Direct Portal Links",
    
    // Nav
    navWizard: "Check Eligibility",
    navAllSchemes: "Explore All Schemes",
    navChecklist: "My Document Checklist",
    navBookmarked: "Saved",
    
    // Wizard
    wizardTitle: "Quick Eligibility Questionnaire",
    wizardSubtitle: "Answer 5 simple questions to get your personalized benefits dossier.",
    step: "Step",
    of: "of",
    btnNext: "Next Step",
    btnPrev: "Previous",
    btnCalculate: "Find My Eligible Schemes",
    btnRecalculate: "Edit Profile Answers",
    btnReset: "Reset Questionnaire",
    liveMatchCount: "schemes potentially match so far",
    
    // Step 1
    step1Title: "Who is this application for?",
    step1Desc: "Age and gender determine key educational grants, senior pensions, and maternity programs.",
    labelAge: "Citizen's Current Age (years)",
    labelGender: "Gender",
    optFemale: "Female",
    optMale: "Male",
    optTransgender: "Other / Transgender",
    
    // Step 2
    step2Title: "Where do you reside?",
    step2Desc: "Certain welfare schemes have rural vs. urban funding channels or state-specific top-ups.",
    labelState: "State / Union Territory",
    labelArea: "Residential Area",
    optRural: "Rural (Village / Gram Panchayat)",
    optUrban: "Urban (City / Town / Municipality)",
    optAnyArea: "All Areas",
    
    // Step 3
    step3Title: "What is your primary occupation?",
    step3Desc: "Tailored benefits exist for farmers, traditional artisans, street vendors, and students.",
    labelOccupation: "Current Occupation",
    occStudent: "Student (School / College)",
    occFarmer: "Farmer / Agriculturalist",
    occStreetVendor: "Street Vendor / Hawker / Daily Stall",
    occArtisan: "Artisan / Craftsman (Carpenter, Tailor, Potter, etc.)",
    occSmallBusiness: "Small Business Owner / Trader / Shopkeeper",
    occDailyWage: "Daily Wage / Unorganized Worker",
    occUnemployed: "Job Seeker / Unemployed",
    occSalaried: "Salaried Employee (Private / Public)",
    
    // Step 4
    step4Title: "Socio-Economic Background",
    step4Desc: "Welfare programs target priority groups with fee concessions and direct financial aid.",
    labelIncome: "Annual Household Income",
    incUnder1L: "Under ₹1,00,000 (Low Income / BPL)",
    inc1LTo25L: "₹1,00,000 to ₹2,50,000 (EWS / Lower Middle)",
    inc25LTo5L: "₹2,50,000 to ₹5,00,000",
    inc5LTo8L: "₹5,00,000 to ₹8,00,000 (Non-Creamy Limit)",
    incAbove8L: "Above ₹8,00,000",
    labelCategory: "Social Category / Caste",
    catGeneral: "General",
    catOBC: "OBC (Other Backward Class)",
    catSC: "SC (Scheduled Caste)",
    catST: "ST (Scheduled Tribe)",
    catEWS: "EWS (Economically Weaker Section)",
    labelBPL: "Do you hold a BPL / Antyodaya / Ration Card?",
    optYes: "Yes",
    optNo: "No",
    
    // Step 5
    step5Title: "Special Circumstances & Eligibility Boosters",
    step5Desc: "Check any that apply to you or your immediate household.",
    condDifferentlyAbled: "Person with Disability (UDID / 40%+ Disability)",
    condGirlChild: "Have a girl child aged 10 years or younger",
    condPregnantLactating: "Pregnant or Lactating Mother (or infant under 1 yr)",
    condOwnsLand: "Family owns agricultural / cultivable land",
    condNone: "None of these apply",
    
    // Results
    resultsTitle: "Schemes You Qualify For",
    resultsSubtitle: "Based on your verified profile, here are the welfare programs you can apply for right now.",
    filterAll: "All Categories",
    filterHealth: "Healthcare",
    filterAgri: "Agriculture",
    filterEdu: "Education & Scholarships",
    filterHousing: "Housing",
    filterBiz: "Business & Loans",
    filterWomen: "Women & Child",
    filterPension: "Pensions & Security",
    searchPlaceholder: "Search by keyword (e.g. loan, scholarship, farmer)...",
    sortBy: "Sort by:",
    sortRelevance: "Highest Match",
    sortBenefit: "Largest Benefit Value",
    sortName: "Scheme Name (A-Z)",
    noResultsTitle: "No schemes match your exact criteria",
    noResultsDesc: "Try adjusting your filters or expanding your income range in the profile answers.",
    
    // Scheme Card
    badgeMatch: "100% Eligible",
    badgePotential: "High Potential",
    benefitValue: "Estimated Benefit",
    btnViewDetails: "View Details & Apply",
    btnBookmark: "Save Scheme",
    btnBookmarked: "Saved",
    whyEligible: "Why you qualify:",
    
    // Scheme Modal
    modalClose: "Close",
    modalOverview: "Scheme Overview",
    modalEligibility: "Detailed Eligibility Criteria",
    modalDocs: "Documents You Need",
    modalSteps: "How to Apply (Step-by-Step)",
    modalVisitPortal: "Visit Official Government Portal",
    modalPrintChecklist: "Add to My Document Checklist",
    
    // Checklist Tab
    checklistTitle: "Consolidated Citizen Document Dossier",
    checklistSubtitle: "All verified documents needed across your qualified schemes, merged so you only gather each once.",
    checklistPrintBtn: "Print / Export Application Dossier",
    checklistStatusHave: "Ready / In Hand",
    checklistStatusNeed: "Need to Arrange",
    docWhereToProcure: "How & Where to obtain:",
    docSchemesRequiring: "Schemes requiring this document:",
    totalDocsNeeded: "Total unique documents required:",
    docsReadyCount: "Ready to submit:",
    
    // Print Header
    printHeaderTitle: "GOVERNMENT WELFARE APPLICATION DOSSIER",
    printHeaderDate: "Generated on",
    printNotice: "Take this printed checklist along with original documents to your nearest Common Service Center (CSC), Panchayat Office, or Bank branch."
  },
  
  hi: {
    appTitle: "योजना सेतु",
    appSubTitle: "नागरिक कल्याण एवं सरकारी योजना खोजक",
    tagline: "आप किन सरकारी योजनाओं और लाभों के वास्तव में पात्र हैं?",
    heroLead: "मात्र 2 मिनट में उन सभी छात्रवृत्तियों, पेंशनों, स्वास्थ्य कवर और व्यावसायिक सब्सिडी की जानकारी पाएं जिनके आप हकदार हैं। बिना किसी बिचौलिए के।",
    badgeVerified: "सत्यापित आधिकारिक केंद्रीय व राज्य योजनाएं",
    statsSchemesCount: "25+ प्रमुख योजनाएं",
    statsDirectBenefit: "₹5 लाख तक का स्वास्थ्य कवर",
    statsAccuracy: "100% आधिकारिक पोर्टल लिंक",
    
    // Nav
    navWizard: "पात्रता जांचें",
    navAllSchemes: "सभी योजनाएं देखें",
    navChecklist: "मेरी दस्तावेज़ चेकलिस्ट",
    navBookmarked: "सहेजी गई योजनाएं",
    
    // Wizard
    wizardTitle: "त्वरित पात्रता प्रश्नावली",
    wizardSubtitle: "अपनी व्यक्तिगत योजना सूची प्राप्त करने हेतु 5 सरल प्रश्नों के उत्तर दें।",
    step: "चरण",
    of: "का",
    btnNext: "अगला चरण",
    btnPrev: "पिछला",
    btnCalculate: "मेरी पात्र योजनाएं खोजें",
    btnRecalculate: "प्रोफ़ाइल उत्तर बदलें",
    btnReset: "पुनः शुरू करें",
    liveMatchCount: "योजनाएं अब तक मेल खाती हैं",
    
    // Step 1
    step1Title: "यह आवेदन किसके लिए है?",
    step1Desc: "आयु और लिंग के आधार पर छात्रवृत्तियां, वृद्धावस्था पेंशन और मातृत्व सहायता निर्धारित होती हैं।",
    labelAge: "नागरिक की वर्तमान आयु (वर्षों में)",
    labelGender: "लिंग",
    optFemale: "महिला",
    optMale: "पुरुष",
    optTransgender: "अन्य / ट्रांसजेंडर",
    
    // Step 2
    step2Title: "आप कहां रहते हैं?",
    step2Desc: "कुछ कल्याणकारी योजनाएं ग्रामीण या शहरी क्षेत्र के अनुसार अलग-अलग सहायता देती हैं।",
    labelState: "राज्य / केंद्र शासित प्रदेश",
    labelArea: "निवास का प्रकार",
    optRural: "ग्रामीण (गांव / ग्राम पंचायत)",
    optUrban: "शहरी (शहर / कस्बा / नगर पालिका)",
    optAnyArea: "सभी क्षेत्र",
    
    // Step 3
    step3Title: "आपका मुख्य व्यवसाय क्या है?",
    step3Desc: "किसानों, पारंपरिक कारीगरों, रेहड़ी-पटरी विक्रेताओं और छात्रों के लिए विशेष योजनाएं हैं।",
    labelOccupation: "वर्तमान व्यवसाय",
    occStudent: "विद्यार्थी / छात्र (स्कूल / कॉलेज)",
    occFarmer: "किसान / कृषक",
    occStreetVendor: "स्ट्रीट वेंडर / रेहड़ी-पटरी / ठेला संचालक",
    occArtisan: "कारीगर / दस्तकार (बढ़ई, दर्जी, कुम्हार, लोहार आदि)",
    occSmallBusiness: "लघु व्यवसायी / दुकानदार / व्यापारी",
    occDailyWage: "दैनिक वेतनभोगी / असंगठित मजदूर",
    occUnemployed: "बेरोजगार / नौकरी की तलाश में",
    occSalaried: "वेतनभोगी कर्मचारी (निजी / सरकारी)",
    
    // Step 4
    step4Title: "सामाजिक एवं आर्थिक पृष्ठभूमि",
    step4Desc: "सरकारी कल्याणकारी योजनाएं प्राथमिकता वाले वर्गों को विशेष आर्थिक सहायता प्रदान करती हैं।",
    labelIncome: "परिवार की कुल वार्षिक आय",
    incUnder1L: "₹1,00,000 से कम (कम आय / बीपीएल)",
    inc1LTo25L: "₹1,00,000 से ₹2,50,000 (ईडब्ल्यूएस / निम्न मध्यम)",
    inc25LTo5L: "₹2,50,000 से ₹5,00,000",
    inc5LTo8L: "₹5,00,000 से ₹8,00,000 (नॉन-क्रीमी लेयर)",
    incAbove8L: "₹8,00,000 से अधिक",
    labelCategory: "सामाजिक वर्ग / जाति श्रेणी",
    catGeneral: "सामान्य (General)",
    catOBC: "अन्य पिछड़ा वर्ग (OBC)",
    catSC: "अनुसूचित जाति (SC)",
    catST: "अनुसूचित जनजाति (ST)",
    catEWS: "आर्थिक रूप से कमजोर वर्ग (EWS)",
    labelBPL: "क्या आपके पास बीपीएल / अंत्योदय / खाद्य सुरक्षा राशन कार्ड है?",
    optYes: "हाँ",
    optNo: "नहीं",
    
    // Step 5
    step5Title: "विशेष परिस्थितियां",
    step5Desc: "जो भी विकल्प आपके या आपके परिवार पर लागू होते हैं, उन्हें चुनें।",
    condDifferentlyAbled: "दिव्यांगजन (UDID कार्ड / 40%+ दिव्यांगता)",
    condGirlChild: "परिवार में 10 वर्ष या उससे कम उम्र की बालिका है",
    condPregnantLactating: "गर्भवती या स्तनपान कराने वाली माता",
    condOwnsLand: "परिवार के नाम खेती योग्य कृषि भूमि है",
    condNone: "इनमें से कोई नहीं",
    
    // Results
    resultsTitle: "योजनाएं जिनके आप पात्र हैं",
    resultsSubtitle: "आपकी प्रोफ़ाइल के आधार पर, यहाँ वे योजनाएं हैं जिनमें आप तुरंत आवेदन कर सकते हैं।",
    filterAll: "सभी श्रेणियां",
    filterHealth: "स्वास्थ्य सेवाएं",
    filterAgri: "कृषि एवं किसान",
    filterEdu: "शिक्षा एवं छात्रवृत्ति",
    filterHousing: "आवास योजना",
    filterBiz: "व्यापार एवं ऋण",
    filterWomen: "महिला एवं बाल विकास",
    filterPension: "पेंशन एवं सामाजिक सुरक्षा",
    searchPlaceholder: "कीवर्ड से खोजें (जैसे: छात्रवृत्ति, लोन, किसान, पेंशन)...",
    sortBy: "क्रमबद्ध करें:",
    sortRelevance: "सर्वाधिक उपयुक्त",
    sortBenefit: "अधिकतम वित्तीय लाभ",
    sortName: "योजना नाम (A-Z)",
    noResultsTitle: "कोई योजना मेल नहीं खाती",
    noResultsDesc: "कृपया प्रश्नावली में अपनी आय सीमा या प्राथमिकताओं को बदलकर पुनः प्रयास करें।",
    
    // Scheme Card
    badgeMatch: "100% पात्र",
    badgePotential: "संभावित पात्र",
    benefitValue: "अनुमानित लाभ",
    btnViewDetails: "विवरण व आवेदन देखें",
    btnBookmark: "योजना सहेजें",
    btnBookmarked: "सहेजा गया",
    whyEligible: "आप क्यों पात्र हैं:",
    
    // Scheme Modal
    modalClose: "बंद करें",
    modalOverview: "योजना का संक्षिप्त विवरण",
    modalEligibility: "विस्तृत पात्रता शर्तें",
    modalDocs: "आवश्यक सरकारी दस्तावेज",
    modalSteps: "आवेदन कैसे करें (चरणबद्ध तरीका)",
    modalVisitPortal: "आधिकारिक सरकारी पोर्टल पर जाएं",
    modalPrintChecklist: "मेरी दस्तावेज़ चेकलिस्ट में जोड़ें",
    
    // Checklist Tab
    checklistTitle: "नागरिक संयुक्त दस्तावेज़ संचिका",
    checklistSubtitle: "आपकी सभी पात्र योजनाओं हेतु आवश्यक दस्तावेजों की एकीकृत सूची, ताकि आपको कोई भी दस्तावेज दोबारा न जुटाना पड़े।",
    checklistPrintBtn: "दस्तावेज़ चेकलिस्ट प्रिंट / डाउनलोड करें",
    checklistStatusHave: "मेरे पास उपलब्ध है",
    checklistStatusNeed: "बनवाना बाकी है",
    docWhereToProcure: "कहाँ और कैसे प्राप्त करें:",
    docSchemesRequiring: "इस दस्तावेज की आवश्यकता वाली योजनाएं:",
    totalDocsNeeded: "कुल आवश्यक दस्तावेज:",
    docsReadyCount: "तैयार दस्तावेज:",
    
    // Print Header
    printHeaderTitle: "सरकारी कल्याणकारी योजना आवेदन संचिका (Dossier)",
    printHeaderDate: "दिनांक",
    printNotice: "इस चेकलिस्ट और मूल दस्तावेजों के साथ नजदीकी जन सेवा केंद्र (CSC), ग्राम पंचायत या संबंधित बैंक शाखा में जाएं।"
  }
};

const INDIAN_STATES = [
  "All India (Central)",
  "Andhra Pradesh",
  "Arunachal Pradesh",
  "Assam",
  "Bihar",
  "Chhattisgarh",
  "Goa",
  "Gujarat",
  "Haryana",
  "Himachal Pradesh",
  "Jharkhand",
  "Karnataka",
  "Kerala",
  "Madhya Pradesh",
  "Maharashtra",
  "Manipur",
  "Meghalaya",
  "Mizoram",
  "Nagaland",
  "Odisha",
  "Punjab",
  "Rajasthan",
  "Sikkim",
  "Tamil Nadu",
  "Telangana",
  "Tripura",
  "Uttar Pradesh",
  "Uttarakhand",
  "West Bengal",
  "Delhi (NCT)",
  "Jammu & Kashmir",
  "Ladakh"
];

if (typeof window !== "undefined") {
  window.TRANSLATIONS = TRANSLATIONS;
  window.INDIAN_STATES = INDIAN_STATES;
}
