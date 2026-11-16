// YojanaSetu - Interactive Application Logic & Eligibility Engine
// Fully exposed global API with resilient link handler and responsive category filtering

(function () {
  "use strict";

  // Application State
  const state = {
    lang: localStorage.getItem("yojana_lang") || "en",
    activeTab: "wizard", // 'wizard', 'results', 'all', 'checklist', 'saved'
    wizardStep: 1,
    totalSteps: 5,
    userProfile: {
      age: 24,
      gender: "all",
      state: "All India (Central)",
      area: "all",
      occupation: "farmer",
      income: 200000,
      category: "obc",
      hasBpl: false,
      conditions: []
    },
    filterCategory: "all",
    searchQuery: "",
    sortBy: "match",
    bookmarkedIds: new Set(JSON.parse(localStorage.getItem("yojana_bookmarks") || "[]")),
    checkedDocs: new Set(JSON.parse(localStorage.getItem("yojana_checked_docs") || "[]")),
    qualifiedSchemes: [],
    selectedSchemeForModal: null
  };

  // Human-crafted SVG Icon Registry (Lucide-inspired clean 1.75px stroke)
  const ICONS = {
    shield: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="m9 12 2 2 4-4"/></svg>`,
    health: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M4.8 2.3A.3.3 0 1 0 5 2H4a2 2 0 0 0-2 2v5a6 6 0 0 0 6 6v0a6 6 0 0 0 6-6V4a2 2 0 0 0-2-2h-1a.2.2 0 1 0 .3.3"/><path d="M8 15v1a6 6 0 0 0 6 6v0a6 6 0 0 0 6-6v-4"/><circle cx="20" cy="10" r="2"/></svg>`,
    agriculture: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M7 20h10"/><path d="M10 20c5.5-2.5.8-6.4 3-10"/><path d="M9.5 9.4c1.1.8 1.8 2.2 2.3 3.7-2 .4-3.5.4-4.8-.3-1.2-.6-2.3-1.9-3-4.2 2.8-.5 4.4 0 5.5.8z"/><path d="M14.1 6a7 7 0 0 0-1.1 4c1.9-.1 3.3-.6 4.3-1.4 1-1 1.6-2.3 1.7-4.6-2.7.1-4 1-4.9 2z"/></svg>`,
    education: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>`,
    housing: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>`,
    business: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect width="20" height="14" x="2" y="7" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>`,
    women: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="5"/><path d="M12 13v8"/><path d="M9 18h6"/></svg>`,
    pension: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><line x1="3" x2="21" y1="22" y2="22"/><line x1="6" x2="6" y1="18"/><line x1="10" x2="10" y1="18"/><line x1="14" x2="14" y1="18"/><line x1="18" x2="18" y1="18"/><polygon points="12 2 20 7 4 7"/></svg>`,
    social_security: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg>`,
    check: `<svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>`,
    checkCircle: `<svg class="w-5 h-5 text-emerald-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>`,
    bookmark: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg>`,
    bookmarkFilled: `<svg class="w-5 h-5 text-amber-600 fill-amber-500" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.75"><path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg>`,
    externalLink: `<svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" x2="21" y1="14" y2="3"/></svg>`,
    copy: `<svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>`,
    printer: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect width="12" height="8" x="6" y="14"/></svg>`,
    fileText: `<svg class="w-5 h-5 text-emerald-700" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/><line x1="16" x2="8" y1="13" y2="13"/><line x1="16" x2="8" y1="17" y2="17"/><line x1="10" x2="8" y1="9" y2="9"/></svg>`,
    coins: `<svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><circle cx="8" cy="8" r="6"/><path d="M18.09 10.37A6 6 0 1 1 10.34 18"/><path d="M7 6h1v4"/><path d="m16.71 13.88.7.71-2.82 2.82"/></svg>`,
    arrowRight: `<svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>`,
    arrowLeft: `<svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg>`,
    sparkles: `<svg class="w-5 h-5 text-amber-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3Z"/></svg>`,
    info: `<svg class="w-4 h-4 text-emerald-700" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/></svg>`,
    close: `<svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>`
  };

  // Helper: Get text from translation dictionary
  function t(key) {
    const dict = window.TRANSLATIONS ? window.TRANSLATIONS[state.lang] : {};
    return dict[key] || (window.TRANSLATIONS && window.TRANSLATIONS.en[key]) || key;
  }

  // Get Scheme localized string
  function getLocalized(obj) {
    if (!obj) return "";
    if (typeof obj === "string") return obj;
    return obj[state.lang] || obj.en || "";
  }

  // Category Icon & Badge Styling Map
  function getCategoryVisuals(category) {
    switch (category) {
      case "health":
        return {
          icon: ICONS.health,
          color: "bg-emerald-50 text-emerald-700 border-emerald-200",
          badgeBg: "bg-emerald-100 text-emerald-800",
          name: state.lang === "hi" ? "स्वास्थ्य" : "Healthcare"
        };
      case "agriculture":
        return {
          icon: ICONS.agriculture,
          color: "bg-lime-50 text-lime-800 border-lime-200",
          badgeBg: "bg-lime-100 text-lime-800",
          name: state.lang === "hi" ? "कृषि" : "Agriculture"
        };
      case "education":
        return {
          icon: ICONS.education,
          color: "bg-blue-50 text-blue-700 border-blue-200",
          badgeBg: "bg-blue-100 text-blue-800",
          name: state.lang === "hi" ? "शिक्षा" : "Education"
        };
      case "housing":
        return {
          icon: ICONS.housing,
          color: "bg-indigo-50 text-indigo-700 border-indigo-200",
          badgeBg: "bg-indigo-100 text-indigo-800",
          name: state.lang === "hi" ? "आवास" : "Housing"
        };
      case "business":
        return {
          icon: ICONS.business,
          color: "bg-amber-50 text-amber-800 border-amber-200",
          badgeBg: "bg-amber-100 text-amber-800",
          name: state.lang === "hi" ? "व्यापार" : "Business"
        };
      case "women":
        return {
          icon: ICONS.women,
          color: "bg-rose-50 text-rose-700 border-rose-200",
          badgeBg: "bg-rose-100 text-rose-800",
          name: state.lang === "hi" ? "महिला" : "Women"
        };
      case "pension":
        return {
          icon: ICONS.pension,
          color: "bg-teal-50 text-teal-800 border-teal-200",
          badgeBg: "bg-teal-100 text-teal-800",
          name: state.lang === "hi" ? "पेंशन" : "Pension"
        };
      case "social_security":
      default:
        return {
          icon: ICONS.social_security,
          color: "bg-slate-50 text-slate-700 border-slate-200",
          badgeBg: "bg-slate-100 text-slate-800",
          name: state.lang === "hi" ? "सामाजिक सुरक्षा" : "Social Security"
        };
    }
  }

  // Core Rule Matching Engine
  function evaluateEligibility(scheme, profile) {
    const reasons = [];
    let isEligible = true;
    let matchScore = 100;
    const elig = scheme.eligibility;

    // 1. Age Rule
    const age = Number(profile.age) || 25;
    if (elig.minAge !== undefined && elig.maxAge !== undefined) {
      if (age >= elig.minAge && age <= elig.maxAge) {
        reasons.push({
          type: "pass",
          en: `Age ${age} falls within range (${elig.minAge} - ${elig.maxAge} yrs)`,
          hi: `आयु ${age} वर्ष पात्र सीमा (${elig.minAge} - ${elig.maxAge} वर्ष) में है`
        });
      } else {
        isEligible = false;
        matchScore -= 40;
        reasons.push({
          type: "fail",
          en: `Age ${age} does not meet required range (${elig.minAge} - ${elig.maxAge} yrs)`,
          hi: `आयु ${age} वर्ष आवश्यक सीमा (${elig.minAge} - ${elig.maxAge} वर्ष) से बाहर है`
        });
      }
    }

    // 2. Gender Rule
    if (elig.genders && !elig.genders.includes("all")) {
      const userGen = profile.gender;
      if (elig.genders.includes(userGen) || userGen === "all") {
        reasons.push({
          type: "pass",
          en: `Gender requirement satisfied (${elig.genders.join(", ")})`,
          hi: `लिंग पात्रता पूर्ण (${elig.genders.join(", ")})`
        });
      } else {
        if (elig.specialConditions && elig.specialConditions.includes("has_girl_child") && profile.conditions.includes("has_girl_child")) {
          reasons.push({
            type: "pass",
            en: `Beneficiary girl child eligible in family`,
            hi: `परिवार में बालिका लाभार्थी पात्र है`
          });
        } else {
          isEligible = false;
          matchScore -= 40;
          reasons.push({
            type: "fail",
            en: `Targeted exclusively for: ${elig.genders.join(", ")}`,
            hi: `केवल ${elig.genders.join(", ")} हेतु निर्धारित`
          });
        }
      }
    }

    // 3. Occupation Rule
    if (elig.occupations && !elig.occupations.includes("all")) {
      if (elig.occupations.includes(profile.occupation)) {
        reasons.push({
          type: "pass",
          en: `Occupation matches target group (${profile.occupation})`,
          hi: `व्यवसाय लक्षित समूह से मेल खाता है (${profile.occupation})`
        });
      } else {
        isEligible = false;
        matchScore -= 35;
        reasons.push({
          type: "fail",
          en: `Targeted for: ${elig.occupations.join(", ")}`,
          hi: `लक्षित वर्ग: ${elig.occupations.join(", ")}`
        });
      }
    }

    // 4. Income Limit Rule
    const userIncome = Number(profile.income) || 200000;
    if (elig.maxIncome !== undefined && elig.maxIncome < 10000000) {
      if (userIncome <= elig.maxIncome) {
        reasons.push({
          type: "pass",
          en: `Household income meets limit (₹${elig.maxIncome.toLocaleString("en-IN")})`,
          hi: `पारिवारिक आय सीमा (₹${elig.maxIncome.toLocaleString("en-IN")}) के अंतर्गत है`
        });
      } else {
        isEligible = false;
        matchScore -= 30;
        reasons.push({
          type: "fail",
          en: `Exceeds max income limit of ₹${elig.maxIncome.toLocaleString("en-IN")}`,
          hi: `अधिकतम आय सीमा ₹${elig.maxIncome.toLocaleString("en-IN")} से अधिक`
        });
      }
    }

    // 5. Social Category / Caste Rule
    if (elig.categories && !elig.categories.includes("all")) {
      if (elig.categories.includes(profile.category)) {
        reasons.push({
          type: "pass",
          en: `Qualifies under category (${profile.category.toUpperCase()})`,
          hi: `आरक्षित वर्ग (${profile.category.toUpperCase()}) के अंतर्गत पात्र`
        });
      } else {
        isEligible = false;
        matchScore -= 30;
        reasons.push({
          type: "fail",
          en: `Reserved for categories: ${elig.categories.join(", ").toUpperCase()}`,
          hi: `केवल इन वर्गों हेतु: ${elig.categories.join(", ").toUpperCase()}`
        });
      }
    }

    // 6. Special Conditions (Land, Disability, Girl child, Pregnancy, BPL)
    if (elig.specialConditions && elig.specialConditions.length > 0) {
      for (const cond of elig.specialConditions) {
        if (cond === "bpl_or_low_income") {
          if (profile.hasBpl || userIncome <= 250000) {
            reasons.push({
              type: "pass",
              en: `BPL / Low Income criteria satisfied`,
              hi: `बीपीएल या कम आय मानदंड पूर्ण`
            });
          } else {
            isEligible = false;
            matchScore -= 25;
            reasons.push({
              type: "fail",
              en: `Requires BPL Card or income ≤ ₹2.5 Lakh`,
              hi: `बीपीएल कार्ड या ₹2.5 लाख से कम आय आवश्यक`
            });
          }
        } else if (cond === "owns_cultivable_land") {
          if (profile.conditions.includes("owns_cultivable_land")) {
            reasons.push({
              type: "pass",
              en: `Cultivable landholding confirmed`,
              hi: `खेती योग्य भूमि स्वामित्व की पुष्टि`
            });
          } else {
            isEligible = false;
            matchScore -= 35;
            reasons.push({
              type: "fail",
              en: `Requires cultivable land in applicant's name`,
              hi: `आवेदक के नाम खेती की जमीन आवश्यक`
            });
          }
        } else if (cond === "differently_abled") {
          if (profile.conditions.includes("differently_abled")) {
            reasons.push({
              type: "pass",
              en: `Divyangjan / UDID disability status verified`,
              hi: `दिव्यांगजन / यूडीआईडी स्थिति सत्यापित`
            });
          } else {
            isEligible = false;
            matchScore -= 50;
            reasons.push({
              type: "fail",
              en: `Scheme for persons with ≥40% disability (UDID)`,
              hi: `40%+ दिव्यांगता वाले व्यक्तियों हेतु योजना`
            });
          }
        } else if (cond === "has_girl_child") {
          if (profile.conditions.includes("has_girl_child")) {
            reasons.push({
              type: "pass",
              en: `Has girl child aged 10 or younger`,
              hi: `10 वर्ष या उससे कम उम्र की बालिका उपलब्ध`
            });
          } else {
            isEligible = false;
            matchScore -= 35;
            reasons.push({
              type: "fail",
              en: `Requires girl child aged ≤10 years`,
              hi: `10 वर्ष या उससे कम उम्र की बालिका आवश्यक`
            });
          }
        } else if (cond === "pregnant_or_lactating") {
          if (profile.conditions.includes("pregnant_or_lactating")) {
            reasons.push({
              type: "pass",
              en: `Maternity condition verified`,
              hi: `मातृत्व पोषण स्थिति सत्यापित`
            });
          } else {
            isEligible = false;
            matchScore -= 40;
            reasons.push({
              type: "fail",
              en: `Targeted for pregnant/lactating mothers`,
              hi: `गर्भवती या धात्री माताओं हेतु लक्षित`
            });
          }
        }
      }
    }

    matchScore = Math.max(0, Math.min(100, matchScore));
    return {
      isEligible,
      matchScore,
      reasons
    };
  }

  // Run calculation over all schemes
  function calculateAllMatches() {
    const rawSchemes = window.SCHEMES_DATA || [];
    state.qualifiedSchemes = rawSchemes.map((scheme) => {
      const evaluation = evaluateEligibility(scheme, state.userProfile);
      return {
        ...scheme,
        isEligible: evaluation.isEligible,
        matchScore: evaluation.matchScore,
        reasons: evaluation.reasons
      };
    });
  }

  // Count matches in real-time for wizard feedback
  function getLiveMatchCount() {
    const rawSchemes = window.SCHEMES_DATA || [];
    let count = 0;
    for (const scheme of rawSchemes) {
      const evalResult = evaluateEligibility(scheme, state.userProfile);
      if (evalResult.isEligible) count++;
    }
    return count;
  }

  // Toast notification
  function showToast(message) {
    const existing = document.getElementById("yojana-toast");
    if (existing) existing.remove();

    const toast = document.createElement("div");
    toast.id = "yojana-toast";
    toast.className = "fixed bottom-5 right-5 z-50 flex items-center gap-3 bg-slate-900 text-white px-4 py-3 rounded-xl shadow-xl text-sm font-medium transition-all transform duration-200 border border-slate-700 animate-slide-up";
    toast.innerHTML = `
      <span class="text-emerald-400">${ICONS.checkCircle}</span>
      <span>${message}</span>
    `;
    document.body.appendChild(toast);
    setTimeout(() => {
      if (toast) toast.remove();
    }, 3200);
  }

  // Resilient External Government Link Opener
  window.openOfficialGovLink = function (url, event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    if (!url) return;

    try {
      // First attempt: standard window.open in a new tab
      const win = window.open(url, "_blank", "noopener,noreferrer");
      if (!win || win.closed || typeof win.closed === "undefined") {
        // If popup blocker intervened, copy to clipboard automatically as a fallback
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(url).then(() => {
            showToast(state.lang === "hi" 
              ? "पॉपअप अवरुद्ध था। आधिकारिक लिंक क्लिपबोर्ड में कॉपी हो गया! नए टैब में खोलें।" 
              : "Popup was blocked. Official link copied to clipboard! Paste into browser.");
          }).catch(() => {
            window.location.href = url;
          });
        } else {
          window.location.href = url;
        }
      } else {
        showToast(state.lang === "hi" ? "आधिकारिक सरकारी पोर्टल खोला जा रहा है..." : "Opening official government portal...");
      }
    } catch (e) {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(url);
        showToast("Link copied to clipboard: " + url);
      } else {
        window.location.href = url;
      }
    }
  };

  // Dedicated Copy Link to Clipboard
  window.copyLinkToClipboard = function (url, event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    if (!url) return;

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url).then(() => {
        showToast(state.lang === "hi" ? "आधिकारिक पोर्टल लिंक क्लिपबोर्ड में कॉपी हो गया! ✓" : "Official portal link copied to clipboard! ✓");
      }).catch(() => {
        prompt("Copy official link:", url);
      });
    } else {
      prompt("Copy official link:", url);
    }
  };

  // Set category filter from UI buttons
  window.setCategoryFilter = function (catId, sourceTab) {
    state.filterCategory = catId;
    if (sourceTab === "all" || state.activeTab === "all") {
      renderAllSchemesTab();
    } else {
      renderResultsTab();
    }
  };

  // Switch category filter and jump to All Schemes Catalog if not found in results
  window.viewCategoryInCatalog = function (catId) {
    state.filterCategory = catId;
    state.activeTab = "all";
    renderApp();
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  // Search query updater
  window.setSearchQuery = function (query, sourceTab) {
    state.searchQuery = query;
    if (sourceTab === "all" || state.activeTab === "all") {
      renderAllSchemesTab();
    } else {
      renderResultsTab();
    }
  };

  // Sort updater
  window.setSortBy = function (sortVal, sourceTab) {
    state.sortBy = sortVal;
    if (sourceTab === "all" || state.activeTab === "all") {
      renderAllSchemesTab();
    } else {
      renderResultsTab();
    }
  };

  // BPL toggle in Step 4
  window.toggleBpl = function () {
    state.userProfile.hasBpl = !state.userProfile.hasBpl;
    renderWizardStep();
  };

  // Bookmark scheme toggle
  window.toggleBookmark = function (schemeId, event) {
    if (event) event.stopPropagation();
    if (state.bookmarkedIds.has(schemeId)) {
      state.bookmarkedIds.delete(schemeId);
      showToast(state.lang === "hi" ? "योजना सूची से हटा दी गई" : "Removed from saved schemes");
    } else {
      state.bookmarkedIds.add(schemeId);
      showToast(state.lang === "hi" ? "योजना सहेज ली गई! चेकलिस्ट में जुड़ी" : "Scheme saved to your dossier!");
    }
    localStorage.setItem("yojana_bookmarks", JSON.stringify(Array.from(state.bookmarkedIds)));
    updateHeaderCounters();
    renderActiveTab();
  };

  // Toggle document checked state
  window.toggleDocCheck = function (docKey) {
    if (state.checkedDocs.has(docKey)) {
      state.checkedDocs.delete(docKey);
    } else {
      state.checkedDocs.add(docKey);
    }
    localStorage.setItem("yojana_checked_docs", JSON.stringify(Array.from(state.checkedDocs)));
    renderChecklistTab();
  };

  // Language switcher
  window.switchLanguage = function (newLang) {
    state.lang = newLang;
    localStorage.setItem("yojana_lang", newLang);
    renderApp();
  };

  // Navigation tab switcher
  window.switchTab = function (tab) {
    state.activeTab = tab;
    if (tab === "results") {
      calculateAllMatches();
    }
    renderApp();
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  // Wizard Step Navigation
  window.goToWizardStep = function (step) {
    state.wizardStep = Math.max(1, Math.min(state.totalSteps, step));
    renderWizardStep();
  };

  window.nextWizardStep = function () {
    if (state.wizardStep < state.totalSteps) {
      state.wizardStep++;
      renderWizardStep();
    } else {
      state.activeTab = "results";
      calculateAllMatches();
      renderApp();
      window.scrollTo({ top: 0, behavior: "smooth" });
    }
  };

  window.prevWizardStep = function () {
    if (state.wizardStep > 1) {
      state.wizardStep--;
      renderWizardStep();
    }
  };

  // Open Scheme Details Modal
  window.openSchemeModal = function (schemeId) {
    const scheme = (window.SCHEMES_DATA || []).find((s) => s.id === schemeId);
    if (!scheme) return;
    state.selectedSchemeForModal = scheme;
    renderModal();
  };

  window.closeSchemeModal = function () {
    state.selectedSchemeForModal = null;
    const modalEl = document.getElementById("scheme-modal");
    if (modalEl) modalEl.classList.add("hidden");
  };

  // Print application dossier
  window.printDossier = function () {
    window.print();
  };

  // Update header bookmark badge (desktop and mobile)
  function updateHeaderCounters() {
    const badgeEl = document.getElementById("bookmark-counter");
    if (badgeEl) {
      badgeEl.textContent = state.bookmarkedIds.size;
      badgeEl.classList.toggle("hidden", state.bookmarkedIds.size === 0);
    }
    const mobileBadge = document.getElementById("mobile-bookmark-counter");
    if (mobileBadge) {
      mobileBadge.classList.toggle("hidden", state.bookmarkedIds.size === 0);
    }
  }

  // Render Scheme Card
  function renderSchemeCard(scheme) {
    const visual = getCategoryVisuals(scheme.category);
    const isBookmarked = state.bookmarkedIds.has(scheme.id);
    const title = getLocalized(scheme.name);
    const desc = getLocalized(scheme.shortDescription);
    const benefit = getLocalized(scheme.benefitAmount);
    const ministry = getLocalized(scheme.ministry);
    const evalData = evaluateEligibility(scheme, state.userProfile);

    // Statutory government badge
    let statutoryBadge = "OFFICIAL WELFARE SCHEME";
    if (scheme.category === "health") statutoryBadge = "100% CASHLESS HEALTHCARE";
    else if (scheme.category === "agriculture") statutoryBadge = "DIRECT BENEFIT TRANSFER (DBT)";
    else if (scheme.category === "education") statutoryBadge = "GOVT SCHOLARSHIP & STIPEND";
    else if (scheme.category === "business") statutoryBadge = "COLLATERAL-FREE CREDIT";
    else if (scheme.category === "housing") statutoryBadge = "HOUSING FOR ALL GRANT";
    else if (scheme.category === "women") statutoryBadge = "WOMEN EMPOWERMENT SCHEME";
    else if (scheme.category === "pension") statutoryBadge = "SOVEREIGN GUARANTEED PENSION";

    // Reasons chips (display up to 3 pass reasons)
    const passReasons = (evalData.reasons || [])
      .filter((r) => r.type === "pass")
      .slice(0, 3)
      .map((r) => `<span class="inline-flex items-center gap-1 text-xs font-bold px-2.5 py-1 rounded-md bg-emerald-50 text-emerald-950 border border-emerald-300">
        <span class="text-emerald-700">${ICONS.check}</span>
        <span>${r[state.lang] || r.en}</span>
      </span>`)
      .join("");

    return `
      <div class="scheme-card bg-white rounded-3xl border border-slate-200/90 p-5 md:p-6 shadow-xs hover:shadow-md transition-all duration-200 flex flex-col justify-between relative group">
        <div>
          <!-- Statutory Sub-header -->
          <div class="flex items-center justify-between text-[10px] font-black tracking-widest text-slate-500 uppercase pb-2.5 mb-3 border-b border-slate-100">
            <span class="text-emerald-900 font-extrabold flex items-center gap-1">
              <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span>
              ${statutoryBadge}
            </span>
            <span>Central & State</span>
          </div>

          <!-- Card Header -->
          <div class="flex items-start justify-between gap-3 mb-3">
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 rounded-2xl flex items-center justify-center border font-bold shrink-0 ${visual.color}">
                ${visual.icon}
              </div>
              <div>
                <button 
                  onclick="setCategoryFilter('${scheme.category}', '${state.activeTab}')" 
                  class="inline-block text-xs font-black px-2.5 py-0.5 rounded-full ${visual.badgeBg} hover:opacity-80 transition-opacity text-left">
                  ${visual.name}
                </button>
                <span class="text-xs font-medium text-slate-500 block mt-0.5 line-clamp-1">${ministry}</span>
              </div>
            </div>

            <!-- Bookmark Button -->
            <button 
              onclick="toggleBookmark('${scheme.id}', event)" 
              class="p-2 rounded-xl text-slate-400 hover:text-amber-600 hover:bg-amber-50 transition-colors border border-transparent hover:border-amber-200"
              title="${isBookmarked ? t("btnBookmarked") : t("btnBookmark")}">
              ${isBookmarked ? ICONS.bookmarkFilled : ICONS.bookmark}
            </button>
          </div>

          <!-- Title & Description -->
          <h3 class="text-lg md:text-xl font-black text-slate-950 group-hover:text-emerald-900 transition-colors cursor-pointer leading-snug" onclick="openSchemeModal('${scheme.id}')">
            ${title}
          </h3>
          <p class="text-sm font-medium text-slate-600 mt-2 line-clamp-2 leading-relaxed cursor-pointer" onclick="openSchemeModal('${scheme.id}')">
            ${desc}
          </p>

          <!-- Benefit Callout -->
          <div class="mt-4 p-3.5 rounded-2xl bg-amber-50/90 border border-amber-300/80 flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-amber-100 border border-amber-300 text-amber-950 flex items-center justify-center font-black shrink-0">
              ₹
            </div>
            <div>
              <span class="text-[10px] uppercase tracking-wider font-extrabold text-amber-900/90 block">${t("benefitValue")}</span>
              <span class="text-base md:text-lg font-black text-amber-950 tracking-tight">${benefit}</span>
            </div>
          </div>

          <!-- Qualification Chips -->
          <div class="mt-4">
            <span class="text-xs font-extrabold text-slate-700 block mb-1.5 uppercase tracking-wider">${t("whyEligible")}</span>
            <div class="flex flex-wrap gap-1.5">
              ${passReasons || `<span class="text-xs font-bold text-slate-400 italic">${t("badgeMatch")}</span>`}
            </div>
          </div>
        </div>

        <!-- Card Footer Actions -->
        <div class="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between gap-3">
          <button 
            onclick="openSchemeModal('${scheme.id}')"
            class="inline-flex items-center gap-1.5 text-xs md:text-sm font-black text-emerald-800 hover:text-emerald-950 hover:underline">
            <span>${t("btnViewDetails")}</span>
            ${ICONS.arrowRight}
          </button>
          
          <div class="flex items-center gap-1">
            <button 
              type="button"
              onclick="openOfficialGovLink('${scheme.officialUrl}', event)"
              class="inline-flex items-center gap-1 text-xs text-emerald-900 hover:text-emerald-950 px-2.5 py-1.5 rounded-lg border border-emerald-200 bg-emerald-50/70 hover:bg-emerald-100 font-bold transition-colors"
              title="Open Official Portal">
              <span>${scheme.portalName}</span>
              ${ICONS.externalLink}
            </button>
            <button 
              type="button"
              onclick="copyLinkToClipboard('${scheme.officialUrl}', event)"
              class="p-1.5 rounded-lg border border-slate-200 text-slate-400 hover:text-slate-700 hover:bg-slate-50 transition-colors"
              title="Copy official link">
              ${ICONS.copy}
            </button>
          </div>
        </div>
      </div>
    `;
  }

  // Real-time live benefit estimator calculation
  function updateLiveBenefitCounter() {
    const counterEl = document.getElementById("live-benefit-counter");
    if (!counterEl) return;

    let maxHospitalCover = 0;
    let directCashSum = 0;
    const rawSchemes = window.SCHEMES_DATA || [];

    for (const scheme of rawSchemes) {
      const evalResult = evaluateEligibility(scheme, state.userProfile);
      if (evalResult.isEligible) {
        if (scheme.id === "pm-jay") maxHospitalCover = 500000;
        if (scheme.id === "pm-kisan") directCashSum += 6000;
        if (scheme.id === "ladli-behna-state") directCashSum += 15000;
        if (scheme.id === "pm-svanidhi") directCashSum += 10000;
        if (scheme.id === "nmms-scholarship") directCashSum += 12000;
        if (scheme.id === "post-matric-sc-st" || scheme.id === "post-matric-obc") directCashSum += 25000;
        if (scheme.id === "atal-pension") directCashSum += 60000;
        if (scheme.id === "old-age-pension-ignoaps") directCashSum += 12000;
        if (scheme.id === "pm-matru-vandana") directCashSum += 6000;
      }
    }

    const total = maxHospitalCover + (directCashSum > 0 ? directCashSum : 18000);
    counterEl.textContent = "Up to ₹" + total.toLocaleString("en-IN") + "+";
  }

  // Render Wizard Step View
  function renderWizardStep() {
    const stepContainer = document.getElementById("wizard-step-container");
    if (!stepContainer) return;

    updateLiveBenefitCounter();

    const p = state.userProfile;
    let html = "";

    const progressPercent = (state.wizardStep / state.totalSteps) * 100;
    const matchCount = getLiveMatchCount();

    const headerHtml = `
      <div class="mb-6">
        <div class="flex items-center justify-between text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">
          <span>${t("step")} ${state.wizardStep} ${t("of")} ${state.totalSteps}</span>
          <span class="text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200 font-bold flex items-center gap-1">
            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            ${matchCount} ${t("liveMatchCount")}
          </span>
        </div>
        <div class="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
          <div class="bg-gradient-to-r from-emerald-600 to-teal-500 h-2 rounded-full transition-all duration-300" style="width: ${progressPercent}%"></div>
        </div>
      </div>
    `;

    if (state.wizardStep === 1) {
      // Step 1: Age & Gender
      html = `
        ${headerHtml}
        <h2 class="text-xl md:text-2xl font-bold text-slate-900 mb-1">${t("step1Title")}</h2>
        <p class="text-sm text-slate-600 mb-6">${t("step1Desc")}</p>

        <div class="space-y-6">
          <div>
            <div class="flex items-center justify-between mb-2">
              <label class="text-sm font-semibold text-slate-800">${t("labelAge")}</label>
              <span id="age-display" class="text-base font-extrabold text-emerald-800 bg-emerald-50 px-3 py-1 rounded-lg border border-emerald-200">${p.age} years</span>
            </div>
            <input 
              type="range" 
              min="1" 
              max="90" 
              value="${p.age}" 
              id="input-age-range"
              class="w-full accent-emerald-700 cursor-pointer h-2 bg-slate-200 rounded-lg"
              oninput="document.getElementById('age-display').textContent = this.value + ' years'; updateProfileField('age', Number(this.value));">
            <div class="flex justify-between text-xs text-slate-400 mt-1">
              <span>Child (0-14)</span>
              <span>Youth (15-35)</span>
              <span>Adult (36-59)</span>
              <span>Senior (60+)</span>
            </div>
          </div>

          <div>
            <label class="text-sm font-semibold text-slate-800 block mb-2">${t("labelGender")}</label>
            <div class="grid grid-cols-3 gap-3">
              ${[
                { id: "female", label: t("optFemale"), icon: "♀" },
                { id: "male", label: t("optMale"), icon: "♂" },
                { id: "all", label: t("optTransgender"), icon: "⚧" }
              ].map((g) => `
                <button 
                  type="button"
                  onclick="updateProfileField('gender', '${g.id}');"
                  class="p-4 rounded-xl border text-center transition-all ${
                    p.gender === g.id
                      ? "border-emerald-600 bg-emerald-50/70 text-emerald-900 font-bold shadow-sm"
                      : "border-slate-200 bg-white text-slate-700 hover:border-slate-300"
                  }">
                  <span class="text-xl block mb-1">${g.icon}</span>
                  <span class="text-sm">${g.label}</span>
                </button>
              `).join("")}
            </div>
          </div>
        </div>
      `;
    } else if (state.wizardStep === 2) {
      // Step 2: Location
      const statesList = window.INDIAN_STATES || ["All India (Central)"];
      html = `
        ${headerHtml}
        <h2 class="text-xl md:text-2xl font-bold text-slate-900 mb-1">${t("step2Title")}</h2>
        <p class="text-sm text-slate-600 mb-6">${t("step2Desc")}</p>

        <div class="space-y-6">
          <div>
            <label class="text-sm font-semibold text-slate-800 block mb-2">${t("labelState")}</label>
            <select 
              id="select-state" 
              class="w-full p-3.5 rounded-xl border border-slate-300 bg-white text-slate-800 font-medium focus:ring-2 focus:ring-emerald-500 focus:outline-none"
              onchange="updateProfileField('state', this.value);">
              ${statesList.map((st) => `<option value="${st}" ${p.state === st ? "selected" : ""}>${st}</option>`).join("")}
            </select>
          </div>

          <div>
            <label class="text-sm font-semibold text-slate-800 block mb-2">${t("labelArea")}</label>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
              ${[
                { id: "rural", title: t("optRural"), desc: "Gram Panchayat, Agricultural hamlets" },
                { id: "urban", title: t("optUrban"), desc: "Town, Municipality, Metro ward" },
                { id: "all", title: t("optAnyArea"), desc: "Applicable everywhere" }
              ].map((a) => `
                <button 
                  type="button"
                  onclick="updateProfileField('area', '${a.id}');"
                  class="p-4 rounded-xl border text-left transition-all ${
                    p.area === a.id
                      ? "border-emerald-600 bg-emerald-50/70 text-emerald-900 shadow-sm"
                      : "border-slate-200 bg-white text-slate-700 hover:border-slate-300"
                  }">
                  <span class="text-sm font-bold block">${a.title}</span>
                  <span class="text-xs text-slate-500 mt-1 block">${a.desc}</span>
                </button>
              `).join("")}
            </div>
          </div>
        </div>
      `;
    } else if (state.wizardStep === 3) {
      // Step 3: Occupation
      const occs = [
        { id: "farmer", label: t("occFarmer"), icon: ICONS.agriculture },
        { id: "student", label: t("occStudent"), icon: ICONS.education },
        { id: "street_vendor", label: t("occStreetVendor"), icon: ICONS.business },
        { id: "artisan", label: t("occArtisan"), icon: ICONS.housing },
        { id: "small_business", label: t("occSmallBusiness"), icon: ICONS.coins },
        { id: "daily_wage", label: t("occDailyWage"), icon: ICONS.pension },
        { id: "unemployed", label: t("occUnemployed"), icon: ICONS.shield },
        { id: "salaried", label: t("occSalaried"), icon: ICONS.social_security }
      ];

      html = `
        ${headerHtml}
        <h2 class="text-xl md:text-2xl font-bold text-slate-900 mb-1">${t("step3Title")}</h2>
        <p class="text-sm text-slate-600 mb-6">${t("step3Desc")}</p>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 max-h-[360px] overflow-y-auto pr-1">
          ${occs.map((o) => `
            <button 
              type="button"
              onclick="updateProfileField('occupation', '${o.id}');"
              class="p-4 rounded-xl border flex items-center gap-3.5 text-left transition-all ${
                p.occupation === o.id
                  ? "border-emerald-600 bg-emerald-50/70 text-emerald-950 font-bold shadow-sm"
                  : "border-slate-200 bg-white text-slate-700 hover:border-slate-300"
              }">
              <div class="w-9 h-9 rounded-lg flex items-center justify-center shrink-0 ${p.occupation === o.id ? "bg-emerald-600 text-white" : "bg-slate-100 text-slate-600"}">
                ${o.icon}
              </div>
              <span class="text-sm">${o.label}</span>
            </button>
          `).join("")}
        </div>
      `;
    } else if (state.wizardStep === 4) {
      // Step 4: Income & Category
      html = `
        ${headerHtml}
        <h2 class="text-xl md:text-2xl font-bold text-slate-900 mb-1">${t("step4Title")}</h2>
        <p class="text-sm text-slate-600 mb-6">${t("step4Desc")}</p>

        <div class="space-y-6">
          <div>
            <label class="text-sm font-semibold text-slate-800 block mb-2">${t("labelIncome")}</label>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              ${[
                { val: 100000, label: t("incUnder1L") },
                { val: 250000, label: t("inc1LTo25L") },
                { val: 500000, label: t("inc25LTo5L") },
                { val: 800000, label: t("inc5LTo8L") },
                { val: 1500000, label: t("incAbove8L") }
              ].map((inc) => `
                <button 
                  type="button"
                  onclick="updateProfileField('income', ${inc.val});"
                  class="p-3.5 rounded-xl border text-left text-sm transition-all ${
                    p.income === inc.val
                      ? "border-emerald-600 bg-emerald-50/70 text-emerald-900 font-bold shadow-sm"
                      : "border-slate-200 bg-white text-slate-700 hover:border-slate-300"
                  }">
                  ${inc.label}
                </button>
              `).join("")}
            </div>
          </div>

          <div>
            <label class="text-sm font-semibold text-slate-800 block mb-2">${t("labelCategory")}</label>
            <div class="grid grid-cols-2 sm:grid-cols-5 gap-2">
              ${[
                { id: "general", label: t("catGeneral") },
                { id: "obc", label: t("catOBC") },
                { id: "sc", label: t("catSC") },
                { id: "st", label: t("catST") },
                { id: "ews", label: t("catEWS") }
              ].map((c) => `
                <button 
                  type="button"
                  onclick="updateProfileField('category', '${c.id}');"
                  class="p-3 rounded-xl border text-center text-xs md:text-sm transition-all ${
                    p.category === c.id
                      ? "border-emerald-600 bg-emerald-50/70 text-emerald-900 font-bold shadow-sm"
                      : "border-slate-200 bg-white text-slate-700 hover:border-slate-300"
                  }">
                  ${c.label}
                </button>
              `).join("")}
            </div>
          </div>

          <!-- BPL Card Switch -->
          <div class="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-200">
            <div>
              <span class="text-sm font-bold text-slate-900 block">${t("labelBPL")}</span>
              <span class="text-xs text-slate-500">Subsidized rations, housing grants & free LPG</span>
            </div>
            <button 
              type="button"
              onclick="toggleBpl();"
              class="w-14 h-8 flex items-center rounded-full p-1 duration-300 cursor-pointer ${
                p.hasBpl ? "bg-emerald-600 justify-end" : "bg-slate-300 justify-start"
              }">
              <div class="bg-white w-6 h-6 rounded-full shadow-md transform"></div>
            </button>
          </div>
        </div>
      `;
    } else if (state.wizardStep === 5) {
      // Step 5: Special Circumstances
      const conditionsList = [
        { id: "differently_abled", label: t("condDifferentlyAbled"), badge: "PwD" },
        { id: "has_girl_child", label: t("condGirlChild"), badge: "Sukanya / Beti" },
        { id: "pregnant_lactating", label: t("condPregnantLactating"), badge: "PMMVY" },
        { id: "owns_cultivable_land", label: t("condOwnsLand"), badge: "PM-Kisan / KCC" }
      ];

      html = `
        ${headerHtml}
        <h2 class="text-xl md:text-2xl font-bold text-slate-900 mb-1">${t("step5Title")}</h2>
        <p class="text-sm text-slate-600 mb-6">${t("step5Desc")}</p>

        <div class="space-y-3">
          ${conditionsList.map((cond) => {
            const isChecked = p.conditions.includes(cond.id);
            return `
              <div 
                onclick="toggleCondition('${cond.id}');"
                class="p-4 rounded-xl border flex items-center justify-between cursor-pointer transition-all ${
                  isChecked
                    ? "border-emerald-600 bg-emerald-50/70 shadow-sm"
                    : "border-slate-200 bg-white hover:border-slate-300"
                }">
                <div class="flex items-center gap-3">
                  <div class="w-5 h-5 rounded-md border flex items-center justify-center ${
                    isChecked ? "bg-emerald-600 border-emerald-600 text-white" : "border-slate-300 bg-white"
                  }">
                    ${isChecked ? ICONS.check : ""}
                  </div>
                  <div>
                    <span class="text-sm font-semibold text-slate-900 block">${cond.label}</span>
                    <span class="text-xs text-slate-500">${cond.badge}</span>
                  </div>
                </div>
              </div>
            `;
          }).join("")}
        </div>
      `;
    }

    // Step Navigation
    html += `
      <div class="mt-8 pt-6 border-t border-slate-100 flex items-center justify-between">
        ${
          state.wizardStep > 1
            ? `<button 
                type="button" 
                onclick="prevWizardStep()" 
                class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 font-semibold text-sm hover:bg-slate-50 transition-colors">
                ${ICONS.arrowLeft}
                <span>${t("btnPrev")}</span>
              </button>`
            : `<div></div>`
        }

        <button 
          type="button" 
          onclick="nextWizardStep()" 
          class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-sm shadow-md hover:shadow-lg transition-all">
          <span>${state.wizardStep === state.totalSteps ? t("btnCalculate") : t("btnNext")}</span>
          ${state.wizardStep === state.totalSteps ? ICONS.sparkles : ICONS.arrowRight}
        </button>
      </div>
    `;

    stepContainer.innerHTML = html;
  }

  // Update profile fields
  window.updateProfileField = function (field, value) {
    state.userProfile[field] = value;
    renderWizardStep();
  };

  window.toggleCondition = function (condId) {
    const list = state.userProfile.conditions;
    const idx = list.indexOf(condId);
    if (idx > -1) {
      list.splice(idx, 1);
    } else {
      list.push(condId);
    }
    renderWizardStep();
  };

  // Category Configuration with Accurate Counts
  function getCategoryDefinitions(dataset) {
    const counts = {
      all: dataset.length,
      health: 0,
      agriculture: 0,
      education: 0,
      housing: 0,
      business: 0,
      women: 0,
      pension: 0,
      social_security: 0
    };

    dataset.forEach((s) => {
      if (counts[s.category] !== undefined) {
        counts[s.category]++;
      }
    });

    return [
      { id: "all", label: t("filterAll"), count: counts.all },
      { id: "health", label: t("filterHealth"), count: counts.health },
      { id: "agriculture", label: t("filterAgri"), count: counts.agriculture },
      { id: "education", label: t("filterEdu"), count: counts.education },
      { id: "housing", label: t("filterHousing"), count: counts.housing },
      { id: "business", label: t("filterBiz"), count: counts.business },
      { id: "women", label: t("filterWomen"), count: counts.women },
      { id: "pension", label: t("filterPension"), count: counts.pension },
      { id: "social_security", label: state.lang === "hi" ? "सामाजिक सुरक्षा" : "Social Security", count: counts.social_security }
    ];
  }

  // Render Scheme Results Tab
  function renderResultsTab() {
    const container = document.getElementById("results-container");
    if (!container) return;

    const qualifiedList = state.qualifiedSchemes.filter((s) => s.isEligible);
    const categoryDefs = getCategoryDefinitions(qualifiedList);

    let list = [...qualifiedList];

    if (state.filterCategory !== "all") {
      list = list.filter((s) => s.category === state.filterCategory);
    }

    if (state.searchQuery.trim()) {
      const q = state.searchQuery.toLowerCase().trim();
      list = list.filter((s) => {
        const nameEn = (s.name.en || "").toLowerCase();
        const nameHi = (s.name.hi || "").toLowerCase();
        const descEn = (s.shortDescription.en || "").toLowerCase();
        const descHi = (s.shortDescription.hi || "").toLowerCase();
        const tags = (s.tags || []).join(" ").toLowerCase();
        return nameEn.includes(q) || nameHi.includes(q) || descEn.includes(q) || descHi.includes(q) || tags.includes(q);
      });
    }

    // Sort
    if (state.sortBy === "benefit") {
      list.sort((a, b) => (b.eligibility.maxIncome || 0) - (a.eligibility.maxIncome || 0));
    } else if (state.sortBy === "name") {
      list.sort((a, b) => getLocalized(a.name).localeCompare(getLocalized(b.name)));
    } else {
      list.sort((a, b) => b.matchScore - a.matchScore);
    }

    container.innerHTML = `
      <div class="space-y-6">
        <!-- Results Header Banner -->
        <div class="bg-gradient-to-r from-emerald-800 to-teal-900 text-white rounded-3xl p-6 md:p-8 shadow-md relative overflow-hidden">
          <div class="relative z-10 max-w-2xl">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-200 border border-emerald-400/30 text-xs font-semibold mb-3">
              ${ICONS.shield}
              ${t("badgeVerified")}
            </span>
            <h1 class="text-2xl md:text-3xl font-extrabold tracking-tight">
              ${t("resultsTitle")}: <span class="text-amber-400">${qualifiedList.length}</span>
            </h1>
            <p class="text-sm md:text-base text-emerald-100/90 mt-2 leading-relaxed">
              ${t("resultsSubtitle")}
            </p>

            <div class="flex flex-wrap items-center gap-3 mt-5">
              <button 
                onclick="switchTab('wizard')"
                class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white text-xs md:text-sm font-semibold border border-white/20 backdrop-blur-sm transition-all">
                ${ICONS.arrowLeft}
                <span>${t("btnRecalculate")}</span>
              </button>

              <button 
                onclick="switchTab('checklist')"
                class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 text-xs md:text-sm font-bold shadow-md transition-all">
                ${ICONS.fileText}
                <span>${t("navChecklist")}</span>
              </button>

              <button 
                onclick="switchTab('all')"
                class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white text-xs md:text-sm font-semibold border border-white/20 backdrop-blur-sm transition-all">
                <span>Browse All 30 Schemes</span>
                ${ICONS.arrowRight}
              </button>
            </div>
          </div>
        </div>

        <!-- Citizen Action Roadmap -->
        <div class="bg-white rounded-2xl border border-slate-200/90 p-4 shadow-xs">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-xs">
            <div class="flex items-center gap-2.5 p-2 rounded-xl bg-emerald-50/80 border border-emerald-300 text-emerald-950 font-bold">
              <span class="w-6 h-6 rounded-lg bg-emerald-800 text-white flex items-center justify-center font-black shrink-0 text-[11px]">1</span>
              <span>Review Benefits</span>
            </div>
            <div class="flex items-center gap-2.5 p-2 rounded-xl bg-slate-50 border border-slate-200 text-slate-800 font-bold">
              <span class="w-6 h-6 rounded-lg bg-slate-800 text-white flex items-center justify-center font-black shrink-0 text-[11px]">2</span>
              <span>Save Scheme</span>
            </div>
            <div class="flex items-center gap-2.5 p-2 rounded-xl bg-slate-50 border border-slate-200 text-slate-800 font-bold">
              <span class="w-6 h-6 rounded-lg bg-slate-800 text-white flex items-center justify-center font-black shrink-0 text-[11px]">3</span>
              <span>Check Documents</span>
            </div>
            <div class="flex items-center gap-2.5 p-2 rounded-xl bg-slate-50 border border-slate-200 text-slate-800 font-bold">
              <span class="w-6 h-6 rounded-lg bg-slate-800 text-white flex items-center justify-center font-black shrink-0 text-[11px]">4</span>
              <span>Print Dossier for CSC</span>
            </div>
          </div>
        </div>

        <!-- Filter Bar & Search -->
        <div class="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm space-y-4">
          <div class="flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
            <!-- Search -->
            <div class="relative flex-1">
              <input 
                type="text" 
                id="search-input"
                placeholder="${t("searchPlaceholder")}" 
                value="${state.searchQuery}"
                oninput="setSearchQuery(this.value, 'results')"
                class="w-full pl-4 pr-10 py-2.5 rounded-xl border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500">
            </div>

            <!-- Sort By -->
            <div class="flex items-center gap-2 shrink-0">
              <span class="text-xs font-medium text-slate-500">${t("sortBy")}</span>
              <select 
                class="p-2 rounded-xl border border-slate-300 text-xs font-medium bg-white focus:outline-none"
                onchange="setSortBy(this.value, 'results')">
                <option value="match" ${state.sortBy === "match" ? "selected" : ""}>${t("sortRelevance")}</option>
                <option value="benefit" ${state.sortBy === "benefit" ? "selected" : ""}>${t("sortBenefit")}</option>
                <option value="name" ${state.sortBy === "name" ? "selected" : ""}>${t("sortName")}</option>
              </select>
            </div>
          </div>

          <!-- Category Chips with Badges -->
          <div class="flex items-center gap-2 overflow-x-auto pb-1 scrollbar-none">
            ${categoryDefs.map((c) => `
              <button 
                type="button"
                onclick="setCategoryFilter('${c.id}', 'results')"
                class="px-3.5 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition-all flex items-center gap-1.5 ${
                  state.filterCategory === c.id
                    ? "bg-emerald-700 text-white shadow-sm ring-2 ring-emerald-500/50"
                    : "bg-slate-100 text-slate-700 hover:bg-slate-200"
                }">
                <span>${c.label}</span>
                <span class="text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                  state.filterCategory === c.id ? "bg-white/20 text-white" : "bg-slate-200 text-slate-600"
                }">${c.count}</span>
              </button>
            `).join("")}
          </div>
        </div>

        <!-- Schemes Grid -->
        ${
          list.length > 0
            ? `<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                ${list.map((scheme) => renderSchemeCard(scheme)).join("")}
              </div>`
            : `
              <div class="bg-white rounded-2xl border border-slate-200 p-10 text-center max-w-lg mx-auto shadow-sm">
                <div class="w-16 h-16 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center mx-auto mb-4 border border-amber-200">
                  ${ICONS.info}
                </div>
                <h3 class="text-lg font-bold text-slate-900">${t("noResultsTitle")}</h3>
                <p class="text-sm text-slate-500 mt-2">
                  ${state.filterCategory !== "all" 
                    ? `No schemes under this category matched your current profile answers (e.g., occupation or age).` 
                    : t("noResultsDesc")}
                </p>
                <div class="mt-5 flex flex-wrap items-center justify-center gap-3">
                  ${state.filterCategory !== "all" ? `
                    <button 
                      onclick="viewCategoryInCatalog('${state.filterCategory}')"
                      class="px-5 py-2.5 rounded-xl bg-emerald-700 text-white text-sm font-semibold hover:bg-emerald-800 transition-colors">
                      Browse All Schemes in this Category
                    </button>
                    <button 
                      onclick="setCategoryFilter('all', 'results')"
                      class="px-4 py-2 rounded-xl border border-slate-300 text-slate-700 text-sm font-medium hover:bg-slate-50">
                      Show All Categories
                    </button>
                  ` : `
                    <button 
                      onclick="switchTab('wizard')"
                      class="px-5 py-2.5 rounded-xl bg-emerald-700 text-white text-sm font-semibold hover:bg-emerald-800 transition-colors">
                      ${t("btnRecalculate")}
                    </button>
                  `}
                </div>
              </div>
            `
        }
      </div>
    `;
  }

  // Render All Schemes Catalog
  function renderAllSchemesTab() {
    const container = document.getElementById("all-schemes-container");
    if (!container) return;

    const rawSchemes = window.SCHEMES_DATA || [];
    const categoryDefs = getCategoryDefinitions(rawSchemes);

    let list = [...rawSchemes];

    if (state.filterCategory !== "all") {
      list = list.filter((s) => s.category === state.filterCategory);
    }

    if (state.searchQuery.trim()) {
      const q = state.searchQuery.toLowerCase().trim();
      list = list.filter((s) => {
        const nameEn = (s.name.en || "").toLowerCase();
        const nameHi = (s.name.hi || "").toLowerCase();
        const descEn = (s.shortDescription.en || "").toLowerCase();
        const descHi = (s.shortDescription.hi || "").toLowerCase();
        return nameEn.includes(q) || nameHi.includes(q) || descEn.includes(q) || descHi.includes(q);
      });
    }

    container.innerHTML = `
      <div class="space-y-6">
        <div>
          <h1 class="text-2xl md:text-3xl font-extrabold text-slate-900">${t("navAllSchemes")}</h1>
          <p class="text-sm text-slate-600 mt-1">Browse every welfare program currently in the database with verified guidelines.</p>
        </div>

        <!-- Filter Bar -->
        <div class="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
          <input 
            type="text" 
            placeholder="${t("searchPlaceholder")}" 
            value="${state.searchQuery}"
            oninput="setSearchQuery(this.value, 'all')"
            class="flex-1 px-4 py-2.5 rounded-xl border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500">

          <div class="flex items-center gap-2 overflow-x-auto pb-1 scrollbar-none">
            ${categoryDefs.map((c) => `
              <button 
                type="button"
                onclick="setCategoryFilter('${c.id}', 'all')"
                class="px-3.5 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition-all flex items-center gap-1.5 ${
                  state.filterCategory === c.id
                    ? "bg-emerald-700 text-white shadow-sm ring-2 ring-emerald-500/50"
                    : "bg-slate-100 text-slate-700 hover:bg-slate-200"
                }">
                <span>${c.label}</span>
                <span class="text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                  state.filterCategory === c.id ? "bg-white/20 text-white" : "bg-slate-200 text-slate-600"
                }">${c.count}</span>
              </button>
            `).join("")}
          </div>
        </div>

        <!-- Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          ${list.map((scheme) => renderSchemeCard(scheme)).join("")}
        </div>
      </div>
    `;
  }

  // Render Consolidated Citizen Document Checklist
  function renderChecklistTab() {
    const container = document.getElementById("checklist-container");
    if (!container) return;

    const targetSchemes = state.bookmarkedIds.size > 0
      ? (window.SCHEMES_DATA || []).filter((s) => state.bookmarkedIds.has(s.id))
      : state.qualifiedSchemes.filter((s) => s.isEligible);

    const docMap = new Map();
    targetSchemes.forEach((scheme) => {
      (scheme.documents || []).forEach((docName) => {
        if (!docMap.has(docName)) {
          docMap.set(docName, []);
        }
        docMap.get(docName).push(getLocalized(scheme.name));
      });
    });

    const docKeys = Array.from(docMap.keys());
    const totalDocs = docKeys.length;
    let readyDocs = 0;
    docKeys.forEach((key) => {
      if (state.checkedDocs.has(key)) readyDocs++;
    });

    const completionRate = totalDocs > 0 ? Math.round((readyDocs / totalDocs) * 100) : 0;

    container.innerHTML = `
      <div class="space-y-6">
        <div class="bg-white rounded-3xl border border-slate-200 p-6 md:p-8 shadow-sm">
          <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
            <div>
              <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-semibold mb-2">
                ${ICONS.fileText}
                ${t("checklistTitle")}
              </span>
              <h1 class="text-2xl md:text-3xl font-extrabold text-slate-900">${t("navChecklist")}</h1>
              <p class="text-sm text-slate-600 mt-1 max-w-xl leading-relaxed">${t("checklistSubtitle")}</p>
            </div>

            <button 
              onclick="printDossier()" 
              class="inline-flex items-center gap-2.5 px-6 py-3 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-sm shadow-md hover:shadow-lg transition-all shrink-0">
              ${ICONS.printer}
              <span>${t("checklistPrintBtn")}</span>
            </button>
          </div>

          <div class="mt-6 pt-6 border-t border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div class="flex items-center gap-4">
              <div class="text-2xl font-black text-emerald-800">${completionRate}%</div>
              <div>
                <span class="text-xs font-semibold text-slate-700 block">${t("docsReadyCount")} ${readyDocs} / ${totalDocs}</span>
                <span class="text-xs text-slate-400">Based on ${targetSchemes.length} schemes</span>
              </div>
            </div>

            <div class="w-full sm:w-64 bg-slate-100 rounded-full h-2.5 overflow-hidden">
              <div class="bg-emerald-600 h-2.5 rounded-full transition-all duration-300" style="width: ${completionRate}%"></div>
            </div>
          </div>
        </div>

        <div class="space-y-3" id="printable-dossier-items">
          ${
            docKeys.length > 0
              ? docKeys.map((docKey) => {
                  const isChecked = state.checkedDocs.has(docKey);
                  const regEntry = window.DOCUMENT_REGISTRY && window.DOCUMENT_REGISTRY[docKey];
                  const howToGet = regEntry ? getLocalized(regEntry.whereToGet) : "Available via nearest CSC or State Portal";
                  const requiringSchemes = docMap.get(docKey) || [];

                  return `
                    <div class="bg-white rounded-2xl border ${isChecked ? "border-emerald-300 bg-emerald-50/20" : "border-slate-200"} p-5 transition-all shadow-sm">
                      <div class="flex items-start justify-between gap-4">
                        <div class="flex items-start gap-3.5">
                          <button 
                            type="button"
                            onclick="toggleDocCheck('${docKey}')"
                            class="mt-0.5 w-6 h-6 rounded-lg border flex items-center justify-center shrink-0 transition-colors ${
                              isChecked
                                ? "bg-emerald-600 border-emerald-600 text-white"
                                : "border-slate-300 bg-white hover:border-slate-400 text-transparent"
                            }">
                            ${ICONS.check}
                          </button>

                          <div>
                            <h3 class="text-base font-bold text-slate-900 ${isChecked ? "line-through text-slate-400" : ""}">
                              ${docKey}
                            </h3>
                            <div class="mt-1 flex items-start gap-1.5 text-xs text-slate-600">
                              <span class="font-semibold text-slate-700 shrink-0">${t("docWhereToProcure")}</span>
                              <span class="text-slate-500">${howToGet}</span>
                            </div>

                            <div class="mt-3 flex flex-wrap items-center gap-1.5">
                              <span class="text-[11px] font-semibold text-slate-400">${t("docSchemesRequiring")}</span>
                              ${requiringSchemes.slice(0, 3).map((name) => `
                                <span class="text-[11px] px-2 py-0.5 rounded-md bg-slate-100 text-slate-600 font-medium">${name}</span>
                              `).join("")}
                              ${
                                requiringSchemes.length > 3
                                  ? `<span class="text-[11px] px-1.5 py-0.5 rounded-md bg-slate-200 text-slate-600 font-bold">+${requiringSchemes.length - 3}</span>`
                                  : ""
                              }
                            </div>
                          </div>
                        </div>

                        <span class="text-xs font-semibold px-2.5 py-1 rounded-full shrink-0 ${
                          isChecked ? "bg-emerald-100 text-emerald-800" : "bg-amber-100 text-amber-800"
                        }">
                          ${isChecked ? t("checklistStatusHave") : t("checklistStatusNeed")}
                        </span>
                      </div>
                    </div>
                  `;
                }).join("")
              : `
                <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center max-w-md mx-auto">
                  <p class="text-slate-600 text-sm">No schemes selected yet. Complete the questionnaire or browse schemes to build your document checklist.</p>
                  <button 
                    onclick="switchTab('wizard')"
                    class="mt-4 px-5 py-2.5 rounded-xl bg-emerald-700 text-white text-sm font-semibold hover:bg-emerald-800">
                    ${t("navWizard")}
                  </button>
                </div>
              `
          }
        </div>
      </div>
    `;
  }

  // Render Saved Schemes Tab
  function renderSavedTab() {
    const container = document.getElementById("saved-container");
    if (!container) return;

    const rawSchemes = window.SCHEMES_DATA || [];
    const list = rawSchemes.filter((s) => state.bookmarkedIds.has(s.id));

    container.innerHTML = `
      <div class="space-y-6">
        <div>
          <h1 class="text-2xl md:text-3xl font-extrabold text-slate-900">${t("navBookmarked")} (${list.length})</h1>
          <p class="text-sm text-slate-600 mt-1">Bookmarked welfare programs saved for your reference.</p>
        </div>

        ${
          list.length > 0
            ? `<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                ${list.map((scheme) => renderSchemeCard(scheme)).join("")}
              </div>`
            : `
              <div class="bg-white rounded-2xl border border-slate-200 p-12 text-center max-w-md mx-auto">
                <div class="w-16 h-16 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
                  ${ICONS.bookmark}
                </div>
                <h3 class="text-base font-bold text-slate-800">No saved schemes yet</h3>
                <p class="text-xs text-slate-500 mt-1">Click the bookmark icon on any scheme to save it for quick review and document generation.</p>
                <button 
                  onclick="switchTab('wizard')"
                  class="mt-4 px-4 py-2 rounded-xl bg-emerald-700 text-white text-xs font-semibold">
                  ${t("navWizard")}
                </button>
              </div>
            `
        }
      </div>
    `;
  }

  // Render Scheme Detail Modal
  function renderModal() {
    const modal = document.getElementById("scheme-modal");
    if (!modal || !state.selectedSchemeForModal) return;

    const s = state.selectedSchemeForModal;
    const title = getLocalized(s.name);
    const desc = getLocalized(s.shortDescription);
    const ministry = getLocalized(s.ministry);
    const visual = getCategoryVisuals(s.category);
    const criteria = s.criteriaDescriptions ? s.criteriaDescriptions[state.lang] || s.criteriaDescriptions.en || [] : [];
    const steps = s.applicationSteps ? s.applicationSteps[state.lang] || s.applicationSteps.en || [] : [];
    const isBookmarked = state.bookmarkedIds.has(s.id);

    modal.innerHTML = `
      <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 overflow-y-auto animate-fade-in" onclick="closeSchemeModal()">
        <div class="bg-white rounded-3xl max-w-2xl w-full p-6 md:p-8 shadow-2xl border border-slate-200 relative my-8" onclick="event.stopPropagation()">
          
          <button 
            onclick="closeSchemeModal()" 
            class="absolute top-5 right-5 p-2 rounded-xl text-slate-400 hover:text-slate-800 hover:bg-slate-100 transition-colors">
            ${ICONS.close}
          </button>

          <div class="flex items-start gap-4 mb-4 pr-8">
            <div class="w-12 h-12 rounded-2xl flex items-center justify-center border shrink-0 ${visual.color}">
              ${visual.icon}
            </div>
            <div>
              <span class="inline-block text-xs font-semibold px-2.5 py-0.5 rounded-full ${visual.badgeBg}">
                ${visual.name}
              </span>
              <h2 class="text-xl md:text-2xl font-black text-slate-900 mt-1">${title}</h2>
              <span class="text-xs text-slate-500 block">${ministry}</span>
            </div>
          </div>

          <div class="p-3.5 rounded-2xl bg-amber-50 border border-amber-200 flex items-center gap-3 my-4">
            <div class="text-amber-700">${ICONS.coins}</div>
            <div>
              <span class="text-[11px] uppercase tracking-wider font-semibold text-amber-800/80 block">${t("benefitValue")}</span>
              <span class="text-base font-extrabold text-amber-950">${getLocalized(s.benefitAmount)}</span>
            </div>
          </div>

          <p class="text-sm text-slate-600 leading-relaxed">${desc}</p>

          <div class="mt-5">
            <h4 class="text-xs font-bold text-slate-900 uppercase tracking-wider mb-2 flex items-center gap-1.5">
              ${ICONS.shield}
              ${t("modalEligibility")}
            </h4>
            <ul class="space-y-1.5 text-xs md:text-sm text-slate-700">
              ${criteria.map((c) => `
                <li class="flex items-start gap-2">
                  <span class="text-emerald-600 shrink-0 mt-0.5">${ICONS.check}</span>
                  <span>${c}</span>
                </li>
              `).join("")}
            </ul>
          </div>

          <div class="mt-5">
            <h4 class="text-xs font-bold text-slate-900 uppercase tracking-wider mb-2 flex items-center gap-1.5">
              ${ICONS.fileText}
              ${t("modalDocs")}
            </h4>
            <div class="flex flex-wrap gap-2">
              ${(s.documents || []).map((doc) => `
                <span class="text-xs px-3 py-1.5 rounded-xl bg-slate-100 text-slate-700 border border-slate-200 font-medium">
                  ${doc}
                </span>
              `).join("")}
            </div>
          </div>

          <div class="mt-5">
            <h4 class="text-xs font-bold text-slate-900 uppercase tracking-wider mb-2 flex items-center gap-1.5">
              ${ICONS.sparkles}
              ${t("modalSteps")}
            </h4>
            <ol class="space-y-2 text-xs md:text-sm text-slate-700">
              ${steps.map((st, i) => `
                <li class="flex items-start gap-2.5">
                  <span class="w-5 h-5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-xs flex items-center justify-center shrink-0 mt-0.5">${i + 1}</span>
                  <span class="leading-relaxed">${st}</span>
                </li>
              `).join("")}
            </ol>
          </div>

          <!-- Official Portal Section with Resilient Actions -->
          <div class="mt-6 p-4 rounded-2xl bg-emerald-50/60 border border-emerald-200/80">
            <div class="flex items-center justify-between mb-2">
              <span class="text-xs font-bold text-emerald-900 uppercase tracking-wider flex items-center gap-1.5">
                ${ICONS.shield}
                <span>Verified Official Portal</span>
              </span>
              <span class="text-xs text-emerald-700 font-medium">${s.portalName}</span>
            </div>
            <div class="flex items-center justify-between gap-3 text-xs bg-white p-2.5 rounded-xl border border-emerald-200">
              <span class="font-mono text-slate-600 truncate">${s.officialUrl}</span>
              <button 
                type="button"
                onclick="copyLinkToClipboard('${s.officialUrl}', event)" 
                class="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium flex items-center gap-1 shrink-0">
                ${ICONS.copy}
                <span>Copy Link</span>
              </button>
            </div>
          </div>

          <!-- Modal Bottom Actions -->
          <div class="mt-6 pt-5 border-t border-slate-100 flex flex-wrap items-center justify-between gap-3">
            <button 
              onclick="toggleBookmark('${s.id}')"
              class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl border border-slate-200 text-xs md:text-sm font-semibold hover:bg-slate-50 transition-colors">
              ${isBookmarked ? ICONS.bookmarkFilled : ICONS.bookmark}
              <span>${isBookmarked ? t("btnBookmarked") : t("btnBookmark")}</span>
            </button>

            <button 
              type="button"
              onclick="openOfficialGovLink('${s.officialUrl}', event)"
              class="inline-flex items-center gap-2 px-6 py-2.5 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white text-xs md:text-sm font-bold shadow-md hover:shadow-lg transition-all cursor-pointer">
              <span>${t("modalVisitPortal")}</span>
              ${ICONS.externalLink}
            </button>
          </div>

        </div>
      </div>
    `;
    modal.classList.remove("hidden");
  }

  // Render the whole app view
  function renderApp() {
    const elTitle = document.getElementById("app-title");
    const elSubTitle = document.getElementById("app-subtitle");
    if (elTitle) elTitle.textContent = t("appTitle");
    if (elSubTitle) elSubTitle.textContent = t("appSubTitle");

    ["wizard", "results", "all", "checklist", "saved"].forEach((tab) => {
      const btn = document.getElementById(`nav-btn-${tab}`);
      if (btn) {
        if (state.activeTab === tab) {
          btn.className = "nav-link active px-4 py-2.5 rounded-xl text-xs md:text-sm font-bold bg-emerald-800 text-white shadow-sm transition-all";
        } else {
          btn.className = "nav-link px-4 py-2.5 rounded-xl text-xs md:text-sm font-semibold text-slate-700 hover:text-slate-900 hover:bg-slate-200/70 transition-all";
        }
      }

      const mobileBtn = document.getElementById(`mobile-nav-${tab}`);
      if (mobileBtn) {
        if (state.activeTab === tab) {
          mobileBtn.className = "flex flex-col items-center justify-center py-1.5 px-3 rounded-2xl text-emerald-800 font-black bg-emerald-50 transition-all";
        } else {
          mobileBtn.className = "flex flex-col items-center justify-center py-1.5 px-3 rounded-2xl text-slate-500 font-medium transition-all";
        }
      }
    });

    const btnEn = document.getElementById("lang-en");
    const btnHi = document.getElementById("lang-hi");
    if (btnEn) btnEn.className = state.lang === "en" ? "font-bold text-emerald-800 bg-emerald-50 px-2 py-1 rounded" : "text-slate-500 hover:text-slate-800 px-2 py-1";
    if (btnHi) btnHi.className = state.lang === "hi" ? "font-bold text-emerald-800 bg-emerald-50 px-2 py-1 rounded" : "text-slate-500 hover:text-slate-800 px-2 py-1";

    ["wizard", "results", "all", "checklist", "saved"].forEach((tab) => {
      const container = document.getElementById(`tab-section-${tab}`);
      if (container) {
        container.classList.toggle("hidden", state.activeTab !== tab);
      }
    });

    renderActiveTab();
    updateHeaderCounters();
  }

  function renderActiveTab() {
    if (state.activeTab === "wizard") {
      renderWizardStep();
    } else if (state.activeTab === "results") {
      renderResultsTab();
    } else if (state.activeTab === "all") {
      renderAllSchemesTab();
    } else if (state.activeTab === "checklist") {
      renderChecklistTab();
    } else if (state.activeTab === "saved") {
      renderSavedTab();
    }
  }

  // Initialize
  document.addEventListener("DOMContentLoaded", () => {
    calculateAllMatches();
    renderApp();
  });

  // Expose everything to window for inline onclick handlers and debugging
  window.state = state;
  window.renderResultsTab = renderResultsTab;
  window.renderAllSchemesTab = renderAllSchemesTab;
  window.renderChecklistTab = renderChecklistTab;
  window.renderWizardStep = renderWizardStep;
  window.renderModal = renderModal;
  window.renderApp = renderApp;
  window.calculateAllMatches = calculateAllMatches;
  window.YojanaApp = {
    state,
    calculateAllMatches,
    renderApp
  };
})();
