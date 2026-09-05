$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$articlePath = Join-Path $repoRoot "personal-website\Prompting Without Magic.html"

if (-not (Test-Path -LiteralPath $articlePath)) {
    throw "Article is missing: $articlePath"
}

$html = Get-Content -Raw -LiteralPath $articlePath
$lineCount = (Get-Content -LiteralPath $articlePath).Count

function Require-Pattern([string]$Pattern, [string]$Message) {
    if ($html -notmatch $Pattern) { throw $Message }
}

function Reject-Pattern([string]$Pattern, [string]$Message) {
    if ($html -match $Pattern) { throw $Message }
}

Require-Pattern '<!DOCTYPE html>' "Missing HTML5 doctype."
Require-Pattern '<html lang="en">' "Article language must be English."
Require-Pattern '<title>Prompting Without Magic — Six Principles That Survive Model Changes</title>' "Unexpected document title."
Require-Pattern '<meta name="description" content="[^"]+">' "Meta description is missing."
Require-Pattern '<meta property="og:title"' "Open Graph title is missing."
Require-Pattern '<meta property="og:description"' "Open Graph description is missing."
Require-Pattern '<meta property="og:type" content="article">' "Open Graph article type is missing."
Require-Pattern '<meta name="twitter:card" content="summary">' "Twitter card is missing."
Require-Pattern '"@type": "Article"' "Article JSON-LD is missing."
Require-Pattern '"name": "Ali Reza Rashidi"' "Author JSON-LD is missing."
Require-Pattern '<style>' "CSS must be embedded."
Require-Pattern '<script>document\.documentElement\.classList\.add\(''js''\);</script>' "The head readiness script is missing."
Require-Pattern '<script>' "Progressive enhancement must be embedded."
Reject-Pattern '<script[^>]+src=' "External JavaScript is not allowed."
Reject-Pattern '<img\b' "Images are not allowed."
Reject-Pattern '<footer\b' "The article must end after Sources without a footer."
Reject-Pattern 'bootstrap|tailwind|font-awesome|react(?:\.min)?\.js' "Frameworks and icon libraries are not allowed."

foreach ($section in @('specification', 'context', 'patterns', 'evaluation', 'sources')) {
    Require-Pattern ('<section[^>]+id="' + [regex]::Escape($section) + '"') "Missing section: $section"
}

foreach ($principle in @(
    'Define success',
    'Supply context',
    'Specify the output contract',
    'Demonstrate the pattern',
    'Separate instructions from data',
    'Evaluate and revise'
)) {
    Require-Pattern ([regex]::Escape($principle)) "Missing principle: $principle"
}

Require-Pattern 'INV-2047' "The recurring invoice scenario is missing."
Require-Pattern '<svg[^>]+role="img"[^>]+aria-labelledby="prompt-anatomy-title prompt-anatomy-desc"' "The prompt-anatomy diagram must be an accessible inline SVG."
Require-Pattern '<title id="prompt-anatomy-title">' "Prompt-anatomy SVG title is missing or misplaced."
Require-Pattern '<desc id="prompt-anatomy-desc">' "Prompt-anatomy SVG description is missing."
Require-Pattern '(?s)<svg[^>]+aria-labelledby="prompt-anatomy-title prompt-anatomy-desc"[^>]*>\s*<title id="prompt-anatomy-title">[^<]+</title>\s*<desc id="prompt-anatomy-desc">' "Prompt-anatomy title and description must be the first SVG children."
Require-Pattern '<svg[^>]+role="img"[^>]+aria-labelledby="evaluation-loop-title evaluation-loop-desc"' "The evaluation-loop diagram must be an accessible inline SVG."
Require-Pattern '<title id="evaluation-loop-title">' "Evaluation-loop SVG title is missing or misplaced."
Require-Pattern '<desc id="evaluation-loop-desc">' "Evaluation-loop SVG description is missing."
Require-Pattern '(?s)<svg[^>]+aria-labelledby="evaluation-loop-title evaluation-loop-desc"[^>]*>\s*<title id="evaluation-loop-title">[^<]+</title>\s*<desc id="evaluation-loop-desc">' "Evaluation-loop title and description must be the first SVG children."
foreach ($slotLabel in @('QUESTION', 'INPUT', 'CONTROL', 'OUTPUT')) {
    if (([regex]::Matches($html, '>' + $slotLabel + '<')).Count -ne 5) { throw "Prompt-anatomy must use the stable $slotLabel slot in all five stages." }
}
Require-Pattern '\.motion-node, \.motion-path \{ opacity: 1; transform: none; stroke-dashoffset: 0; \}' "SVG motion content must be visible without JavaScript."
Require-Pattern '\.js\.diagram-motion-ready \.observe-diagram:not\(\.is-visible\) \.motion-node \{ opacity: 0;' "Diagram hiding must be gated by JavaScript readiness."
Require-Pattern '@media \(prefers-reduced-motion: reduce\)' "Reduced-motion behavior is missing."
Require-Pattern '@media \(max-width: 720px\)' "Tablet layout is missing."
Require-Pattern '@media \(max-width: 430px\)' "Mobile layout is missing."
Require-Pattern 'diagram-motion-ready' "Diagram animation readiness gate is missing."
Require-Pattern '(?s)\.section-dark\s+\.section-head\s+h2\s*\{[^}]*color:\s*var\(--dark-paper\);[^}]*background:\s*var\(--dark\)' "Dark-section H2 must set foreground and background explicitly."
Require-Pattern '(?s)\.code\s+pre\s*\{[^}]*color:\s*#f2efe5;[^}]*background:\s*var\(--dark\)' "Code pre must set foreground and background explicitly."
Require-Pattern 'https://developers\.openai\.com/' "Current official OpenAI guidance must be cited."
Require-Pattern 'https://platform\.claude\.com/' "Current official Anthropic guidance must be cited."
Require-Pattern 'https://(?:ai\.)?google\.dev/' "Official Google guidance must be cited."
Require-Pattern 'https://developers\.openai\.com/api/docs/guides/evaluation-best-practices' "OpenAI evaluation guidance must be cited."
Require-Pattern 'https://openai\.com/index/prompt-injections/' "OpenAI prompt-injection guidance must be cited."
Require-Pattern 'class="to-top"' "The standalone back-to-top button is missing."

Reject-Pattern '67% productivity' "The unsupported productivity statistic remains."
Reject-Pattern '13\.79%' "The copied benchmark claim remains."
Reject-Pattern 'Include 3-5 examples for best results' "The unsupported universal example-count claim remains."
Reject-Pattern 'Threatening the AI' "The copied section framing remains."

if ($lineCount -lt 600 -or $lineCount -gt 900) {
    throw "Article must stay between 600 and 900 readable source lines; found $lineCount."
}

$numberedKickers = [regex]::Matches($html, 'class="kicker-num">0[1-5]</span>').Count
if ($numberedKickers -ne 5) {
    throw "Expected five numbered sections; found $numberedKickers."
}

$svgCount = [regex]::Matches($html, '<svg\b').Count
if ($svgCount -ne 2) {
    throw "Expected exactly two teaching SVGs; found $svgCount."
}

Write-Output "PASS: Prompting Without Magic article contract ($lineCount lines)."
