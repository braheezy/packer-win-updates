Stop-Service -Name "wuauserv"
Set-Service -Name "wuauserv" -StartupType Manual

Disable-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate" -TaskName "Scheduled Start"
