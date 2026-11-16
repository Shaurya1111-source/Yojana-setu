// YojanaSetu - Supabase Cloud Database Integration Layer
// Provides live PostgreSQL syncing, schema mapping, and seamless offline/local fallback

(function () {
  "use strict";

  const SUPABASE_STORAGE_KEY_URL = "yojana_supabase_url";
  const SUPABASE_STORAGE_KEY_KEY = "yojana_supabase_key";

  // Clean and sanitize Supabase Project URL (e.g., strips /rest/v1 or trailing slashes if pasted by mistake)
  function cleanSupabaseUrl(rawUrl) {
    let u = (rawUrl || "").trim();
    u = u.replace(/\/rest\/v1\/?$/i, "");
    u = u.replace(/\/+$/, "");
    return u;
  }

  // Default credentials (can be pre-configured here or entered dynamically in UI)
  const config = {
    url: cleanSupabaseUrl(localStorage.getItem(SUPABASE_STORAGE_KEY_URL) || window.SUPABASE_URL || ""),
    key: (localStorage.getItem(SUPABASE_STORAGE_KEY_KEY) || window.SUPABASE_ANON_KEY || "").trim()
  };

  let client = null;
  let isConnected = false;
  let lastErrorMessage = "";

  // Initialize Supabase client
  function initClient() {
    config.url = cleanSupabaseUrl(config.url);
    config.key = (config.key || "").trim();

    if (config.url && config.key && window.supabase && typeof window.supabase.createClient === "function") {
      try {
        client = window.supabase.createClient(config.url, config.key);
        return true;
      } catch (err) {
        console.warn("[Supabase] Failed to initialize client:", err);
        lastErrorMessage = err.message || String(err);
        client = null;
        return false;
      }
    }
    return false;
  }

  // Map PostgreSQL snake_case columns back to YojanaSetu camelCase scheme structure
  function mapPostgresToScheme(row) {
    return {
      id: row.id,
      name: row.name,
      shortDescription: row.short_description || row.shortDescription,
      ministry: row.ministry,
      category: row.category,
      benefitType: row.benefit_type || row.benefitType,
      benefitAmount: row.benefit_amount || row.benefitAmount,
      officialUrl: row.official_url || row.officialUrl,
      portalName: row.portal_name || row.portalName,
      tags: row.tags || [],
      eligibility: row.eligibility || {},
      criteriaDescriptions: row.criteria_descriptions || row.criteriaDescriptions || {},
      documents: row.documents || [],
      applicationSteps: row.application_steps || row.applicationSteps || {}
    };
  }

  // Fetch schemes from Supabase with automatic local fallback
  async function loadSchemes() {
    if (!client) initClient();

    if (client) {
      try {
        const { data, error } = await client
          .from("schemes")
          .select("*")
          .order("id", { ascending: true });

        if (error) {
          console.warn("[Supabase] Query error, falling back to local dataset:", error.message);
          lastErrorMessage = error.message;
          isConnected = false;
        } else if (data && data.length > 0) {
          console.log(`[Supabase] Successfully loaded ${data.length} schemes from live PostgreSQL database.`);
          isConnected = true;
          lastErrorMessage = "";
          window.SCHEMES_DATA = data.map(mapPostgresToScheme);
          updateStatusUI();
          return window.SCHEMES_DATA;
        } else if (data && data.length === 0) {
          lastErrorMessage = "Table 'schemes' exists but contains 0 rows. Please make sure the INSERT statements in supabase-schema.sql were executed.";
          isConnected = false;
        }
      } catch (err) {
        console.warn("[Supabase] Network error, utilizing local dataset:", err);
        lastErrorMessage = err.message || String(err);
        isConnected = false;
      }
    }

    // Local fallback
    isConnected = false;
    updateStatusUI();
    return window.SCHEMES_DATA || [];
  }

  // Fetch document registry from Supabase
  async function loadDocumentRegistry() {
    if (!client) initClient();

    if (client) {
      try {
        const { data, error } = await client.from("document_registry").select("*");
        if (!error && data && data.length > 0) {
          const reg = {};
          data.forEach((row) => {
            reg[row.doc_key] = {
              name: row.name,
              desc: row.description,
              whereToGet: row.where_to_get
            };
          });
          window.DOCUMENT_REGISTRY = reg;
          return reg;
        }
      } catch (e) {
        console.warn("[Supabase] Document registry fetch fallback:", e);
      }
    }
    return window.DOCUMENT_REGISTRY || {};
  }

  // Save/Update configuration from user
  function setCredentials(url, key) {
    config.url = cleanSupabaseUrl(url);
    config.key = (key || "").trim();
    localStorage.setItem(SUPABASE_STORAGE_KEY_URL, config.url);
    localStorage.setItem(SUPABASE_STORAGE_KEY_KEY, config.key);
    initClient();
    return loadSchemes();
  }

  // Disconnect Supabase and use local mode
  function clearCredentials() {
    config.url = "";
    config.key = "";
    localStorage.removeItem(SUPABASE_STORAGE_KEY_URL);
    localStorage.removeItem(SUPABASE_STORAGE_KEY_KEY);
    client = null;
    isConnected = false;
    updateStatusUI();
  }

  // Update Status Pill UI
  function updateStatusUI() {
    const statusPill = document.getElementById("supabase-status-pill");
    const statusText = document.getElementById("supabase-status-text");
    const statusDot = document.getElementById("supabase-status-dot");

    if (statusPill && statusText && statusDot) {
      if (isConnected) {
        statusDot.className = "w-2 h-2 rounded-full bg-emerald-500 animate-pulse";
        statusText.textContent = "Supabase Live";
        statusPill.className = "flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-emerald-50 border border-emerald-300 text-emerald-900 text-xs font-bold hover:bg-emerald-100 transition-all cursor-pointer";
        statusPill.title = "Connected to Supabase PostgreSQL Database (Click to view details)";
      } else if (config.url && config.key) {
        statusDot.className = "w-2 h-2 rounded-full bg-amber-500";
        statusText.textContent = "Connecting...";
        statusPill.className = "flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-amber-50 border border-amber-300 text-amber-900 text-xs font-bold hover:bg-amber-100 transition-all cursor-pointer";
      } else {
        statusDot.className = "w-2 h-2 rounded-full bg-slate-400";
        statusText.textContent = "Connect Cloud DB";
        statusPill.className = "flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-slate-100 border border-slate-200 text-slate-700 text-xs font-semibold hover:bg-slate-200 transition-all cursor-pointer";
        statusPill.title = "Local Offline Mode (Click to connect Supabase)";
      }
    }
  }

  // Modal handler for user to input Supabase credentials easily
  window.openSupabaseModal = function () {
    const modal = document.getElementById("supabase-modal");
    if (!modal) return;

    const inputUrl = document.getElementById("supabase-input-url");
    const inputKey = document.getElementById("supabase-input-key");

    if (inputUrl) inputUrl.value = config.url;
    if (inputKey) inputKey.value = config.key;

    modal.classList.remove("hidden");
  };

  window.closeSupabaseModal = function () {
    const modal = document.getElementById("supabase-modal");
    if (modal) modal.classList.add("hidden");
  };

  window.saveSupabaseConfig = async function () {
    const inputUrl = document.getElementById("supabase-input-url");
    const inputKey = document.getElementById("supabase-input-key");
    const saveBtn = document.getElementById("supabase-save-btn");

    let url = inputUrl ? inputUrl.value : "";
    let key = inputKey ? inputKey.value : "";

    url = cleanSupabaseUrl(url);
    if (inputUrl) inputUrl.value = url;

    if (saveBtn) {
      saveBtn.disabled = true;
      saveBtn.textContent = "Verifying Connection...";
    }

    try {
      await setCredentials(url, key);
      await loadDocumentRegistry();
      if (window.YojanaApp && window.YojanaApp.calculateAllMatches) {
        window.YojanaApp.calculateAllMatches();
        window.YojanaApp.renderApp();
      }
      closeSupabaseModal();
      if (isConnected) {
        alert("🎉 Successfully connected to Supabase! 30 schemes are now loaded live from PostgreSQL.");
      } else if (url && key) {
        const detail = lastErrorMessage ? `\n\nDatabase message: ${lastErrorMessage}` : "";
        alert(`⚠️ Credentials saved, but could not load schemes from table 'schemes'.${detail}\n\nNote: If RLS is enabled, please ensure the policy 'Allow public read for schemes' is active.`);
      }
    } finally {
      if (saveBtn) {
        saveBtn.disabled = false;
        saveBtn.textContent = "Save & Connect";
      }
      updateStatusUI();
    }
  };

  window.disconnectSupabase = function () {
    if (confirm("Disconnect Supabase and switch back to local dataset?")) {
      clearCredentials();
      closeSupabaseModal();
      if (window.YojanaApp && window.YojanaApp.calculateAllMatches) {
        window.YojanaApp.calculateAllMatches();
        window.YojanaApp.renderApp();
      }
    }
  };

  // Expose API to window
  window.YojanaSupabase = {
    loadSchemes,
    loadDocumentRegistry,
    setCredentials,
    clearCredentials,
    getStatus: () => isConnected,
    getConfig: () => ({ ...config }),
    updateStatusUI
  };

  // Auto-init on DOMContentLoaded
  document.addEventListener("DOMContentLoaded", async () => {
    initClient();
    updateStatusUI();
    if (config.url && config.key) {
      await loadSchemes();
      await loadDocumentRegistry();
      if (window.YojanaApp && window.YojanaApp.calculateAllMatches) {
        window.YojanaApp.calculateAllMatches();
        window.YojanaApp.renderApp();
      }
    }
  });
})();
