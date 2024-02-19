

$PathToCsv = "C:\Temp\MMA_VMs.csv"
$computers = (Import-Csv -Path $PathToCsv).name

foreach ($vmName in $computers) { 
    $vmAzure = Get-AzVM -Name $vmName
    if ($vmAzure) {
        Write-Output "Removing MMA agent from $vmName"
        Remove-AzVMExtension -ResourceGroupName $vmAzure.ResourceGroupName -Name MicrosoftMonitoringAgent -VMName $vmAzure.Name -Force
    } 
    else {
        Write-Output "$vmName VM not found"
    }
}