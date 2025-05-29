# PowerShell Environment Validation Script for Windows
# RFC-001 Implementation

param()

# Required environment variables
$RequiredVars = @(
    "POSTGRES_DB",
    "POSTGRES_USER", 
    "POSTGRES_PASSWORD",
    "N8N_HOST",
    "N8N_ENCRYPTION_KEY",
    "BASE_DOMAIN",
    "NC_AUTH_JWT_SECRET"
)

# Optional but recommended variables
$OptionalVars = @(
    "VPS_POSTGRES_HOST",
    "VPS_POSTGRES_USER",
    "VPS_POSTGRES_PASSWORD",
    "VPS_POSTGRES_DB",
    "LETSENCRYPT_EMAIL"
)

function Test-EnvFile {
    if (-not (Test-Path ".env")) {
        Write-Host "❌ .env file not found!" -ForegroundColor Red
        Write-Host "📋 Please create .env file from env.txt template" -ForegroundColor Yellow
        Write-Host "💡 Copy env.txt to .env and fill in the values" -ForegroundColor Cyan
        return $false
    }
    Write-Host "✅ .env file exists" -ForegroundColor Green
    return $true
}

function Get-EnvVariables {
    $envVars = @{}
    if (Test-Path ".env") {
        Get-Content ".env" | ForEach-Object {
            if ($_ -match "^([^#][^=]+)=(.*)$") {
                $envVars[$matches[1].Trim()] = $matches[2].Trim()
            }
        }
    }
    return $envVars
}

function Test-RequiredVars {
    param($envVars)
    
    Write-Host "🔍 Validating required environment variables..." -ForegroundColor Cyan
    $missingVars = @()
    
    foreach ($var in $RequiredVars) {
        if ($envVars.ContainsKey($var) -and $envVars[$var]) {
            Write-Host "✅ $var is set" -ForegroundColor Green
        } else {
            $missingVars += $var
        }
    }
    
    if ($missingVars.Count -gt 0) {
        Write-Host "❌ Missing required variables:" -ForegroundColor Red
        foreach ($var in $missingVars) {
            Write-Host "   - $var" -ForegroundColor Red
        }
        return $false
    }
    return $true
}

function Test-PasswordStrength {
    param($envVars)
    
    Write-Host "🔒 Validating password strength..." -ForegroundColor Cyan
    
    if ($envVars["POSTGRES_PASSWORD"].Length -lt 12) {
        Write-Host "❌ POSTGRES_PASSWORD must be at least 12 characters" -ForegroundColor Red
        return $false
    }
    
    if ($envVars["N8N_ENCRYPTION_KEY"].Length -lt 32) {
        Write-Host "❌ N8N_ENCRYPTION_KEY must be at least 32 characters" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ Password strength validation passed" -ForegroundColor Green
    return $true
}

function Test-DomainFormat {
    param($envVars)
    
    Write-Host "🌐 Validating domain format..." -ForegroundColor Cyan
    
    $domainPattern = '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if ($envVars["N8N_HOST"] -notmatch $domainPattern) {
        Write-Host "❌ N8N_HOST format invalid: $($envVars['N8N_HOST'])" -ForegroundColor Red
        return $false
    }
    
    if ($envVars["BASE_DOMAIN"] -notmatch $domainPattern) {
        Write-Host "❌ BASE_DOMAIN format invalid: $($envVars['BASE_DOMAIN'])" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ Domain format validation passed" -ForegroundColor Green
    return $true
}

function Test-OptionalVars {
    param($envVars)
    
    Write-Host "📋 Checking optional variables..." -ForegroundColor Cyan
    
    foreach ($var in $OptionalVars) {
        if ($envVars.ContainsKey($var) -and $envVars[$var]) {
            Write-Host "✅ $var is set" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $var is not set (optional)" -ForegroundColor Yellow
        }
    }
}

# Main execution
Write-Host "🔍 Environment Validation (RFC-001)..." -ForegroundColor Cyan

$envVars = Get-EnvVariables
$exitCode = 0

if (-not (Test-EnvFile)) { $exitCode = 1 }
if (-not (Test-RequiredVars $envVars)) { $exitCode = 1 }
if (-not (Test-PasswordStrength $envVars)) { $exitCode = 1 }
if (-not (Test-DomainFormat $envVars)) { $exitCode = 1 }
Test-OptionalVars $envVars

if ($exitCode -eq 0) {
    Write-Host "✅ Environment validation passed!" -ForegroundColor Green
} else {
    Write-Host "❌ Environment validation failed!" -ForegroundColor Red
    Write-Host "📋 Please check your .env file and fix the issues above" -ForegroundColor Yellow
}

exit $exitCode 