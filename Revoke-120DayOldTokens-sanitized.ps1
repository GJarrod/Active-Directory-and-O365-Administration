connect-azuread -accountid jgainor@contoso.com

#Get the date
$today = get-date

#Calculate 124 days ago (passwords expire after 120 days)
$daysago = $today.adddays(-124)
#Calculate 120 days ago to help calculate expired passwords
$daysbefore = $today.adddays(-120)

#Get users that have passwords that will be expiring
#Return default properties plus specified (passwordlastset), search everywhere, only return enabled users that have passwords with an age over 120 days but under 124 days
$Expired = Get-ADuser -Properties ("passwordlastset") -SearchBase "dc=contoso,DC=COM" -Filter { (passwordlastset -lt $daysbefore) -and (passwordlastset -gt $daysago) -and (Enabled -eq $true) -and (passwordneverexpires -eq $false)  }

#for each user that is returned, set their samaccountname and then revoke any Azure tokens that are still valid
$tobeexpired = foreach ($user in $expired){
		$username = $user.samaccountname 
		Get-AzureADUser -SearchString '$username' | Revoke-AzureADUserAllRefreshToken
		
        }

disconnect-azuread