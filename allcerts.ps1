#Script Gathers All Certs in AD Domain

$aadapServPrinc = Get-AzureADServicePrincipal -Top 100000 | where-object {$_.Tags -Contains "WindowsAzureActiveDirectoryOnPremApp"}  

$allApps = Get-AzureADApplication -Top 100000 

$aadapApp = $aadapServPrinc | ForEach-Object { $allApps -match $_.AppId} 

foreach ($item in $aadapApp) { 

    $tempApps = Get-AzureADApplicationProxyApplication -ObjectId $item.ObjectId

    If ($tempApps.ExternalUrl -notmatch ".msappproxy.net") {

       $aadapServPrinc[$aadapApp.IndexOf($item)].DisplayName + " (AppId: " + $aadapServPrinc[$aadapApp.IndexOf($item)].AppId + ")"; 

       $tempApps | select ExternalUrl,InternalUrl,ExternalAuthenticationType, VerifiedCustomDomainCertificatesMetadata | fl

    }
}  

# Get the list of SSL certificates assigned Azure AD Application Proxy applications

[string[]]$certs = $null

foreach ($item in $aadapApp) { 

    $tempApps = Get-AzureADApplicationProxyApplication -ObjectId $item.ObjectId

    If ($tempApps.VerifiedCustomDomainCertificatesMetadata -match "class") { $certs += $tempApps.VerifiedCustomDomainCertificatesMetadata }     
}  

$certs | Sort-Object | Get-Unique 

Exit-PSSession