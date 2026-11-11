param(
    [Parameter(Mandatory = $true)]
    [DateTimeOffset] $MergedAt
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location -LiteralPath $root

# Use the merge date, so rerunning the workflow keeps the same release number.
$zone = [TimeZoneInfo]::FindSystemTimeZoneById('Vladivostok Standard Time')
$version = [TimeZoneInfo]::ConvertTime($MergedAt, $zone).ToString(
    'yy.MM.dd', [Globalization.CultureInfo]::InvariantCulture
)
$payload = Join-Path $root 'build/payload'
if (Test-Path -LiteralPath $payload) {
    throw 'build/payload already exists; use a clean checkout to prepare a release.'
}
New-Item -ItemType Directory -Path $payload -Force | Out-Null

# Only ship tracked runtime files, without repository metadata or local caches.
$files = git -c "safe.directory=$($root.Replace('\', '/'))" ls-files -- __init__.py plugin.json plugin assets
if ($LASTEXITCODE -ne 0) { throw 'Could not enumerate plugin files' }
foreach ($file in $files) {
    if ($file -match '(^|/)(__pycache__|\.git)(/|$)|\.py[co]$') { continue }
    $destination = Join-Path $payload $file
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $root $file) -Destination $destination
}
foreach ($required in @('__init__.py', 'plugin.json', 'plugin/__init__.py', 'assets')) {
    if (!(Test-Path -LiteralPath (Join-Path $payload $required))) {
        throw "Required payload entry is missing: $required"
    }
}
$configPath = Join-Path $payload 'plugin.json'
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$config.version = $version
[IO.File]::WriteAllText(
    $configPath, ($config | ConvertTo-Json -Depth 100), [Text.UTF8Encoding]::new($false)
)

if ($env:GITHUB_OUTPUT) { "version=$version" >> $env:GITHUB_OUTPUT }
Write-Host "Prepared installer payload for release $version"
