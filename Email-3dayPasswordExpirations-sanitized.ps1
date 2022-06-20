#enter email relay IP
$internalemailrelayIP = "10.0.0.1"
#Get the date
$today = get-date

#Calculate 120 days ago (passwords expire after 120 days)
$daysago = $today.adddays(-120)
#Calculate 117 days ago (to find passwords that will expire in the next 3 days)
$daysbefore = $today.adddays(-117)

#Get users that have passwords that will be expiring within 3 days
#Return default properties plus specified (passwordlastset), search everywhere, only return enabled users that have passwords with an age over 117 days but under 120 days 
$Expired = Get-ADuser -Properties ("passwordlastset") -SearchBase "dc=contoso,DC=COM" -Filter { (passwordlastset -lt $daysbefore) -and (passwordlastset -gt $daysago) -and (Enabled -eq $true) -and (passwordneverexpires -eq $false) }


$tobeexpired = foreach ($user in $expired){ 
    $expiration = $user.passwordlastset
    $Body = $expiration.adddays(120)
    #Send-MailMessage -to $user.userprincipalname -from noreply@contoso.com -SmtpServer $internalemailrelayIP -Subject "Your Password Expires Soon!"  -body "Your password will expire on $body (timezone)"
    write-host $user.userprincipalname
    write-host $body
    } 

$tobeexpired | out-file C:\temp\expired1.txt

#created body of the email with each line as a new paragraph
$body = (Get-Content "C:\temp\expired1.txt") -join "`n"

$sub1 = $expired.Count.ToString()
$subject = $sub1 +" User Passwords Expiring Within 3 Days"

Send-MailMessage -to jgainor@contoso.com -from noreply@contoso.com -SmtpServer $internalemailrelayIP -Subject $subject  -body "$body"  