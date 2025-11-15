$scriptFile = "C:\Scripts\CreateUser.ps1"
$regPath = "HKLM:\Software\MyScripts"

# قراءة محتوى السكريبت
$scriptContent = Get-Content -Path $scriptFile -Raw

# إنشاء مفتاح الريجيستري إذا لم يكن موجود
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# تخزين السكريبت في الريجيستري
Set-ItemProperty -Path $regPath -Name "StoredScript" -Value $scriptContent

Write-Output "Sorted in Reg has Done : - )"