<#
This Windows Updates (WUs) approach focuses on .msu files

Why .msu vs the many other ways to deal with and reason about WUs?
- A simple mental model. Your updates are normal files that are familiar to work with
- Very transferable e.g. offline, airgapped

PSWindowsUpdate is a 3rd party module that provides cmdlets for working with WUs
Alias: Clear-WUJob
Alias: Download-WindowsUpdate
Alias: Get-WUInstall
Alias: Get-WUList
Alias: Hide-WindowsUpdate
Alias: Install-WindowsUpdate
Alias: Show-WindowsUpdate
Alias: UnHide-WindowsUpdate
Alias: Uninstall-WindowsUpdate
Cmdlet: Add-WUServiceManager
Cmdlet: Enable-WURemoting
Cmdlet: Get-WindowsUpdate
Cmdlet: Get-WUApiVersion
Cmdlet: Get-WUHistory
Cmdlet: Get-WUInstallerStatus
Cmdlet: Get-WUJob
Cmdlet: Get-WULastResults
Cmdlet: Get-WUOfflineMSU
Cmdlet: Get-WURebootStatus
Cmdlet: Get-WUServiceManager
Cmdlet: Get-WUSettings
Cmdlet: Invoke-WUJob
Cmdlet: Remove-WindowsUpdate
Cmdlet: Remove-WUServiceManager
Cmdlet: Reset-WUComponents
Cmdlet: Set-PSWUSettings
Cmdlet: Set-WUSettings
Cmdlet: Update-WUModule
#>

# Install PSWindowsUpdates module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PSWindowsUpdate -Force
# Use module to get list of KBs required
<#
Get-WindowsUpdate to get a list
    Filter to avoid downnloads over 10G
Powershell magic to turn results into an array of KB IDs needed
Get-WUOfflineMSU for each KB :)
#>
# Download all KBs (Can the module do this?)
# Install all KBs to patch current system
# Use DISM to capture folder of KBs as data image
# Create ZIP file of KBs
# Use Packer file provisioner to download artifacts back to host