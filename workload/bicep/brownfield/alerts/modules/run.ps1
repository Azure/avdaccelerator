# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# USER DEFINED INFORMATION REQUIRED
#    Initial Subscription for getting Authentication Token
#    Tag used for LogAnalytics and HostPool Workspaces
$subscriptionName = $env:SubscriptionName
$subscriptionid = $env:subscriptionID
$LAWName = $env:LogAnalyticsWorkSpaceName
$resourceGroups = $env:HostPoolResourceGroupNames | convertfrom-json

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

Function Create-AccessToken {
    param($resourceURI)

    If ($null -eq $env:MSI_ENDPOINT) {
        # Connect-AzAccount -Identity
        $token = Get-AzAccessToken
        Return $token.Token
    }
    Else {
        $tokenAuthURI = $env:MSI_ENDPOINT + "?resource=$resourceURI&api-version=2017-09-01"
        $headers =  @{'Secret'="$env:MSI_SECRET"}
        try {
            $tokenResponse = Invoke-RestMethod -Method Get -header $headers -Uri $tokenAuthURI -ErrorAction:stop
            return $tokenResponse.access_token
        }
        catch {
            write-error "Unable to retrieve access token $error"
            exit 1
        }
    }
}

Function Query-Azure {
    param($query,$accesstoken)

    $url = $ManageURL + $query
    $headers = @{'Authorization' = "Bearer $accessToken"}
    
    try {
        $response = Invoke-RestMethod -Method 'Get' -Uri $url -Headers $headers -ErrorAction:stop
        Return $response
    }
    catch { write-error "Unable to query Azure RestAPI: $error" }
}

Function DimensionSpliter {
    param($dimensiongroup)

    $dims = $dimensiongroup.split(";")
    [System.Collections.Generic.List[System.Object]]$dimobject = @()
    foreach ($dim in $dims) {
        $obj = [pscustomobject]@{
	        name = $dim.split(":")[0]
	        value = $dim.split(":")[1]
        }
        $dimobject.Add($obj)
    }
    return $dimobject
}

Function Calculate-Metric {
    param($metric,$sessions,$hosts,$vms,$hostpool)

    $dimvalues = DimensionSpliter $metric.Dimensions | Foreach-Object {$_.Value}

    try { [int]$imetricresult = Invoke-Command -Scriptblock $metric.Query }
    catch {
        Write-Warning ("Metric query failed for: [{0}] - {1}" -f $metric.Namespace,$metric.Metric)
        Write-Warning ("{0}" -f $_.exception.message)
        return $False
    }

    $metricdata = [pscustomobject]@{
        dimValues = $dimvalues
        min = $imetricresult
        max = $imetricresult
        sum = $imetricresult
        count = 1
    }
    return $metricdata
}

Function POST-CustomMetric{
    param($custommetricjson,$accesstoken,$targetresourceid,$region)

    $url = "https://$region.monitoring.azure.com$targetresourceid/metrics"
    # Write-Host "--> URL: $url"
    $headers = @{'Authorization' = "Bearer $accessToken"
    'Content-Type' = "application/json"}
    try { $metricapiresponse = Invoke-RestMethod -Method 'Post' -Uri $url -Headers $headers -body $custommetricjson -ErrorAction:stop }
    catch {
        write-warning "Unable POST metric $error"
        return $false
    }
    return $true
}

Function Publish-Metric{
    param($metric,$sessions,$hosts,$vms,$hostpool,$azmontoken,$targetresourceid,$region)
    
    $dimnames = DimensionSpliter $metric.Dimensions | Select-Object -ExpandProperty Name

    $series = [System.Collections.Generic.List[System.Object]]@()
    $metricresult = Calculate-Metric $metric $sessions $hosts $vms $hostpool
    
    If($metricresult -eq $False) { return $False }
    Else { $series.Add($metricresult) }

    $custommetric = [PSCustomObject]@{
        time = (Get-Date -Format 'o')
        data = [PSCustomObject]@{
            baseData = [PSCustomObject]@{
                metric = $metric.metric
                namespace = $metric.namespace
                dimNames = $dimnames
                series = $series
            }
        }
    }

    $custommetricjson = $custommetric | convertto-json -depth 10 -compress
    write-output ("Publishing to Azure Monitor for Namespace:{0} Metric:{1}" -f $metric.namespace,$metric.metric)
    $Postresult = POST-CustomMetric $custommetricjson $azmontoken $targetresourceid $region 
    return $Postresult
}

# URL(s) for creating access tokens
$Environment = (Get-AzContext).Environment.Name
$ManageURL = (Get-AzEnvironment | Where-Object {$_.Name -eq $Environment}).ResourceManagerUrl
$WVDResourceURI = $ManageURL
$AZMonResourceURI = "https://monitoring.azure.com/"

# $WVDResourceURI = "https://management.core.windows.net/"
# $AZMonResourceURI = "https://monitoring.azure.com/"


Write-Output ("Creating Access Token for Azure Management ({0})" -f $WVDResourceURI)
$token = Create-AccessToken -resourceURI $WVDResourceURI
Write-Output ("Creating Access Token for Azure Monitor ({0})" -f $AZMonResourceURI)
$azmontoken = Create-AccessToken -resourceURI $AZMonResourceURI

Write-Output ("Collecting AVD Azure Subscriptions")
$subscriptionQuery = "/subscriptions?api-version=2016-06-01"
$subscription = (Query-Azure $subscriptionQuery $token).Value.Where{$_.displayName -eq $subscriptionName}

# foreach ($subscription in $subscriptions) {
    Write-Output ("Working on '{0}' Subscription Resources" -f $subscription.displayName)
    $subscriptionid = $subscription.subscriptionid 
    
   # $resourceGroupQuery = ("/subscriptions/{0}/resourcegroups/?api-version=2019-10-01" -f $subscriptionid)
   # $resourceGroups = (Query-Azure $resourceGroupQuery $token).Value.Where{$_.Tags.$tagName -eq $tagValue}
   # Write-Output ("Found {0} Host Pool Resource Groups in '{1}'" -f $resourceGroups.Count,$subscription.displayName)

    $logAnalyticsQuery = ("/subscriptions/{0}/providers/Microsoft.OperationalInsights/workspaces?api-version=2015-11-01-preview" -f $subscriptionid)
    $logAnalyticsWorkspace = (Query-Azure $logAnalyticsQuery $token).Value.Where{$_.name -eq $LAWName}

    <# $logAnalyticsWorkspace = (Query-Azure $logAnalyticsQuery $token).Value.Where{$_.Tags.$tagName -eq $tagValue}
    If ($logAnalyticsWorkspace.Count -gt 1) {
        Write-Warning ("Found {0} Log Analytics Workspaces in the {1} Subscription" -f $logAnalyticsWorkspace.Count,$subscription.displayName)
        Write-Warning ("Review the Azure Query and ensure only 1 Log Analytics Workspace is returned")
        Exit 1
    }#>

    If (!$logAnalyticsWorkspace) {
        Write-Warning ("Unable to find a Log Analytics Workspace: $LAWName")
        Exit 1
    }
    Else {
       # Write-Host ("-------> Log Analytics Workspace: {0}" -f $logAnalyticsWorkspace.Name)
       # Write-Host ("-------> Log Query: {0}" -f $logAnalyticsQuery) 
        $workspaceId = $logAnalyticsWorkspace.Id
        $workspaceRegion = $logAnalyticsWorkspace.Location
        $workspaceName = $logAnalyticsWorkspace.Name
    }
    
    foreach($resourceGroup in $resourceGroups) {
        $resourceGroupQuery = ("/subscriptions/{0}/resourcegroups/{1}?api-version=2021-04-01" -f $subscriptionid,$resourceGroup)  # Moved inside foreach
        $resourceGroup = Query-Azure $resourceGroupQuery $token       # Moved inside foreach


        Write-Output ("Working on '{0}' Resources" -f $resourceGroup.Name)
        $resourceGroupName = $resourceGroup.Name
        $wvdapi = '2019-12-10-preview'
        $hostPoolsQuery = ("/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DesktopVirtualization/hostPools?api-version={2}" -f $subscriptionid,$resourceGroupName,$wvdapi)
        $hostPools = (Query-Azure $hostPoolsQuery $token).Value
        
        If ($hostPools.Count -gt 0) {
            Write-Output ("Found {0} Host Pool(s) in {1} Resource Group" -f $hostPools.Count,$resourceGroupName)
        
            foreach ($hostPool in  $hostPools) {
                Write-Output ("Working on '{0}' Resources" -f $hostPool.Name)
                $poolName = $hostPool.Name
                # $workspaceRegion = $hostPool.Location
                
                Write-Output ("Querying Azure for AVD Resource data (Virtual Machines, Session Hosts, Sessions)")
                $sessionsquery = ("/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DesktopVirtualization/hostPools/{2}/userSessions?api-version={3}" -f $subscriptionid,$resourceGroupName,$poolName,$wvdapi)
                $hostsquery = ("/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DesktopVirtualization/hostPools/{2}/SessionHosts?api-version={3}" -f $subscriptionid,$resourceGroupName,$poolName,$wvdapi)
                $vmquery = ("/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Compute/virtualMachines?api-version=2020-06-01" -f $subscriptionid,$resourceGroupName)

                $sessions = (Query-Azure $sessionsquery $token).Value
                $hosts = (Query-Azure $hostsquery $token).Value
                $vms = (Query-Azure $vmquery $token).Value

                Write-Output ("Creating Azure Monitor Metric Definitions")
                [System.Collections.Generic.List[System.Object]]$metricDefinitions = @(
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Active Sessions"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = { ($sessions.properties | Where-Object {$_.sessionstate -eq "Active" -AND $_.userprincipalname -ne $null}).Count }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Disconnected Sessions"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = { ($sessions.properties | Where-Object {$_.sessionState -eq "Disconnected" -AND $_.userPrincipalName -ne $null}).Count }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Total Sessions"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = { ($sessions.properties | Where-Object {$_.userPrincipalName -ne $null}).Count }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Draining Hosts"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = { ($hosts.properties | Where-Object {$_.allowNewSession -eq $false}).Count }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Unhealthy Hosts"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = { ($hosts.properties | Where-Object {$_.allowNewSession -eq $true -AND $_.status -ne "Available"}).Count }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Healthy Hosts"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = { ($hosts.properties | Where-Object {$_.allowNewSession -eq $true -AND $_.status -eq "Available"}).Count }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Max Sessions in Pool"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = {
                            $healthyHosts = ($hosts.properties | Where-Object {$_.allowNewSession -eq $true -AND $_.status -eq "Available"}).Count
                            $healthyHosts * $hostpool.properties.maxSessionLimit
                        }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Available Sessions in Pool"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = {
                            $healthyHosts = ($hosts.properties | Where-Object {$_.allowNewSession -eq $true -AND $_.status -eq "Available"}).Count
                            $totalSessions = ($hosts.properties | Where-Object {$_.allowNewSession -eq $true -AND $_.status -eq "Available"} | Measure-Object -Property Sessions -Sum).Sum
                            $maxSessions = $healthyHosts * $hostpool.properties.maxSessionLimit
                            $maxSessions - $totalSessions
                        }        
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Session Load (%)"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = {
                            $healthyHosts = ($hosts.properties | Where-Object {$_.allowNewSession -eq $true -AND $_.status -eq "Available"}).Count
                            $totalSessions = ($hosts.properties | Where-Object {$_.allowNewSession -eq $true -AND $_.status -eq "Available"} | Measure-Object -Property Sessions -Sum).Sum
                            $maxSessions = $healthyHosts * $hostpool.properties.maxSessionLimit
                            If ($maxSessions -eq 0) { $maxSessions }
                            Else { [math]::Ceiling($totalSessions / $maxSessions * 100) }
                        }
                    },
                    [pscustomobject]@{
                        NameSpace = "AVD"
                        Metric = "Session Hosts in Maintenance"
                        Dimensions = "Workspace:$workspacename;Pool:$poolname"
                        Query = { ($vms.Tags | Where-Object {$_.'WVD-Maintenance' -eq $true}).Count }
                    }
                )

                Foreach ($metric in $metricDefinitions) {
                    Write-Output ("Publishing Metric: [{0}] - {1} ({2})" -f $metric.Namespace,$metric.Metric,$workspaceRegion)
                    $metricPosted = Publish-Metric $metric $sessions $hosts $vms $poolName $azmontoken $workspaceId $workspaceRegion
                    If ($metricPosted -eq $false) { Write-Warning ("Failed to Publish Metric: [{0}] - {1}" -f $metric.Namespace,$metric.Metric) }
                }
            }
        }
        Else { Write-Warning ("No Host Pools found in {0} Resource Group" -f $resourceGroupName) }
    }
# }