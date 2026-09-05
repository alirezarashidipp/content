$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$articlePath = Join-Path $repoRoot "personal-website\The Model Is Not the Product.html"

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
Require-Pattern '<title>The Model Is Not the Product — Choosing the Right LLM</title>' "Unexpected document title."
Require-Pattern '<meta name="description" content="[^"]+">' "Meta description is missing."
Require-Pattern '<meta property="og:type" content="article">' "Open Graph article type is missing."
Require-Pattern '<meta name="twitter:card" content="summary">' "Twitter card is missing."
Require-Pattern '"@type": "Article"' "Article JSON-LD is missing."
Require-Pattern '"name": "Ali Reza Rashidi"' "Author metadata is missing."
Require-Pattern '<script>document\.documentElement\.classList\.add\(''js''\);</script>' "The head readiness script is missing."
Reject-Pattern '<script[^>]+src=' "External JavaScript is not allowed."
Reject-Pattern '<img\b' "External or embedded images are not allowed."
Reject-Pattern '<footer\b' "The article must end after Sources without a footer."
Reject-Pattern 'bootstrap|tailwind|font-awesome|react(?:\.min)?\.js' "Frameworks and icon libraries are not allowed."

foreach ($section in @('workload', 'families', 'deployment', 'selection', 'sources')) {
    Require-Pattern ('<section[^>]+id="' + [regex]::Escape($section) + '"') "Missing section: $section"
}

foreach ($concept in @(
    'Base models',
    'Instruction-tuned and chat models',
    'Dense and Mixture of Experts',
    'Specialist models',
    'Weights, formats, and quantization',
    'Evaluate the system'
)) {
    Require-Pattern ([regex]::Escape($concept)) "Missing concept: $concept"
}

Require-Pattern 'SUP-4821' "The recurring support-copilot scenario is missing."
Require-Pattern '(?s)<svg[^>]+aria-labelledby="selection-funnel-title selection-funnel-desc"[^>]*>\s*<title id="selection-funnel-title">[^<]+</title>\s*<desc id="selection-funnel-desc">' "Selection-funnel SVG must begin with an accessible title and description."
Require-Pattern '(?s)<svg[^>]+aria-labelledby="model-system-title model-system-desc"[^>]*>\s*<title id="model-system-title">[^<]+</title>\s*<desc id="model-system-desc">' "Multi-model SVG must begin with an accessible title and description."
Require-Pattern '@media \(prefers-reduced-motion: reduce\)' "Reduced-motion behavior is missing."
Require-Pattern '@media \(max-width: 720px\)' "Tablet layout is missing."
Require-Pattern '@media \(max-width: 430px\)' "Mobile layout is missing."
Require-Pattern 'diagram-motion-ready' "Diagram animation readiness gate is missing."
Require-Pattern '(?s)\.diagram-node, \.diagram-path\s*\{[^}]*opacity:\s*1' "Diagram content must be visible without JavaScript."
Require-Pattern 'diagram-path:not\(\.diagram-path-dashed\)' "Solid-path animation must preserve dashed escalation semantics."
Require-Pattern 'class="diagram-path diagram-path-dashed"' "Escalation path must carry the dashed-path exemption."
Require-Pattern '(?s)\.section-dark\s+\.section-head\s+h2\s*\{[^}]*color:\s*var\(--dark-paper\);[^}]*background:\s*var\(--dark\)' "Dark-section H2 must set foreground and background explicitly."
Require-Pattern '(?s)\.section-dark\s+\.xref\s*\{[^}]*color:\s*#9db8ff' "Dark-section source links need an explicit high-contrast color."
Require-Pattern '(?s)\.code\s+pre\s*\{[^}]*color:\s*#f2efe5;[^}]*background:\s*var\(--dark\)' "Code pre must set foreground and background explicitly."
Require-Pattern 'https://handbook\.modular\.com/getting-started/choosing-the-right-model/' "The requested Modular handbook page must be cited."
Require-Pattern 'https://huggingface\.co/docs/' "Official Hugging Face documentation must be cited."
Require-Pattern 'https://github\.com/ggml-org/ggml/blob/master/docs/gguf\.md' "The GGUF specification must be cited."

$articleText = [regex]::Replace($html, '(?is)<style\b[^>]*>.*?</style>|<script\b[^>]*>.*?</script>', ' ')
$articleText = [regex]::Replace($articleText, '(?s)<[^>]+>', ' ')
$wordCount = ([regex]::Matches([System.Net.WebUtility]::HtmlDecode($articleText), "\b[A-Za-z][A-Za-z’'-]*\b")).Count
if ($wordCount -lt 2100) { throw "Article is too short for a ten-minute read: $wordCount words." }
if ($lineCount -lt 600) { throw "Article is too short for the site format: $lineCount lines." }

Write-Output "PASS: model-selection article contract ($wordCount words, $lineCount lines)."
