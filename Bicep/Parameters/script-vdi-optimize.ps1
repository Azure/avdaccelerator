
	$baseURI = "https://raw.githubusercontent.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/main/21H2/ConfigurationFiles"
    $fileList = @('AppxPackages.json','Autologgers.Json','DefaultUserSettings.json','LanManWorkstation.json','ScheduledTasks.json','Services.json')
    $outputPath = "C:\temp"

    if ((Test-Path $outputPath) -ne $true) { New-Item -ItemType Directory -Path $outputPath }

    foreach ($file in $fileList) {
        Invoke-WebRequest "$baseURI/$file" -OutFile "$outputPath\$file"
    }

 
        # All VDOT main function Event ID's [1-9]
        $EventSources = @('VDOT', 'WindowsMediaPlayer', 'AppxPackages', 'ScheduledTasks', 'DefaultUserSettings', 'Autologgers', 'Services', 'NetworkOptimizations', 'LGPO', 'DiskCleanup')
        New-EventLog -Source $EventSources -LogName 'Virtual Desktop Optimization'
        Limit-EventLog -OverflowAction OverWriteAsNeeded -MaximumSize 64KB -LogName 'Virtual Desktop Optimization'
        Write-EventLog -LogName 'Virtual Desktop Optimization' -Source 'VDOT' -EntryType Information -EventId 1 -Message "Log Created"
        Write-EventLog -LogName 'Virtual Desktop Optimization' -Source 'VDOT' -EntryType Information -EventId 1 -Message "Starting VDOT by $env:USERNAME with the following options:`n$($PSBoundParameters | Out-String)" 

    $WorkingLocation = (Join-Path $PSScriptRoot $WindowsVersion)

    try
    {
        Push-Location (Join-Path $PSScriptRoot $WindowsVersion)-ErrorAction Stop
    }
    catch
    {
        $Message = "Invalid Path $WorkingLocation - Exiting Script!"
        Write-EventLog -Message $Message -Source 'VDOT' -EventID 100 -EntryType Error -LogName 'Virtual Desktop Optimization'
        Write-Warning $Message
        Return
    }




    Set-Location $outputPath

    #region Disable, then remove, Windows Media Player including payload
        try
        {
            Write-EventLog -EventId 10 -Message "[VDI Optimize] Disable / Remove Windows Media Player" -LogName 'Virtual Desktop Optimization' -Source 'WindowsMediaPlayer' -EntryType Information 
            Write-Host "[VDI Optimize] Disable / Remove Windows Media Player" -ForegroundColor Cyan
            Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart | Out-Null
            Get-WindowsPackage -Online -PackageName "*Windows-mediaplayer*" | ForEach-Object { 
                Write-EventLog -EventId 10 -Message "Removing $($_.PackageName)" -LogName 'Virtual Desktop Optimization' -Source 'WindowsMediaPlayer' -EntryType Information 
                Remove-WindowsPackage -PackageName $_.PackageName -Online -ErrorAction SilentlyContinue -NoRestart | Out-Null
            }
        }
        catch 
        { 
            $msg = ($_ | Format-List | Out-String)
            Write-EventLog -EventId 110 -Message "Disabling / Removing Windows Media Player - $msg" -LogName 'Virtual Desktop Optimization' -Source 'WindowsMediaPlayer' -EntryType Error 
        }
    #endregion

    #region Begin Clean APPX Packages
        $AppxConfigFilePath = "$outputPath\AppxPackages.json"
        If (Test-Path $AppxConfigFilePath)
        {
            Write-EventLog -EventId 20 -Message "[VDI Optimize] Removing Appx Packages" -LogName 'Virtual Desktop Optimization' -Source 'AppxPackages' -EntryType Information 
            Write-Host "[VDI Optimize] Removing Appx Packages" -ForegroundColor Cyan
            $AppxPackage = (Get-Content $AppxConfigFilePath | ConvertFrom-Json).Where( { $_.VDIState -eq 'Disabled' })
            If ($AppxPackage.Count -gt 0)
            {
                Foreach ($Item in $AppxPackage)
                {
                    try
                    {                
                        Write-EventLog -EventId 20 -Message "Removing Provisioned Package $($Item.AppxPackage)" -LogName 'Virtual Desktop Optimization' -Source 'AppxPackages' -EntryType Information 
                        Write-Verbose "Removing Provisioned Package $($Item.AppxPackage)"
                        Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like ("*{0}*" -f $Item.AppxPackage) } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
                        
                        Write-EventLog -EventId 20 -Message "Attempting to remove [All Users] $($Item.AppxPackage) - $($Item.Description)" -LogName 'Virtual Desktop Optimization' -Source 'AppxPackages' -EntryType Information 
                        Write-Verbose "Attempting to remove [All Users] $($Item.AppxPackage) - $($Item.Description)"
                        Get-AppxPackage -AllUsers -Name ("*{0}*" -f $Item.AppxPackage) | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 
                        
                        Write-EventLog -EventId 20 -Message "Attempting to remove $($Item.AppxPackage) - $($Item.Description)" -LogName 'Virtual Desktop Optimization' -Source 'AppxPackages' -EntryType Information 
                        Write-Verbose "Attempting to remove $($Item.AppxPackage) - $($Item.Description)"
                        Get-AppxPackage -Name ("*{0}*" -f $Item.AppxPackage) | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
                    }
                    catch 
                    {
                        $msg = ($_ | Format-List | Out-String)
                        Write-EventLog -EventId 120 -Message "Failed to remove Appx Package $($Item.AppxPackage) - $msg" -LogName 'Virtual Desktop Optimization' -Source 'AppxPackages' -EntryType Error 
                        Write-Warning "Failed to remove Appx Package $($Item.AppxPackage) - $msg"
                    }
                }
            }
            Else 
            {
                Write-EventLog -EventId 20 -Message "No AppxPackages found to disable" -LogName 'Virtual Desktop Optimization' -Source 'AppxPackages' -EntryType Warning 
                Write-Warning "No AppxPackages found to disable in $AppxConfigFilePath"
            }
        }
    #endregion

    #region Disable Scheduled Tasks

    # This section is for disabling scheduled tasks.  If you find a task that should not be disabled
    # change its "VDIState" from Disabled to Enabled, or remove it from the json completely.
        $ScheduledTasksFilePath = "$outputPath\ScheduledTasks.json"
        If (Test-Path $ScheduledTasksFilePath)
        {
            Write-EventLog -EventId 30 -Message "[VDI Optimize] Disable Scheduled Tasks" -LogName 'Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Information 
            Write-Host "[VDI Optimize] Disable Scheduled Tasks" -ForegroundColor Cyan
            $SchTasksList = (Get-Content $ScheduledTasksFilePath | ConvertFrom-Json).Where( { $_.VDIState -eq 'Disabled' })
            If ($SchTasksList.count -gt 0)
            {
                Foreach ($Item in $SchTasksList)
                {
                    $TaskObject = Get-ScheduledTask $Item.ScheduledTask
                    If ($TaskObject -and $TaskObject.State -ne 'Disabled')
                    {
                        Write-EventLog -EventId 30 -Message "Attempting to disable Scheduled Task: $($TaskObject.TaskName)" -LogName 'Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Information 
                        Write-Verbose "Attempting to disable Scheduled Task: $($TaskObject.TaskName)"
                        try
                        {
                            Disable-ScheduledTask -InputObject $TaskObject | Out-Null
                            Write-EventLog -EventId 30 -Message "Disabled Scheduled Task: $($TaskObject.TaskName)" -LogName 'Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Information 
                        }
                        catch
                        {
                            $msg = ($_ | Format-List | Out-String)
                            Write-EventLog -EventId 130 -Message "Failed to disabled Scheduled Task: $($TaskObject.TaskName) - $msg" -LogName 'Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Error 
                        }
                    }
                    ElseIf ($TaskObject -and $TaskObject.State -eq 'Disabled') 
                    {
                        Write-EventLog -EventId 30 -Message "$($TaskObject.TaskName) Scheduled Task is already disabled" -LogName 'Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Warning
                    }
                    Else
                    {
                        Write-EventLog -EventId 130 -Message "Unable to find Scheduled Task: $($TaskObject.TaskName)" -LogName 'Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Error
                    }
                }
            }
            Else
            {
                Write-EventLog -EventId 30 -Message "No Scheduled Tasks found to disable" -LogName 'Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Warning
            }
        }
    #endregion

    #region Customize Default User Profile

    # Apply appearance customizations to default user registry hive, then close hive file
        $DefaultUserSettingsFilePath = "$outputPath\DefaultUserSettings.json"
        If (Test-Path $DefaultUserSettingsFilePath)
        {
            Write-EventLog -EventId 40 -Message "Set Default User Settings" -LogName 'Virtual Desktop Optimization' -Source 'VDOT' -EntryType Information
            Write-Host "[VDI Optimize] Set Default User Settings" -ForegroundColor Cyan
            $UserSettings = (Get-Content $DefaultUserSettingsFilePath | ConvertFrom-Json).Where( { $_.SetProperty -eq $true })
            If ($UserSettings.Count -gt 0)
            {
                Write-EventLog -EventId 40 -Message "Processing Default User Settings (Registry Keys)" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Information
                Write-Verbose "Processing Default User Settings (Registry Keys)"

                & REG LOAD HKLM\VDOT_TEMP C:\Users\Default\NTUSER.DAT | Out-Null

                Foreach ($Item in $UserSettings)
                {
                    If ($Item.PropertyType -eq "BINARY")
                    {
                        $Value = [byte[]]($Item.PropertyValue.Split(","))
                    }
                    Else
                    {
                        $Value = $Item.PropertyValue
                    }

                    If (Test-Path -Path ("{0}" -f $Item.HivePath))
                    {
                        Write-EventLog -EventId 40 -Message "Found $($Item.HivePath) - $($Item.KeyName)" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Information        
                        Write-Verbose "Found $($Item.HivePath) - $($Item.KeyName)"
                        If (Get-ItemProperty -Path ("{0}" -f $Item.HivePath) -ErrorAction SilentlyContinue)
                        {
                            try {
                                Write-EventLog -EventId 40 -Message "Set $($Item.HivePath) - $Value" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Information
                                Set-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -Value $Value -Force 
                            } catch {
                                $msg = ($_ | Format-List | Out-String)
                                Write-EventLog -EventId 30 -Message "Set failed for $($Item.HivePath) - $Value - $msg" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Error
                            }
                        }
                        Else
                        {
                            try {
                                Write-EventLog -EventId 40 -Message "New $($Item.HivePath) Name $($Item.KeyName) PropertyType $($Item.PropertyType) Value $Value" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Information
                                New-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -PropertyType $Item.PropertyType -Value $Value -Force | Out-Null
                            } catch {
                                $msg = ($_ | Format-List | Out-String)
                                Write-EventLog -EventId 30 -Message "Unable to create New $($Item.HivePath) Name $($Item.KeyName) PropertyType $($Item.PropertyType) Value $Value - $msg" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Error
                            }
                        }
                    }
                    Else
                    {
                        Write-EventLog -EventId 40 -Message "Registry Path not found $($Item.HivePath)" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Information
                        Write-EventLog -EventId 40 -Message "Creating new Registry Key $($Item.HivePath)" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Information
                        try {
                            $newKey = New-Item -Path ("{0}" -f $Item.HivePath) -Force
                            $newKey.Handle.Close()
                            New-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -PropertyType $Item.PropertyType -Value $Value -Force | Out-Null
                        } catch {
                            $msg = ($_ | Format-List | Out-String)
                            Write-EventLog -EventId 30 -Message "Error creating new Registry Key $($Item.HivePath): $msg" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Error
                        }
                    }
                }

                [gc]::Collect()
                & REG UNLOAD HKLM\VDOT_TEMP | Out-Null
            }
            Else
            {
                Write-EventLog -EventId 40 -Message "No Default User Settings to set" -LogName 'Virtual Desktop Optimization' -Source 'DefaultUserSettings' -EntryType Warning
            }
        }
    #endregion

    #region Disable Windows Traces
        $AutoLoggersFilePath = "$outputPath\Autologgers.Json"
        If (Test-Path $AutoLoggersFilePath)
        {
            Write-EventLog -EventId 50 -Message "Disable AutoLoggers" -LogName 'Virtual Desktop Optimization' -Source 'AutoLoggers' -EntryType Information
            Write-Host "[VDI Optimize] Disable Autologgers" -ForegroundColor Cyan
            $DisableAutologgers = (Get-Content $AutoLoggersFilePath | ConvertFrom-Json).Where( { $_.Disabled -eq 'True' })
            If ($DisableAutologgers.count -gt 0)
            {
                Write-EventLog -EventId 50 -Message "Disable AutoLoggers" -LogName 'Virtual Desktop Optimization' -Source 'AutoLoggers' -EntryType Information
                Write-Verbose "Processing Autologger Configuration File"
                Foreach ($Item in $DisableAutologgers)
                {
                    Write-EventLog -EventId 50 -Message "Updating Registry Key for: $($Item.KeyName)" -LogName 'Virtual Desktop Optimization' -Source 'AutoLoggers' -EntryType Information
                    Write-Verbose "Updating Registry Key for: $($Item.KeyName)"
                    Try 
                    {
                        New-ItemProperty -Path ("{0}" -f $Item.KeyName) -Name "Start" -PropertyType "DWORD" -Value 0 -Force -ErrorAction Stop | Out-Null
                    }
                    Catch
                    {
                        $msg = ($_ | Format-List | Out-String)
                        Write-EventLog -EventId 150 -Message "Failed to add $($Item.KeyName)`n`n $msg" -LogName 'Virtual Desktop Optimization' -Source 'AutoLoggers' -EntryType Error
                    }
                    
                }
            }
            Else 
            {
                Write-EventLog -EventId 50 -Message "No Autologgers found to disable" -LogName 'Virtual Desktop Optimization' -Source 'AutoLoggers' -EntryType Warning
                Write-Verbose "No Autologgers found to disable"
            }
        }
    #endregion

    #region Disable Services
        $ServicesFilePath = "$outputPath\Services.json"
        If (Test-Path $ServicesFilePath)
        {
            Write-EventLog -EventId 60 -Message "Disable Services" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Information
            Write-Host "[VDI Optimize] Disable Services" -ForegroundColor Cyan
            $ServicesToDisable = (Get-Content $ServicesFilePath | ConvertFrom-Json ).Where( { $_.VDIState -eq 'Disabled' })

            If ($ServicesToDisable.count -gt 0)
            {
                Write-EventLog -EventId 60 -Message "Processing Services Configuration File" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Information
                Write-Verbose "Processing Services Configuration File"
                Foreach ($Item in $ServicesToDisable)
                {
                    $service = Get-Service -Name $Item.name -ErrorAction SilentlyContinue
                    if ($null -ne $service){
                        if ($service.StartType -ne 'Disabled'){                        
                            Write-EventLog -EventId 60 -Message "Attempting to Stop Service $($Item.Name) - $($Item.Description)" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Information
                            Write-Verbose "Attempting to Stop Service $($Item.Name) - $($Item.Description)"
                            try
                            {
                                Stop-Service $Item.Name -Force
                            }
                            catch
                            {
                                $msg = ($_ | Format-List | Out-String)
                                Write-EventLog -EventId 160 -Message "Failed to disabled Service: $($Item.Name) `n $msg" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Error
                                Write-Warning "Failed to disabled Service: $($Item.Name) `n $msg"
                            }
                            Write-EventLog -EventId 60 -Message "Attempting to Disable Service $($Item.Name) - $($Item.Description)" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Information
                            Write-Verbose "Attempting to Disable Service $($Item.Name) - $($Item.Description)"
                            try {
                                Set-Service $Item.Name -StartupType Disabled 
                            } catch {
                                $msg = ($_ | Format-List | Out-String)
                                Write-EventLog -EventId 60 -Message "Unable to Disable Service $($Item.Name) - $($Item.Description) - $msg" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Error
                            }
                        } else {
                            Write-EventLog -EventId 60 -Message "Service was already disabled $($Item.Name) - $($Item.Description)" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Information
                            Write-Verbose "Service was already disabled $($Item.Name) - $($Item.Description)"
                        }
                    } else {
                        Write-EventLog -EventId 60 -Message "Unable to find Service $($Item.Name) - $($Item.Description)" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Warning
                        Write-Warning "Unable to find Service $($Item.Name) - $($Item.Description)"

                    }
                }
            }  
            Else
            {
                Write-EventLog -EventId 60 -Message "No Services found to disable" -LogName 'Virtual Desktop Optimization' -Source 'Services' -EntryType Warnnig
                Write-Verbose "No Services found to disable"
            }
        }
    #endregion

    #region Network Optimization
    # LanManWorkstation optimizations
        $NetworkOptimizationsFilePath = "$outputPath\LanManWorkstation.json"
        If (Test-Path $NetworkOptimizationsFilePath)
        {
            Write-EventLog -EventId 70 -Message "Configure LanManWorkstation Settings" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Information
            Write-Host "[VDI Optimize] Configure LanManWorkstation Settings" -ForegroundColor Cyan
            $LanManSettings = Get-Content $NetworkOptimizationsFilePath | ConvertFrom-Json
            If ($LanManSettings.Count -gt 0)
            {
                Write-EventLog -EventId 70 -Message "Processing LanManWorkstation Settings ($($LanManSettings.Count) Hives)" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Information
                Write-Verbose "Processing LanManWorkstation Settings ($($LanManSettings.Count) Hives)"
                Foreach ($Hive in $LanManSettings)
                {
                    If (Test-Path -Path $Hive.HivePath)
                    {
                        Write-EventLog -EventId 70 -Message "Found $($Hive.HivePath)" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Information
                        Write-Verbose "Found $($Hive.HivePath)"
                        $Keys = $Hive.Keys.Where{ $_.SetProperty -eq $true }
                        If ($Keys.Count -gt 0)
                        {
                            Write-EventLog -EventId 70 -Message "Create / Update LanManWorkstation Keys" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Information
                            Write-Verbose "Create / Update LanManWorkstation Keys"
                            Foreach ($Key in $Keys)
                            {
                                If (Get-ItemProperty -Path $Hive.HivePath -Name $Key.Name -ErrorAction SilentlyContinue)
                                {
                                    Write-EventLog -EventId 70 -Message "Setting $($Hive.HivePath) -Name $($Key.Name) -Value $($Key.PropertyValue)" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Information
                                    Write-Verbose "Setting $($Hive.HivePath) -Name $($Key.Name) -Value $($Key.PropertyValue)"
                                    try {
                                        Set-ItemProperty -Path $Hive.HivePath -Name $Key.Name -Value $Key.PropertyValue -Force
                                    } catch {
                                        $msg = ($_ | Format-List | Out-String)
                                        Write-EventLog -EventId 70 -Message "Error setting $($Hive.HivePath) -Name $($Key.Name) -Value $($Key.PropertyValue) $msg" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Error
                                    }
                                }
                                Else
                                {
                                    Write-EventLog -EventId 70 -Message "New $($Hive.HivePath) -Name $($Key.Name) -Value $($Key.PropertyValue)" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Information
                                    Write-Host "New $($Hive.HivePath) -Name $($Key.Name) -Value $($Key.PropertyValue)"
                                    try {
                                        New-ItemProperty -Path $Hive.HivePath -Name $Key.Name -PropertyType $Key.PropertyType -Value $Key.PropertyValue -Force | Out-Null
                                    } catch {
                                        $msg = ($_ | Format-List | Out-String)
                                        Write-EventLog -EventId 70 -Message "Error creating New $($Hive.HivePath) -Name $($Key.Name) -Value $($Key.PropertyValue) $msg" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Error
                                    }
                                }
                            }
                        }
                        Else
                        {
                            Write-EventLog -EventId 70 -Message "No LanManWorkstation Keys to create / update" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Warning
                            Write-Warning "No LanManWorkstation Keys to create / update"
                        }  
                    }
                    Else
                    {
                        Write-EventLog -EventId 70 -Message "Registry Path not found $($Hive.HivePath)" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Warning
                        Write-Warning "Registry Path not found $($Hive.HivePath)"
                    }
                }
            }
            Else
            {
                Write-EventLog -EventId 70 -Message "No LanManWorkstation Settings foun" -LogName 'Virtual Desktop Optimization' -Source 'NetworkOptimizations' -EntryType Warning
                Write-Warning "No LanManWorkstation Settings found"
            }
        }
    #endregion
     
    Remove-Item $outputPath -Recurse -Force
    
    ########################  END OF SCRIPT  ########################
