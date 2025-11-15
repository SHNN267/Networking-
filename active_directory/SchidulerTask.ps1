$regPath = "HKLM:\Software\MyScripts"
$tempScriptPath = "$env:TEMP\CreateUser_Run.ps1"
$taskName = "CreateUserTaskEveryMinute"

$scriptContent = (Get-ItemProperty -Path $regPath -Name "StoredScript").StoredScript
$scriptContent | Out-File -FilePath $tempScriptPath -Encoding UTF8

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$tempScriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Days 365)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# تسجيل المهمة (أعد التشغيل إذا كانت موجودة)
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force

Write-Output " Now I am Run the script every min ... "