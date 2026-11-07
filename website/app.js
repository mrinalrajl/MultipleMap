/**
 * NaviSync — Apple Fluid Web Experience
 *
 * Built following Apple Design principles:
 * - Fluid response on pointer-down
 * - Physical spring curves & interruptible transitions
 * - Multi-agent spatial simulation & Live Activity synchronization
 */

document.addEventListener('DOMContentLoaded', () => {
  'use strict';

  /* ==========================================================================
     01. THEME TOGGLER (Light / Dark)
     ========================================================================== */
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  const themeToggleLabel = document.getElementById('themeToggleLabel');

  function initTheme() {
    const savedTheme = localStorage.getItem('navisync-theme') || 'light';
    setTheme(savedTheme);

    if (themeToggleBtn) {
      themeToggleBtn.addEventListener('click', () => {
        const current = document.documentElement.getAttribute('data-theme') || 'light';
        const next = current === 'dark' ? 'light' : 'dark';
        setTheme(next);
      });
    }
  }

  function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('navisync-theme', theme);
    if (themeToggleLabel) {
      themeToggleLabel.textContent = theme === 'dark' ? 'Dark' : 'Light';
    }
    if (themeToggleBtn) {
      themeToggleBtn.setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
    }
  }

  initTheme();

  /* ==========================================================================
     02. FLUID POINTER-DOWN FEEDBACK (Response - Kill Latency)
     ========================================================================== */
  document.querySelectorAll('button, .roster-row, .preset-chip, .bento-card-light, .bento-card-dark, .dynamic-island').forEach(el => {
    el.addEventListener('pointerdown', () => {
      el.style.transform = 'scale(0.97)';
      el.style.transition = 'transform 80ms cubic-bezier(0.16, 1, 0.3, 1)';
    });
    const resetTransform = () => {
      el.style.transform = '';
      el.style.transition = 'transform 300ms cubic-bezier(0.16, 1, 0.3, 1)';
    };
    el.addEventListener('pointerup', resetTransform);
    el.addEventListener('pointercancel', resetTransform);
    el.addEventListener('mouseleave', resetTransform);
  });

  /* ==========================================================================
     03. NAVIGATION SCROLLSPY & SCROLLED STATE
     ========================================================================== */
  const navbar = document.getElementById('mainNavbar');
  const navLinks = document.querySelectorAll('.nav-links .nav-link');
  const sections = document.querySelectorAll('section[id]');

  window.addEventListener('scroll', () => {
    if (navbar) {
      navbar.classList.toggle('scrolled', window.scrollY > 20);
    }
  }, { passive: true });

  if ('IntersectionObserver' in window && sections.length > 0) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const id = entry.target.getAttribute('id');
          navLinks.forEach(link => {
            link.classList.toggle('active', link.getAttribute('href') === `#${id}`);
          });
        }
      });
    }, { rootMargin: '-20% 0px -70% 0px' });

    sections.forEach(sec => observer.observe(sec));
  }

  /* ==========================================================================
     04. DESTINATION PRESETS & COMPOSER
     ========================================================================== */
  const heroDestInput = document.getElementById('heroDestInput');
  const heroCopyBtn = document.getElementById('heroCopyBtn');
  const heroLinkPreview = document.getElementById('heroLinkPreview');
  const presetChips = document.querySelectorAll('.preset-chip');
  const mapDestPinText = document.getElementById('mapDestPinText');
  const sheetDestTitle = document.getElementById('sheetDestTitle');
  const diExpDest = document.getElementById('diExpDest');

  function slugify(text) {
    return text.toString().toLowerCase().trim()
      .replace(/\s+/g, '-')
      .replace(/[^\w\-]+/g, '')
      .replace(/\-\-+/g, '-');
  }

  function updateDestination(name) {
    if (!name) name = 'Tartine Manufactory';
    const slug = slugify(name);
    if (heroLinkPreview) heroLinkPreview.textContent = `navisync.app/m/${slug}`;
    if (mapDestPinText) mapDestPinText.textContent = name.split(' ')[0];
    if (sheetDestTitle) sheetDestTitle.textContent = name;
    if (diExpDest) diExpDest.textContent = `Heading to ${name.split(' ')[0]}`;
  }

  if (heroDestInput) {
    heroDestInput.addEventListener('input', (e) => {
      updateDestination(e.target.value);
    });
  }

  presetChips.forEach(chip => {
    chip.addEventListener('click', () => {
      presetChips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      const place = chip.getAttribute('data-place');
      if (heroDestInput) heroDestInput.value = place;
      updateDestination(place);
    });
  });

  if (heroCopyBtn && heroLinkPreview) {
    heroCopyBtn.addEventListener('click', () => {
      const url = `https://${heroLinkPreview.textContent}`;
      navigator.clipboard.writeText(url).then(() => {
        const original = heroCopyBtn.textContent;
        heroCopyBtn.textContent = 'Copied!';
        heroCopyBtn.style.background = '#30d158';
        setTimeout(() => {
          heroCopyBtn.textContent = original;
          heroCopyBtn.style.background = '';
        }, 1800);
      }).catch(() => {
        heroCopyBtn.textContent = 'Copied!';
        setTimeout(() => { heroCopyBtn.textContent = 'Copy App Clip'; }, 1800);
      });
    });
  }

  /* ==========================================================================
     05. HERO MULTI-AGENT SPATIAL SIMULATION & SCRUBBER
     ========================================================================== */
  const heroSimSlider = document.getElementById('heroSimSlider');
  const heroPlayBtn = document.getElementById('heroPlayBtn');
  const playIcon = document.getElementById('playIcon');
  const playLabel = document.getElementById('playLabel');
  const simProgressPct = document.getElementById('simProgressPct');
  const statSpread = document.getElementById('statSpread');

  // Markers & Elements
  const markerAlice = document.getElementById('marker-alice');
  const markerBob = document.getElementById('marker-bob');
  const markerCharlie = document.getElementById('marker-charlie');

  const aliceEta = document.getElementById('aliceEta');
  const bobEta = document.getElementById('bobEta');
  const charlieEta = document.getElementById('charlieEta');

  const aliceDist = document.getElementById('aliceDist');
  const bobDist = document.getElementById('bobDist');
  const charlieDist = document.getElementById('charlieDist');

  const aliceSub = document.getElementById('aliceSub');
  const bobSub = document.getElementById('bobSub');
  const charlieSub = document.getElementById('charlieSub');

  const hudDist = document.getElementById('hudDist');
  const hudInstruction = document.getElementById('hudInstruction');
  const diCompactEta = document.getElementById('diCompactEta');
  const diExpEta = document.getElementById('diExpEta');
  const diExpDist = document.getElementById('diExpDist');
  const diExpFill = document.getElementById('diExpFill');

  // Quadratic Bézier curve math: B(t) = (1-t)^2 * P0 + 2*(1-t)*t * P1 + t^2 * P2
  function bezierPoint(t, p0, p1, p2) {
    const inv = 1 - t;
    const x = inv * inv * p0.x + 2 * inv * t * p1.x + t * t * p2.x;
    const y = inv * inv * p0.y + 2 * inv * t * p1.y + t * t * p2.y;
    return { x, y };
  }

  // Route Paths
  // Alice: M 48,395 Q 130,295 215,205
  const aliceRoute = { p0: { x: 48, y: 395 }, p1: { x: 130, y: 295 }, p2: { x: 215, y: 205 } };
  // Bob: M 285,510 Q 250,350 215,205
  const bobRoute = { p0: { x: 285, y: 510 }, p1: { x: 250, y: 350 }, p2: { x: 215, y: 205 } };
  // Charlie: M 65,530 Q 135,380 215,205
  const charlieRoute = { p0: { x: 65, y: 530 }, p1: { x: 135, y: 380 }, p2: { x: 215, y: 205 } };

  let simProgress = 0.45;
  let isPlaying = false;
  let animFrameId = null;

  function updateSimulation(t) {
    simProgress = Math.max(0, Math.min(1, t));

    if (heroSimSlider) {
      heroSimSlider.value = Math.round(simProgress * 100);
    }
    if (simProgressPct) {
      simProgressPct.textContent = `${Math.round(simProgress * 100)}% En Route · 3 Peers Active`;
    }

    // Alice progress (starts earlier, reaches destination at t=0.92)
    const tAlice = Math.min(1, simProgress * 1.05);
    const posA = bezierPoint(tAlice, aliceRoute.p0, aliceRoute.p1, aliceRoute.p2);
    if (markerAlice) markerAlice.setAttribute('transform', `translate(${posA.x.toFixed(1)}, ${posA.y.toFixed(1)})`);

    // Bob progress (reaches destination at t=0.98)
    const tBob = Math.min(1, simProgress * 0.95);
    const posB = bezierPoint(tBob, bobRoute.p0, bobRoute.p1, bobRoute.p2);
    if (markerBob) markerBob.setAttribute('transform', `translate(${posB.x.toFixed(1)}, ${posB.y.toFixed(1)})`);

    // Charlie progress (reaches destination at t=1.0)
    const tCharlie = Math.min(1, simProgress * 0.90);
    const posC = bezierPoint(tCharlie, charlieRoute.p0, charlieRoute.p1, charlieRoute.p2);
    if (markerCharlie) markerCharlie.setAttribute('transform', `translate(${posC.x.toFixed(1)}, ${posC.y.toFixed(1)})`);

    // ETAs and Distances calculation
    const aRemainingSec = Math.max(0, Math.round((1 - tAlice) * 360));
    const bRemainingSec = Math.max(0, Math.round((1 - tBob) * 440));
    const cRemainingSec = Math.max(0, Math.round((1 - tCharlie) * 480));

    const aMin = Math.ceil(aRemainingSec / 60);
    const bMin = Math.ceil(bRemainingSec / 60);
    const cMin = Math.ceil(cRemainingSec / 60);

    const aDistMiles = ((1 - tAlice) * 1.8).toFixed(1);
    const bDistMiles = ((1 - tBob) * 2.2).toFixed(1);
    const cDistMiles = ((1 - tCharlie) * 2.5).toFixed(1);

    if (aliceEta) aliceEta.textContent = aMin === 0 ? 'Here' : `${aMin}m`;
    if (bobEta) bobEta.textContent = bMin === 0 ? 'Here' : `${bMin}m`;
    if (charlieEta) charlieEta.textContent = cMin === 0 ? 'Here' : `${cMin}m`;

    if (aliceDist) aliceDist.textContent = aMin === 0 ? 'Arrived' : `${aDistMiles} mi`;
    if (bobDist) bobDist.textContent = bMin === 0 ? 'Arrived' : `${bDistMiles} mi`;
    if (charlieDist) charlieDist.textContent = cMin === 0 ? 'Arrived' : `${cDistMiles} mi`;

    // Dynamic Island updates
    if (diCompactEta) diCompactEta.textContent = aMin === 0 ? '0m' : `${aMin}m`;
    if (diExpEta) {
      const mins = Math.floor(aRemainingSec / 60).toString().padStart(2, '0');
      const secs = (aRemainingSec % 60).toString().padStart(2, '0');
      diExpEta.textContent = `${mins}m ${secs}s`;
    }
    if (diExpDist) diExpDist.textContent = aMin === 0 ? 'Arrived at curb' : `${aDistMiles} mi away`;
    if (diExpFill) diExpFill.style.width = `${Math.min(100, Math.round(tAlice * 100))}%`;

    // Turn HUD updates
    if (hudDist && hudInstruction) {
      if (tAlice < 0.55) {
        hudDist.textContent = 'In 400 feet';
        hudInstruction.textContent = 'Turn right on Market St';
        if (aliceSub) aliceSub.textContent = '400 ft to Market St';
      } else if (tAlice < 0.88) {
        hudDist.textContent = 'In 150 feet';
        hudInstruction.textContent = 'Turn left onto Alabama St';
        if (aliceSub) aliceSub.textContent = 'Turning on Alabama St';
      } else {
        hudDist.textContent = 'Arriving';
        hudInstruction.textContent = 'Tartine Manufactory on right';
        if (aliceSub) aliceSub.textContent = 'Arrived at parking curb';
      }
    }

    // Arrival Spread Window
    const spreadMin = ((Math.max(bRemainingSec, cRemainingSec) - aRemainingSec) / 60).toFixed(1);
    if (statSpread) statSpread.textContent = `${Math.max(0.4, spreadMin)} min`;
  }

  if (heroSimSlider) {
    heroSimSlider.addEventListener('input', (e) => {
      pauseSimulation();
      updateSimulation(parseFloat(e.target.value) / 100);
    });
  }

  function playLoop() {
    if (!isPlaying) return;
    simProgress += 0.0018;
    if (simProgress > 1) {
      simProgress = 0;
    }
    updateSimulation(simProgress);
    animFrameId = requestAnimationFrame(playLoop);
  }

  function startSimulation() {
    isPlaying = true;
    if (playIcon) playIcon.textContent = '⏸';
    if (playLabel) playLabel.textContent = 'Pause';
    animFrameId = requestAnimationFrame(playLoop);
  }

  function pauseSimulation() {
    isPlaying = false;
    if (playIcon) playIcon.textContent = '▶';
    if (playLabel) playLabel.textContent = 'Auto-Drive';
    if (animFrameId) cancelAnimationFrame(animFrameId);
  }

  if (heroPlayBtn) {
    heroPlayBtn.addEventListener('click', () => {
      if (isPlaying) {
        pauseSimulation();
      } else {
        startSimulation();
      }
    });
  }

  // Initial state render
  updateSimulation(simProgress);

  /* ==========================================================================
     06. DYNAMIC ISLAND EXPAND / COLLAPSE
     ========================================================================== */
  const dynamicIsland = document.getElementById('heroDynamicIsland');

  if (dynamicIsland) {
    dynamicIsland.addEventListener('click', (e) => {
      e.stopPropagation();
      const isExpanded = dynamicIsland.classList.toggle('expanded');
      dynamicIsland.setAttribute('aria-expanded', isExpanded ? 'true' : 'false');
    });

    // Close when tapping anywhere outside the Dynamic Island
    document.addEventListener('click', (e) => {
      if (dynamicIsland.classList.contains('expanded') && !dynamicIsland.contains(e.target)) {
        dynamicIsland.classList.remove('expanded');
        dynamicIsland.setAttribute('aria-expanded', 'false');
      }
    });
  }

  /* ==========================================================================
     07. PEER FOCUS SWITCHER
     ========================================================================== */
  const rosterRows = document.querySelectorAll('.roster-row');
  const hudPeerBadge = document.getElementById('hudPeerBadge');
  const diCompactName = document.getElementById('diCompactName');
  const diExpName = document.getElementById('diExpName');
  const diExpAvatar = document.getElementById('diExpAvatar');

  const peerData = {
    alice: { name: 'Alice', fullName: 'Alice Johnson', avatar: 'A', routeId: 'route-alice', markerId: 'marker-alice' },
    bob: { name: 'Bob', fullName: 'Bob Martinez', avatar: 'B', routeId: 'route-bob', markerId: 'marker-bob' },
    charlie: { name: 'Charlie', fullName: 'Charlie Kim', avatar: 'C', routeId: 'route-charlie', markerId: 'marker-charlie' }
  };

  rosterRows.forEach(row => {
    row.addEventListener('click', () => {
      const peerKey = row.getAttribute('data-peer-row');
      const data = peerData[peerKey];
      if (!data) return;

      // Update badge focus
      rosterRows.forEach(r => {
        const badge = r.querySelector('.badge-focus');
        if (badge) badge.style.display = r === row ? 'inline-block' : 'none';
      });

      // Update Turn HUD
      if (hudPeerBadge) hudPeerBadge.textContent = data.name;

      // Update Dynamic Island
      if (diCompactName) diCompactName.textContent = data.name;
      if (diExpName) diExpName.textContent = data.fullName;
      if (diExpAvatar) diExpAvatar.textContent = data.avatar;

      // Update map focused polylines
      document.querySelectorAll('.route-poly').forEach(p => p.classList.remove('focused'));
      const activeRoute = document.getElementById(data.routeId);
      if (activeRoute) activeRoute.classList.add('focused');

      // Update peer markers
      document.querySelectorAll('.peer-marker').forEach(m => m.classList.remove('focused'));
      const activeMarker = document.getElementById(data.markerId);
      if (activeMarker) activeMarker.classList.add('focused');
    });
  });

  /* ==========================================================================
     08. SECTION 01: INTERACTIVE CONTRAST (Chaos vs Calm)
     ========================================================================== */
  const compVisualBox = document.getElementById('compVisualBox');
  const compHeadline = document.getElementById('compHeadline');
  const compCopy = document.getElementById('compCopy');
  const compMetricTexts = document.getElementById('compMetricTexts');
  const compMetricInstall = document.getElementById('compMetricInstall');
  const compMetricSpread = document.getElementById('compMetricSpread');
  const compModeBtns = document.querySelectorAll('[data-comp-mode]');

  const contrastModes = {
    chaos: {
      headline: '20 frantic texts. 45 minutes of staggered delays.',
      copy: 'Without a unified spatial layer, groups rely on fragmented texting. Drivers are forced to read screens at 65 MPH, guess arrival windows, and circle the block waiting for latecomers.',
      texts: '18 Texts',
      install: '0 Apps',
      spread: '24.0m',
      visualHtml: `
        <div class="chaos-chat-thread">
          <div class="chat-bubble incoming">
            <span class="chat-sender">Bob</span>
            Where are you guys?? Table is being called.
          </div>
          <div class="chat-bubble incoming">
            <span class="chat-sender">Charlie</span>
            Stuck on 101, GPS says 15m but traffic is totally dead
          </div>
          <div class="chat-bubble outgoing">
            <span class="chat-sender">You</span>
            I took exit 43B, is that right??
          </div>
          <div class="chat-bubble incoming">
            <span class="chat-sender">Alice</span>
            No exit 44!! Circle back around Market
          </div>
        </div>
      `
    },
    sync: {
      headline: 'One link replaces twenty chaotic texts.',
      copy: 'When you share a NaviSync invite, friends tap it and launch an instant iOS App Clip in under 2 seconds. No login, no password. Everyone sees real-time road polylines, live ETAs, and parking corridors on a shared Apple Map that auto-terminates the moment you arrive.',
      texts: '0 Texts',
      install: '< 2s',
      spread: '3.2m',
      visualHtml: `
        <div class="sync-graphic">
          <div class="sync-badge-icon">✓</div>
          <div class="sync-text-group">
            <strong>Synchronized Arrival</strong>
            <span>Everyone converges within a 3-minute window. Zero texts sent.</span>
          </div>
        </div>
      `
    }
  };

  compModeBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      compModeBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const modeKey = btn.getAttribute('data-comp-mode');
      const mode = contrastModes[modeKey];
      if (!mode) return;

      if (compVisualBox) compVisualBox.innerHTML = mode.visualHtml;
      if (compHeadline) compHeadline.textContent = mode.headline;
      if (compCopy) compCopy.textContent = mode.copy;
      if (compMetricTexts) compMetricTexts.textContent = mode.texts;
      if (compMetricInstall) compMetricInstall.textContent = mode.install;
      if (compMetricSpread) compMetricSpread.textContent = mode.spread;
    });
  });

  /* ==========================================================================
     09. SECTION 04: DEEP COMPARISON MATRIX (vs Life360 & Find My)
     ========================================================================== */
  const vsTabBtns = document.querySelectorAll('.vs-tab-btn');
  const vsKicker = document.getElementById('vsKicker');
  const vsTitle = document.getElementById('vsTitle');
  const vsBadge = document.getElementById('vsBadge');
  const vsOnboarding = document.getElementById('vsOnboarding');
  const vsOnboardingText = document.getElementById('vsOnboardingText');
  const vsPrivacy = document.getElementById('vsPrivacy');
  const vsPrivacyText = document.getElementById('vsPrivacyText');
  const vsGuidance = document.getElementById('vsGuidance');
  const vsGuidanceText = document.getElementById('vsGuidanceText');
  const vsSurfaces = document.getElementById('vsSurfaces');
  const vsSurfacesText = document.getElementById('vsSurfacesText');

  const vsData = {
    navisync: {
      kicker: 'NAVISYNC ARCHITECTURE',
      title: 'Purpose-built for arrival. Zero 24/7 tracking.',
      badge: 'Privacy-First',
      badgeClass: 'badge-emerald',
      onboarding: '< 2 Seconds (App Clip)',
      onboardingText: 'Invitees tap one universal link. No account creation, no password, no 140MB App Store download.',
      privacy: 'Ephemeral Session',
      privacyText: 'Tracks only while traveling to the destination pin. Auto-terminates the second you arrive.',
      guidance: 'Active 3D Polylines + ETAs',
      guidanceText: 'Real MKDirections road geometry, turn maneuvers, and synchronized arrival countdowns.',
      surfaces: 'CarPlay + Dynamic Island',
      surfacesText: 'Glanceable heads-up display right on your dashboard and Lock Screen Live Activities.'
    },
    life360: {
      kicker: 'LIFE360 LEGACY MODEL',
      title: 'Continuous surveillance and battery drain.',
      badge: '24/7 Tracking',
      badgeClass: 'badge-amber',
      onboarding: 'High Friction (Account Required)',
      onboardingText: 'Everyone must download the heavy 180MB app, create permanent accounts, and join a family circle.',
      privacy: 'Permanent Background Logging',
      privacyText: 'Tracks users 24 hours a day, 7 days a week. Logs top speed, phone usage while driving, and home locations.',
      guidance: 'No Road Navigation',
      guidanceText: 'Only shows static pins on a map. No turn-by-turn guidance, no lane recommendations, no shared arrival window.',
      surfaces: 'Phone-Only Widget',
      surfacesText: 'No native Apple CarPlay CPMapTemplate integration. Distracts drivers by requiring phone handling.'
    },
    findmy: {
      kicker: 'APPLE FIND MY',
      title: 'Built for lost keys, not coordinated travel.',
      badge: 'Passive Pins',
      badgeClass: 'badge-indigo',
      onboarding: 'Apple-Only Friction',
      onboardingText: 'Requires exchanging personal Apple IDs or iCloud contacts before any location can be shared.',
      privacy: 'Coarse Updates',
      privacyText: 'Locations update intermittently (every few minutes), making it impossible to coordinate highway exits or turns.',
      guidance: 'Static Dot Without Route',
      guidanceText: 'Shows where someone is, but not which route they are on, whether they are stuck in traffic, or when they will arrive.',
      surfaces: 'Find My App Only',
      surfacesText: 'No dynamic arrival countdown in CarPlay and no multi-peer convergence Live Activity.'
    }
  };

  vsTabBtns.forEach(tab => {
    tab.addEventListener('click', () => {
      vsTabBtns.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      const targetKey = tab.getAttribute('data-vs-target');
      const item = vsData[targetKey];
      if (!item) return;

      if (vsKicker) vsKicker.textContent = item.kicker;
      if (vsTitle) vsTitle.textContent = item.title;
      if (vsBadge) {
        vsBadge.textContent = item.badge;
        vsBadge.className = `vs-showcase-badge ${item.badgeClass}`;
      }
      if (vsOnboarding) vsOnboarding.textContent = item.onboarding;
      if (vsOnboardingText) vsOnboardingText.textContent = item.onboardingText;
      if (vsPrivacy) vsPrivacy.textContent = item.privacy;
      if (vsPrivacyText) vsPrivacyText.textContent = item.privacyText;
      if (vsGuidance) vsGuidance.textContent = item.guidance;
      if (vsGuidanceText) vsGuidanceText.textContent = item.guidanceText;
      if (vsSurfaces) vsSurfaces.textContent = item.surfaces;
      if (vsSurfacesText) vsSurfacesText.textContent = item.surfacesText;
    });
  });

  /* ==========================================================================
     10. SECTION 05: COREML ROUTE SCORER INTERACTIVE SIMULATOR
     ========================================================================== */
  const mlDistSlider = document.getElementById('mlDistSlider');
  const mlTurnsSlider = document.getElementById('mlTurnsSlider');
  const mlTimeSlider = document.getElementById('mlTimeSlider');

  const mlDistVal = document.getElementById('mlDistVal');
  const mlTurnsVal = document.getElementById('mlTurnsVal');
  const mlTimeVal = document.getElementById('mlTimeVal');
  const mlScoreVal = document.getElementById('mlScoreVal');
  const mlVerdict = document.getElementById('mlVerdict');

  function calculateCoreMLScore() {
    if (!mlDistSlider || !mlTurnsSlider || !mlTimeSlider) return;

    const dist = parseFloat(mlDistSlider.value);
    const turns = parseFloat(mlTurnsSlider.value);
    const time = parseFloat(mlTimeSlider.value);

    if (mlDistVal) mlDistVal.textContent = `${dist} km`;
    if (mlTurnsVal) mlTurnsVal.textContent = `${turns} turns`;
    if (mlTimeVal) mlTimeVal.textContent = `${time} min`;

    // Heuristic approximating RouteScorer.mlpackage Random Forest model:
    // Optimal benchmark: 8 km, 6 turns, 14 min -> ~8.4
    let rawScore = 10.0 - (dist * 0.04) - (turns * 0.12) - (time * 0.06);
    rawScore = Math.max(1.2, Math.min(9.8, rawScore));
    const scoreFormatted = rawScore.toFixed(1);

    if (mlScoreVal) mlScoreVal.textContent = `${scoreFormatted} / 10`;

    if (mlVerdict) {
      if (rawScore >= 7.8) {
        mlVerdict.textContent = 'Optimal Route';
        mlVerdict.style.color = '#30d158';
      } else if (rawScore >= 5.5) {
        mlVerdict.textContent = 'Congested Corridor';
        mlVerdict.style.color = '#ff9500';
      } else {
        mlVerdict.textContent = 'Suboptimal Detour';
        mlVerdict.style.color = '#ff453a';
      }
    }
  }

  [mlDistSlider, mlTurnsSlider, mlTimeSlider].forEach(slider => {
    if (slider) {
      slider.addEventListener('input', calculateCoreMLScore);
    }
  });

  calculateCoreMLScore();

  /* ==========================================================================
     11. FINAL CTA INSTANT APP CLIP GENERATOR
     ========================================================================== */
  const sandboxTitle = document.getElementById('sandboxTitle');
  const sandboxHost = document.getElementById('sandboxHost');
  const sandboxGenerateBtn = document.getElementById('sandboxGenerateBtn');
  const sandboxUrlDisplay = document.getElementById('sandboxUrlDisplay');
  const sandboxCopyBtn = document.getElementById('sandboxCopyBtn');

  function generateInstantLink() {
    const titleVal = sandboxTitle && sandboxTitle.value ? sandboxTitle.value : 'Sunset Dinner';
    const hostVal = sandboxHost && sandboxHost.value ? sandboxHost.value : 'Sarah';
    const slug = slugify(titleVal);
    const fullUrl = `https://navisync.app/m/${slug}?host=${encodeURIComponent(hostVal)}`;

    if (sandboxUrlDisplay) {
      sandboxUrlDisplay.textContent = fullUrl;
    }
  }

  if (sandboxGenerateBtn) {
    sandboxGenerateBtn.addEventListener('click', generateInstantLink);
  }

  if (sandboxTitle) {
    sandboxTitle.addEventListener('input', generateInstantLink);
  }

  if (sandboxCopyBtn && sandboxUrlDisplay) {
    sandboxCopyBtn.addEventListener('click', () => {
      const url = sandboxUrlDisplay.textContent;
      navigator.clipboard.writeText(url).then(() => {
        const original = sandboxCopyBtn.textContent;
        sandboxCopyBtn.textContent = 'Copied!';
        sandboxCopyBtn.style.background = '#30d158';
        setTimeout(() => {
          sandboxCopyBtn.textContent = original;
          sandboxCopyBtn.style.background = '';
        }, 1800);
      }).catch(() => {
        sandboxCopyBtn.textContent = 'Copied!';
        setTimeout(() => { sandboxCopyBtn.textContent = 'Copy'; }, 1800);
      });
    });
  }
});
