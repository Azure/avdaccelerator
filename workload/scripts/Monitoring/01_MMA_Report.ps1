
$subscription = "NameofSubscription"

Connect-AzAccount -Subscription $subscription 
Set-AzContext -Subscription $subscription


# Create Report Array
$report = @()
$reportName = "MMA_VMs.csv"

$VMs = Get-AzVM 
$WindowsVMs = $VMs | Where-Object  {$_.StorageProfile.OsDisk.OsType -eq "Windows" }
foreach ($VM in $WindowsVMs) {

    $ReportDetails = "" | Select Name, ResourceGroupName

    $extension = Get-AzVMExtension -ResourceGroupName $Vm.ResourceGroupName -Name $VM.Name

    if ($extension.Name -contains "MicrosoftMonitoringAgent") {
        #Write-Host "Microsoft Monitoring Agent is Installed on" $VM.Name "in the RG:" $VM.ResourceGroupName
        $ReportDetails.Name = $vm.Name 
        $ReportDetails.ResourceGroupName = $vm.ResourceGroupName 
        $report+=$ReportDetails 
        }
}

$report | ft -AutoSize Name, ResourceGroupName
 
#Change the path based on your convenience
$report | Export-CSV  "c:\temp\$reportName" –NoTypeInformation