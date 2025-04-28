# AAD-PSM-Installer
AzureAD/EntraAD Powershell module offline installer


# Show help
.\OfflineModuleInstaller.ps1 -h

# Package on online PC:
.\OfflineModuleInstaller.ps1 -Mode Package -ModulePath C:\OfflineModules

# Install on offline PC:
.\OfflineModuleInstaller.ps1 -Mode Install -ModulePath "D:\OfflineModules"
