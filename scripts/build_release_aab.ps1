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
        throw "$Name must point to your deployed public PHP API, not an example or local host."
    }
}

function Assert-ApiHealth {
    param([string]$ApiBaseUrl)

    $healthUrl = "$($ApiBaseUrl.TrimEnd('/'))/health"
    try {
        $health = Invoke-RestMethod -Method Get -Uri $healthUrl -TimeoutSec 20
    } catch {
        throw "Could not verify PHP API health at $healthUrl. Deploy the PHP API or rerun with -SkipApiPreflight if you already verified it manually. Error: $($_.Exception.Message)"
    }

    if ($null -eq $health.ok -or $health.ok -ne $true) {
        throw "PHP API health check at $healthUrl did not return ok=true."
    }
}

Import-EnvFile -Path $EnvFile

if ([string]::IsNullOrWhiteSpace($env:API_BASE_URL) -and
    -not [string]::IsNullOrWhiteSpace($env:PHP_API_BASE_URL)) {
    $env:API_BASE_URL = $env:PHP_API_BASE_URL
}

Assert-PublicHttpsUrl -Name "API_BASE_URL" -Value $env:API_BASE_URL

$phoneAuthEnabled = Get-BoolEnv -Name "API_PHONE_AUTH_ENABLED" -Default $true
$emailAuthEnabled = Get-BoolEnv -Name "API_EMAIL_AUTH_ENABLED" -Default $true
$googleAuthEnabled = Get-BoolEnv -Name "API_GOOGLE_AUTH_ENABLED" -Default $false
$appleAuthEnabled = Get-BoolEnv -Name "API_APPLE_AUTH_ENABLED" -Default $false

if (-not $SkipApiPreflight) {
    Assert-ApiHealth -ApiBaseUrl $env:API_BASE_URL
}

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
    "--dart-define=API_BASE_URL=$env:API_BASE_URL" `
    "--dart-define=API_PHONE_AUTH_ENABLED=$($phoneAuthEnabled.ToString().ToLowerInvariant())" `
    "--dart-define=API_EMAIL_AUTH_ENABLED=$($emailAuthEnabled.ToString().ToLowerInvariant())" `
    "--dart-define=API_GOOGLE_AUTH_ENABLED=$($googleAuthEnabled.ToString().ToLowerInvariant())" `
    "--dart-define=API_APPLE_AUTH_ENABLED=$($appleAuthEnabled.ToString().ToLowerInvariant())"

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$aab = Join-Path $projectRoot "build\app\outputs\bundle\release\app-release.aab"
if (-not (Test-Path -LiteralPath $aab)) {
    throw "Build completed but the expected AAB was not found at $aab."
}

Write-Host "AAB ready: $aab"
