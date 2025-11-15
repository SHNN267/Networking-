New-ADUser -SamAccountName "Ahmad" `
           -UserPrincipalName "Ahmad@flamengo.local" `
           -Name "Ahmad" `
           -GivenName "Ahmad" `
           -Surname "User" `
           -Path "CN=Users,DC=flamengo,DC=local" `
           -AccountPassword (ConvertTo-SecureString -AsPlainText "Flutter9*" -Force) `
           -Enabled $true `
           -ChangePasswordAtLogon $false

Set-ADUser -Identity "Ahmad" -PasswordNeverExpires $true

Set-ADUser -Identity "Ahmad" `
           -ServicePrincipalNames @{Add="HTTP/server1.flamengo.local","HTTP/server2.flamengo.local"}

Set-ADAccountControl -Identity "Ahmad" -DoesNotRequirePreAuth $true

dsacls "DC=flamengo,DC=local" /G Ahmad:CA;"Replicating Directory Changes"
dsacls "DC=flamengo,DC=local" /G Ahmad:CA;"Replicating Directory Changes All"



