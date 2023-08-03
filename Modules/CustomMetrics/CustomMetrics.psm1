

function Get-JsonPayload {

    param (
        $Share
    )

    $time = Get-Date -UFormat "%Y-%m-%dT%T"
   
    $client = $share.ShareClient
    $stats = $client.GetStatistics()
    $usage = [math]::Round($stats.Value.ShareUsageInBytes / 1024 / 1024, 3)
    $name = $client.Name
    $quota = $share.Quota 
    $account = $client.AccountName

    $json = @"
    { 
        "time": "$time", 
        "data": { 
            "baseData": { 
                "metric": "ShareUsageInMB", 
                "namespace": "File", 
                "dimNames": [ 
                "StorageAccountName", 
                "FileShareName" 
                ], 
                "series": [ { 
                    "dimValues": [ 
                    "$account", 
                    "$name" 
                    ], 
                    "min": $usage, 
                    "max": $usage, 
                    "sum": $usage, 
                    "count": 1 
                } 
                ] 
            } 
        } 
    }
"@

    Write-Output $json
}


function Push-MetricToMonitor {

    param (
        $Json,
        $Token,
        $StorageAccountId
    )

    $headers = @{
        Authorization = "Bearer $Token"
    }
    
    $uri = "https://westeurope.monitoring.azure.com$storageAccountId/metrics"
    $result = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $Json -ContentType "application/json"
    
    Write-Output $result
}