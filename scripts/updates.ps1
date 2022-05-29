# Install OSDUpdate module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name OSDUpdate -Force

# Collect OS info
$comp_info = Get-ComputerInfo
$os_name = ($comp_info | Select WindowsProductName)
if ($os_name -like '*Windows 10*') {
   $os = "Windows 10"
}
else {
   Throw "Could not detect OS"
}
$build_version = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion
$arch = If (($comp_info | Select OsArchitecture) -like "*64*") {"x64"} Else {"x86"}

# Collect update info
$desired_updates = @('LCU', 'DotNetCU')
Get-OSDUpdate | Where-Object { $_.UpdateOS -eq $os -and $_.UpdateArch -eq $arch -and $_.UpdateBuild -eq $build_version -and $_.UpdateGroup -in $desired_updates} | Get-DownOSDUpdate -DownloadPath C:\Windows\Temp\Updates

$update_files = Get-ChildItem C:\Windows\Temp\Updates -Recurse -Include *.cab
foreach ($update_file in $update_files) {
    DISM.exe /Online /NoRestart /Add-Package /PackagePath:"$update_file"
}

#gci . -Recurse -Exclude *.xml.cab -Include "*KB*.cab" | foreach { Dism.exe /Online /NoRestart /Add-Package /PackagePath:"$_" }