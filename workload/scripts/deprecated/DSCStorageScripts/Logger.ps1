function Write-Log {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # note: can't use variable named '$Error': https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/AvoidAssignmentToAutomaticVariable.md
        [switch]$Err
    )
     
    try {
        $DateTime = Get-Date -Format "MM-dd-yy HH:mm:ss"
        $Invocation = "$($MyInvocation.MyCommand.Source):$($MyInvocation.ScriptLineNumber)"

        if ($Err) {
            $Message = "[ERROR] $Message"
        }
        
        Add-Content -Value "$DateTime - $Invocation - $Message" -Path "$([environment]::GetEnvironmentVariable('TEMP', 'Machine'))\ManualDscStorageScriptsLog.log"
    }
    catch {
        throw [System.Exception]::new("Some error occurred while writing to log file with message: $Message", $PSItem.Exception)
    }
}