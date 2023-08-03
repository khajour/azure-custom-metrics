
param($Timer)

$clientID = "$env:clientID"
$clientSecret = "$env:clientSecret"
$tenantId = "$env:tenantId"
$subscription = "$env:subscription"
$storageAccountName = $env:storageAccountName
$storageAccountKey = "$env:storageAccountKey"
$filePrefix = "ak"
$resourceGroup = $env:resourceGroup
$storageAccountId = "/subscriptions/$subscription/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccountName"
$authenticationUri = "https://login.microsoft.com/$tenantId/oauth2/token"


Write-Output ">>>>>>> BEGIN <<<<<<<<<<<"

$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientID
    client_secret = $clientSecret
    resource      = "https://monitor.azure.com"
}

$result = Invoke-RestMethod -Method Post -Uri $authenticationUri -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $result.access_token

Set-AzContext -Subscription $subscription
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$shares = Get-AzStorageShare -Prefix $filePrefix -Context $context 

foreach ($share in $shares) {
    $json = Get-JsonPayload -Share $share
    Push-MetricToMonitor -Json $json -Token $token -StorageAccountId  $storageAccountId

}

Write-Output ">>>>>>> END <<<<<<<<<<<"
