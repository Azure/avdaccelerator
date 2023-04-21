[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string]$BeginPeakTime,

	[Parameter(Mandatory)]
	[string]$EndPeakTime,

	[Parameter(Mandatory)]
	[string]$EnvironmentName,

	[Parameter(Mandatory)]
	[string]$HostPoolName,

	[Parameter(Mandatory)]
	[int]$LimitSecondsToForceLogOffUser,

	[Parameter(Mandatory)]
	[string]$LogOffMessageBody,

	[Parameter(Mandatory)]
	[string]$LogOffMessageTitle,

	[Parameter(Mandatory)]
	[string]$MaintenanceTagName,

	[Parameter(Mandatory)]
	[int]$MinimumNumberOfRDSH,

	[Parameter(Mandatory)]
	[string]$ResourceGroupName,

	[Parameter(Mandatory)]
	[double]$SessionThresholdPerCPU,

	[Parameter(Mandatory)]
	[string]$TimeDifference
)

try
{
	[int]$StatusCheckTimeOut = (60 * 60) # 1 hr
	[string[]]$DesiredRunningStates = @('Available', 'NeedsAssistance')
	[string[]]$TimeDiffHrsMin = "$($TimeDifference):0".Split(':')


	#region helper/common functions, set exec policies, set TLS 1.2 security protocol, log rqt params
	# Function to return local time converted from UTC
	function Get-LocalDateTime
    {
		return (Get-Date).ToUniversalTime().AddHours($TimeDiffHrsMin[0]).AddMinutes($TimeDiffHrsMin[1])
	}

	function Write-Log 
    {
		# Note: this is required to support param such as ErrorAction
		[CmdletBinding()]
		param (
			[Parameter(Mandatory = $true)]
			[string]$Message,

			[switch]$Err,

			[switch]$Warn,

			[Parameter(Mandatory = $true)]
			[string]$HostPoolName
		)

		[string]$MessageTimeStamp = (Get-LocalDateTime).ToString('yyyy-MM-dd HH:mm:ss')
		$Message = "[$($MyInvocation.ScriptLineNumber)] [$($HostPoolName)] $Message"
		[string]$WriteMessage = "[$($MessageTimeStamp)] $Message"

		if ($Err)
        {
			Write-Error $WriteMessage
			$Message = "ERROR: $Message"
		}
		elseif ($Warn)
        {
			Write-Warning $WriteMessage
			$Message = "WARN: $Message"
		}
		else 
        {
			Write-Output $WriteMessage
		}
	}

	function Set-nVMsToStartOrStop 
    {
		param (
			[Parameter(Mandatory = $true)]
			[int]$nRunningVMs,
			
			[Parameter(Mandatory = $true)]
			[int]$nRunningCores,
			
			[Parameter(Mandatory = $true)]
			[int]$nUserSessions,

			[Parameter(Mandatory = $true)]
			[int]$MaxUserSessionsPerVM,
			
			[switch]$InPeakHours,
			
			[Parameter(Mandatory = $true)]
			[hashtable]$Res
		)

		# check if need to adjust min num of running session hosts required if the number of user sessions is close to the max allowed by the min num of running session hosts required
		[double]$MaxUserSessionsThreshold = 0.9
		[int]$MaxUserSessionsThresholdCapacity = [math]::Floor($MinimumNumberOfRDSH * $MaxUserSessionsPerVM * $MaxUserSessionsThreshold)
		if ($nUserSessions -gt $MaxUserSessionsThresholdCapacity)
        {
			$MinimumNumberOfRDSH = [math]::Ceiling($nUserSessions / ($MaxUserSessionsPerVM * $MaxUserSessionsThreshold))
			Write-Log -HostPoolName $HostPoolName -Message "Number of user sessions is more than $($MaxUserSessionsThreshold * 100) % of the max number of sessions allowed with minimum number of running session hosts required ($MaxUserSessionsThresholdCapacity). Adjusted minimum number of running session hosts required to $MinimumNumberOfRDSH"
		}

		# Check if minimum number of session hosts are running
		if ($nRunningVMs -lt $MinimumNumberOfRDSH)
        {
			$res.nVMsToStart = $MinimumNumberOfRDSH - $nRunningVMs
			Write-Log -HostPoolName $HostPoolName -Message "Number of running session host is less than minimum required. Need to start $($res.nVMsToStart) VMs"
		}
		
		if ($InPeakHours)
        {
			[double]$nUserSessionsPerCore = $nUserSessions / $nRunningCores
			# In peak hours: check if current capacity is meeting the user demands
			if ($nUserSessionsPerCore -gt $SessionThresholdPerCPU)
            {
				$res.nCoresToStart = [math]::Ceiling(($nUserSessions / $SessionThresholdPerCPU) - $nRunningCores)
				Write-Log -HostPoolName $HostPoolName -Message "[In peak hours] Number of user sessions per Core is more than the threshold. Need to start $($res.nCoresToStart) cores"
			}

			return
		}

		if ($nRunningVMs -gt $MinimumNumberOfRDSH)
        {
			# Calculate the number of session hosts to stop
			$res.nVMsToStop = $nRunningVMs - $MinimumNumberOfRDSH
			Write-Log -HostPoolName $HostPoolName -Message "[Off peak hours] Number of running session host is greater than minimum required. Need to stop $($res.nVMsToStop) VMs"
		}
	}

	# Function to wait for background jobs
	function Wait-ForJobs 
    {
		param ([array]$Jobs = @())

		Write-Log -HostPoolName $HostPoolName -Message "Wait for $($Jobs.Count) jobs"
		$StartTime = Get-Date
		[string]$StatusInfo = ''
		while ($true) 
        {
			if ((Get-Date).Subtract($StartTime).TotalSeconds -ge $StatusCheckTimeOut)
            {
				throw "Jobs status check timed out. Taking more than $StatusCheckTimeOut seconds. $StatusInfo"
			}
			$StatusInfo = "[Check jobs status] Total: $($Jobs.Count), $(($Jobs | Group-Object State | ForEach-Object { "$($_.Name): $($_.Count)" }) -join ', ')"
			Write-Log -HostPoolName $HostPoolName -Message $StatusInfo 
			if (!($Jobs | Where-Object { $_.State -ieq 'Running' }))
            {
				break
			}
			Start-Sleep -Seconds 30
		}

		[array]$IncompleteJobs = @($Jobs | Where-Object { $_.State -ine 'Completed' })
		if ($IncompleteJobs)
        {
			throw "$($IncompleteJobs.Count)/$($Jobs.Count) jobs did not complete successfully: $($IncompleteJobs | Format-List -Force | Out-String)"
		}
	}

	function Get-SessionHostName
    {
		param (
			[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
			$SessionHost
		)

		return $SessionHost.Name.Split('/')[-1]
	}

	function TryUpdateSessionHostDrainMode
    {
		[CmdletBinding(SupportsShouldProcess)]
		param (
			[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
			[hashtable]$VM,

			[switch]$AllowNewSession
		)
		Begin { }
		Process 
        {
			$SessionHost = $VM.SessionHost
			if ($SessionHost.AllowNewSession -eq $AllowNewSession)
            {
				return
			}
			
			[string]$SessionHostName = $VM.SessionHostName
			Write-Log -HostPoolName $HostPoolName -Message "Update session host '$SessionHostName' to set allow new sessions to $AllowNewSession"
			if ($PSCmdlet.ShouldProcess($SessionHostName, "Update session host to set allow new sessions to $AllowNewSession"))
            {
				try 
				{
					$SessionHost = $VM.SessionHost = Update-AzWvdSessionHost -ResourceGroupName $ResourceGroupName -Name $SessionHostName -AllowNewSession:$AllowNewSession

					if ($SessionHost.AllowNewSession -ne $AllowNewSession) 
					{
						throw $SessionHost
					}
				}
				catch 
				{
					Write-Log -HostPoolName $HostPoolName -Warn -Message "Failed to update the session host '$SessionHostName' to set allow new sessions to $($AllowNewSession): $($PSItem | Format-List -Force | Out-String)"
				}
			}
		}
		End { }
	}

	function TryForceLogOffUser
    {
		[CmdletBinding(SupportsShouldProcess)]
		param (
			[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
			$Session
		)
		Begin { }
		Process
        {
            [string[]]$Toks = $Session.Name.Split('/')
            [string]$SessionHostName = $Toks[1]
            [string]$SessionID = $Toks[-1]
            [string]$User = $Session.ActiveDirectoryUserName

			try 
			{
				Write-Log -HostPoolName $HostPoolName -Message "Force log off user: '$User', session ID: $SessionID"
				if ($PSCmdlet.ShouldProcess($SessionID, 'Force log off user with session ID'))
				{
					# Note: -SessionHostName param is case sensitive, so the command will fail if it's case is modified
					Remove-AzWvdUserSession -ResourceGroupName $ResourceGroupName -SessionHostName $SessionHostName -Id $SessionID -Force
				}
			}
			catch 
			{
				Write-Log -HostPoolName $HostPoolName -Warn -Message "Failed to force log off user: '$User', session ID: $SessionID $($PSItem | Format-List -Force | Out-String)"
			}
		}
		End { }
	}

	function TryResetSessionHostDrainModeAndUserSessions
    {
		[CmdletBinding(SupportsShouldProcess)]
		param (
			[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
			[hashtable]$VM
		)
		Begin { }
		Process 
        {
			TryUpdateSessionHostDrainMode -VM $VM -AllowNewSession:$true
			
			$SessionHost = $VM.SessionHost
			[string]$SessionHostName = $VM.SessionHostName
			if (!$SessionHost.Session)
            {
				return
			}

			Write-Log -HostPoolName $HostPoolName -Warn -Message "Session host '$SessionHostName' still has $($SessionHost.Session) sessions left behind in broker DB"

			[array]$UserSessions = @()
			Write-Log -HostPoolName $HostPoolName -Message "Get all user sessions from session host '$SessionHostName'"
			try 
			{
				$UserSessions = @(Get-AzWvdUserSession -ResourceGroupName $ResourceGroupName -SessionHostName $SessionHostName)
			}
			catch 
			{
				Write-Log -HostPoolName $HostPoolName -Warn -Message "Failed to retrieve user sessions of session host '$SessionHostName': $($PSItem | Format-List -Force | Out-String)"
				return
			}

			Write-Log -HostPoolName $HostPoolName -Message "Force log off $($UserSessions.Count) users on session host: '$SessionHostName'"
			$UserSessions | TryForceLogOffUser
		}
		End { }
	}

	Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force -Confirm:$false
	if (!$SkipAuth)
    {
		# Note: this requires admin priviledges
		Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -Confirm:$false
	}

	# Note: https://stackoverflow.com/questions/41674518/powershell-setting-security-protocol-to-tls-1-2
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	Write-Log -HostPoolName $HostPoolName -Message "Request params: $($RqtParams | Format-List -Force | Out-String)"
	#endregion


	#region azure auth, ctx
    # Azure auth
    $AzContext = $null
    try
    {
        $AzAuth = Connect-AzAccount -Environment $EnvironmentName -Identity
        if (!$AzAuth -or !$AzAuth.Context) {
            throw $AzAuth
        }
        $AzContext = $AzAuth.Context
    }
    catch
    {
        throw [System.Exception]::new('Failed to authenticate Azure with application ID, tenant ID, subscription ID', $PSItem.Exception)
    }
    Write-Log -HostPoolName $HostPoolName -Message "Successfully authenticated with Azure using service principal: $($AzContext | Format-List -Force | Out-String)"
	#endregion


	#region validate host pool, validate / update HostPool load balancer type, ensure there is at least 1 session host, get num of user sessions
	# Validate and get HostPool info
	$HostPool = $null
	try 
	{
		Write-Log -HostPoolName $HostPoolName -Message "Get Hostpool info of '$HostPoolName' in resource group '$ResourceGroupName'"
		$HostPool = Get-AzWvdHostPool -ResourceGroupName $ResourceGroupName -Name $HostPoolName

		if (!$HostPool) 
		{
			throw $HostPool
		}
	}
	catch 
	{
		throw [System.Exception]::new("Failed to get Hostpool info of '$HostPoolName' in resource group '$ResourceGroupName'. Ensure that you have entered the correct values", $PSItem.Exception)
	}

	# Ensure HostPool load balancer type is not persistent
	if ($HostPool.LoadBalancerType -ieq 'Persistent')
    {
		throw "HostPool '$HostPoolName' is configured with 'Persistent' load balancer type. Scaling tool only supports these load balancer types: BreadthFirst, DepthFirst"
	}

	Write-Log -HostPoolName $HostPoolName -Message 'Get all session hosts'

	$SessionHosts = @(Get-AzWvdSessionHost -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName)

	if (!$SessionHosts)
    {
		Write-Log -HostPoolName $HostPoolName -Message "There are no session hosts in the Hostpool '$HostPoolName'. Ensure that hostpool has session hosts"
		Write-Log -HostPoolName $HostPoolName -Message 'End'
		return
	}

	Write-Log -HostPoolName $HostPoolName -Message 'Get number of user sessions in Hostpool'

	[int]$nUserSessions = @(Get-AzWvdUserSession -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName).Count

	# Set up breadth 1st load balacing type
	# Note: breadth 1st is enforced on AND off peak hours to simplify the things with scaling in the start/end of peak hours
	if (!$SkipUpdateLoadBalancerType -and $HostPool.LoadBalancerType -ine 'BreadthFirst')
    {
		Write-Log -HostPoolName $HostPoolName -Message "Update HostPool with 'BreadthFirst' load balancer type (current: '$($HostPool.LoadBalancerType)')"
		if ($PSCmdlet.ShouldProcess($HostPoolName, "Update HostPool with BreadthFirstLoadBalancer type (current: '$($HostPool.LoadBalancerType)')"))
        {
			$HostPool = Update-AzWvdHostPool -ResourceGroupName $ResourceGroupName -Name $HostPoolName -LoadBalancerType 'BreadthFirst'
		}
	}

	Write-Log -HostPoolName $HostPoolName -Message "HostPool info: $($HostPool | Format-List -Force | Out-String)"
	Write-Log -HostPoolName $HostPoolName -Message "Number of session hosts in the HostPool: $($SessionHosts.Count)"
	#endregion
	

	#region determine if on/off peak hours
	# Convert local time, begin peak time & end peak time from UTC to local time
	$CurrentDateTime = Get-LocalDateTime
	$BeginPeakDateTime = [datetime]::Parse($CurrentDateTime.ToShortDateString() + ' ' + $BeginPeakTime)
	$EndPeakDateTime = [datetime]::Parse($CurrentDateTime.ToShortDateString() + ' ' + $EndPeakTime)

	# Adjust peak times to make sure begin peak time is always before end peak time
	if ($EndPeakDateTime -lt $BeginPeakDateTime)
    {
		if ($CurrentDateTime -lt $EndPeakDateTime)
        {
			$BeginPeakDateTime = $BeginPeakDateTime.AddDays(-1)
		}
		else
        {
			$EndPeakDateTime = $EndPeakDateTime.AddDays(1)
		}
	}

	Write-Log -HostPoolName $HostPoolName -Message "Using current time: $($CurrentDateTime.ToString('yyyy-MM-dd HH:mm:ss')), begin peak time: $($BeginPeakDateTime.ToString('yyyy-MM-dd HH:mm:ss')), end peak time: $($EndPeakDateTime.ToString('yyyy-MM-dd HH:mm:ss'))"

	[bool]$InPeakHours = ($BeginPeakDateTime -le $CurrentDateTime -and $CurrentDateTime -le $EndPeakDateTime)
	if ($InPeakHours)
    {
		Write-Log -HostPoolName $HostPoolName -Message 'In peak hours'
	}
	else
    {
		Write-Log -HostPoolName $HostPoolName -Message 'Off peak hours'
	}
	#endregion


	#region get all session hosts, VMs & user sessions info and compute workload
	# Note: session host is considered "running" if its running AND is in desired states AND allowing new sessions
	# Number of session hosts that are running, are in desired states and allowing new sessions
	[int]$nRunningVMs = 0
	# Number of cores that are running, are in desired states and allowing new sessions
	[int]$nRunningCores = 0
	# Object that contains all session host objects, VM instance objects except the ones that are under maintenance
	$VMs = @{ }
	# Object that contains the number of cores for each VM size SKU
	$VMSizeCores = @{ }
	# Number of user sessions reported by each session host that is running, is in desired state and allowing new sessions
	[int]$nUserSessionsFromAllRunningVMs = 0

	# Populate all session hosts objects
	foreach ($SessionHost in $SessionHosts)
    {
		[string]$SessionHostName = Get-SessionHostName -SessionHost $SessionHost
		$VMs.Add($SessionHostName.Split('.')[0].ToLower(), @{ 'SessionHostName' = $SessionHostName; 'SessionHost' = $SessionHost; 'Instance' = $null })
	}
	
	Write-Log -HostPoolName $HostPoolName -Message 'Get all VMs, check session host status and get usage info'
	foreach ($VMInstance in (Get-AzVM -Status))
    {
		if (!$VMs.ContainsKey($VMInstance.Name.ToLower()))
        {
			# This VM is not a WVD session host
			continue
		}
		[string]$VMName = $VMInstance.Name.ToLower()
		if ($VMInstance.Tags.Keys -contains $MaintenanceTagName)
        {
			Write-Log -HostPoolName $HostPoolName -Message "VM '$VMName' is in maintenance and will be ignored"
			$VMs.Remove($VMName)
			continue
		}

		$VM = $VMs[$VMName]
		$SessionHost = $VM.SessionHost
        if (($SessionHost.VirtualMachineId) -and $VMInstance.VmId -ine $SessionHost.VirtualMachineId)
        {
            # This VM is not a WVD session host
            continue
        }

		if ($VM.Instance)
        {
			throw "More than 1 VM found in Azure with same session host name '$($VM.SessionHostName)' (This is not supported): $($VMInstance | Format-List -Force | Out-String)$($VM.Instance | Format-List -Force | Out-String)"
		}

		$VM.Instance = $VMInstance

		Write-Log -HostPoolName $HostPoolName -Message "Session host: '$($VM.SessionHostName)', power state: '$($VMInstance.PowerState)', status: '$($SessionHost.Status)', update state: '$($SessionHost.UpdateState)', sessions: $($SessionHost.Session), allow new session: $($SessionHost.AllowNewSession)"
		# Check if we know how many cores are in this VM
		if (!$VMSizeCores.ContainsKey($VMInstance.HardwareProfile.VmSize))
        {
			Write-Log -HostPoolName $HostPoolName -Message "Get all VM sizes in location: $($VMInstance.Location)"
			foreach ($VMSize in (Get-AzVMSize -Location $VMInstance.Location))
            {
				if (!$VMSizeCores.ContainsKey($VMSize.Name))
                {
					$VMSizeCores.Add($VMSize.Name, $VMSize.NumberOfCores)
				}
			}
		}

		if ($VMInstance.PowerState -ieq 'VM running')
        {
			if ($SessionHost.Status -notin $DesiredRunningStates)
            {
				Write-Log -HostPoolName $HostPoolName -Warn -Message 'VM is in running state but session host is not and so it will be ignored (this could be because the VM was just started and has not connected to broker yet)'
			}
			if (!$SessionHost.AllowNewSession)
            {
				Write-Log -HostPoolName $HostPoolName -Warn -Message 'VM is in running state but session host is not allowing new sessions and so it will be ignored'
			}

			if ($SessionHost.Status -in $DesiredRunningStates -and $SessionHost.AllowNewSession)
            {
				++$nRunningVMs
				$nRunningCores += $VMSizeCores[$VMInstance.HardwareProfile.VmSize]
				$nUserSessionsFromAllRunningVMs += $SessionHost.Session
			}
		}
		else 
        {
			if ($SessionHost.Status -in $DesiredRunningStates)
            {
				Write-Log -HostPoolName $HostPoolName -Warn -Message "VM is not in running state but session host is (this could be because the VM was just stopped and broker doesn't know that yet)"
			}
		}
	}

	if ($nUserSessionsFromAllRunningVMs -ne $nUserSessions)
    {
		Write-Log -HostPoolName $HostPoolName -Warn -Message "Sum of user sessions reported by every running session host ($nUserSessionsFromAllRunningVMs) is not equal to the total number of user sessions reported by the host pool ($nUserSessions)"
	}

	$nUserSessions = $nUserSessionsFromAllRunningVMs
	# Check if we need to override the number of user sessions for simulation / testing purpose
	if ($null -ne $OverrideNUserSessions)
    {
		$nUserSessions = $OverrideNUserSessions
	}

	# Make sure VM instance was found in Azure for every session host
	[int]$nVMsWithoutInstance = @($VMs.Values | Where-Object { !$_.Instance }).Count
	if ($nVMsWithoutInstance)
    {
		throw "There are $nVMsWithoutInstance/$($VMs.Count) session hosts whose VM instance was not found in Azure"
	}

	if (!$nRunningCores)
    {
		$nRunningCores = 1
	}

	Write-Log -HostPoolName $HostPoolName -Message "Number of running session hosts: $nRunningVMs of total $($VMs.Count)"
	Write-Log -HostPoolName $HostPoolName -Message "Number of user sessions: $nUserSessions of total allowed $($nRunningVMs * $HostPool.MaxSessionLimit)"
	Write-Log -HostPoolName $HostPoolName -Message "Number of user sessions per Core: $($nUserSessions / $nRunningCores), threshold: $SessionThresholdPerCPU"
	Write-Log -HostPoolName $HostPoolName -Message "Minimum number of running session hosts required: $MinimumNumberOfRDSH"

	# Check if minimum num of running session hosts required is higher than max allowed
	if ($VMs.Count -le $MinimumNumberOfRDSH)
    {
		Write-Log -HostPoolName $HostPoolName -Warn -Message 'Minimum number of RDSH is set higher than or equal to total number of session hosts'
	}
	#endregion


	#region determine number of session hosts to start/stop if any
	# Now that we have all the info about the session hosts & their usage, figure how many session hosts to start/stop depending on in/off peak hours and the demand [Ops = operations to perform]
	$Ops = @{
		nVMsToStart   = 0
		nCoresToStart = 0
		nVMsToStop    = 0
	}

	Set-nVMsToStartOrStop -nRunningVMs $nRunningVMs -nRunningCores $nRunningCores -nUserSessions $nUserSessions -MaxUserSessionsPerVM $HostPool.MaxSessionLimit -InPeakHours:$InPeakHours -Res $Ops
	#endregion


	#region start any session hosts if need to
	# Check if we have any session hosts to start
	if ($Ops.nVMsToStart -or $Ops.nCoresToStart)
    {
		if ($nRunningVMs -eq $VMs.Count)
        {
			Write-Log -HostPoolName $HostPoolName -Message 'All session hosts are running'
			Write-Log -HostPoolName $HostPoolName -Message 'End'
			return
		}

		# Object that contains names of session hosts that will be started
		# $StartSessionHostFullNames = @{ }
		# Array that contains jobs of starting the session hosts
		[array]$StartVMjobs = @()

		Write-Log -HostPoolName $HostPoolName -Message 'Find session hosts that are stopped and allowing new sessions'
		foreach ($VM in $VMs.Values)
        {
			if (!$Ops.nVMsToStart -and !$Ops.nCoresToStart)
            {
				# Done with starting session hosts that needed to be
				break
			}
			if ($VM.Instance.PowerState -ieq 'VM running')
            {
				continue
			}
			if ($VM.SessionHost.UpdateState -ine 'Succeeded')
            {
				Write-Log -HostPoolName $HostPoolName -Warn -Message "Session host '$($VM.SessionHostName)' may not be healthy"
			}

			[string]$SessionHostName = $VM.SessionHostName

			if (!$VM.SessionHost.AllowNewSession)
            {
				Write-Log -HostPoolName $HostPoolName -Warn -Message "Session host '$SessionHostName' is not allowing new sessions and so it will not be started"
				continue
			}

			Write-Log -HostPoolName $HostPoolName -Message "Start session host '$SessionHostName' as a background job"
			if ($PSCmdlet.ShouldProcess($SessionHostName, 'Start session host as a background job'))
            {
				# $StartSessionHostFullNames.Add($VM.SessionHost.Name, $null)
				$StartVMjobs += ($VM.Instance | Start-AzVM -AsJob)
			}

			--$Ops.nVMsToStart
			if ($Ops.nVMsToStart -lt 0)
            {
				$Ops.nVMsToStart = 0
			}

			$Ops.nCoresToStart -= $VMSizeCores[$VM.Instance.HardwareProfile.VmSize]
			if ($Ops.nCoresToStart -lt 0)
            {
				$Ops.nCoresToStart = 0
			}
		}

		# Check if there were enough number of session hosts to start
		if ($Ops.nVMsToStart -or $Ops.nCoresToStart)
        {
			Write-Log -HostPoolName $HostPoolName -Warn -Message "Not enough session hosts to start. Still need to start maximum of either $($Ops.nVMsToStart) VMs or $($Ops.nCoresToStart) cores"
		}

		# Wait for those jobs to start the session hosts
		Wait-ForJobs $StartVMjobs

		Write-Log -HostPoolName $HostPoolName -Message 'All jobs completed'
		Write-Log -HostPoolName $HostPoolName -Message 'End'
		return
	}
	#endregion


	#region stop any session hosts if need to
	if (!$Ops.nVMsToStop)
    {
		Write-Log -HostPoolName $HostPoolName -Message 'No need to start/stop any session hosts'
		Write-Log -HostPoolName $HostPoolName -Message 'End'
		return
	}

	# Object that contains names of session hosts that will be stopped
	# $StopSessionHostFullNames = @{ }
	# Array that contains jobs of stopping the session hosts
	[array]$StopVMjobs = @()
	$VMsToStop = @{ }
	[array]$VMsToStopAfterLogOffTimeOut = @()

	Write-Log -HostPoolName $HostPoolName -Message 'Find session hosts that are running and allowing new sessions, sort them by number of user sessions'
	foreach ($VM in ($VMs.Values | Where-Object { $_.Instance.PowerState -ieq 'VM running' -and $_.SessionHost.AllowNewSession } | Sort-Object { $_.SessionHost.Session }))
    {
		if (!$Ops.nVMsToStop)
        {
			# Done with stopping session hosts that needed to be
			break
		}
		$SessionHost = $VM.SessionHost
		[string]$SessionHostName = $VM.SessionHostName
		
		if ($SessionHost.Session -and !$LimitSecondsToForceLogOffUser)
        {
			Write-Log -HostPoolName $HostPoolName -Warn -Message "Session host '$SessionHostName' has $($SessionHost.Session) sessions but limit seconds to force log off user is set to 0, so will not stop any more session hosts (https://aka.ms/wvdscale#how-the-scaling-tool-works)"
			# Note: why break ? Because the list this loop iterates through is sorted by number of sessions, if it hits this, the rest of items in the loop will also hit this
			break
		}

		TryUpdateSessionHostDrainMode -VM $VM -AllowNewSession:$false
		$SessionHost = $VM.SessionHost

		# Note: check if there were new user sessions since session host info was 1st fetched
		if ($SessionHost.Session -and !$LimitSecondsToForceLogOffUser)
        {
			Write-Log -HostPoolName $HostPoolName -Warn -Message "Session host '$SessionHostName' has $($SessionHost.Session) sessions but limit seconds to force log off user is set to 0, so will not stop any more session hosts (https://aka.ms/wvdscale#how-the-scaling-tool-works)"
			TryUpdateSessionHostDrainMode -VM $VM -AllowNewSession:$true
			$SessionHost = $VM.SessionHost
			continue
		}

		if ($SessionHost.Session)
        {
			[array]$VM.UserSessions = @()
			Write-Log -HostPoolName $HostPoolName -Message "Get all user sessions from session host '$SessionHostName'"
			try 
			{
				# Note: Get-AzWvdUserSession roundtrips the input param SessionHostName and its case, so if lower case is specified, command will return lower case as well
				$VM.UserSessions = @(Get-AzWvdUserSession -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName -SessionHostName $SessionHostName)
			}
			catch 
			{
				Write-Log -HostPoolName $HostPoolName -Warn -Message "Failed to retrieve user sessions of session host '$SessionHostName': $($PSItem | Format-List -Force | Out-String)"
			}

			Write-Log -HostPoolName $HostPoolName -Message "Send log off message to active user sessions on session host: '$SessionHostName'"
			foreach ($Session in $VM.UserSessions) 
            {
				if($Session.SessionState -ine 'Active')
                {
					continue
				}

				[string]$SessionID = $Session.Name.Split('/')[-1]
				[string]$User = $Session.ActiveDirectoryUserName
				
				try 
                {
					Write-Log -HostPoolName $HostPoolName -Message "Send a log off message to user: '$User', session ID: $SessionID"
					if ($PSCmdlet.ShouldProcess($SessionID, 'Send a log off message to user with session ID'))
                    {
						# Note: -SessionHostName param is case sensitive, so the command will fail if it's case is modified
						Send-AzWvdUserSessionMessage -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName -SessionHostName $SessionHostName -UserSessionId $SessionID -MessageTitle $LogOffMessageTitle -MessageBody "$LogOffMessageBody You will be logged off in $LimitSecondsToForceLogOffUser seconds"
					}
				}
				catch 
				{
					Write-Log -HostPoolName $HostPoolName -Warn -Message "Failed to send a log off message to user: '$User', session ID: $SessionID $($PSItem | Format-List -Force | Out-String)"
				}
			}
			$VMsToStopAfterLogOffTimeOut += $VM
		}
		else
        {
			Write-Log -HostPoolName $HostPoolName -Message "Stop session host '$SessionHostName' as a background job"
			if ($PSCmdlet.ShouldProcess($SessionHostName, 'Stop session host as a background job'))
            {
				# $StopSessionHostFullNames.Add($SessionHost.Name, $null)
				$StopVMjobs += ($VM.StopJob = $VM.Instance | Stop-AzVM -Force -AsJob)
				$VMsToStop.Add($SessionHostName, $VM)
			}
		}

		--$Ops.nVMsToStop
		if ($Ops.nVMsToStop -lt 0) {
			$Ops.nVMsToStop = 0
		}
	}

	if ($VMsToStopAfterLogOffTimeOut)
    {
		Write-Log -HostPoolName $HostPoolName -Message "Wait $LimitSecondsToForceLogOffUser seconds for users to log off"
		if ($PSCmdlet.ShouldProcess("for $LimitSecondsToForceLogOffUser seconds", 'Wait for users to log off'))
        {
			Start-Sleep -Seconds $LimitSecondsToForceLogOffUser
		}

		Write-Log -HostPoolName $HostPoolName -Message "Force log off users and stop remaining $($VMsToStopAfterLogOffTimeOut.Count) session hosts"
		foreach ($VM in $VMsToStopAfterLogOffTimeOut)
        {
			[string]$SessionHostName = $VM.SessionHostName

			Write-Log -HostPoolName $HostPoolName -Message "Force log off $($VM.UserSessions.Count) users on session host: '$SessionHostName'"
			$VM.UserSessions | TryForceLogOffUser
			
			Write-Log -HostPoolName $HostPoolName -Message "Stop session host '$SessionHostName' as a background job"
			if ($PSCmdlet.ShouldProcess($SessionHostName, 'Stop session host as a background job'))
            {
				# $StopSessionHostFullNames.Add($VM.SessionHost.Name, $null)
				$StopVMjobs += ($VM.StopJob = $VM.Instance | Stop-AzVM -Force -AsJob)
				$VMsToStop.Add($SessionHostName, $VM)
			}
		}
	}

	# Check if there were enough number of session hosts to stop
	if ($Ops.nVMsToStop)
    {
		Write-Log -HostPoolName $HostPoolName -Warn -Message "Not enough session hosts to stop. Still need to stop $($Ops.nVMsToStop) VMs"
	}

	# Wait for those jobs to stop the session hosts
	Write-Log -HostPoolName $HostPoolName -Message "Wait for $($StopVMjobs.Count) jobs"
	$StartTime = Get-Date
	while ($true)
    {
		if ((Get-Date).Subtract($StartTime).TotalSeconds -ge $StatusCheckTimeOut)
        {
			break
		}
		if (!($StopVMjobs | Where-Object { $_.State -ieq 'Running' }))
        {
			break
		}
		
		Write-Log -HostPoolName $HostPoolName -Message "[Check jobs status] Total: $($StopVMjobs.Count), $(($StopVMjobs | Group-Object State | ForEach-Object { "$($_.Name): $($_.Count)" }) -join ', ')"
		
		$VMstoResetDrainModeAndSessions = @($VMsToStop.Values | Where-Object { $_.StopJob.State -ine 'Running' })
		foreach ($VM in $VMstoResetDrainModeAndSessions)
        {
			TryResetSessionHostDrainModeAndUserSessions -VM $VM
			$VMsToStop.Remove($VM.SessionHostName)
		}
		if (!$VMstoResetDrainModeAndSessions)
        {
			Start-Sleep -Seconds 30
		}
	}

	[string]$StopVMJobsStatusInfo = "[Check jobs status] Total: $($StopVMjobs.Count), $(($StopVMjobs | Group-Object State | ForEach-Object { "$($_.Name): $($_.Count)" }) -join ', ')"
	Write-Log -HostPoolName $HostPoolName -Message $StopVMJobsStatusInfo

	$VMsToStop.Values | TryResetSessionHostDrainModeAndUserSessions

	if ((Get-Date).Subtract($StartTime).TotalSeconds -ge $StatusCheckTimeOut)
    {
		throw "Jobs status check timed out. Taking more than $StatusCheckTimeOut seconds. $StopVMJobsStatusInfo"
	}

	[array]$IncompleteJobs = @($StopVMjobs | Where-Object { $_.State -ine 'Completed' })
	if ($IncompleteJobs)
    {
		throw "$($IncompleteJobs.Count)/$($StopVMjobs.Count) jobs did not complete successfully: $($IncompleteJobs | Format-List -Force | Out-String)"
	}

	Write-Log -HostPoolName $HostPoolName -Message 'All jobs completed'
	Write-Log -HostPoolName $HostPoolName -Message 'End'
	return
	#endregion
}
catch 
{
	$ErrContainer = $PSItem
	# $ErrContainer = $_

	[string]$ErrMsg = $ErrContainer | Format-List -Force | Out-String
	$ErrMsg += "Version: $Version`n"

	if (Get-Command 'Write-Log' -ErrorAction:SilentlyContinue)
    {
		Write-Log -HostPoolName $HostPoolName -Err -Message $ErrMsg -ErrorAction:Continue
	}
	else
    {
		Write-Error $ErrMsg -ErrorAction:Continue
	}

	throw [System.Exception]::new($ErrMsg, $ErrContainer.Exception)
}