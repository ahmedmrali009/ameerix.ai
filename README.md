# Ameerix Market Intelligence — Corporate Website (Flutter Web)

A multilingual (8 languages, full RTL for Arabic), responsive B2B corporate website for **Ameerix Market Intelligence**, built with Flutter Web.

All company copy comes from the Ameerix business plan. Nothing has been added that the plan does not support: no customers, partners, revenue, offices, certifications, integrations or awards. No personal information about any individual appears anywhere; Ameerix is presented only as a corporate brand.

---

## 1. Quick start

Requirements: **Flutter 3.35 or newer** (tested against the Flutter 3.47 stable API), with Chrome for local runs.

```bash
flutter pub get          # also generates lib/l10n/app_localizations*.dart
flutter run -d chrome    # local development
flutter test             # layout, localisation and form tests (see §9)
flutter analyze
```

Production build:

```bash
flutter build web --release \
  --dart-define=SITE_URL=https://www.your-domain.com \
  --dart-define=CONTACT_ENDPOINT=https://api.your-domain.com/v1/leads
# output: build/web/
```

Optional: add `--wasm` for the WebAssembly renderer on browsers that support it (it falls back to JS automatically).

> **Status of this code.** The project was written against the Flutter 3.47 framework source. It was **not** compiled in the authoring environment, which could not download the Flutter SDK. Run `flutter analyze` and `flutter test` once on your machine. The test suite renders every page at 1440, 1024, 768 and 390 px and in all 8 languages, so layout overflows show up straight away.

---

## 2. Site map

| Route | Page | Content (from the business plan) |
|---|---|---|
| `/` | Home | Hero → What Ameerix does → Problem → Solution → 7 modules → How it works → Industries → Market data → Benefits → Technology → Why Ameerix → International strategy → CTA |
| `/platform` | Platform | The 7 modules in detail: readiness dimensions, Market Score variable families, matching criteria, Trade Graph data sources, pipeline stages, intelligence signals, ways to engage |
| `/solutions` | Solutions | 6 customer segments, ideal customer and buyer roles, GCC importers/distributors (pilot use cases), partner types and partnership principles |
| `/industries` | Industries | 4 launch verticals with use cases and benefits, GCC buyer segments, market data |
| `/how-it-works` | How it works | 6-step methodology, pilot-first engagement, closed-loop learning, success metrics |
| `/technology` | Technology | Architecture, scoring method, responsible AI / EU AI Act, data sources, data principles, security, GDPR |
| `/about` | About | Overview, vision, mission, why we exist, Spain & Europe, international strategy, product culture, commercial ethics, roadmap |
| `/insights` | Insights | Category filters and **clearly labelled placeholders** (no invented articles) |
| `/contact` | Request a demo / Contact us | Validated form with two modes, plus what to expect and location |

**Note on wording.** The plan describes an early-stage company: an S.L. being set up in Barcelona, the MVP in development, pilots planned. The copy says exactly that ("being established", "in development and validated through pilots", "pilot programme"). Update those lines as the company progresses. The plan's pricing figures and financial projections are **not** shown, because the plan itself calls them hypotheses. The market figures that are shown (Spanish SMEs, exports, EU–GCC trade) are official statistics cited in the plan, with sources listed on the page.

---

## 3. Architecture

```
lib/
  main.dart                 Entry point: path URLs, semantics, locale bootstrap
  app.dart                  MaterialApp, localisation, theme, routing, services
  config/
    app_config.dart         SITE_URL / CONTACT_ENDPOINT (--dart-define)
    routes.dart             Route paths
  core/
    breakpoints.dart        mobile < 600 ≤ tablet < 1024 ≤ laptop < 1280 ≤ desktop
    navigation.dart         Navigator helpers, RouteObserver
    router.dart             Path → page mapping, fade/slide page transition
    validators.dart         Localised form validators
  theme/
    app_colors.dart         Monochrome palette + section "tones" (dark/light/muted)
    app_typography.dart     Responsive, script-aware type scale (Latin/Arabic/CJK)
    app_theme.dart          Material theme for inputs, menus, etc.
  localization/
    supported_languages.dart  Language registry (order, native names, RTL flag)
    locale_controller.dart    Active language + persistence
  l10n/
    app_en.arb (source) + ar, zh, es, it, fr, de, pt
  models/
    site_content.dart       Groups ARB strings into typed content lists
    contact_request.dart    Form payload + stable industry IDs
  services/
    app_services.dart       Dependency container (swap implementations in tests)
    contact/contact_service.dart   Pluggable form backend
    seo/                    <title>, meta, OG, canonical, <html lang/dir>
  widgets/                  Reusable UI: header, footer, buttons, cards, grid,
                            reveal animations, counters, language selector,
                            visuals/ (market score card, corridor map,
                            architecture diagram, dot grid)
  sections/                 Page sections (home/, shared/)
  pages/                    One file per route
```

Main design decisions:

- **Few dependencies.** The only packages are `intl`, `shared_preferences`, `http` and `web`. Routing, animations and the scroll-reveal logic use only the Flutter SDK.
- **Tones instead of hard-coded colours.** Every section declares `SectionTone.dark/light/muted`. Components read `Tone.of(context)`, so the same card or button works on black or white backgrounds.
- **Equal-height responsive grid** (`ResponsiveGrid`). It works out the column count from the available width, so it adapts to any screen and any language length.
- **Header measures itself.** It measures the translated nav labels and switches to the menu button only when they would not fit. German or Portuguese labels therefore never overflow.

---

## 4. Design system

- Black `#0A0A0A` and white, plus a grey scale (`#111`, `#262626`, `#525252`, `#737373`, `#A3A3A3`, `#E5E5E5`, `#F5F5F5`). No gradients.
- Text/background pairs meet WCAG AA or better: body text is `#A3A3A3` on black (8.3:1) and `#525252` on white (7.8:1).
- **Inter** is bundled for Latin scripts, subset and static-instanced (≈128 KB per weight). **IBM Plex Sans Arabic** is bundled for Arabic. Chinese uses Noto Sans SC, which Flutter Web downloads on demand only when Chinese glyphs are needed. Fonts are under the OFL; licences are in `assets/fonts/`.
- Motion (inner pages): fade-and-rise reveals on scroll, count-up statistics, animated score bars, a pulsing corridor diagram, hover lift on cards and fade page transitions. **All motion is switched off** when the operating system asks for reduced motion.
- The Ameerix mark (an open "A" with a node) is drawn in code and exported to `web/favicon.svg`, `favicon.png`, the PWA icons and `og-image.png`. Replace it if a final logo exists.

---

## 5. Localisation

- Uses Flutter's official `gen-l10n` with ARB files; configuration is in `l10n.yaml`. English (`app_en.arb`) is the template.
- Languages: English, 中文, العربية, Español, Italiano, Français, Deutsch, Português (555 keys each, all translated in the ARB files — no runtime machine translation).
- **Arabic switches the whole app to RTL** through `GlobalWidgetsLocalizations`. Layouts use directional insets and alignments, and arrows mirror. The corridor map deliberately keeps its geographic left-to-right layout. Arabic text never uses letter-spacing, which would break the joined script.
- Language selector: a dropdown in the header (desktop and tablet), a full list in the mobile menu, and an `EN | 中文 | العربية | ES | IT | FR | DE | PT` row in the footer.
- The choice is **saved** in localStorage via `shared_preferences`. The order of precedence is `?lang=xx` in the URL, then the saved choice, then the browser language, then English.
- Numbers in statistics are stored in the ARB files together with their units (for example `2.96` "M" in English and `296` "万家" in Chinese), so each language shows magnitudes naturally.

**Adding a language:** copy `app_en.arb` to `app_xx.arb` and translate it, add an entry in `supported_languages.dart`, run `python3 tool/check_arb.py` to check that every key and placeholder is present, then run `python3 tool/generate_sitemap.py`.

Translations were written carefully, but they should get a native-speaker review before launch, especially the Arabic and Chinese legal and regulatory wording.

---

## 6. SEO: what is done, and Flutter Web's limits

Flutter Web draws the page on a canvas instead of producing ordinary HTML documents. What that means in practice:

| Limitation | What this project does about it |
|---|---|
| Crawlers that don't run JavaScript see an almost empty page | `web/index.html` holds a **static, crawlable summary** (h1, key copy, links to every route) in `#seo-content`, visually hidden once the app loads, plus Organization JSON-LD |
| One HTML file for all routes | Path URLs (`/platform`, not `/#/platform`). At runtime `SeoService` sets a per-page `<title>`, meta description, OG/Twitter tags, `<link rel=canonical>`, robots and `<html lang dir>` |
| No real DOM text | `SemanticsBinding.ensureSemantics()` is always on. Headings are exposed as `h1`–`h4` (`Semantics.headingLevel`) and navigation, cards and buttons as real `<a href>` links (`Semantics.linkUrl`) |
| Languages share URLs | hreflang alternates use `?lang=xx` (in `index.html` and `sitemap.xml`); the app reads the parameter on load |
| Social preview bots don't run JS | Default OG/Twitter tags and `og-image.png` are in the static HTML |

Files: `web/robots.txt`, `web/sitemap.xml` (generated by `tool/generate_sitemap.py`, with 9 routes × 8 hreflang alternates), `web/manifest.json`, the favicons and `og-image.png`.

**If search ranking is a priority**, the most effective step is to **pre-render** static HTML for each route and language (for example a headless-Chrome pre-render step in CI, or serving the marketing pages from a static generator with Flutter used for interactive parts). No Flutter-only setup matches server-rendered HTML for SEO.

Before launch, replace `https://www.ameerix.com` in `index.html`, `robots.txt` and the sitemap (`python3 tool/generate_sitemap.py https://your-domain`), and pass `--dart-define=SITE_URL=…` when building.

---

## 7. Connecting the contact / demo form

The form validates on the client: required fields, email and phone format, minimum message length, consent. It then calls `ContactService`:

- If `CONTACT_ENDPOINT` is **not set**, `UnconfiguredContactService` is used. It **does not pretend to send anything**: the visitor sees "Online submissions are not enabled yet".
- If `CONTACT_ENDPOINT` **is set**, `HttpContactService` sends a `POST` with JSON. Any 2xx response counts as success.

Payload:

```json
{
  "type": "demo | contact",
  "firstName": "…", "lastName": "…", "company": "…", "jobTitle": "…",
  "email": "…", "phone": "… or null", "country": "…",
  "industry": "gourmet_food | cosmetics_personal_care | furniture_interiors | hospitality_construction_supplies | gcc_import_distribution | association_chamber_consultancy | other",
  "message": "…", "language": "en", "consent": true,
  "source": "website", "submittedAt": "ISO-8601 UTC"
}
```

The endpoint must allow CORS from the site's origin and should add its own validation, rate limiting and spam protection (for example Turnstile or reCAPTCHA). To use a CRM or a form service instead, implement `ContactService` and return it from `ContactService.fromConfig()`.

Make sure a privacy policy exists that matches how leads are processed (GDPR); the plan commits to data minimisation.

---

## 8. Deployment

The site is a static build (`build/web`). Every unknown path must be **rewritten to `/index.html`** so deep links like `/platform` work.

- **Firebase Hosting:** `firebase.json` is included (rewrites and cache headers).
- **Netlify:** `web/_redirects` is included and copied into the build.
- **Nginx:** `try_files $uri $uri/ /index.html;`
- **Vercel:** add a rewrite from `/(.*)` to `/index.html`.

Caching: fonts and images can be cached; `index.html`, `flutter_bootstrap.js`, `main.dart.js` and the service worker should be revalidated (`no-cache`).

---

## 9. Quality checks

`flutter test` runs:

- every route at **1440 / 1024 / 768 / 390 px**, scrolled top to bottom (any overflow or layout exception fails the test)
- the home page in **all 8 languages** at 390 and 1440 px
- **RTL** for Arabic and LTR for English
- **ARB completeness**: same keys and placeholders in every language
- contact-form validation (an empty submit does not call the backend)
- unit tests for the validators

Helper scripts (Python 3):

- `tool/check_arb.py`: checks ARB keys and placeholders
- `tool/generate_sitemap.py`: regenerates `sitemap.xml`
- `tool/syntax_check.py` and `tool/import_check.py`: quick static checks used while writing the code (optional; need `pip install tree-sitter tree-sitter-language-pack`)

---

## 10. Items to confirm before launch

1. The production **domain** (`SITE_URL`, `index.html`, `robots.txt`, sitemap).
2. The **contact endpoint** and privacy policy.
3. Company **status wording** (for example "being established as an S.L.") and pilot-programme wording, kept in line with reality.
4. A **native-speaker review** of the translations.
5. Final **logo** and brand assets, if they differ from the placeholder mark.
6. **Insights**: replace the placeholders with real content, or hide the page until the first publication.

---

## Cinematic homepage (scroll-driven motion)

The homepage alternates full-viewport, scroll-controlled scenes with calmer information sections. The scroll position drives every scene; nothing plays on a timer except slow ambient drift.

| Order | Section | Component |
|---|---|---|
| 1 | Minimal hero, Spain → intelligence layer → GCC | `HeroScene` |
| 2 | What Ameerix does | `WhatWeDoSection` |
| 3 | Pinned 8-stage Spain → GCC story | `SpainGccStory` |
| 4 | Problem | `ProblemSection` |
| 5 | "Know where to expand…" statement | `RevealText` |
| 6 | Explainable Market Score (illustrative) | `MarketScoreVisualization` |
| 7 | Platform modules | `ModulesSection` |
| 8 | "The right market is only half the decision…" | `RevealText` (handOff) |
| 9 | Distributor matching funnel (demo cards A/B/C) | `DistributorNetwork` |
| 10 | Industries | `IndustriesSection` |
| 11 | Trade Graph signature visual | `TradeGraphVisualization` |
| 12 | How it works | `HowItWorksSection` |
| 13 | Pinned product-concept demo (7 modules) | `PlatformDemo` |
| 14–16 | Market data, technology, Spain + GCC strategy | existing sections |
| 17 | Trust & methodology | `TrustSection` |
| 18 | "From intelligence to opportunity." | `RevealText` (finale) |
| 19 | Final CTA | `CtaSection` |

Building blocks live in `lib/motion/motion.dart`:

- `PinnedStorySection` makes a section N viewports tall and pins its stage while the page scrolls through it. It exposes `progress` (0–1) and `visible` as `ValueListenable`s, so only painters and small `AnimatedBuilder`s rebuild each frame, never the page.
- `ScrollProgressSection` gives parallax progress for non-pinned sections.
- `ResponsiveMotionController` provides `reduced` (OS reduced-motion), `compact` (< 960 px: fewer nodes, no tilt, stacked layouts) and `rtl` (process flows mirror in Arabic; the geographic Spain → GCC map does not).
- `AmbientClock` is a ticker that runs only while its scene is on screen and motion is allowed.
- `SeededRandom` keeps the visuals identical on every visit.

Other pieces: `RevealText` (`sections/cinematic/statement_scene.dart`), `Magnetic` buttons (`widgets/magnetic.dart`), and `AnimatedCounter` (`widgets/reveal.dart`), which serves as the AnimatedMetric. The header is transparent over the hero and turns solid once the page scrolls.

Performance: the scenes animate only transforms, opacity and `CustomPainter` output inside `RepaintBoundary`. Tickers pause off-screen, and text painters are cached. When reduced motion is on, the scenes stay scroll-driven but have no ambient drift, and the pinned stages still show every step.

Honesty: every score, count and partner card in the scenes carries an **Illustrative** or **Demo** label. UAE 82 and KSA 74 follow the business plan's own worked example; the other values are demo values. "Distributor A/B/C" are fictional.

---

## Art direction: cinematic enterprise AI

Colour has meaning and is used the same way everywhere (`lib/theme/app_colors.dart`):

| Colour | Token | Meaning |
|---|---|---|
| Deep space `#030712`, midnight `#071426`, navy | `deepSpace`, `midnight`, `navy` | environments |
| Intelligence blue `#3B82F6` / electric `#4F8CFF` | `blue`, `electric` | data, market intelligence, analysis |
| AI violet `#8B5CF6` | `violet` | AI processing, the Ameerix engine |
| Cyan `#22D3EE` | `cyan` | connections, live data, relationships |
| Opportunity gold `#F4C76B` | `gold` | commercial opportunity, priority (used sparingly) |
| Magenta `#D946EF` | `magenta` | rare AI energy (trade-graph signals only) |
| Green / red | `green`, `error` | validated states / errors only |

`SectionTone` now has six related environments: `dark` (deep space, AI scenes), `midnight` (product), `haze` (near-black with violet haze, Trade Graph), `light` and `muted` (corporate credibility bands), and `opportunity` (deep blue with a trace of gold, final CTA). Each palette carries soft radial "volumetric" light (`AmbientLighting`).

Signature pieces:

- **`paintIntelligenceCore`** (`widgets/visuals/intelligence_core.dart`) is the recurring Ameerix object: a translucent data cube inside a lattice, two orbital rings and the Ameerix mark. It appears in the hero, the Spain → GCC story and the product demo; it is also available as a stand-alone `IntelligenceCore` widget.
- **Procedural dotted earth** (`motion/light.dart` + `motion/geo_data.dart`) is an orthographic globe drawn from a ~3,400-point land mask, with no images or video. It is used in the hero and at the centre of the Trade Graph. The GCC regional mask drives the dashboard map. Regenerate it with `tool/generate_geo.py`.
- **Glow and arcs**: `Glow.draw` provides additive soft light, `drawArc`/`arcAt` draw lifted great-circle data paths, and `LabelCache` holds localised painter labels. No public-facing text is hard-coded in the painters.

Transitions carry one idea into the next. Blue data enters the core and leaves as cyan paths to the markets. In the dashboard, score columns collapse onto the GCC map, partner nodes spread into a Trade Graph and then fly into the CRM as gold opportunities. Light sections open with a band of settling dots.

Performance: everything is `CustomPainter`, gradients and transforms (no video, no heavy images). Tickers stop off-screen. Mobile uses fewer nodes, a sparser globe and no depth-of-field or tilt. Reduced motion freezes all ambient drift.
