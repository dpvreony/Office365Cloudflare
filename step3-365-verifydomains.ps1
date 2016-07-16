Import-Module MSOnline
$cred = Get-Credential
Connect-MsolService -Credential $cred

$count=import-csv .\cloudflare.csv | measure
$domainlist=import-csv .\cloudflare.csv
write-host 
write-host --------------------------------------------
write-host Importing $count.count Domains....
write-host --------------------------------------------

$domainList = Get-MsolDomain 

foreach ($domain in $domainlist) 
{
    write-host "DOMAIN:" $domain.Name

    if ($domain.Status -ine "Verified")
    {
        Confirm-MsolDomain -DomainName $domain.Name
    }

}

Get-MsolDomain
