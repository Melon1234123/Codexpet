[CmdletBinding()]
param(
  [string]$Repo = "Melon1234123/Codexpet",
  [string]$Branch = "main",
  [switch]$SkipSelect
)

$ErrorActionPreference = "Stop"

function Get-CodexHome {
  if ($env:CODEX_HOME) {
    return $env:CODEX_HOME
  }

  return Join-Path $HOME ".codex"
}

function Copy-PetFiles {
  param(
    [string]$PetDir,
    [string]$Repo,
    [string]$Branch
  )

  $scriptDir = $null
  if ($PSCommandPath) {
    $scriptDir = Split-Path -Parent $PSCommandPath
  }

  $localPetDir = $null
  if ($scriptDir) {
    $candidate = Join-Path $scriptDir "terminal-gremlin"
    if ((Test-Path (Join-Path $candidate "pet.json")) -and (Test-Path (Join-Path $candidate "spritesheet.webp"))) {
      $localPetDir = $candidate
    }
  }

  if ($localPetDir) {
    Copy-Item -LiteralPath (Join-Path $localPetDir "pet.json") -Destination (Join-Path $PetDir "pet.json") -Force
    Copy-Item -LiteralPath (Join-Path $localPetDir "spritesheet.webp") -Destination (Join-Path $PetDir "spritesheet.webp") -Force
    return
  }

  $baseUrl = "https://raw.githubusercontent.com/$Repo/$Branch/terminal-gremlin"
  Invoke-WebRequest -Uri "$baseUrl/pet.json" -OutFile (Join-Path $PetDir "pet.json") -UseBasicParsing
  Invoke-WebRequest -Uri "$baseUrl/spritesheet.webp" -OutFile (Join-Path $PetDir "spritesheet.webp") -UseBasicParsing
}

function Set-SelectedPet {
  param([string]$ConfigPath)

  $selectedLine = 'selected-avatar-id = "custom:terminal-gremlin"'
  $configDir = Split-Path -Parent $ConfigPath
  New-Item -ItemType Directory -Force -Path $configDir | Out-Null

  if (-not (Test-Path $ConfigPath)) {
    Set-Content -LiteralPath $ConfigPath -Value "[desktop]`n$selectedLine`n" -Encoding UTF8
    return
  }

  $lines = [System.Collections.Generic.List[string]]::new()
  foreach ($line in Get-Content -LiteralPath $ConfigPath) {
    $lines.Add($line)
  }

  $desktopIndex = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*\[desktop\]\s*$') {
      $desktopIndex = $i
      break
    }
  }

  if ($desktopIndex -lt 0) {
    if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -ne "") {
      $lines.Add("")
    }
    $lines.Add("[desktop]")
    $lines.Add($selectedLine)
    Set-Content -LiteralPath $ConfigPath -Value $lines -Encoding UTF8
    return
  }

  $nextSectionIndex = $lines.Count
  for ($i = $desktopIndex + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*\[') {
      $nextSectionIndex = $i
      break
    }
  }

  for ($i = $desktopIndex + 1; $i -lt $nextSectionIndex; $i++) {
    if ($lines[$i] -match '^\s*selected-avatar-id\s*=') {
      $lines[$i] = $selectedLine
      Set-Content -LiteralPath $ConfigPath -Value $lines -Encoding UTF8
      return
    }
  }

  $lines.Insert($desktopIndex + 1, $selectedLine)
  Set-Content -LiteralPath $ConfigPath -Value $lines -Encoding UTF8
}

$codexHome = Get-CodexHome
$petDir = Join-Path $codexHome "pets\terminal-gremlin"
New-Item -ItemType Directory -Force -Path $petDir | Out-Null

Copy-PetFiles -PetDir $petDir -Repo $Repo -Branch $Branch

$manifestPath = Join-Path $petDir "pet.json"
$spritePath = Join-Path $petDir "spritesheet.webp"
if (-not (Test-Path $manifestPath)) {
  throw "pet.json was not installed."
}
if (-not (Test-Path $spritePath)) {
  throw "spritesheet.webp was not installed."
}

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
if ($manifest.id -ne "terminal-gremlin") {
  throw "Unexpected pet id: $($manifest.id)"
}

if (-not $SkipSelect) {
  Set-SelectedPet -ConfigPath (Join-Path $codexHome "config.toml")
}

Write-Host "Installed Terminal Gremlin to: $petDir"
if (-not $SkipSelect) {
  Write-Host "Selected avatar id: custom:terminal-gremlin"
}
Write-Host "Restart Codex Desktop to load the pet."
