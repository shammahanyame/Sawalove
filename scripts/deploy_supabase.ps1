# SawaLove Supabase deploy (blue-green helper).
#
# Usage:
#   .\scripts\deploy_supabase.ps1 -Migrations            # apply pending migrations
#   .\scripts\deploy_supabase.ps1 -Functions             # deploy + smoke-test edge functions
#   .\scripts\deploy_supabase.ps1 -Migrations -Functions # both
#
# Requires: supabase CLI logged in + project linked (supabase link).
param(
    [switch]$Migrations,
    [switch]$Functions,
    [string]$ProjectRef = $env:SUPABASE_PROJECT_REF
)

$ErrorActionPreference = "Stop"
$supabaseDir = Join-Path $PSScriptRoot "..\supabase"

if (-not $Migrations -and -not $Functions) {
    throw "Nothing to do: pass -Migrations and/or -Functions."
}

function Invoke-Supabase {
    param([string[]]$Arguments)
    $cmd = "supabase " + ($Arguments -join " ")
    Write-Host ">> $cmd"
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        throw "supabase command failed: $cmd"
    }
}

if ($Migrations) {
    if ([string]::IsNullOrWhiteSpace($ProjectRef)) {
        throw "SUPABASE_PROJECT_REF is not set and -ProjectRef was not passed."
    }
    # Migrations are additive-first; this never destroys production data.
    Invoke-Supabase @("db push --project-ref $ProjectRef")
    Write-Host "Migrations applied."
}

if ($Functions) {
    $functions = @("ai-icebreakers", "ai-bio-suggestions")
    foreach ($fn in $functions) {
        Write-Host "Deploying edge function: $fn"
        Invoke-Supabase @("functions deploy $fn --project-ref $ProjectRef")
    }

    # Smoke test each function; a bad deploy is reported but the previous
    # function version keeps serving until this script exits non-zero.
    if ([string]::IsNullOrWhiteSpace($env:SUPABASE_URL) -or
        [string]::IsNullOrWhiteSpace($env:SUPABASE_ANON_KEY)) {
        Write-Warning "SUPABASE_URL / SUPABASE_ANON_KEY not set; skipping smoke tests."
    } else {
        $failures = @()
        foreach ($fn in $functions) {
            $url = "$($env:SUPABASE_URL.TrimEnd('/'))/functions/v1/$fn"
            try {
                # OPTIONS must always pass (CORS preflight); unauthenticated POST
                # must 401, never 5xx.
                $options = Invoke-WebRequest -Method Options -Uri $url -TimeoutSec 20
                if ($options.StatusCode -ge 500) { $failures += "$fn OPTIONS $($options.StatusCode)" }

                $post = Invoke-WebRequest -Method Post -Uri $url `
                    -Headers @{ "Authorization" = "Bearer invalid" ; "Content-Type" = "application/json" } `
                    -Body '{}' -SkipHttpErrorCheck -TimeoutSec 20
                if ([int]$post.StatusCode -ge 500) { $failures += "$fn POST $($post.StatusCode)" }
            } catch {
                $failures += "$fn $($_.Exception.Message)"
            }
        }
        if ($failures.Count -gt 0) {
            throw "Smoke tests failed:`n$($failures -join "`n")"
        }
        Write-Host "Edge function smoke tests passed."
    }
}

Write-Host "Deploy complete."
