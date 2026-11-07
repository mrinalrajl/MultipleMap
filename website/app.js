/* ==========================================================================
   NaviSync — Fluid Apple Interaction Engine
   - 1:1 Direct Scrubbing & Spring Transitions
   - Instant pointerdown active feedback
   - Dynamic Island Expand/Collapse
   - Multi-Peer MapKit Telemetry (Alice, Bob, Charlie)
   - Before/After Arrival Convergence Switcher
   - 3-Way Architecture Matrix (NaviSync vs. Life360 vs. Find My)
   - CoreML RouteScorer Live Playground
   - Universal Link Sandbox & App Clip Generator
   ========================================================================== */

(function () {
  "use strict";

  // --------------------------------------------------------------------------
  // 1. Theme Switcher (Apple Light Default <-> Dark Theater)
  // --------------------------------------------------------------------------
  const themeToggleBtn = document.getElementById("themeToggleBtn");
  const themeToggleLabel = document.getElementById("themeToggleLabel");
  const themeToggleIcon = document.getElementById("themeToggleIcon");

  const SUN_SVG = '<circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"></path>';
  const MOON_SVG = '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>';

  function applyTheme(theme) {
    const isDark = theme === "dark";
    document.documentElement.setAttribute("data-theme", isDark ? "dark" : "light");
    if (themeToggleLabel) themeToggleLabel.textContent = isDark ? "Dark" : "Light";
    if (themeToggleIcon) themeToggleIcon.innerHTML = isDark ? MOON_SVG : SUN_SVG;
    if (themeToggleBtn) themeToggleBtn.setAttribute("aria-pressed", isDark ? "false" : "true");
    try { localStorage.setItem("navisync-theme", theme); } catch (_) {}
  }

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener("pointerdown", () => {
      const cur = document.documentElement.getAttribute("data-theme") || "light";
      applyTheme(cur === "dark" ? "light" : "dark");
    });
  }

  try {
    const saved = localStorage.getItem("navisync-theme");
    if (saved) applyTheme(saved);
  } catch (_) {}

  // --------------------------------------------------------------------------
  // 2. Dynamic Island Interactive Expansion
  // --------------------------------------------------------------------------
  const dynamicIsland = document.getElementById("heroDynamicIsland");
  if (dynamicIsland) {
    dynamicIsland.addEventListener("click", () => {
      const isExp = dynamicIsland.classList.toggle("expanded");
      dynamicIsland.setAttribute("aria-expanded", isExp ? "true" : "false");
    });
  }

  // --------------------------------------------------------------------------
  // 3. Multi-Peer MapKit Telemetry & Live Replay
  // --------------------------------------------------------------------------
  const peers = {
    alice: {
      name: "Alice Johnson",
      short: "Alice",
      color: "#2bb3c0",
      avatarClass: "avatar-alice",
      distTotal: 1.4,
      minTotal: 6,
      p0: [50, 420],
      p1: [130, 300],
      p2: [220, 200],
      instruction: "Turn right on Market St",
      distStep: "In 400 feet"
    },
    bob: {
      name: "Bob Martinez",
      short: "Bob",
      color: "#d97757",
      avatarClass: "avatar-bob",
      distTotal: 2.1,
      minTotal: 9,
      p0: [285, 550],
      p1: [240, 380],
      p2: [220, 200],
      instruction: "Merge onto Bryant St",
      distStep: "In 800 feet"
    },
    charlie: {
      name: "Charlie Kim",
      short: "Charlie",
      color: "#7c86f7",
      avatarClass: "avatar-charlie",
      distTotal: 1.8,
      minTotal: 8,
      p0: [70, 580],
      p1: [140, 410],
      p2: [220, 200],
      instruction: "Continue on Folsom St",
      distStep: "In 0.3 miles"
    }
  };

  let activePeer = "alice";
  let progress = 0.45;

  function bezier(p0, p1, p2, t) {
    const u = 1 - t;
    return [
      u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
      u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]
    ];
  }

  function updateSimulation() {
    const isArrived = progress >= 0.96;
    const pct = Math.round(progress * 100);
    const progressEl = document.getElementById("simProgressPct");
    if (progressEl) {
      progressEl.textContent = isArrived ? "100% · Arrived" : pct + "% En Route";
    }

    const cur = peers[activePeer];
    const rem = Math.max(0, 1 - progress);

    // Dynamic Island Sync
    const diEta = document.getElementById("diCompactEta");
    if (diEta) diEta.textContent = isArrived ? "Arrived" : Math.ceil(cur.minTotal * rem) + "m";
    const diExpEta = document.getElementById("diExpEta");
    if (diExpEta) diExpEta.textContent = isArrived ? "Arrived" : "0" + Math.ceil(cur.minTotal * rem) + "m " + Math.floor((rem * 60) % 60) + "s";
    const diExpDist = document.getElementById("diExpDist");
    if (diExpDist) diExpDist.textContent = isArrived ? "0.0 mi left" : (cur.distTotal * rem).toFixed(1) + " mi away";
    const diExpFill = document.getElementById("diExpFill");
    if (diExpFill) diExpFill.style.width = isArrived ? "100%" : Math.max(10, pct) + "%";

    // Maneuver HUD Sync
    const hudDist = document.getElementById("hudDist");
    if (hudDist) hudDist.textContent = isArrived ? "At Destination" : cur.distStep;
    const hudInstruction = document.getElementById("hudInstruction");
    if (hudInstruction) hudInstruction.textContent = isArrived ? "Arrived at target" : cur.instruction;
    const hudPeerBadge = document.getElementById("hudPeerBadge");
    if (hudPeerBadge) {
      hudPeerBadge.textContent = cur.short;
      hudPeerBadge.style.color = cur.color;
    }

    // Move Markers & Polylines
    Object.keys(peers).forEach((key) => {
      const p = peers[key];
      const [x, y] = bezier(p.p0, p.p1, p.p2, progress);

      const marker = document.getElementById("marker-" + key);
      if (marker) {
        marker.setAttribute("transform", "translate(" + x.toFixed(1) + ", " + y.toFixed(1) + ")");
        if (key === activePeer && marker.parentNode) {
          marker.parentNode.appendChild(marker); // promote focused peer to top
        }
      }

      const poly = document.getElementById("route-" + key);
      if (poly) {
        const ctrlX = (1 - progress) * p.p1[0] + progress * p.p2[0];
        const ctrlY = (1 - progress) * p.p1[1] + progress * p.p2[1];
        poly.setAttribute("d", "M " + x.toFixed(1) + "," + y.toFixed(1) + " Q " + ctrlX.toFixed(1) + "," + ctrlY.toFixed(1) + " " + p.p2[0] + "," + p.p2[1]);
        poly.setAttribute("opacity", key === activePeer ? "1" : "0.35");
      }

      // Bottom Sheet Rows
      const etaLabel = document.getElementById(key + "Eta");
      if (etaLabel) etaLabel.textContent = isArrived ? "Arrived" : Math.ceil(p.minTotal * rem) + "m";
      const distLabel = document.getElementById(key + "Dist");
      if (distLabel) distLabel.textContent = isArrived ? "0.0 mi" : (p.distTotal * rem).toFixed(1) + " mi";
    });
  }

  function setFocusedPeer(key) {
    if (!peers[key]) return;
    activePeer = key;

    // Update bottom sheet rows
    document.querySelectorAll(".sheet-peer-row").forEach((row) => {
      const isTarget = row.getAttribute("data-peer-row") === key;
      row.classList.toggle("active", isTarget);
      const badge = row.querySelector(".peer-badge");
      if (badge) badge.style.display = isTarget ? "inline-block" : "none";
    });

    // Update chip buttons
    document.querySelectorAll(".apple-chip-btn").forEach((chip) => {
      chip.classList.toggle("active", chip.getAttribute("data-select-peer") === key);
    });

    // Update Dynamic Island text
    const cur = peers[key];
    const diCompactName = document.getElementById("diCompactName");
    if (diCompactName) diCompactName.textContent = cur.short;
    const diExpName = document.getElementById("diExpName");
    if (diExpName) diExpName.textContent = cur.name;
    const diExpAvatar = document.getElementById("diExpAvatar");
    if (diExpAvatar) {
      diExpAvatar.textContent = cur.short.charAt(0);
      diExpAvatar.style.background = cur.color;
    }

    updateSimulation();
  }

  // Scrubber Listener
  const simSlider = document.getElementById("heroSimSlider");
  if (simSlider) {
    simSlider.addEventListener("input", (e) => {
      progress = Number(e.target.value) / 100;
      updateSimulation();
    });
  }

  // Peer chip listeners
  document.querySelectorAll(".apple-chip-btn").forEach((btn) => {
    btn.addEventListener("pointerdown", () => {
      setFocusedPeer(btn.getAttribute("data-select-peer"));
    });
  });

  // Sheet row listeners
  document.querySelectorAll(".sheet-peer-row").forEach((row) => {
    row.addEventListener("pointerdown", () => {
      setFocusedPeer(row.getAttribute("data-peer-row"));
    });
  });

  // --------------------------------------------------------------------------
  // 4. Destination Command Bar Synchronization
  // --------------------------------------------------------------------------
  const heroDestInput = document.getElementById("heroDestInput");
  const heroCopyBtn = document.getElementById("heroCopyBtn");
  const heroLinkPreview = document.getElementById("heroLinkPreview");

  function syncDestination(name, addr) {
    const cleanName = (name || "Tartine").trim();
    const shortName = cleanName.split(",")[0].slice(0, 16);
    const slug = cleanName.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "") || "meetup";

    if (heroLinkPreview) heroLinkPreview.textContent = "navisync.app/m/" + slug;
    const mapPinText = document.getElementById("mapDestPinText");
    if (mapPinText) mapPinText.textContent = shortName;
    const sheetTitle = document.getElementById("sheetDestTitle");
    if (sheetTitle) sheetTitle.textContent = cleanName;
    const sheetAddress = document.getElementById("sheetDestAddress");
    if (sheetAddress && addr) sheetAddress.textContent = addr + " · 3 Friends Converging";
    const diExpDest = document.getElementById("diExpDest");
    if (diExpDest) diExpDest.textContent = "Heading to " + shortName;
    const cpSub = document.getElementById("cpBannerSub");
    if (cpSub) cpSub.textContent = "Converging on " + shortName;
    const sandboxUrl = document.getElementById("sandboxUrlDisplay");
    if (sandboxUrl) sandboxUrl.textContent = "https://navisync.app/m/" + slug;
  }

  if (heroDestInput) {
    heroDestInput.addEventListener("input", (e) => {
      syncDestination(e.target.value, "Custom Location");
    });
  }

  document.querySelectorAll(".apple-chip-preset").forEach((chip) => {
    chip.addEventListener("pointerdown", () => {
      document.querySelectorAll(".apple-chip-preset").forEach((c) => c.classList.remove("active"));
      chip.classList.add("active");
      const presetName = chip.getAttribute("data-dest-preset");
      const presetAddr = chip.getAttribute("data-dest-addr");
      if (heroDestInput) heroDestInput.value = presetName;
      syncDestination(presetName, presetAddr);
    });
  });

  if (heroCopyBtn) {
    heroCopyBtn.addEventListener("pointerdown", () => {
      const orig = heroCopyBtn.innerHTML;
      heroCopyBtn.innerHTML = "<span>✓ Copied Link</span>";
      setTimeout(() => { heroCopyBtn.innerHTML = orig; }, 1800);
    });
  }

  // --------------------------------------------------------------------------
  // 5. Before vs. After Arrival Comparison Switcher
  // --------------------------------------------------------------------------
  const compHeadline = document.getElementById("compHeadline");
  const compCopy = document.getElementById("compCopy");
  const compMetricTexts = document.getElementById("compMetricTexts");
  const compMetricInstall = document.getElementById("compMetricInstall");
  const compMetricWindow = document.getElementById("compMetricWindow");
  const mockCardDisplay = document.getElementById("mockCardDisplay");

  document.querySelectorAll(".seg-btn").forEach((btn) => {
    btn.addEventListener("pointerdown", () => {
      document.querySelectorAll(".seg-btn").forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      const mode = btn.getAttribute("data-mode");

      if (mode === "chaos") {
        if (compHeadline) compHeadline.textContent = "20 frantic texts, missed exits, lost reservations.";
        if (compCopy) compCopy.textContent = "Without NaviSync, friends guess arrival times. Drivers text while merging, ETAs slip without notice, and the first arrivals wait 25+ minutes alone while venues cancel tables.";
        if (compMetricTexts) { compMetricTexts.textContent = "18 Texts"; compMetricTexts.style.color = "#ff3b30"; }
        if (compMetricInstall) { compMetricInstall.textContent = "140 MB"; compMetricInstall.style.color = "#ff9500"; }
        if (compMetricWindow) { compMetricWindow.textContent = "28.5m"; compMetricWindow.style.color = "#ff3b30"; }
        if (mockCardDisplay) {
          mockCardDisplay.innerHTML = `
            <div style="text-align:center;color:#ff3b30;">
              <div style="font-size:2.2rem;margin-bottom:8px;">⚠️</div>
              <strong style="display:block;font-size:1.1rem;color:var(--text-primary);">Distracted Messaging Loop</strong>
              <span style="font-size:0.85rem;color:var(--text-secondary);">"Where are you guys?" · "5 mins away" (still at home)</span>
            </div>
          `;
        }
      } else {
        if (compHeadline) compHeadline.textContent = "One link replaces twenty chaotic texts.";
        if (compCopy) compCopy.textContent = "When you share a NaviSync invite, friends tap it and launch an instant iOS App Clip in under 2 seconds. No login, no password. Everyone sees real-time road polylines, live ETAs, and parking corridors on a shared Apple Map.";
        if (compMetricTexts) { compMetricTexts.textContent = "0 Texts"; compMetricTexts.style.color = "var(--apple-blue)"; }
        if (compMetricInstall) { compMetricInstall.textContent = "< 2s"; compMetricInstall.style.color = "var(--apple-blue)"; }
        if (compMetricWindow) { compMetricWindow.textContent = "3.2m"; compMetricWindow.style.color = "var(--apple-blue)"; }
        if (mockCardDisplay) {
          mockCardDisplay.innerHTML = `
            <div class="visual-sync-box">
              <div class="sync-icon">✓</div>
              <div class="sync-text">
                <strong>Synchronized Arrival</strong>
                <span>Everyone converges within a 3-minute window. Zero texts sent.</span>
              </div>
            </div>
          `;
        }
      }
    });
  });

  // --------------------------------------------------------------------------
  // 6. 3-Way Architecture Matrix (NaviSync vs. Life360 vs. Apple Find My)
  // --------------------------------------------------------------------------
  const vsTag = document.getElementById("vsTag");
  const vsTitle = document.getElementById("vsTitle");
  const vsBadge = document.getElementById("vsBadge");
  const vsOnboarding = document.getElementById("vsOnboarding");
  const vsOnboardingDesc = document.getElementById("vsOnboardingDesc");
  const vsPrivacy = document.getElementById("vsPrivacy");
  const vsPrivacyDesc = document.getElementById("vsPrivacyDesc");
  const vsGuidance = document.getElementById("vsGuidance");
  const vsGuidanceDesc = document.getElementById("vsGuidanceDesc");
  const vsSurfaces = document.getElementById("vsSurfaces");
  const vsSurfacesDesc = document.getElementById("vsSurfacesDesc");

  document.querySelectorAll(".vs-select-btn").forEach((btn) => {
    btn.addEventListener("pointerdown", () => {
      document.querySelectorAll(".vs-select-btn").forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      const app = btn.getAttribute("data-vs-app");

      if (app === "life360") {
        if (vsTag) vsTag.textContent = "LIFE360 SURVEILLANCE PARADIGM";
        if (vsTitle) vsTitle.textContent = "24/7 background tracking. High friction & privacy invasion.";
        if (vsBadge) { vsBadge.textContent = "High Surveillance"; vsBadge.style.background = "rgba(255, 59, 48, 0.15)"; vsBadge.style.color = "#ff3b30"; }
        if (vsOnboarding) vsOnboarding.textContent = "Mandatory 140 MB App Download";
        if (vsOnboardingDesc) vsOnboardingDesc.textContent = "Every person must download an app, create an account, verify SMS, and join a permanent Circle.";
        if (vsPrivacy) vsPrivacy.textContent = "Constant 24/7 Monitoring";
        if (vsPrivacyDesc) vsPrivacyDesc.textContent = "Tracks your exact speed, battery percentage, and lifetime whereabouts even when not meeting up.";
        if (vsGuidance) vsGuidance.textContent = "None (Raw Dots Only)";
        if (vsGuidanceDesc) vsGuidanceDesc.textContent = "Shows raw coordinate circles. Zero road polylines, turn maneuvers, or convergence ETAs.";
        if (vsSurfaces) vsSurfaces.textContent = "Phone App Push Only";
        if (vsSurfacesDesc) vsSurfacesDesc.textContent = "No CarPlay multi-peer HUD or Lock Screen Dynamic Island integration.";
      } else if (app === "findmy") {
        if (vsTag) vsTag.textContent = "APPLE FIND MY LIMITATIONS";
        if (vsTitle) vsTitle.textContent = "Passive static dots with zero route or arrival awareness.";
        if (vsBadge) { vsBadge.textContent = "Passive Tracker"; vsBadge.style.background = "rgba(142, 142, 147, 0.15)"; vsBadge.style.color = "#8e8e93"; }
        if (vsOnboarding) vsOnboarding.textContent = "Requires Prior Apple ID Contact Approval";
        if (vsOnboardingDesc) vsOnboardingDesc.textContent = "Cannot share an ephemeral link with mixed groups or new friends without exchanging Apple IDs.";
        if (vsPrivacy) vsPrivacy.textContent = "Always-On Contact Link";
        if (vsPrivacyDesc) vsPrivacyDesc.textContent = "Shares ongoing background location until manually revoked. Not scoped to a specific arrival.";
        if (vsGuidance) vsGuidance.textContent = "Passive Static Pin";
        if (vsGuidanceDesc) vsGuidanceDesc.textContent = "A static blue dot on a blank map. No traffic-adjusted route polyline or group countdown.";
        if (vsSurfaces) vsSurfaces.textContent = "Basic Widget Only";
        if (vsSurfacesDesc) vsSurfacesDesc.textContent = "No CarPlay multi-vehicle HUD or Dynamic Island turn countdowns.";
      } else {
        // NaviSync
        if (vsTag) vsTag.textContent = "NAVISYNC ARCHITECTURE";
        if (vsTitle) vsTitle.textContent = "Purpose-built for arrival. Zero 24/7 tracking.";
        if (vsBadge) { vsBadge.textContent = "Privacy-First"; vsBadge.style.background = "rgba(48, 209, 88, 0.15)"; vsBadge.style.color = "var(--apple-emerald)"; }
        if (vsOnboarding) vsOnboarding.textContent = "< 2 Seconds (App Clip)";
        if (vsOnboardingDesc) vsOnboardingDesc.textContent = "Invitees tap one link. No account creation, no password, no 140MB App Store download.";
        if (vsPrivacy) vsPrivacy.textContent = "Ephemeral Session";
        if (vsPrivacyDesc) vsPrivacyDesc.textContent = "Tracks only while traveling to the destination pin. Auto-terminates the second you arrive.";
        if (vsGuidance) vsGuidance.textContent = "Active 3D Polylines + ETAs";
        if (vsGuidanceDesc) vsGuidanceDesc.textContent = "Real MKDirections road geometry, turn maneuvers, and synchronized arrival countdowns.";
        if (vsSurfaces) vsSurfaces.textContent = "CarPlay + Dynamic Island";
        if (vsSurfacesDesc) vsSurfacesDesc.textContent = "Glanceable heads-up display right on your dashboard and Lock Screen.";
      }
    });
  });

  // --------------------------------------------------------------------------
  // 7. CoreML RouteScorer Playground
  // --------------------------------------------------------------------------
  const mlDistSlider = document.getElementById("mlDistSlider");
  const mlTurnsSlider = document.getElementById("mlTurnsSlider");
  const mlTimeSlider = document.getElementById("mlTimeSlider");

  const mlDistVal = document.getElementById("mlDistVal");
  const mlTurnsVal = document.getElementById("mlTurnsVal");
  const mlTimeVal = document.getElementById("mlTimeVal");
  const mlScoreVal = document.getElementById("mlScoreVal");
  const mlVerdict = document.getElementById("mlVerdict");

  function updateCoreML() {
    const dist = Number(mlDistSlider.value);
    const turns = Number(mlTurnsSlider.value);
    const time = Number(mlTimeSlider.value);

    if (mlDistVal) mlDistVal.textContent = dist + " km";
    if (mlTurnsVal) mlTurnsVal.textContent = turns + " turns";
    if (mlTimeVal) mlTimeVal.textContent = time + " min";

    // Scoring formula from MLTraining/train_model.py
    const score = Math.max(0, Math.min(10, 10 - (time / 60) * 5 - (turns / 40) * 3 - (dist / 50) * 2));
    if (mlScoreVal) mlScoreVal.textContent = score.toFixed(1) + " / 10";

    if (mlVerdict) {
      if (score >= 7.8) {
        mlVerdict.textContent = "Optimal Route";
        mlVerdict.style.color = "var(--apple-emerald)";
      } else if (score >= 5.2) {
        mlVerdict.textContent = "Moderate Traffic";
        mlVerdict.style.color = "var(--apple-blue)";
      } else {
        mlVerdict.textContent = "High Turn Penalty";
        mlVerdict.style.color = "var(--apple-terracotta)";
      }
    }
  }

  [mlDistSlider, mlTurnsSlider, mlTimeSlider].forEach((slider) => {
    if (slider) slider.addEventListener("input", updateCoreML);
  });

  // --------------------------------------------------------------------------
  // 8. Sandbox Generator
  // --------------------------------------------------------------------------
  const sandboxGenerateBtn = document.getElementById("sandboxGenerateBtn");
  const sandboxTitle = document.getElementById("sandboxTitle");
  const sandboxCopyBtn = document.getElementById("sandboxCopyBtn");

  if (sandboxGenerateBtn) {
    sandboxGenerateBtn.addEventListener("pointerdown", () => {
      const title = (sandboxTitle && sandboxTitle.value) || "Meetup";
      const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "") || "meetup";
      const display = document.getElementById("sandboxUrlDisplay");
      if (display) display.textContent = "https://navisync.app/m/" + slug;
    });
  }

  if (sandboxCopyBtn) {
    sandboxCopyBtn.addEventListener("pointerdown", () => {
      sandboxCopyBtn.textContent = "Copied!";
      setTimeout(() => { sandboxCopyBtn.textContent = "Copy"; }, 1500);
    });
  }

  // Initial Run
  updateSimulation();
  updateCoreML();

})();
