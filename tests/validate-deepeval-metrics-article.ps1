$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$articlePath = Join-Path $repoRoot "Five DeepEval Metrics That Turn RAG Scores into Engineering Decisions.html"

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
Require-Pattern '<title>Five DeepEval Metrics That Turn RAG Scores into Engineering Decisions</title>' "Unexpected document title."
Require-Pattern '<style>' "CSS must be embedded."
Require-Pattern '<script>' "Progressive enhancement must be embedded."
Reject-Pattern '<script[^>]+src=' "External JavaScript is not allowed."
Reject-Pattern '<img\b' "External or embedded images are not allowed."
Reject-Pattern '<footer\b' "The article must end after Sources without a footer."
Reject-Pattern 'bootstrap|tailwind|font-awesome|react(?:\.min)?\.js' "Frameworks and icon libraries are not allowed."

foreach ($section in @('diagnose', 'five-metrics', 'case-study', 'thresholds', 'sources')) {
    Require-Pattern ('<section[^>]+id="' + [regex]::Escape($section) + '"') "Missing section: $section"
}

foreach ($metric in @('Faithfulness', 'Answer Relevancy', 'Contextual Precision', 'Contextual Recall', 'G-Eval')) {
    Require-Pattern ([regex]::Escape($metric)) "Missing metric: $metric"
}

Require-Pattern 'Ticket 7319' "The recurring support scenario is missing."
Require-Pattern '<table[^>]+class="fault-table"' "The fault-isolation matrix is missing."
Require-Pattern '<svg[^>]+role="img"[^>]+aria-labelledby="metric-route-title metric-route-desc"' "The decision flow must be an accessible inline SVG."
Require-Pattern '<title id="metric-route-title">' "SVG title is missing or misplaced."
Require-Pattern '<desc id="metric-route-desc">' "SVG description is missing."
Require-Pattern '@media \(prefers-reduced-motion: reduce\)' "Reduced-motion behavior is missing."
Require-Pattern '@media \(max-width: 720px\)' "Small-screen layout is missing."
Require-Pattern '(?s)\.section-dark\s+\.section-head\s+h2\s*\{[^}]*color:\s*var\(--dark-paper\)' "Dark-section headings must set their light foreground explicitly."
Require-Pattern '(?s)\.code\s+pre\s*\{[^}]*color:\s*#e8e6dd;[^}]*background:\s*var\(--dark\)' "Code blocks must set foreground and background explicitly on pre."
Require-Pattern 'https://deepeval\.com/docs/' "Official DeepEval documentation must be cited."
Require-Pattern 'https://github\.com/confident-ai/deepeval' "Official DeepEval source repository must be cited."

Reject-Pattern 'The DeepEval Metrics That Matter: A Ranked Guide for QA Practitioners' "The copied headline remains."
Reject-Pattern 'Tier 1.{0,10}the RAG quartet' "The copied tier framing remains."
Reject-Pattern 'the slot that earns its keep' "Copied phrasing remains."

if ($lineCount -lt 520 -or $lineCount -gt 1150) {
    throw "Article must stay between 520 and 1150 readable source lines; found $lineCount."
}

$numberedKickers = [regex]::Matches($html, 'class="kicker-num">0[1-5]</span>').Count
if ($numberedKickers -ne 5) {
    throw "Expected five numbered sections; found $numberedKickers."
}

$svgCount = [regex]::Matches($html, '<svg\b').Count
if ($svgCount -ne 1) {
    throw "Expected exactly one teaching SVG; found $svgCount SVG elements."
}

Write-Output "PASS: DeepEval article contract ($lineCount lines)."
