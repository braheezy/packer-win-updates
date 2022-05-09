Write-Output "calling sysprep"
Start-Process "$env:WINDIR\System32\Sysprep\sysprep.exe" -Wait -ArgumentList "/generalize /oobe /shutdown /unattend:A:\sysprep_unattend.xml"
