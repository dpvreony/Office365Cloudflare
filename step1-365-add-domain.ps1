#taken from http://mmug.co.uk/blogs/tony-brown/14-adding-multiple-domains-to-office-365-in-powershell
write-host 
write-host --------------------------------------------
write-host Authenticating....
write-host --------------------------------------------
Import-Module MSOnline
$cred = Get-Credential
Connect-MsolService -Credential $cred
$count=import-csv .\domains.csv | measure
$domainlist=import-csv .\domains.csv
write-host 
write-host --------------------------------------------
write-host Importing $count.count Domains....
write-host --------------------------------------------
$logfile=".\domains.log"

Function LogWrite {
 Param ([string]$logstring)
 Add-content $logfile -value $logstring
 }

logwrite "Domain,TXTRecord"cd

foreach ($domain in $domainlist) 
{
New-MSOLDomain -name $domain.domain
$proof = (Get-MSOLDomainVerificationDNS -domainname $domain.domain | select-object -expandproperty label).split(".")[0]
$txtrecord="MS=" + $proof
$domainrecord=$domain.domain
logwrite "$domainrecord,$txtrecord"
}
