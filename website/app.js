/* NaviSync: scroll-driven motion and the link composer. */
(function () {
  "use strict";

  var reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  // Nav hairline
  var nav = document.getElementById("nav");
  // Split statement into words for scroll lighting
  var statement = document.getElementById("statement");
  var words = [];
  if (statement) {
    statement.innerHTML = statement.textContent.trim().split(/\s+/)
      .map(function (w) { return '<span class="w">' + w + "</span>"; }).join(" ");
    words = statement.querySelectorAll(".w");
  }
  var heroMedia = document.getElementById("heroMedia");

  function onScroll() {
    var y = window.scrollY, vh = window.innerHeight;
    if (nav) nav.classList.toggle("scrolled", y > 24);
    if (reduce) return;

    // Hero image scales up as you scroll past the headline
    if (heroMedia) {
      var p = Math.min(1, Math.max(0, y / (vh * 0.8)));
      heroMedia.style.transform = "scale(" + (0.88 + p * 0.12) + ")";
    }

    // Light words progressively as the statement crosses the viewport
    if (statement) {
      var r = statement.getBoundingClientRect();
      var prog = (vh * 0.85 - r.top) / (r.height + vh * 0.35);
      var lit = Math.round(Math.min(1, Math.max(0, prog)) * words.length);
      for (var i = 0; i < words.length; i++) words[i].classList.toggle("lit", i < lit);
    }
  }
  var ticking = false;
  window.addEventListener("scroll", function () {
    if (!ticking) { ticking = true; requestAnimationFrame(function () { onScroll(); ticking = false; }); }
  }, { passive: true });
  onScroll();

  // Reveal-on-enter + count-up stats
  function countUp(el) {
    var target = +el.getAttribute("data-count"),
        prefix = el.getAttribute("data-prefix") || "",
        suffix = el.getAttribute("data-suffix") || "";
    if (reduce || target === 0) { el.textContent = prefix + target + suffix; return; }
    var start = performance.now(), dur = 1200;
    (function tick(t) {
      var k = Math.min(1, (t - start) / dur), e = 1 - Math.pow(1 - k, 3);
      el.textContent = prefix + Math.round(target * e) + suffix;
      if (k < 1) requestAnimationFrame(tick);
    })(start);
  }

  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (en) {
      if (!en.isIntersecting) return;
      en.target.classList.add("visible");
      var n = en.target.querySelector("[data-count]");
      if (n) countUp(n);
      io.unobserve(en.target);
    });
  }, { threshold: 0.05 });
  document.querySelectorAll(".reveal").forEach(function (el) {
    if (el.getBoundingClientRect().top < window.innerHeight) {
      el.classList.add("visible");
      var n = el.querySelector("[data-count]");
      if (n) countUp(n);
    } else {
      io.observe(el);
    }
  });

  // Sticky showcase steps
  var showcaseImgs = document.querySelectorAll("[data-showcase-img]");
  var stepIo = new IntersectionObserver(function (entries) {
    entries.forEach(function (en) {
      en.target.classList.toggle("active", en.isIntersecting);
      if (en.isIntersecting && showcaseImgs.length) {
        var idx = en.target.getAttribute("data-step");
        showcaseImgs.forEach(function (img) {
          img.classList.toggle("active", img.getAttribute("data-showcase-img") === idx);
        });
      }
    });
  }, { rootMargin: "-40% 0px -40% 0px" });
  document.querySelectorAll("[data-step]").forEach(function (el) { stepIo.observe(el); });

  // Link composer
  var form = document.getElementById("composer"),
      input = document.getElementById("placeInput"),
      linkText = document.getElementById("linkText"),
      copyBtn = document.getElementById("copyBtn");
  function slug(v) { return v.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "") || "meetup"; }
  function update() { linkText.textContent = "navisync.app/m/" + slug(input.value); }
  input.addEventListener("input", update);
  form.addEventListener("submit", function (e) { e.preventDefault(); update(); });
  copyBtn.addEventListener("click", function () {
    var done = function () { copyBtn.textContent = "Copied"; setTimeout(function () { copyBtn.textContent = "Copy"; }, 1500); };
    if (navigator.clipboard && window.isSecureContext) navigator.clipboard.writeText("https://" + linkText.textContent).then(done, done);
    else done();
  });

  // Active section scrollspy
  var navLinks = document.querySelectorAll(".nav-link");
  var sections = document.querySelectorAll("section[id]");
  if ("IntersectionObserver" in window && sections.length > 0) {
    var spyIo = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          var id = entry.target.getAttribute("id");
          navLinks.forEach(function (link) {
            var href = link.getAttribute("href");
            link.classList.toggle("active", href === "#" + id);
          });
        }
      });
    }, { rootMargin: "-25% 0px -65% 0px" });
    sections.forEach(function (sec) { spyIo.observe(sec); });
  }

  // Apple Horizontal Gallery Carousel Controls
  var galleryTrack = document.getElementById("galleryTrack");
  var galleryPrev = document.getElementById("galleryPrev");
  var galleryNext = document.getElementById("galleryNext");

  function updateGalleryButtons() {
    if (!galleryTrack || !galleryPrev || !galleryNext) return;
    var sl = galleryTrack.scrollLeft;
    var maxScroll = galleryTrack.scrollWidth - galleryTrack.clientWidth - 4;
    galleryPrev.disabled = sl <= 4;
    galleryNext.disabled = sl >= maxScroll;
  }

  function getGalleryStep() {
    if (!galleryTrack) return 520;
    var firstItem = galleryTrack.querySelector(".gallery-item");
    return firstItem ? firstItem.offsetWidth + 24 : 520;
  }

  if (galleryTrack && galleryPrev && galleryNext) {
    galleryPrev.addEventListener("click", function () {
      galleryTrack.scrollBy({ left: -getGalleryStep(), behavior: "smooth" });
    });
    galleryNext.addEventListener("click", function () {
      galleryTrack.scrollBy({ left: getGalleryStep(), behavior: "smooth" });
    });
    galleryTrack.addEventListener("scroll", updateGalleryButtons, { passive: true });
    window.addEventListener("resize", updateGalleryButtons);
    updateGalleryButtons();
  }
})();
