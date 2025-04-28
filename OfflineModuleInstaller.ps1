<#
.SYNOPSIS
    Package or install PowerShell modules for offline use.

.DESCRIPTION
    -Help (-h):       Show this help message and examples.
    -Mode Package:    Downloads specified modules and all dependencies into a local folder.
    -Mode Install:    Copies saved modules into the system module path and imports them.

.PARAMETER Help
    Show usage and examples.

.PARAMETER Mode
    “Package” or “Install”

.PARAMETER ModulePath
    Path to save modules to (Package) or source modules from (Install). Default: “.\OfflineModules”
#>
param(
    [Alias("h","?")]
    [switch]$Help,

    [ValidateSet("Package","Install")]
    [string]$Mode,

    [string]$ModulePath = ".\OfflineModules"
)

if ($Help -or -not $Mode) {
    Write-Host @"
Usage:   .\OfflineModuleInstaller.ps1 -Mode <Package|Install> [-ModulePath <path>] [-Help]

Parameters:
  -Mode         “Package” or “Install” (required)
  -ModulePath   Path to save or load modules. Default: .\OfflineModules
  -Help, -h     Show this help message

Examples:
  # On an internet-connected PC:
  .\OfflineModuleInstaller.ps1 -Mode Package -ModulePath C:\OfflineModules

  # On the offline machine:
  .\OfflineModuleInstaller.ps1 -Mode Install -ModulePath "D:\OfflineModules"
"@ -ForegroundColor Cyan
    exit
}

# The modules you want to handle
$modules = @("Az","AzureAD","MSOnline")

if ($Mode -eq "Package") {
    Write-Host "=== PACKAGE MODE ===`n" -ForegroundColor Cyan
    Write-Host "Saving modules [$($modules -join ', ')] to `"$ModulePath`"..." -ForegroundColor Yellow

    if (-not (Test-Path -Path $ModulePath)) {
        New-Item -ItemType Directory -Path $ModulePath -Force | Out-Null
    }

    foreach ($mod in $modules) {
        Write-Host -NoNewline "Saving module '$mod'... "
        try {
            Save-Module -Name $mod -Path $ModulePath -Force -ErrorAction Stop
            Write-Host "OK" -ForegroundColor Green
        }
        catch {
            Write-Host "FAILED: $_" -ForegroundColor Red
        }
    }

    Write-Host "`nPackaging complete! Copy `"$ModulePath`" to your offline systems." -ForegroundColor Green
}
else {
    Write-Host "=== INSTALL MODE ===`n" -ForegroundColor Cyan
    Write-Host "Installing modules from `"$ModulePath`"..." -ForegroundColor Yellow

    $destRoots = @(
        "$Env:ProgramFiles\WindowsPowerShell\Modules",
        "$Env:ProgramFiles\PowerShell\Modules",
        "$Env:UserProfile\Documents\WindowsPowerShell\Modules"
    )
    $destinationRoot = $destRoots | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $destinationRoot) {
        Throw "No valid PowerShell modules directory found. Please create one of: $($destRoots -join ', ')"
    }

    foreach ($folder in Get-ChildItem -Path $ModulePath -Directory) {
        $dest = Join-Path $destinationRoot $folder.Name
        Write-Host -NoNewline "Copying '$($folder.Name)' to '$dest'... "
        try {
            Copy-Item -Path $folder.FullName -Destination $dest -Recurse -Force -ErrorAction Stop
            Write-Host "OK" -ForegroundColor Green
        }
        catch {
            Write-Host "FAILED: $_" -ForegroundColor Red
            continue
        }

        Write-Host -NoNewline "Importing module '$($folder.Name)'... "
        try {
            Import-Module -Name $folder.Name -Force -ErrorAction Stop
            Write-Host "OK" -ForegroundColor Green
        }
        catch {
            Write-Host "FAILED: $_" -ForegroundColor Red
        }
    }

    Write-Host "`nInstallation & import complete!" -ForegroundColor Green
}
