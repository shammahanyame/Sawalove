[CmdletBinding()]
param(
    [string]$EnvFile = ".env.release",
    [switch]$Clean,
    [switch]$SkipApiPreflight
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
Set-Location -LiteralPath $projectRoot

function Import-EnvFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith("#")) {
            continue
        }

        $separator = $trimmed.IndexOf("=")
        if ($separator -lt 1) {
            throw "Invalid env line in ${Path}: $line"
        }

        $name = $trimmed.Substring(0, $separator).Trim()
        $value = $trimmed.Substring($separator + 1).Trim()
        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'"))) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

function Get-LocalProperty {
    param([string]$Name)

    $localProperties = Join-Path $projectRoot "android\local.properties"
    foreach ($line in Get-Content -LiteralPath $localProperties) {
        if ($line.StartsWith("$Name=")) {
            return $line.Substring($Name.Length + 1).Replace("\\", "\")
        }
    }

    return $null
}

function Get-GradleProperty {
    param([string]$Name)

    $gradleProperties = Join-Path $projectRoot "android\gradle.properties"
    foreach ($line in Get-Content -LiteralPath $gradleProperties) {
        if ($line.StartsWith("$Name=")) {
            return $line.Substring($Name.Length + 1).Replace("\\", "\")
        }
    }

    return $null
}

function Get-BoolEnv {
    param(
        [string]$Name,
        [bool]$Default
    )

    $value = [Environment]::GetEnvironmentVariable($Name, "Process")
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $Default
    }

    $normalized = $value.Trim().ToLowerInvariant()
    if (@("1", "true", "yes", "y", "on") -contains $normalized) {
        return $true
    }
    if (@("0", "false", "no", "n", "off") -contains $normalized) {
        return $false
    }

    throw "$Name must be true or false. Current value: $value"
}

function Assert-PublicHttpsUrl {
    param(
        [string]$Name,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required. Add it to $EnvFile or set it in the current shell."
    }
    if (-not $Value.StartsWith("https://")) {
        throw "$Name must start with https:// for a Play Store release App Bundle."
    }
    if ($Value -match "example\.com|localhost|127\.0\.0\.1|10\.0\.2\.2") {
        throw "$Name must point to your deployed public Supabase project, not an example or local host."
    }
}

Import-EnvFile -Path $EnvFile

Assert-PublicHttpsUrl -Name "SUPABASE_URL" -Value $env:SUPABASE_URL

if ([string]::IsNullOrWhiteSpace($env:SUPABASE_ANON_KEY)) {
    throw "SUPABASE_ANON_KEY is missing from $EnvFile."
}

$phoneAuthEnabled = Get-BoolEnv -Name "SUPABASE_PHONE_AUTH_ENABLED" -Default $true
$emailAuthEnabled = Get-BoolEnv -Name "SUPABASE_EMAIL_AUTH_ENABLED" -Default $true
$googleAuthEnabled = Get-BoolEnv -Name "SUPABASE_GOOGLE_AUTH_ENABLED" -Default $false
$appleAuthEnabled = Get-BoolEnv -Name "SUPABASE_APPLE_AUTH_ENABLED" -Default $false

$flutterSdk = Get-LocalProperty -Name "flutter.sdk"
if ([string]::IsNullOrWhiteSpace($flutterSdk)) {
    throw "flutter.sdk is missing from android/local.properties."
}

$flutter = Join-Path $flutterSdk "bin\flutter.bat"
if (-not (Test-Path -LiteralPath $flutter)) {
    throw "Flutter executable was not found at $flutter."
}

$javaHome = Get-GradleProperty -Name "org.gradle.java.home"
if (-not [string]::IsNullOrWhiteSpace($javaHome)) {
    $java = Join-Path $javaHome "bin\java.exe"
    if (-not (Test-Path -LiteralPath $java)) {
        throw "Configured Java executable was not found at $java."
    }

    $env:JAVA_HOME = $javaHome
    $env:Path = "$javaHome\bin;$env:Path"
}

if ($Clean) {
    & $flutter clean
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

& $flutter build appbundle --release `
    "--dart-define=SUPABASE_URL=$env:SUPABASE_URL" `
    "--dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY" `
    "--dart-define=SUPABASE_PROFILE_PHOTOS_BUCKET=$env:SUPABASE_PROFILE_PHOTOS_BUCKET" `
    "--dart-define=SUPABASE_AUTH_REDIRECT_TO=$env:SUPABASE_AUTH_REDIRECT_TO" `
    "--dart-define=SUPABASE_PHONE_AUTH_ENABLED=$($phoneAuthEnabled.ToString().ToLowerInvariant())" `
    "--dart-define=SUPABASE_EMAIL_AUTH_ENABLED=$($emailAuthEnabled.ToString().ToLowerInvariant())" `
    "--dart-define=SUPABASE_GOOGLE_AUTH_ENABLED=$($googleAuthEnabled.ToString().ToLowerInvariant())" `
    "--dart-define=SUPABASE_APPLE_AUTH_ENABLED=$($appleAuthEnabled.ToString().ToLowerInvariant())"

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$aab = Join-Path $projectRoot "build\app\outputs\bundle\release\app-release.aab"
if (-not (Test-Path -LiteralPath $aab)) {
    throw "Build completed but the expected AAB was not found at $aab."
}

Write-Host "AAB ready: $aab"
