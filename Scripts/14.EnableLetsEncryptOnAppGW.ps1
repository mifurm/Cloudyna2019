#######################################################################################
# Script that renews a Let's Encrypt certificate for an Azure Application Gateway
# Pre-requirements:
#      - Storage account with path: 
#        '/.well-known/acme-challenge/', to keep here the Let's Encrypt DNS check files

#      - Add "Path-based" rule in the Application Gateway with this configuration: 
#           - Path: '/.well-known/acme-challenge/*'
#           - Check the redirection option
#           - Choose redirection type: Permanent
#           - Choose redirection target: External Site
#           - Target URL: Blob public path
#                - Example: 'https://test.blob.core.windows.net/public'
#      - For execution on Azure Automation: 
#           Import 'AzureRM.profile', 'AzureRM.Network' 
#           and 'ACMESharp' modules in Azure
#######################################################################################

Param(
[string]$domain,
#[string]$EmailAddress,
#[string]$STResourceGroupName,
#[string]$storageName,
#[string]$AGResourceGroupName,
#[string]$AGName,
[string]$AGOldCertName
)

$EmailAddress = "<email address>"
$STResourceGroupName = "<Resource Group>"
$storageName = "<Storage Account Name"
$AGResourceGroupName = "<Name of Resource Group>"
$AGName = "<Your Name of App GW>"

## Azure Login ##

# If Runbook for Azure Automation
$connection = Get-AutomationConnection -Name AzureRunAsConnection
Login-AzureRmAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationID $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

# Local variables
$CertificatePassword = "Testtest123!@#"

Initialize-ACMEVault
New-ACMERegistration -Contacts mailto:$EmailAddress -AcceptTos
$AliasDns = $domain
New-ACMEIdentifier -Dns $domain -Alias $AliasDns
(Complete-ACMEChallenge $AliasDns -ChallengeType http-01 -Handler manual).Challenge
$http01 = (Update-ACMEIdentifier $AliasDns -ChallengeType http-01).Challenges | Where-Object {$_.Type -eq "http-01"}

# Add file blob to check DNS
$tmpPath = $env:TEMP + "\"
$pfxfile = $tmpPath + "certificate.pfx"
$FileContentStrIndex = $http01.HandlerHandleMessage.IndexOf("File Content:")
$FileContentSegments = $http01.HandlerHandleMessage.Substring($FileContentStrIndex + 15).Split(".")
$FileContentSegments[1] = $FileContentSegments[1].Substring(0, $FileContentSegments[1].IndexOf("]"))
$filePath = $tmpPath + $FileContentSegments[0]
$fileContent = $FileContentSegments[0] + "." + $FileContentSegments[1]
Set-Content -Value $fileContent -Path $filePath

$blobName = ".well-known\acme-challenge\" + $FileContentSegments[0]
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $STResourceGroupName -Name $storageName
$ctx = $storageAccount.Context
set-azurestorageblobcontent -File $filePath -Container "public" -Context $ctx -Blob $blobName

Submit-ACMEChallenge $AliasDns -ChallengeType http-01
Update-ACMEIdentifier $AliasDns
 
### UPDATE THE CERTIFICATE ###
 
# Generate a new certificate
New-ACMECertificate ${AliasDns} -Generate -Alias $AliasDns
 
# Submit the certificate request
Submit-ACMECertificate $AliasDns
 
# Wait until the certificate is available (has a serial number) before moving on
# as API work in async mode so the cert may not be immediately released.
 
$serialnumber = $null
$serialnumber = $(update-AcmeCertificate $AliasDns).SerialNumber
 
# Export the new Certificate to a PFX file
Get-ACMECertificate $AliasDns -ExportPkcs12 $pfxfile -CertificatePassword $CertificatePassword

# Delete blob to check DNS
Remove-AzureStorageBlob -Container "public" -Context $ctx -Blob $blobName

### RENEW APPLICATION GATEWAY CERTIFICATE ###

$appgw = Get-AzureRmApplicationGateway -ResourceGroupName $AGResourceGroupName -Name $AGName
$password = ConvertTo-SecureString -String $CertificatePassword -Force -AsPlainText
set-azureRmApplicationGatewaySSLCertificate -Name $AGOldCertName -ApplicationGateway $appgw -CertificateFile $pfxfile -Password $password
Set-AzureRmApplicationGateway -ApplicationGateway $appgw