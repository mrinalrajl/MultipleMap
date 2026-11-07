/* ==========================================================================
   NaviSync — Apple HomeView Interactive Product Engine
   Synchronizes the Destination Composer, Multi-Peer MapKit Telemetry
   Simulator, Before/After Convergence Diagnostic, Audience Persona Switcher,
   Life360 & Find My Comparison Matrix Filter, 4-Step Architecture Inspector,
   ActivityKit, CoreML RouteScorer, CarPlay Cockpit, and Theme System.
   ========================================================================== */

(function () {
  "use strict";

  const ASSET_PREFIX = window.NAVISYNC_ASSET_PREFIX || "";

  function addKeyboardClick(el, handler) {
    if (!el) return;
    el.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        handler(e);
      }
    });
  }

  // --------------------------------------------------------------------------
  // 1. Theme Switcher (Apple Light Default <-> Pro Dark)
  // --------------------------------------------------------------------------
  const themeToggleBtn = document.getElementById("themeToggleBtn");
  const themeToggleLabel = document.getElementById("themeToggleLabel");
  const themeToggleIcon = document.getElementById("themeToggleIcon");

  const SUN_SVG_PATHS =
    '<circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"></path>';
  const MOON_SVG_PATHS =
    '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>';

  function applyTheme(theme, persist) {
    const isDark = theme === "dark";
    if (isDark) {
      document.documentElement.setAttribute("data-theme", "dark");
      if (themeToggleLabel) themeToggleLabel.textContent = "Dark";
      if (themeToggleIcon) themeToggleIcon.innerHTML = MOON_SVG_PATHS;
      if (themeToggleBtn) themeToggleBtn.setAttribute("aria-pressed", "false");
    } else {
      document.documentElement.setAttribute("data-theme", "light");
      if (themeToggleLabel) themeToggleLabel.textContent = "Light";
      if (themeToggleIcon) themeToggleIcon.innerHTML = SUN_SVG_PATHS;
      if (themeToggleBtn) themeToggleBtn.setAttribute("aria-pressed", "true");
    }
    if (persist) {
      try {
        localStorage.setItem("navisync-theme", theme);
      } catch (_) {}
    }
  }

  let initialTheme = document.documentElement.getAttribute("data-theme") || "light";
  try {
    const stored = localStorage.getItem("navisync-theme");
    if (stored === "dark" || stored === "light") {
      initialTheme = stored;
    }
  } catch (_) {}
  applyTheme(initialTheme, false);

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener("click", () => {
      const isDark = document.documentElement.getAttribute("data-theme") === "dark";
      applyTheme(isDark ? "light" : "dark", true);
    });
  }

  // --------------------------------------------------------------------------
  // 2. Scroll Reveal Observer
  // --------------------------------------------------------------------------
  const revealElements = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("visible");
          }
        });
      },
      { threshold: 0.1 }
    );
    revealElements.forEach((el) => observer.observe(el));
  } else {
    revealElements.forEach((el) => el.classList.add("visible"));
  }

  // --------------------------------------------------------------------------
  // 3. Interactive Before vs. After Convergence Diagnostic (#the-problem)
  // --------------------------------------------------------------------------
  const convergenceStates = {
    chaos: {
      badgeClass: "apple-card-badge badge-red",
      badgeText: "Legacy Fragmentation · 3 Disconnected Silos",
      headline: "Drivers juggle group texts, static pins, and 80% app-install drop-off.",
      description:
        'Without NaviSync, one friend shares a static Apple Find My dot (with zero route or ETA context), another refuses to download Life360 because of 24/7 background tracking, and the driver is forced to text "Where are you?" while merging at 65 mph.',
      install: "150 MB App + Account Wall",
      spatial: "Static Dot Only (No Route)",
      safety: "Distracted Texting While Driving",
      privacy: "24/7 Background Surveillance"
    },
    synced: {
      badgeClass: "apple-card-badge badge-green",
      badgeText: "Synchronized Multi-Peer Telemetry Active",
      headline: "One universal link unites every driver on a live Apple Map.",
      description:
        "Invitees tap navisync.app/m/... in iMessage. An iOS App Clip launches in under 2 seconds, rendering everyone’s real street polyline, turn-by-turn maneuver, and synchronized ETA across MapKit, Dynamic Island, and CarPlay—then automatically shuts off the moment everyone arrives.",
      install: "0 Installs · 1-Tap App Clip",
      spatial: "Live 3D Route Polylines + ETA",
      safety: "Hands-Free CarPlay & Island",
      privacy: "Auto-Terminates on Arrival"
    }
  };

  const convBtns = document.querySelectorAll("[data-convergence-mode]");
  convBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      const mode = btn.getAttribute("data-convergence-mode") || "synced";
      const state = convergenceStates[mode];
      if (!state) return;

      convBtns.forEach((b) => {
        const active = b === btn;
        b.classList.toggle("active", active);
        b.setAttribute("aria-selected", active ? "true" : "false");
      });

      const badgeEl = document.getElementById("convBadge");
      const headEl = document.getElementById("convHeadline");
      const descEl = document.getElementById("convDescription");
      const instEl = document.getElementById("convMetricInstall");
      const spatEl = document.getElementById("convMetricSpatial");
      const safeEl = document.getElementById("convMetricSafety");
      const privEl = document.getElementById("convMetricPrivacy");

      if (badgeEl) {
        badgeEl.className = state.badgeClass;
        badgeEl.textContent = state.badgeText;
      }
      if (headEl) headEl.textContent = state.headline;
      if (descEl) descEl.textContent = state.description;
      if (instEl) instEl.textContent = state.install;
      if (spatEl) spatEl.textContent = state.spatial;
      if (safeEl) safeEl.textContent = state.safety;
      if (privEl) privEl.textContent = state.privacy;
    });
  });

  // --------------------------------------------------------------------------
  // 4. Interactive Audience Persona Switcher (#who-its-for)
  // --------------------------------------------------------------------------
  const personaConfigs = {
    friends: {
      tag: "ACTIVE PERSONA · FRIENDS & SOCIAL MEETUPS",
      title: "Recommended Setup: Universal iMessage Link → Instant App Clip → Auto-Expire on Arrival",
      specs: "Surface Priority: <code>App Clip + Dynamic Island</code> · Privacy: <code>Ephemeral Session</code>",
      presetDest: "Tartine Manufactory",
      presetAddr: "595 Alabama St, SF"
    },
    convoy: {
      tag: "ACTIVE PERSONA · ROAD-TRIP CONVOYS & CARPOOLS",
      title: "Recommended Setup: Multi-Vehicle CPMapTemplate Cockpit + On-Device CoreML RouteScorer",
      specs: "Surface Priority: <code>CarPlay 3D Cockpit + SharePlay</code> · Engine: <code>RouteScorer.mlpackage</code>",
      presetDest: "Dolores Park Overlook",
      presetAddr: "19th & Cumberland, SF"
    },
    family: {
      tag: "ACTIVE PERSONA · FAMILIES, HOSTS & CURBSIDE PICKUPS",
      title: "Recommended Setup: Lock Screen ActivityKit Progress Track + Sub-Minute Curbside Countdown",
      specs: "Surface Priority: <code>Lock Screen + Dynamic Island</code> · Role: <code>Host / Guest Switcher</code>",
      presetDest: "Blue Bottle Ferry Bldg",
      presetAddr: "1 Ferry Building, SF"
    },
    teams: {
      tag: "ACTIVE PERSONA · FIELD TEAMS & CLIENT OPERATIONS",
      title: "Recommended Setup: Zero-Account Guest Deep Link Scoped Strictly to the Site Appointment",
      specs: "Surface Priority: <code>Zero-Install App Clip + MultiMapView</code> · Auth: <code>Ephemeral Token</code>",
      presetDest: "Tartine Manufactory",
      presetAddr: "595 Alabama St, SF"
    }
  };

  const personaTabs = document.querySelectorAll("[data-persona-select]");
  const personaCards = document.querySelectorAll("[data-persona-card]");

  function activatePersona(key) {
    const cfg = personaConfigs[key];
    if (!cfg) return;

    personaTabs.forEach((t) => {
      t.classList.toggle("active", t.getAttribute("data-persona-select") === key);
    });
    personaCards.forEach((c) => {
      c.classList.toggle("active", c.getAttribute("data-persona-card") === key);
    });

    const spotTag = document.getElementById("personaSpotTag");
    const spotTitle = document.getElementById("personaSpotTitle");
    const spotSpecs = document.getElementById("personaSpotSpecs");

    if (spotTag) spotTag.textContent = cfg.tag;
    if (spotTitle) spotTitle.textContent = cfg.title;
    if (spotSpecs) spotSpecs.innerHTML = cfg.specs;
  }

  personaTabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      activatePersona(tab.getAttribute("data-persona-select"));
    });
  });

  personaCards.forEach((card) => {
    const handler = () => activatePersona(card.getAttribute("data-persona-card"));
    card.addEventListener("click", handler);
    addKeyboardClick(card, handler);
  });

  // --------------------------------------------------------------------------
  // 5. Interactive Comparison Matrix Filter (#comparison)
  // --------------------------------------------------------------------------
  const compareFilterBtns = document.querySelectorAll("[data-compare-filter]");
  const compareRows = document.querySelectorAll("#comparisonTableBody tr[data-compare-cat]");

  compareFilterBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      const filter = btn.getAttribute("data-compare-filter") || "all";
      compareFilterBtns.forEach((b) => b.classList.toggle("active", b === btn));

      compareRows.forEach((row) => {
        const cat = row.getAttribute("data-compare-cat");
        const show = filter === "all" || cat === filter;
        row.classList.toggle("hidden-row", !show);
      });
    });
  });

  // --------------------------------------------------------------------------
  // 6. Shared Destination State + Hero Command Composer + Quickstart Generator
  // --------------------------------------------------------------------------
  let currentDestination = {
    name: "Tartine Manufactory",
    address: "595 Alabama St, SF"
  };

  let activeWalkthroughStep = "1";
  let appClipAccepted = false;
  let activeCarPlayApp = "nav";

  const cpApps = {
    nav: {
      sub: "IN 400 FT · ALABAMA ST",
      title: "Arrive at Tartine Manufactory",
      color: "#2bb3c0"
    },
    music: {
      sub: "SHAREPLAY AUDIO · SYNCHRONIZED",
      title: "Midnight City — M83 (3 Vehicles)",
      color: "#7c86f7"
    },
    messages: {
      sub: "VOICE CHECK-IN · BOB MARTINEZ",
      title: "“Parking on Bryant St now, 2 mins out.”",
      color: "#d97757"
    }
  };

  function slugify(str) {
    return (
      str
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/(^-|-$)/g, "") || "shared-destination"
    );
  }

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  const heroDestInput = document.getElementById("heroDestInput");
  const heroCopyBtn = document.getElementById("heroCopyBtn");
  const heroLinkPreview = document.getElementById("heroLinkPreview");
  const presetChips = document.querySelectorAll("[data-dest-preset]");

  const destInput = document.getElementById("inviteDestInput");
  const generatedLinkText = document.getElementById("generatedLinkText");
  const copyLinkBtn = document.getElementById("copyInviteLinkBtn");

  const mapDestLabel = document.getElementById("mapDestLabel");
  const sheetDestTitle = document.getElementById("sheetDestTitle");
  const sheetDestAddress = document.getElementById("sheetDestAddress");
  const diExpDestSub = document.getElementById("diExpDestSub");
  const diExpAddress = document.getElementById("diExpAddress");
  const laDestSub = document.getElementById("laDestSub");
  const cpBannerSub = document.getElementById("cpBannerSub");
  const cpBannerTitle = document.getElementById("cpBannerTitle");
  const walkthroughStageContainer = document.getElementById("walkthroughStageContainer");

  function parseDestinationInput(rawVal) {
    const trimmed = (rawVal || "").trim();
    if (!trimmed) {
      currentDestination = {
        name: "Tartine Manufactory",
        address: "595 Alabama St, SF"
      };
      return;
    }

    let matchedChip = null;
    presetChips.forEach((chip) => {
      const presetName = chip.getAttribute("data-dest-preset") || "";
      if (presetName.toLowerCase() === trimmed.toLowerCase()) {
        matchedChip = chip;
      }
    });

    if (matchedChip) {
      currentDestination = {
        name: matchedChip.getAttribute("data-dest-preset") || trimmed,
        address: matchedChip.getAttribute("data-dest-addr") || "595 Alabama St, SF"
      };
      presetChips.forEach((c) => c.classList.toggle("active", c === matchedChip));
      return;
    }

    presetChips.forEach((c) => c.classList.remove("active"));

    if (trimmed.indexOf(",") !== -1) {
      const parts = trimmed.split(",");
      const venueName = parts[0].trim() || "Meeting Spot";
      const customAddr = parts.slice(1).join(",").trim() || "San Francisco, CA";
      currentDestination = {
        name: venueName,
        address: customAddr
      };
    } else {
      currentDestination = {
        name: trimmed,
        address: "San Francisco, CA · Live Pin"
      };
    }
  }

  function renderWalkthroughStep(step) {
    if (!walkthroughStageContainer) return;
    const cleanName = (currentDestination.name || "Tartine Manufactory").trim() || "Tartine Manufactory";
    const shortName = escapeHtml(cleanName.split(",")[0].slice(0, 28));
    const safeAddr = escapeHtml(currentDestination.address || "595 Alabama St, SF");
    const slug = slugify(cleanName);
    const fullUrl = escapeHtml(`https://navisync.app/m/${slug}`);

    const templates = {
      1: `
        <div class="appclip-card-demo">
          <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;margin-bottom:14px;">
            <span class="nav-badge">01 · Host Session</span>
            <span style="font-size:0.72rem;color:var(--text-muted);font-family:var(--font-mono);">CreateMeetingView.swift</span>
          </div>
          <h4 style="font-size:1.15rem;font-weight:600;margin-bottom:4px;">${shortName}</h4>
          <p style="font-size:0.82rem;color:var(--text-secondary);margin-bottom:16px;">${safeAddr} · Target Arrival 18:30</p>
          <div style="padding:12px 14px;border-radius:10px;background:var(--bg-page);border:1px solid var(--border-hairline);margin-bottom:14px;">
            <div style="font-size:0.68rem;color:var(--text-muted);font-family:var(--font-mono);text-transform:uppercase;margin-bottom:4px;">Universal Deep Link Payload</div>
            <div style="font-family:var(--font-mono);font-size:0.8rem;color:var(--accent-blue);word-break:break-all;">${fullUrl}</div>
          </div>
          <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:8px;margin-bottom:14px;font-family:var(--font-mono);font-size:0.7rem;">
            <div style="padding:8px 10px;border-radius:8px;background:var(--bg-page);border:1px solid var(--border-hairline);">
              <span style="color:var(--text-muted);display:block;font-size:0.62rem;">COORDINATE ANCHOR</span>
              <strong style="color:var(--text-primary);">37.7614° N, 122.4119° W</strong>
            </div>
            <div style="padding:8px 10px;border-radius:8px;background:var(--bg-page);border:1px solid var(--border-hairline);">
              <span style="color:var(--text-muted);display:block;font-size:0.62rem;">SHARE CHANNELS</span>
              <strong style="color:var(--accent-blue);">iMessage · AirDrop · QR</strong>
            </div>
          </div>
          <div style="display:flex;gap:8px;flex-wrap:wrap;font-family:var(--font-mono);font-size:0.7rem;color:var(--text-secondary);">
            <span style="padding:4px 9px;border-radius:4px;background:var(--bg-page);border:1px solid var(--border-hairline);">MKLocalSearchCompleter</span>
            <span style="padding:4px 9px;border-radius:4px;background:var(--bg-page);border:1px solid var(--border-hairline);">DeepLinkManager.swift</span>
          </div>
        </div>
      `,
      2: `
        <div class="appclip-card-demo">
          <div class="appclip-header">
            <img src="${ASSET_PREFIX}Logo/NaviSync-AppIcon-1024.png" alt="NaviSync App Clip">
            <div>
              <span style="font-size:0.68rem;font-family:var(--font-mono);color:var(--accent-blue);text-transform:uppercase;letter-spacing:0.05em;">iOS App Clip · Zero Install</span>
              <h4 style="font-size:1.05rem;font-weight:600;">Alex invited you to a shared route</h4>
              <p style="font-size:0.78rem;color:var(--text-secondary);">Launches instantly via Associated Domains (&lt; 2.0s)</p>
            </div>
          </div>
          <div style="padding:11px 13px;border-radius:10px;background:var(--bg-page);border:1px solid var(--border-hairline);margin-bottom:12px;font-size:0.8rem;color:var(--text-secondary);">
            <strong style="color:var(--text-primary);">Destination:</strong> ${shortName} (${safeAddr})
          </div>
          <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:8px;margin-bottom:14px;font-family:var(--font-mono);font-size:0.7rem;">
            <div style="padding:8px 10px;border-radius:8px;background:var(--bg-page);border:1px solid var(--border-hairline);">
              <span style="color:var(--text-muted);display:block;font-size:0.62rem;">BUNDLE FOOTPRINT</span>
              <strong style="color:var(--text-primary);">1.8 MB (&lt; 15 MB Limit)</strong>
            </div>
            <div style="padding:8px 10px;border-radius:8px;background:var(--bg-page);border:1px solid var(--border-hairline);">
              <span style="color:var(--text-muted);display:block;font-size:0.62rem;">AUTH ENTITLEMENT</span>
              <strong style="color:var(--accent-blue);">Ephemeral Session Token</strong>
            </div>
          </div>
          <button type="button" id="walkthroughAcceptBtn" class="btn btn-primary" style="width:100%;${appClipAccepted ? "background:#28cd41;color:#fff;" : ""}">
            ${appClipAccepted ? "Accepted · Streaming Live Route Telemetry" : "Accept &amp; Share Live ETA"}
          </button>
        </div>
      `,
      3: `
        <div class="appclip-card-demo">
          <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;margin-bottom:14px;">
            <span class="nav-badge">03 · MultiMapView.swift</span>
            <span style="font-size:0.72rem;font-family:var(--font-mono);color:var(--accent-blue);">3 Peers Synchronized</span>
          </div>
          <h4 style="font-size:1.1rem;font-weight:600;margin-bottom:6px;">Real-Road Polylines &amp; Turn Guidance</h4>
          <p style="font-size:0.82rem;color:var(--text-secondary);margin-bottom:14px;">
            Powered by <code>MKDirections</code> with automatic urban street-grid fallback so routes remain responsive offline and in simulator sessions.
          </p>
          <div style="display:flex;flex-direction:column;gap:8px;font-size:0.8rem;">
            <div style="display:flex;justify-content:space-between;padding:9px 12px;border-radius:8px;background:var(--bg-page);border:1px solid var(--border-hairline);">
              <span><strong>Alice</strong> · Turn right onto Market St</span>
              <strong style="font-family:var(--font-mono);color:var(--accent-blue);">0.2 mi · 3m</strong>
            </div>
            <div style="display:flex;justify-content:space-between;padding:9px 12px;border-radius:8px;background:var(--bg-page);border:1px solid var(--border-hairline);">
              <span><strong>Bob</strong> · Merge onto Bryant St</span>
              <strong style="font-family:var(--font-mono);color:var(--accent-amber);">0.4 mi · 5m</strong>
            </div>
            <div style="display:flex;justify-content:space-between;padding:9px 12px;border-radius:8px;background:var(--bg-page);border:1px solid var(--border-hairline);">
              <span><strong>Charlie</strong> · Continue on Folsom St</span>
              <strong style="font-family:var(--font-mono);color:var(--accent-indigo);">0.5 mi · 5m</strong>
            </div>
          </div>
        </div>
      `,
      4: `
        <div class="appclip-card-demo">
          <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;margin-bottom:14px;">
            <span class="nav-badge">04 · System Handoff</span>
            <span style="font-size:0.72rem;font-family:var(--font-mono);color:var(--accent-blue);">ActivityKit + CarPlay</span>
          </div>
          <h4 style="font-size:1.1rem;font-weight:600;margin-bottom:6px;">Lock Screen, Dynamic Island &amp; CarPlay</h4>
          <p style="font-size:0.82rem;color:var(--text-secondary);margin-bottom:14px;">
            Lock your iPhone or connect to your vehicle — live arrival progress bars and turn banners persist across every native surface.
          </p>
          <div style="padding:12px 14px;border-radius:10px;background:#0c0e12;border:1px solid rgba(255,255,255,0.12);display:flex;justify-content:space-between;align-items:center;gap:8px;margin-bottom:10px;">
            <div>
              <small style="color:#8e9299;display:block;font-family:var(--font-mono);font-size:0.62rem;">DYNAMIC ISLAND COMPACT</small>
              <strong style="color:#f4f4f0;font-size:0.84rem;font-weight:500;">Eve's Route → ${shortName}</strong>
            </div>
            <span style="font-family:var(--font-mono);font-weight:600;color:#34d399;font-size:0.8rem;">Arriving</span>
          </div>
          <div style="padding:10px 14px;border-radius:10px;background:var(--bg-page);border:1px solid var(--border-hairline);display:flex;justify-content:space-between;align-items:center;font-family:var(--font-mono);font-size:0.72rem;">
            <span style="color:var(--text-secondary);">CarPlay Scene: <code>CPMapTemplate</code></span>
            <span style="color:var(--accent-blue);">60Hz Sync</span>
          </div>
        </div>
      `
    };

    if (templates[step]) {
      walkthroughStageContainer.innerHTML = templates[step];
      const acceptBtn = document.getElementById("walkthroughAcceptBtn");
      if (acceptBtn) {
        acceptBtn.addEventListener("click", () => {
          appClipAccepted = true;
          acceptBtn.textContent = "Accepted · Streaming Live Route Telemetry";
          acceptBtn.style.background = "#28cd41";
          acceptBtn.style.color = "#fff";
        });
      }
    }
  }

  function syncDestinationUI(source) {
    const cleanName = (currentDestination.name || "Tartine Manufactory").trim() || "Tartine Manufactory";
    const shortName = cleanName.split(",")[0].slice(0, 24);
    const slug = slugify(cleanName);
    const fullUrl = `https://navisync.app/m/${slug}`;
    const shortUrl = `navisync.app/m/${slug}`;

    if (source !== "hero" && heroDestInput) {
      heroDestInput.value = cleanName;
    }
    if (source !== "footer" && destInput) {
      destInput.value = cleanName;
    }
    if (heroLinkPreview) {
      heroLinkPreview.textContent = shortUrl;
    }
    if (generatedLinkText) {
      generatedLinkText.textContent = fullUrl;
    }
    if (mapDestLabel) {
      mapDestLabel.textContent = shortName;
    }
    if (sheetDestTitle) {
      sheetDestTitle.textContent = `Heading to ${shortName}`;
    }
    if (sheetDestAddress) {
      sheetDestAddress.textContent = `${currentDestination.address} · 3 Peers Active`;
    }
    if (diExpDestSub) {
      diExpDestSub.textContent = `To ${shortName}`;
    }
    if (diExpAddress) {
      diExpAddress.textContent = currentDestination.address;
    }
    if (laDestSub) {
      laDestSub.textContent = `${shortName} · 3 Peers`;
    }

    const streetShort = (currentDestination.address || "Alabama St").split(",")[0].trim().toUpperCase().slice(0, 18);
    cpApps.nav.sub = `IN 400 FT · ${streetShort}`;
    cpApps.nav.title = `Arrive at ${shortName}`;
    if (activeCarPlayApp === "nav") {
      if (cpBannerSub) cpBannerSub.textContent = cpApps.nav.sub;
      if (cpBannerTitle) cpBannerTitle.textContent = cpApps.nav.title;
    }

    renderWalkthroughStep(activeWalkthroughStep);
  }

  if (heroDestInput) {
    heroDestInput.addEventListener("input", () => {
      parseDestinationInput(heroDestInput.value);
      syncDestinationUI("hero");
      updatePhoneSimulation();
    });
  }

  if (destInput) {
    destInput.addEventListener("input", () => {
      parseDestinationInput(destInput.value);
      syncDestinationUI("footer");
      updatePhoneSimulation();
    });
  }

  presetChips.forEach((chip) => {
    chip.addEventListener("click", () => {
      const name = chip.getAttribute("data-dest-preset") || "Tartine Manufactory";
      const addr = chip.getAttribute("data-dest-addr") || "595 Alabama St, SF";
      currentDestination = { name, address: addr };
      presetChips.forEach((c) => c.classList.toggle("active", c === chip));
      syncDestinationUI("preset");
      updatePhoneSimulation();
    });
  });

  function copyCurrentInviteUrl(btnEl, defaultLabel) {
    const slug = slugify(currentDestination.name);
    const url = `https://navisync.app/m/${slug}`;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url).catch(() => {});
    }
    if (btnEl) {
      btnEl.textContent = "Copied Link";
      setTimeout(() => {
        btnEl.textContent = defaultLabel;
      }, 2000);
    }
  }

  if (heroCopyBtn) {
    heroCopyBtn.addEventListener("click", () => copyCurrentInviteUrl(heroCopyBtn, "Copy App Clip"));
  }
  if (copyLinkBtn) {
    copyLinkBtn.addEventListener("click", () => copyCurrentInviteUrl(copyLinkBtn, "Copy Invite Link"));
  }

  // --------------------------------------------------------------------------
  // 7. Hero Interactive iPhone 15 Pro — Multi-Peer Telemetry Simulator
  // --------------------------------------------------------------------------
  const prefersReducedMotion =
    typeof window.matchMedia === "function" &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  const MANEUVER_SVGS = {
    "turn-right":
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 18V9a3 3 0 0 1 3-3h7"></path><polyline points="15 2 19 6 15 10"></polyline></svg>',
    "turn-left":
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 18V9a3 3 0 0 0-3-3H5"></path><polyline points="9 2 5 6 9 10"></polyline></svg>',
    straight:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="12" y1="19" x2="12" y2="5"></line><polyline points="6 11 12 5 18 11"></polyline></svg>',
    "slight-right":
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="7" y1="17" x2="17" y2="7"></line><polyline points="9 7 17 7 17 15"></polyline></svg>',
    arrived:
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6L9 17l-5-5"></path></svg>'
  };

  const peers = {
    alice: {
      id: "alice",
      name: "Alice",
      color: "#2bb3c0",
      startDistMi: 1.4,
      startEtaMin: 6,
      startCoords: { x: 64, y: 295 },
      midCoords: { x: 148, y: 255 },
      endCoords: { x: 232, y: 232 },
      endOffset: { x: -14, y: -6 },
      maneuvers: [
        { dist: "IN 500 FT", text: "Turn right onto Market St", icon: "turn-right" },
        { dist: "IN 0.2 MI", text: "Keep left toward Alabama St", icon: "turn-left" },
        { dist: "ARRIVED", text: "Arrived at Destination", icon: "arrived" }
      ]
    },
    bob: {
      id: "bob",
      name: "Bob",
      color: "#d97757",
      startDistMi: 2.1,
      startEtaMin: 9,
      startCoords: { x: 282, y: 392 },
      midCoords: { x: 245, y: 318 },
      endCoords: { x: 232, y: 232 },
      endOffset: { x: 14, y: 8 },
      maneuvers: [
        { dist: "IN 800 FT", text: "Merge onto Bryant St Corridor", icon: "straight" },
        { dist: "IN 350 FT", text: "Turn right onto 18th St", icon: "turn-right" },
        { dist: "ARRIVED", text: "Arrived at Destination", icon: "arrived" }
      ]
    },
    charlie: {
      id: "charlie",
      name: "Charlie",
      color: "#7c86f7",
      startDistMi: 1.8,
      startEtaMin: 8,
      startCoords: { x: 84, y: 405 },
      midCoords: { x: 158, y: 335 },
      endCoords: { x: 232, y: 232 },
      endOffset: { x: -6, y: 15 },
      maneuvers: [
        { dist: "IN 600 FT", text: "Continue northeast on Folsom St", icon: "slight-right" },
        { dist: "IN 250 FT", text: "Turn left into Meeting Drop-off", icon: "turn-left" },
        { dist: "ARRIVED", text: "Arrived at Destination", icon: "arrived" }
      ]
    }
  };

  let simProgress = 0.42;
  let isAutoPlaying = !prefersReducedMotion;
  let focusedPeerId = "alice";

  const simSlider = document.getElementById("heroSimSlider");
  const simProgressLabel = document.getElementById("simProgressLabel");
  const toggleAutoPlayBtn = document.getElementById("toggleSimBtn");
  const dynamicIsland = document.getElementById("heroDynamicIsland");
  const phoneToast = document.getElementById("phoneToast");

  if (toggleAutoPlayBtn && !isAutoPlaying) {
    toggleAutoPlayBtn.textContent = "Resume";
  }

  function quadBezier(p0, p1, p2, t) {
    const inv = 1 - t;
    return {
      x: inv * inv * p0.x + 2 * inv * t * p1.x + t * t * p2.x,
      y: inv * inv * p0.y + 2 * inv * t * p1.y + t * t * p2.y
    };
  }

  function formatEtaMinutes(remMin) {
    if (remMin <= 0.15) return "Arrived";
    const mins = Math.floor(remMin);
    const secs = Math.round((remMin - mins) * 60);
    return `${mins}m ${secs < 10 ? "0" : ""}${secs}s`;
  }

  function updatePhoneSimulation() {
    const p = Math.max(0, Math.min(1, simProgress));
    const shortDest = (currentDestination.name || "Tartine Manufactory").split(",")[0].slice(0, 24);

    if (simSlider && document.activeElement !== simSlider) {
      simSlider.value = Math.round(p * 100);
    }
    if (simProgressLabel) {
      simProgressLabel.textContent = p >= 0.98 ? "100% · Arrived" : `${Math.round(p * 100)}% En Route`;
    }

    Object.values(peers).forEach((peer) => {
      const pos = quadBezier(peer.startCoords, peer.midCoords, peer.endCoords, p);
      if (p > 0.85 && peer.endOffset) {
        const spread = (p - 0.85) / 0.15;
        pos.x += peer.endOffset.x * spread;
        pos.y += peer.endOffset.y * spread;
      }

      const markerGroup = document.getElementById(`marker-${peer.id}`);
      if (markerGroup) {
        markerGroup.setAttribute("transform", `translate(${pos.x.toFixed(1)}, ${pos.y.toFixed(1)})`);
        if (peer.id === focusedPeerId && markerGroup.parentNode) {
          markerGroup.parentNode.appendChild(markerGroup);
        }
      }

      const routePath = document.getElementById(`route-${peer.id}`);
      if (routePath) {
        const isSelected = peer.id === focusedPeerId;
        const ctrlX = (1 - p) * peer.midCoords.x + p * peer.endCoords.x;
        const ctrlY = (1 - p) * peer.midCoords.y + p * peer.endCoords.y;
        routePath.setAttribute(
          "d",
          `M ${pos.x.toFixed(1)},${pos.y.toFixed(1)} Q ${ctrlX.toFixed(1)},${ctrlY.toFixed(1)} ${peer.endCoords.x},${peer.endCoords.y}`
        );
        routePath.setAttribute("stroke-width", isSelected ? "4.5" : "2.5");
        routePath.setAttribute("opacity", isSelected ? "1" : "0.45");
      }

      const focusBadge = document.querySelector(`[data-focus-badge="${peer.id}"]`);
      const nudgeBtn = document.querySelector(`.participant-row[data-select-peer="${peer.id}"] .nudge-btn`);
      const isFocused = peer.id === focusedPeerId;
      if (focusBadge) {
        focusBadge.style.display = isFocused ? "inline-block" : "none";
        focusBadge.style.color = peer.color;
        focusBadge.style.background = `${peer.color}1f`;
      }
      if (nudgeBtn) {
        nudgeBtn.style.display = isFocused ? "none" : "inline-block";
      }

      const remFraction = Math.max(0, 1 - p);
      const remDist = (peer.startDistMi * remFraction).toFixed(1);
      const remMin = peer.startEtaMin * remFraction;

      const rowSub = document.getElementById(`row-sub-${peer.id}`);
      if (rowSub) {
        rowSub.textContent =
          remFraction <= 0.03 ? `Arrived at ${shortDest}` : `${remDist} mi · ${Math.ceil(remMin)} min`;
      }

      const pinBadge = document.getElementById(`pin-dist-${peer.id}`);
      if (pinBadge) {
        pinBadge.textContent = remFraction <= 0.03 ? "Here" : `${remDist} mi`;
      }
    });

    const activePeer = peers[focusedPeerId] || peers.alice;
    const remFraction = Math.max(0, 1 - p);
    const remDist = (activePeer.startDistMi * remFraction).toFixed(1);
    const remEtaStr = formatEtaMinutes(activePeer.startEtaMin * remFraction);

    const diCompactName = document.getElementById("diCompactName");
    const diCompactEta = document.getElementById("diCompactEta");
    const diPulseIcon = document.getElementById("diPulseIcon");
    const diExpAvatar = document.getElementById("diExpAvatar");
    const diExpName = document.getElementById("diExpName");
    const diExpEta = document.getElementById("diExpEta");
    const diExpDist = document.getElementById("diExpDist");
    const diExpFill = document.getElementById("diExpFill");

    if (diCompactName) diCompactName.textContent = activePeer.name;
    if (diCompactEta) {
      diCompactEta.textContent = remFraction <= 0.03 ? "Here" : `${Math.ceil(activePeer.startEtaMin * remFraction)}m`;
      diCompactEta.style.color = activePeer.color;
    }
    if (diPulseIcon) diPulseIcon.style.background = activePeer.color;
    if (diExpAvatar) {
      diExpAvatar.style.background = activePeer.color;
      diExpAvatar.textContent = activePeer.name.charAt(0);
    }
    if (diExpName) diExpName.textContent = `${activePeer.name}'s Route`;
    if (diExpEta) {
      diExpEta.textContent = remEtaStr;
      diExpEta.style.color = activePeer.color;
    }
    if (diExpDist) diExpDist.textContent = remFraction <= 0.03 ? "At Destination" : `${remDist} mi remaining`;
    if (diExpFill) {
      diExpFill.style.width = `${Math.max(8, Math.round(p * 100))}%`;
      diExpFill.style.background = activePeer.color;
    }

    const manIndex = p >= 0.96 ? 2 : p >= 0.5 ? 1 : 0;
    const man = activePeer.maneuvers[manIndex];
    const manDistEl = document.getElementById("hudManeuverDist");
    const manTextEl = document.getElementById("hudManeuverText");
    const manIconEl = document.getElementById("hudManeuverIcon");
    if (manDistEl) {
      manDistEl.textContent = `${activePeer.name} · ${man.dist}`;
      manDistEl.style.color = activePeer.color;
    }
    if (manTextEl) {
      manTextEl.textContent = manIndex === 2 ? `Arrived at ${shortDest}` : man.text;
    }
    if (manIconEl) {
      manIconEl.innerHTML = MANEUVER_SVGS[man.icon] || MANEUVER_SVGS["turn-right"];
      manIconEl.style.color = activePeer.color;
      manIconEl.style.borderColor = `${activePeer.color}55`;
      manIconEl.style.background = `${activePeer.color}1a`;
    }
  }

  setInterval(() => {
    if (!isAutoPlaying) return;
    simProgress += 0.004;
    if (simProgress > 1.02) {
      simProgress = 0.08;
    }
    updatePhoneSimulation();
  }, 50);

  if (simSlider) {
    simSlider.addEventListener("input", (e) => {
      isAutoPlaying = false;
      if (toggleAutoPlayBtn) toggleAutoPlayBtn.textContent = "Resume";
      simProgress = Number(e.target.value) / 100;
      updatePhoneSimulation();
    });
  }

  if (toggleAutoPlayBtn) {
    const toggleSim = () => {
      isAutoPlaying = !isAutoPlaying;
      toggleAutoPlayBtn.textContent = isAutoPlaying ? "Pause" : "Resume";
    };
    toggleAutoPlayBtn.addEventListener("click", toggleSim);
    addKeyboardClick(toggleAutoPlayBtn, toggleSim);
  }

  const iphoneScreen = document.querySelector(".iphone-screen");
  if (dynamicIsland) {
    const toggleIsland = () => {
      const expanded = dynamicIsland.classList.toggle("expanded");
      dynamicIsland.setAttribute("aria-expanded", expanded ? "true" : "false");
      if (iphoneScreen) {
        iphoneScreen.classList.toggle("island-expanded", expanded);
      }
    };
    dynamicIsland.addEventListener("click", toggleIsland);
    addKeyboardClick(dynamicIsland, toggleIsland);
  }

  function selectParticipant(peerId) {
    if (!peers[peerId]) return;
    focusedPeerId = peerId;
    document.querySelectorAll("[data-select-peer]").forEach((el) => {
      el.classList.toggle("active", el.getAttribute("data-select-peer") === peerId);
    });
    updatePhoneSimulation();
  }

  document.querySelectorAll("[data-select-peer]").forEach((el) => {
    const handler = (e) => {
      if (e.target && e.target.closest && e.target.closest(".nudge-btn")) return;
      selectParticipant(el.getAttribute("data-select-peer"));
    };
    el.addEventListener("click", handler);
    addKeyboardClick(el, handler);
  });

  let toastTimer = null;
  document.querySelectorAll("[data-nudge-peer]").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation();
      const name = btn.getAttribute("data-nudge-peer") || "Bob";
      if (phoneToast) {
        phoneToast.textContent = `Check-in sent to ${name} — "${name}: Parking now, 2 min away."`;
        phoneToast.classList.add("show");
        clearTimeout(toastTimer);
        toastTimer = setTimeout(() => {
          phoneToast.classList.remove("show");
        }, 3000);
      }
    });
  });

  // --------------------------------------------------------------------------
  // 8. Interactive 4-Step Architecture Walkthrough Switcher
  // --------------------------------------------------------------------------
  const stepCards = document.querySelectorAll("[data-walkthrough-step]");
  stepCards.forEach((card) => {
    const activateStep = () => {
      const step = card.getAttribute("data-walkthrough-step") || "1";
      activeWalkthroughStep = step;
      stepCards.forEach((c) => c.classList.remove("active"));
      card.classList.add("active");
      renderWalkthroughStep(step);
    };
    card.addEventListener("click", activateStep);
    addKeyboardClick(card, activateStep);
  });

  syncDestinationUI("init");
  updatePhoneSimulation();

  // --------------------------------------------------------------------------
  // 9. Lock Screen Live Activity Interactive Widget
  // --------------------------------------------------------------------------
  const laSlider = document.getElementById("laProgressSlider");
  const laModeBtn = document.getElementById("laModeToggleBtn");
  let laIsHost = true;

  function updateLiveActivityDemo() {
    if (!laSlider) return;
    const rawPct = Number(laSlider.value);
    const clampedPct = Math.max(6, Math.min(94, rawPct));
    const isArriving = rawPct >= 95;

    const laFill = document.getElementById("laBarFill");
    const laPin = document.getElementById("laPinNode");
    const laCallout = document.getElementById("laCalloutBubble");
    const laStatusPill = document.getElementById("laStatusPill");
    const laEtaValue = document.getElementById("laEtaValue");
    const laRoleLabel = document.getElementById("laRoleLabel");

    if (laFill) {
      laFill.style.width = `${rawPct}%`;
      laFill.style.background = isArriving ? "#10a37f" : "#2bb3c0";
    }
    if (laPin) {
      laPin.style.left = `${rawPct}%`;
      laPin.style.borderColor = isArriving ? "#10a37f" : "#2bb3c0";
    }
    if (laCallout) {
      laCallout.style.left = `${clampedPct}%`;
      laCallout.textContent = laIsHost ? "Eve · 03.4 km" : "You · En Route";
    }
    if (laStatusPill) {
      laStatusPill.textContent = isArriving ? "Arriving" : laIsHost ? "En Route" : "Driving";
      laStatusPill.classList.toggle("arriving", isArriving);
    }
    if (laRoleLabel) {
      laRoleLabel.textContent = laIsHost ? "DRIVER ETA (HOST MODE)" : "ESTIMATED TIME (GUEST MODE)";
    }
    if (laEtaValue) {
      if (isArriving) {
        laEtaValue.textContent = "Arrived · 0.0 km";
        laEtaValue.style.color = "#34d399";
      } else {
        const remKm = ((100 - rawPct) * 0.08).toFixed(1);
        const remMin = Math.max(1, Math.ceil((100 - rawPct) * 0.14));
        laEtaValue.textContent = `${remMin} min · ${remKm} km`;
        laEtaValue.style.color = "#f4f4f0";
      }
    }
  }

  if (laSlider) {
    laSlider.addEventListener("input", updateLiveActivityDemo);
  }
  if (laModeBtn) {
    laModeBtn.addEventListener("click", () => {
      laIsHost = !laIsHost;
      laModeBtn.textContent = laIsHost ? "Switch to Guest Mode" : "Switch to Host Mode";
      updateLiveActivityDemo();
    });
  }
  updateLiveActivityDemo();

  // --------------------------------------------------------------------------
  // 10. CoreML RouteScorer.mlpackage Interactive Playground
  // --------------------------------------------------------------------------
  const mlDistInput = document.getElementById("mlDistanceInput");
  const mlTimeInput = document.getElementById("mlTimeInput");
  const mlTurnsInput = document.getElementById("mlTurnsInput");

  function updateCoreMLScore() {
    if (!mlDistInput || !mlTimeInput || !mlTurnsInput) return;
    const distKm = Number(mlDistInput.value);
    const timeMin = Number(mlTimeInput.value);
    const turns = Number(mlTurnsInput.value);

    document.getElementById("mlDistVal").textContent = `${distKm} km`;
    document.getElementById("mlTimeVal").textContent = `${timeMin} min`;
    document.getElementById("mlTurnsVal").textContent = `${turns} turns`;

    const normDist = (distKm * 1000) / 50000.0;
    const normTime = (timeMin * 60) / 3600.0;
    const normTurns = turns / 50.0;

    const pTime = normTime * 5.0;
    const pTurns = normTurns * 3.0;
    const pDist = normDist * 2.0;

    const penTimeEl = document.getElementById("mlPenaltyTime");
    const penTurnsEl = document.getElementById("mlPenaltyTurns");
    const penDistEl = document.getElementById("mlPenaltyDist");
    if (penTimeEl) penTimeEl.textContent = `-${pTime.toFixed(2)} pt`;
    if (penTurnsEl) penTurnsEl.textContent = `-${pTurns.toFixed(2)} pt`;
    if (penDistEl) penDistEl.textContent = `-${pDist.toFixed(2)} pt`;

    const rawScore = 10.0 - pTime - pTurns - pDist;
    const score = Math.max(0.0, Math.min(10.0, rawScore));

    const scoreEl = document.getElementById("mlScoreOutput");
    const verdictEl = document.getElementById("mlVerdictBadge");
    if (scoreEl) scoreEl.textContent = `${score.toFixed(1)} / 10`;
    if (verdictEl) {
      if (score >= 7.5) {
        verdictEl.textContent = "Optimal Corridor";
        verdictEl.style.color = "var(--accent-green)";
      } else if (score >= 4.8) {
        verdictEl.textContent = "Balanced Urban Route";
        verdictEl.style.color = "var(--accent-blue)";
      } else {
        verdictEl.textContent = "High Turn / Delay Penalty";
        verdictEl.style.color = "var(--accent-amber)";
      }
    }
  }

  [mlDistInput, mlTimeInput, mlTurnsInput].forEach((inp) => {
    if (inp) inp.addEventListener("input", updateCoreMLScore);
  });
  updateCoreMLScore();

  // --------------------------------------------------------------------------
  // 11. CarPlay Cockpit Interactive Switcher
  // --------------------------------------------------------------------------
  const cpCameraBtn = document.getElementById("cpCameraToggle");
  const cpMapStage = document.getElementById("cpMapStage");
  let cpIs3D = true;

  if (cpCameraBtn && cpMapStage) {
    cpCameraBtn.addEventListener("click", () => {
      cpIs3D = !cpIs3D;
      cpCameraBtn.textContent = cpIs3D ? "3D Perspective" : "2D North-Up";
      cpMapStage.style.transform = cpIs3D
        ? "perspective(600px) rotateX(22deg) scale(1.06)"
        : "perspective(600px) rotateX(0deg) scale(1)";
    });
  }

  const cpDockIcons = document.querySelectorAll("[data-cp-app]");
  cpDockIcons.forEach((icon) => {
    const activateCpApp = () => {
      const appKey = icon.getAttribute("data-cp-app") || "nav";
      const info = cpApps[appKey];
      if (!info) return;
      activeCarPlayApp = appKey;
      cpDockIcons.forEach((i) => i.classList.remove("active"));
      icon.classList.add("active");
      if (cpBannerSub) {
        cpBannerSub.textContent = info.sub;
        cpBannerSub.style.color = info.color;
      }
      if (cpBannerTitle) {
        cpBannerTitle.textContent = info.title;
      }
    };
    icon.addEventListener("click", activateCpApp);
    addKeyboardClick(icon, activateCpApp);
  });

  // --------------------------------------------------------------------------
  // 12. 3D Icon Composer SVG Layer Deconstructor
  // --------------------------------------------------------------------------
  const explodeBtn = document.getElementById("toggleExplodeLayersBtn");
  const layerViewport = document.getElementById("layerStackViewport");

  if (explodeBtn && layerViewport) {
    explodeBtn.addEventListener("click", () => {
      const exploded = layerViewport.classList.toggle("exploded");
      explodeBtn.textContent = exploded ? "Collapse to Composite Icon" : "Deconstruct 4 Vector Planes";
    });
  }

  // --------------------------------------------------------------------------
  // 13. Screenshot Lightbox Modal
  // --------------------------------------------------------------------------
  const modal = document.getElementById("screenshotModal");
  const modalImg = document.getElementById("modalPreviewImg");
  const modalTitle = document.getElementById("modalPreviewTitle");
  const modalDesc = document.getElementById("modalPreviewDesc");
  const closeModalBtn = document.getElementById("closeModalBtn");

  document.querySelectorAll("[data-lightbox-src]").forEach((card) => {
    const openLightbox = () => {
      if (!modal || !modalImg) return;
      modalImg.src = card.getAttribute("data-lightbox-src");
      if (modalTitle) modalTitle.textContent = card.getAttribute("data-lightbox-title") || "NaviSync iOS Interface";
      if (modalDesc) modalDesc.textContent = card.getAttribute("data-lightbox-desc") || "";
      modal.classList.add("open");
      if (closeModalBtn) closeModalBtn.focus();
    };
    card.addEventListener("click", openLightbox);
    addKeyboardClick(card, openLightbox);
  });

  if (closeModalBtn && modal) {
    closeModalBtn.addEventListener("click", () => modal.classList.remove("open"));
    modal.addEventListener("click", (e) => {
      if (e.target === modal) modal.classList.remove("open");
    });
    window.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && modal.classList.contains("open")) {
        modal.classList.remove("open");
      }
    });
  }
})();
