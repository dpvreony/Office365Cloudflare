Import-Module -Name .\Posh-CloudFlare.psd1

$CloudFlareAPIToken     = ''
$CloudFlareEmailAddress = ''

$count=import-csv .\cloudflare.csv | measure
$domainlist=import-csv .\cloudflare.csv
write-host 
write-host --------------------------------------------
write-host Importing $count.count Domains....
write-host --------------------------------------------

foreach ($domain in $domainlist) 
{
    write-host "DOMAIN: $domain.domain"
    $CloudFlareDomain = $domain.domain

    try
    {
        $records = get-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain

        $recordCount = $records.Count;
        if ($recordCount -gt 0)
        {
            $position = 0;
            $action = "CREATE";
            Do
            {
                $currentRecord = $records[$position]
                if ($currentRecord.type -eq "TXT" -and $currentRecord.content.StartsWith("MS="))
                {
                    if ($currentRecord.content -ieq $domain.TXTRecord)
                    {
                        $action = "NONE"
                    }
                    else
                    {
                        # for some reason a new validation key has been assigned in the list
                        $action = "NONE"
                        #Write-Host $currentRecord.content
                        #$action = "UPDATE"
                    }
                }

                $position = $position + 1
            } # End of 'Do
            While ($found -eq $false -And $position -lt $recordCount)

            Write-Host "Action Required: $action"
            if ($action -eq "CREATE")
            {
                New-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name $CloudFlareDomain -Content $domain.TXTRecord -Type TXT
            }
            elseif ($action -eq "UPDATE")
            {
            } 
        }
    }
    catch [System.Exception]
    {
        
        Write-Host "problem with $domain.Domain: $error"
    }
}
