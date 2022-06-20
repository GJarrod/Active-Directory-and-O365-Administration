$searchbase = "ou=IT,dc=contoso,dc=com"
$credential = Get-credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

#Variables for rule name and the HTML banner to mark up matching messages
$ruleName = "External Senders matching Internal Display Names IT"
$ruleHTML ="<div style=background-color:#D5EAFF; border:1px dotted #003333; padding:.8em; >

        <span style=font-size:12pt;  font-family: 'Cambria','times new roman','garamond',serif; color:#ff0000;>Sender Outside of Contoso</span></br>
        <p style=font-size:8pt; line-height:10pt; font-family: 'Cambria','times roman',serif;> The email display name matches another contoso employee. Please do not click any links or reply unless you know the sender.</p>
        <p style=font-size:8pt; line-height:10pt; font-family: 'Cambria','times roman',serif;> Any questions, please email helpdesk@contoso.com. </p>"

#Variables for checking if the rule already exists, and getting all employee names 
$rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
#get all users, even disabled, with email addresses populated in the searchbase defined above
$displayNames = (get-aduser -filter ('targetaddress -like "smtp*"') -SearchBase $searchbase).name

#if the rule doesn't exist, create it 
if (!$rule) 
{
    Write-output "Rule not found, creating..." -ForegroundColor Green
    New-TransportRule -Name $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml -enabled $false
}else 
{
    #if the rule does exist, update the rule with current employee displaynames
    Write-output "Rule found, updating rule with current employee list..." -ForegroundColor Green
    #disable the transport rule for verification before go-live
	disable-transportrule -identity $rulename
    Set-TransportRule -Identity $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml 
}



Remove-PSSession $Session
