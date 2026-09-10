# AGENTS.md — Article Page Design System

This project is a collection of standalone, single-file HTML articles (a personal data-science / AI publication by **Ali Reza Rashidi**). Each file is a self-contained interactive essay: no frameworks, no build step, no external assets except Google Fonts.

When asked to create a new article on a topic, produce **one complete `.html` file** that matches the existing pages in structure, content depth, and visual design. This document is the spec. Follow it exactly — do not substitute your own aesthetic.

---

## 1. Deliverable shape

- A single `.html` file, English content, valid HTML5, works by double-clicking (no server).
- All CSS in one `<style>` block in `<head>`; all JS in one `<script>` before `</body>`.
- Hand-built inline SVG charts only — **no chart libraries, no images, no icon fonts, no emoji as icons**.
- Filename: `Title Case With Spaces.html` (matching existing files).

## 2. Head boilerplate (required)

- `<meta name="description">` — one sentence, honest, no marketing adjectives.
- `<title>` — `Editorial Title — Subtitle`.
- Favicon: inline SVG data-URI, four 6px circles in a 32×32 grid using four of the palette colors (pick 4; vary per article).
- Open Graph tags (`og:title`, `og:description`, `og:type=article`) + `twitter:card=summary`.
- JSON-LD `Article` schema: headline, description, `datePublished`, `dateModified`, author `Person` "Ali Reza Rashidi".
- Fonts (exact link):
  ```
  https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Instrument+Serif:ital@0;1&family=Roboto+Mono:wght@400;500&family=Space+Grotesk:wght@500;700&display=swap
  ```
- First script in head: `document.documentElement.classList.add('js');`. Use it only for animations that need no later JavaScript setup. Observer-driven animations require the readiness gate defined below.

## 3. Design tokens (copy verbatim)

```css
:root {
  --bg: #fcfbf8; --paper: #fffdfa; --ink: #171717; --muted: #656565; --soft: #989898;
  --line: rgba(23,23,23,0.12); --line-strong: rgba(23,23,23,0.22);
  --blue: #3468f5; --orange: #eb8237; --green: #23956f; --purple: #7650e6;
  --cyan: #14a9c5; --red: #db6478; --gold: #c9a227; --slate: #5b6b7a;
  --dark: #161614; --dark-paper: #f5f3ec; --dark-line: rgba(245,243,236,0.16);
  --shadow: 0 16px 40px rgba(0,0,0,0.05); --max: 1180px;
}
```

- Body: DM Sans, `line-height: 1.7`, background `linear-gradient(180deg, #fffdfa, #fcfbf8)`.
- Fixed full-viewport **grain layer**: SVG `feTurbulence` noise data-URI, `opacity: .08`, `mix-blend-mode: multiply`.
- `::selection { background: var(--ink); color: var(--paper); }`.
- Custom thin scrollbar (10px, thumb `rgba(23,23,23,.25)`, 8px radius).
- Content column: `.wrap { width: min(1180px, calc(100% - 40px)); margin: 0 auto; }`.

### Typography roles (never swap)

| Role | Font | Notes |
|---|---|---|
| Body text | DM Sans 400/500/700 | |
| H1/H2, labels in charts | Space Grotesk 500/700 | `letter-spacing: -.045em`, tight `line-height: .94–.98` |
| Emphasis inside H1 | Instrument Serif italic 400 | `<em>`, gray `#535353` |
| Numbers, stats, kickers, footnotes | Roboto Mono 400/500 | |

- H1: `clamp(3rem, 8.4vw, 6.8rem)`; H2: `clamp(2rem, 4.4vw, 4rem)`.
- Headings: `text-wrap: balance`; paragraphs: `text-wrap: pretty`.

## 4. Page skeleton (in this order)

1. **Skip link** → `#content`; **reading progress bar** (2px fixed top, ink fill); grain div.
2. **Sticky header**: brand = 12px ink dot + article short-title; nav links to section anchors. On scroll: `rgba(252,251,248,.82)` + `backdrop-filter: blur(10px)` + 1px bottom line. Nav hover: underline grows left→right; active section gets a 6px colored dot (scroll-spy, `--spy` color per section).
3. **Hero**:
   - `.eyebrow`: uppercase mono-ish series label with 24px leading rule (e.g. "AI Architecture Series").
   - H1 wrapped in `.line > .line-inner` spans (one per line) — lines animate up with `translateY(115%) → 0`, staggered 90ms, keyframes `lineUp`, only under `.js`.
   - `.hero-grid` (1.12fr / .88fr): left = `.lead` paragraph (with Instrument Serif drop cap via `::first-letter`), `.hero-links` (anchor jumps), `.byline` (avatar circle with initials "AR", author name, read time, updated date, separated by 3px dots). Right = `.hero-note` (a quiet italic aside) + `.toc` box (`#f3f1e9`, 12px radius, numbered "In this piece" list).
4. **Numbered sections** (`<section class="section reveal">`, 88px vertical padding, 1px bottom border). Each opens with `.section-head` (grid .9fr/1.1fr):
   - Left: `.kicker` = 8px ink square + mono number `01` + `—` + name; then H2 with hover-revealed `#` anchor link.
   - Right: one `.body-copy` paragraph framing the section.
5. **Ending**: finish after the Sources section; keep only the standalone `.to-top` button. Add a `<footer>` or colophon only when the user explicitly requests one. This includes author bios, taglines, series notes, updated-date notes, and related-article links.

### Section body patterns (mix as fits the topic)

- **`.flow`** — numbered step cards (`fnum` mono + strong + description), each with an accent color via `style="--ac:#…"`.
- **`.framework`** — the workhorse: grid `260px 1fr`; sticky aside holds color dot (`<span class="mark">` using the article's accent), H3, `.framework-role` ("Step 01 · …"), one-line summary; right column is prose + diagrams. One `.framework` per concept, each with its own accent color from the palette, used consistently everywhere that concept appears (charts, dots, callouts).
- **`.split`** — two-column compare ("Conservative vs Creative", "Before vs After").
- **`.mini-compare`** — 3–4 small items, top-bordered, with 10px color dots.
- **`.stat-strip`** — 3–4 big Roboto Mono numbers (`clamp(1.7rem,3vw,2.4rem)`) + muted labels.
- **`.callout-line`** — colored one-liner insight with a `<small>` second line.
- **`.formula`** — mono formula block. **`.code`** — mono code block.
- **Quiz** (optional but loved): light quiz block — mono kicker, question, answer rows with left border, progress track/fill, "why" explanation, retake button. Pure JS, no dependencies.
- **Sources section** (last): `.sources-list` — auto-numbered (`decimal-leading-zero`) entries with `<strong>` title + outlet/author; in-text citations as superscript mono links `<a class="xref" href="#src-1">[1]</a>`. External links: `.xlink` with dashed underline and `↗`.

## 5. Charts (hand-built SVG)

### Diagram Design plugin

- When creating, redrawing, or substantially revising a content-bearing diagram or chart, invoke the installed `diagram-design` skill before drawing. Use its semantic-pattern and visual-type routing, then load only the selected type reference.
- On first use in this repository, onboard Diagram Design from this `AGENTS.md` as the local design-system source and show the proposed token mapping before applying it.
- This article spec remains authoritative for delivery: place the final SVG inline in the target article, map its semantic roles to the shared tokens and fonts above, and keep the WordPress-safe static fallback. Create standalone diagram HTML, SVG, PNG, profiles, or project markers only when the user explicitly requests them.

- Types available in the shared CSS/JS vocabulary: horizontal bars (`.bar-rect`), vertical bars (`.vbar-rect`), line charts (`.line-path` + `.line-dot`), scatter (`.sdot`), donut (`.donut-seg`), radar (`.radar-shape`).
- Every chart sits in `.diagram-block`: `.diagram-title` (Space Grotesk), `.chart-scroll` wrapper (horizontal scroll on mobile, `svg { min-width: 560px }` under 430px), then `.diagram-caption` starting with **"How to read this:"**.
- SVG must have `role="img"` and a full-sentence `aria-label` describing the data.
- Bars use horizontal `linearGradient` fills built from palette colors; grid lines `rgba(23,23,23,.07–.18)`; axis labels Roboto Mono `#8a8a8a`; value labels Roboto Mono with `data-count` for count-up animation.
- Data must be **honest and specific** — real numbers, realistic magnitudes, no lorem ipsum.

### Animation (progressive enhancement, staggered via `style="--d:0.12s"`)

- Bars scale from 0 (`transform-box: fill-box`), lines draw via `stroke-dashoffset`, dots pop with `cubic-bezier(.34,1.56,.64,1)`, sections fade/slide in via `.reveal` + IntersectionObserver.
- Scroll-spy sets the active nav dot; progress bar tracks scroll; stat numbers count up on entry.
- `@media (prefers-reduced-motion: reduce)`: disable all of it.
- Content-bearing elements must be fully visible in their base CSS. Never put `opacity: 0`, a non-zero `stroke-dashoffset`, or a zero scale on SVG data in an ungated base selector.
- For animations that depend on body JavaScript, use a two-part selector such as `.js.diagram-motion-ready`. Add the feature-specific readiness class from that same body script only after its observer or required API has initialized. If WordPress strips or blocks inline JavaScript, the missing readiness class must leave the complete diagram and section content visible.
- Before delivery, test both modes: normal JavaScript must animate, and JavaScript-disabled (or script-stripped) rendering must still show every SVG node, line, label, section, and caption.

## 6. Content rules

- **Editorial voice**: second person, direct, confident; explains real mechanisms, not hype. Short sentences. An occasional em-dash aside. No "In today's fast-paced world", no "revolutionary/game-changing", no bullet-only sections.
- **Depth**: pick ONE concrete running example (e.g. the prompt "The weather today is very…") and carry it through the entire article — every diagram reuses it.
- **Structure**: 3–5 numbered sections; each concept = one `.framework` with its own accent color; every diagram earns its place and has a caption that teaches reading it.
- **Honesty**: real citations in Sources; xref superscripts on factual claims; state preconditions and limits, not just benefits.
- Length target: ~5–8 min read, 600–900 lines of HTML.

## 7. Accessibility & mobile (required)

- `lang="en"`, skip link, `aria-labelledby` on sections, `aria-label` on nav/SVG, `:focus-visible` outlines (2px ink).
- `-webkit-tap-highlight-color: transparent`; safe-area-inset padding on `.to-top` for iOS.
- Breakpoints: 720px (stack grids, smaller type) and 430px (H1 `clamp(2.15rem,12.5vw,3rem)`, tighter stat strip, chart min-width scroll).
- `@media (hover: none)`: anchors semi-visible, nav touch padding.
- `color-scheme: light`; `overflow-x: clip` guard.
- **Rendered contrast gate**: on every dark or tinted surface, set both foreground and background explicitly on the text-bearing component selector; do not rely on inheritance for headings or code. At minimum, dark sections must style their own H2 and code blocks must style their own `pre`. After reveal animations settle, inspect computed colors in the browser at desktop and 390px, including under generic host rules for `h2` and `pre`; require WCAG AA contrast (4.5:1 for normal text, 3:1 for large text).

## 8. Hard don'ts

- No CSS frameworks, no JS libraries, no external images, no webfonts beyond the four listed.
- No blue-purple gradients as decoration, no glassmorphism, no cards-nested-in-cards, no emoji/Font-Awesome icons, no meaningless hover zooms.
- No invented techniques outside the vocabulary above — the pages look like siblings, not cousins.
- No placeholder text or fake data; no marketing copy.
