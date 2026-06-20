$scriptFile = "C:\Scripts\CreateUser.ps1"
$regPath = "HKLM:\Software\MyScripts"

$scriptContent = Get-Content -Path $scriptFile -Raw

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

Set-ItemProperty -Path $regPath -Name "StoredScript" -Value $scriptContent

Write-Output "Sorted in Reg has Done : - )"