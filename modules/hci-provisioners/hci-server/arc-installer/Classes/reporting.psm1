<#
.SYNOPSIS
    Common Reporting functions across all modules/scenarios
.DESCRIPTION
    Logging, Reporting
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

function Set-AzStackHciOutputPath
{

    param ($Path, $Source='azshciarc/Diagnostic')
    if ([string]::IsNullOrEmpty($Path))
    {
        $Path = Join-Path -Path $HOME -ChildPath ".AzStackHci"
    }
    $Global:AzStackHciEnvironmentLogFile = Join-Path -Path $Path -ChildPath 'AzStackHciArcIntegration.log'
    Assert-EventLog -source $Source
    Set-AzStackHciIdentifier
}




function Log-Info
{
    <#
    .SYNOPSIS
        Write verbose logging to disk
    .DESCRIPTION
        Formats and writes verbose logging to disk under scriptroot.  Log type (or severity) is essentially cosmetic
        to the verbose log file, no action should be inferred, such as termination of the script.
    .EXAMPLE
        Write-AzStackHciEnvironmentLog -Message ('Script messaging include data {0}' -f $data) -Type 'Info|Warning|Error' -Function 'FunctionName'
    .INPUTS
        Message - a string of the body of the log entry
        Type - a cosmetic type or severity for the message, must be info, warning or error
        Function - ideally the name of the function or the script writing the log entry.
    .OUTPUTS
        Appends Log entry to AzStackHciArcIntegration.log under the script root.
    .NOTES
        General notes
    #>
    [cmdletbinding()]
    param(
        [string]
        $Message,

        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]
        $Type = 'Info',

        [ValidateNotNullOrEmpty()]
        [string]$Function = ((Get-PSCallStack)[0].Command),

        [switch]$ConsoleOut,

        [switch]$Telemetry
    )
    $Message = RunMask $Message
    if ($ConsoleOut)
    {
        if ($true)
        {
            switch -wildcard ($function)
            {
                '*-AzStackHciArc*' { $foregroundcolor = 'DarkYellow' }
                default { $foregroundcolor = "White" }
            }
            switch ($Type)
            {
                'Success' { $foregroundcolor = 'Green' }
                'Warning' { $foregroundcolor = 'Yellow' }
                'Error' { $foregroundcolor = 'Red' }
                default { $foregroundcolor = "White" }
            }
            Write-Host $message -ForegroundColor $foregroundcolor
        }
        else
        {
            Write-Host $message
        }
    }
    else
    {
        Write-Verbose $message
    }

    if (-not [string]::IsNullOrEmpty($message))
    {
        # Log to ETW
        if ($Telemetry)
        {
            $source = "azshciarc/Telemetry"
            $EventId = 17201
        }
        else
        {
            $source = "azshciarc/Operational"
            $EventId = 17203
        }
        $logName = 'azshciarc'
        $EventType = switch ($Type)
        {
            "Error" { "Error" }
            "Warning" { "Warning" }
            "Success" { "Information" }
            "Info" { "Information" }
            Default { "Information" }
        }

        # Only write telemetry or non-info entries to the eventlog to save time and noise.
        if ($Telemetry -or $EventType -ne "Information")
        {
            Write-ETWLog -Source $Source -logName $logName -Message $Message -EventType $EventType -EventId $EventId
        }
        # Log to file
        $entry = "[{0}] [{1}] [{2}] {3}" -f ([datetime]::now).tostring(), $type, $function, ($Message -replace "`n|`t", "")
        if (-not (Test-Path $AzStackHciEnvironmentLogFile))
        {
            New-Item -Path $AzStackHciEnvironmentLogFile -Force | Out-Null
        }
        $retries = 3
        for ($i = 1; $i -le $retries; $i++) {
            try {
                $entry | Out-File -FilePath $AzStackHciEnvironmentLogFile -Append -Force -Encoding UTF8
                $writeFailed = $false
                break
            }
            catch {
                $writeFailed = "Log-info $i/$retries failed: $($_.ToString())"
                start-sleep -Seconds 5
            }
        }
        if ($writeFailed)
        {
            throw $writeFailed
        }
    }
}

function RunMask
{
    [cmdletbinding()]
    [OutputType([string])]
    Param (
        [Parameter(ValueFromPipeline = $True)]
        [string]
        $in
    )
    Begin {}
    Process
    {
        try
        {
            <#$in | Get-PIIMask | Get-GuidMask#>
            $in | Get-GuidMask
        }
        catch
        {
            $_.exception
        }
    }
    End {}
}

function Get-PIIMask
{
    [cmdletbinding()]
    [OutputType([string])]
    Param (
        [Parameter(ValueFromPipeline = $True)]
        [string]
        $in
    )
    Begin
    {
        $pii = $($ENV:USERDNSDOMAIN), $($ENV:COMPUTERNAME), $($ENV:USERNAME), $($ENV:USERDOMAIN) | ForEach-Object {
            if ($null -ne $PSITEM)
            {
                $PSITEM
            }
        }
        $r = $pii -join '|'
    }
    Process
    {
        try
        {
            return [regex]::replace($in, $r, "[*redacted*]")
        }
        catch
        {
            $_.exception
        }
    }
    End {}
}

function Get-GuidMask
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True)]
        [String]
        $guid
    )
    Begin
    {
        $r = [regex]::new("(-([a-fA-F0-9]{4}-){3})")

    }
    Process
    {
        try
        {
            return [regex]::replace($guid, $r, "-xxxx-xxxx-xxxx-")
        }
        catch
        {
            $_.exception
        }
    }
    End {}
}

function Write-AzStackHciHeader
{
    <#
    .SYNOPSIS
        Write invocation and system information into log and writes cmdlet name and version to screen.
    #>
    param (
        [Parameter()]
        [System.Management.Automation.InvocationInfo]
        $invocation,

        [psobject]
        $params,

        [switch]
        $PassThru
    )
    try
    {
        $paramToString = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ';'
        $cmdLetName = Get-CmdletName
        $cmdletVersion = (Get-Command $cmdletName -ErrorAction SilentlyContinue).version.tostring()
        Log-Info -Message ''
        Log-Info -Message ('{0} v{1} started.' -f `
                $cmdLetName, $cmdletVersion) `
            -ConsoleOut:(-not $PassThru)
        #TODO: Need to fix module name
        Log-Info -Telemetry -Message ('{0} started version: {1} with parameters: {2}. Id:{3}' `
                -f $cmdLetName, (Get-Module AzStackHci.EnvironmentChecker).Version.ToString(), $paramToString, $ENV:EnvChkrId)

        Log-Info -Message ('OSVersion: {0} PSVersion: {1} PSEdition: {2} Security Protocol: {3} Lanaguage Mode: {4}' -f `
                [environment]::OSVersion.Version.tostring(), $PSVersionTable.PSVersion.tostring(), $PSEdition, [Net.ServicePointManager]::SecurityProtocol, $ExecutionContext.SessionState.LanguageMode)
        Write-PsSessionInfo -params $params
    }
    catch
    {
        if (-not $PassThru)
        {
            Log-Info ("Unable to write header to screen. Error: {0}" -f $_.exception.message)
        }
    }
}

function Write-AzStackHciFooter
{
    <#
    .SYNOPSIS
        Writes report, log and cmdlet to screen.
    #>
    param (
        [Parameter()]
        [System.Management.Automation.InvocationInfo]
        $invocation,

        [switch]
        $failed,

        [switch]
        $PassThru
    )

    Log-Info -Message ("`nLog location: $AzStackHciEnvironmentLogFile") -ConsoleOut:(-not $PassThru)
    # Log-Info -Message ("Report location: $AzStackHciEnvironmentReport") -ConsoleOut:(-not $PassThru)
    # Log-Info -Message ("Use -Passthru parameter to return results as a PSObject.") -ConsoleOut:(-not $PassThru)
    if ($failed)
    {
        Log-Info -Message ("{0} failed" -f (Get-CmdletName)) -ConsoleOut:(-not $PassThru) -Type Error -Telemetry
    }
    else
    {
        Log-Info -Message ("{0} completed. Id:{1} " -f (Get-CmdletName),$ENV:EnvChkrId) -Telemetry
    }
}

function Get-CmdletName
{
    try
    {
        foreach ($c in (Get-PSCallStack).Command)
        {
            $functionCalled = Select-String -InputObject $c -Pattern "Invoke-AzStackHci(.*)Validation"
            if ($functionCalled)
            {
                 break
            }
        }
        $functionCalled
    }
    catch
    {
        throw "Hci Validation"
    }
}



function Write-ETWLog
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $source = 'azshciarc/Diagnostic',

        [Parameter()]
        [string]
        $logName = 'azshciarc',

        [Parameter(Mandatory = $true)]
        [string]
        $Message,

        [Parameter()]
        [string]
        $EventId = 0,

        [Parameter()]
        [string]
        $EventType = 'Information'
    )
    try
    {
        Write-EventLog -LogName $LogName -Source $Source -EntryType $EventType -Message $Message -EventId $EventId
    }
    catch
    {
        throw "Creating event log failed. Error $($_.exception.message)"
    }
}

function Assert-EventLog
{
    param (
        [Parameter()]
        [string]
        $source = 'azshciarc/Diagnostic'
    )
    try
    {
        $eventLog = Get-EventLog -LogName azshciarc -Source $Source -ErrorAction SilentlyContinue
    }
    catch {}
    # Try to create the log
    if (-not $eventLog)
    {
        New-AzStackHciArcIntegrationLog
    }
}

function Test-Elevation
{
    return  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-AzStackHciArcIntegrationLog
{
    try
    {
        $scriptBlock = {
            $logName = 'azshciarc'
            $sources = @('azshciarc/Operational', 'azshciarc/Diagnostic', 'azshciarc/Telemetry')
            foreach ($source in $sources)
            {
                New-EventLog -LogName $logName -Source $Source -ErrorAction SilentlyContinue
                Limit-EventLog -LogName $logName -MaximumSize 250MB -ErrorAction SilentlyContinue
                Write-EventLog -Message ('Initializing log provider {0}' -f $source) -EventId 0 -EntryType Information -Source $source -LogName $logName -ErrorAction Stop
            }
        }

        if (Test-Elevation)
        {
            Invoke-Command -ScriptBlock $scriptBlock
        }
        else
        {
            $psProcess = if (Join-Path -Path $PSHOME -ChildPath powershell.exe -Resolve -ErrorAction SilentlyContinue)
            {
                Join-Path -Path $PSHOME -ChildPath powershell.exe
            }
            elseif (Join-Path -Path $PSHOME -ChildPath pwsh.exe -Resolve -ErrorAction SilentlyContinue)
            {
                Join-Path -Path $PSHOME -ChildPath pwsh.exe
            }
            else
            {
                throw "Cannot find powershell process. Please run powershell elevated and run the following command: 'New-EventLog -LogName $logName -Source $sourceName'"
            }
            Write-Warning "We need to run an elevated process to register our event log.  `nPlease continue and accept the UAC prompt to continue.  `nAlternatively, run: `nNew-EventLog -LogName $logName -Source $source `nmanually and restart this command."
            if (Grant-UACConcent)
            {
                Start-Process $psProcess -Verb Runas -ArgumentList "-command (Invoke-Command -ScriptBlock {$scriptBlock})" -Wait
            }
            else
            {
                throw "Unable to elevate and register event log provider."
            }
        }
    }
    catch
    {
        throw "Failed to create Environment Checker log. Error: $($_.Exception.Message)"
    }
}

function Remove-AzStackHciArcIntegrationEventLog
{
    <#
    .SYNOPSIS
        Remove AzStackHCI Environment Checker event log
    .EXAMPLE
        Remove-AzStackHciArcIntegrationEventLog -Verbose
        Remove AzStackHCI Environment Checker event log
    #>
    [cmdletbinding()]
    param()
    Remove-EventLog -LogName "azshciarc"
}


function Grant-UACConcent
{
    $concentAnswered = $false
    $concent = $false
    while ($false -eq $concentAnswered)
    {
        $promptResponse = Read-Host -Prompt "Register the event log. (Y/N)"
        if ($promptResponse -imatch '^y$|^yes$')
        {
            $concentAnswered = $true
            $concent = $true
        }
        elseif ($promptResponse -imatch '^n$|^no$')
        {
            $concentAnswered = $true
            $concent = $false
        }
        else
        {
            Write-Warning "Unexpected response"
        }
    }
    return $concent
}

function Write-Summary
{
    param ($result, $property1, $property2, $property3, $seperator = '->')
    try
    {
        $summary = Get-Summary @PSBoundParameters

        # Write percentage
        Write-Host "`nSummary"
        Write-Host $lTxt.Summary
        if (-not ([string]::IsNullOrEmpty($summary.FailedResourceCritical)))
        {
            Write-Host " " -NoNewline
            Write-StatusSymbol -status 'Failed' -Severity Critical
            Write-Host (" {0} Critical Issue(s)" -f @($summary.FailedResourceCritical).Count)
        }

        if (-not ([string]::IsNullOrEmpty($summary.FailedResourceWarning)))
        {
            Write-Host " " -NoNewline
            Write-StatusSymbol -status 'Failed' -Severity Warning
            Write-Host (" {0} Warning Issue(s)" -f @($summary.FailedResourceWarning).Count)
        }

        if (-not ([string]::IsNullOrEmpty($summary.FailedResourceInformational)))
        {
            Write-Host " " -NoNewline
            Write-StatusSymbol -status 'Failed' -Severity Informational
            Write-Host (" {0} Informational Issue(s)" -f @($summary.FailedResourceInformational).Count)
        }

        if ($Summary.successCount -gt 0)
        {
            Write-Host " " -NoNewline
            Write-StatusSymbol -status 'Succeeded'
            Write-Host (" {0} successes" -f ($Summary.successCount))
        }

        <#Write-Host @expandDownSymbol
        Write-Host "  " -NoNewline
        switch ($Severity)
        {
            'Critical' { Write-Host @redCrossSymbol }
            'Warning' { Write-Host @warningSymbol }
            Default { Write-Host @redCrossSymbol }
        }#>
        #Write-Host ("  {0} / {1} ({2}%)" -f $summary.SuccessCount, $Result.AdditionalData.Resource.Count, $summary.SuccessPercentage)

        # Write issues by severity
        foreach ($severity in 'Critical', 'Warning', 'Informational')
        {
            $SeverityProp = "FailedResource{0}" -f $severity
            $failedResources = $summary.$SeverityProp | Sort-Object | Get-Unique

            if ($failedResources -gt 0)
            {
                Write-Host ""
                Write-Severity -severity $Severity
                Write-Host ""
                #Write-Host "`n$Severity Issues:"
                $failedResources | Sort-Object | Get-Unique | ForEach-Object {
                    Write-Host "  " -NoNewline
                    switch ($Severity)
                    {
                        'Critical' { Write-Host @redCrossSymbol }
                        'Warning' { Write-Host @warningSymbol }
                        Default { Write-Host @redCrossSymbol }
                    }
                    Write-Host "  $PSITEM"
                }
            }
        }

        if ($Summary.HelpLinks)
        {
            Write-Host "`nRemediation: "
            $Summary.HelpLinks | ForEach-Object {
                Write-Host "  " -NoNewline
                Write-Host @helpSymbol
                Write-Host "  $PSITEM"
            }
        }

        if (-not $summary.FailedResourceCritical -and -not $summary.FailedResourceWarning -and -not $summary.FailedResourceInformational)
        {
            Write-Host "`nSummary"
            Write-Host @expandOutSymbol
            Write-Host "  " -NoNewline
            Write-Host @greenTickSymbol
            Write-Host ("  {0} / {1} ({2}%) resources test successfully." -f $summary.SuccessCount, $Result.AdditionalData.Resource.Count, $summary.SuccessPercentage)
        }
    }
    catch
    {
        Log-Info -Message "Summary failed. $($_.Exception.Message)" -ConsoleOut -Type Warning
    }
}

function Get-Summary
{
    param ($result, $property1, $property2, $property3, $seperator = '->')

    try
    {
        if (-not $result)
        {
            throw "Unable to write summary. Check tests run successfully."
        }
        [array]$success = $result | Select-Object -ExpandProperty AdditionalData | Where-Object Status -EQ 'Succeeded'
        [array]$HelpLinks = $result | Where-Object Status -NE 'Succeeded' | Select-Object -ExpandProperty Remediation | Sort-Object | Get-Unique
        [array]$nonSuccess = $result | Select-Object -ExpandProperty AdditionalData | Where-Object Status -NE 'Succeeded'
        [array]$nonSuccessCritical = $result | Where-Object Severity -EQ Critical | Select-Object -ExpandProperty AdditionalData | Where-Object Status -NE 'Succeeded'
        [array]$nonSuccessWarning = $result | Where-Object Severity -EQ Warning | Select-Object -ExpandProperty AdditionalData | Where-Object Status -NE 'Succeeded'
        [array]$nonSuccessInformational = $result | Where-Object Severity -EQ Informational | Select-Object -ExpandProperty AdditionalData | Where-Object Status -NE 'Succeeded'

        $successPercentage = if ($success.count -gt 0)
        {
            [Math]::Round(($success.Count / $result.AdditionalData.Resource.count) * 100)
        }
        else
        {
            0
        }

        $sourceDestsb = {
            if ([string]::IsNullOrEmpty($_.$property2) -and [string]::IsNullOrEmpty($_.$property3))
            {
                "{0}" -f $_.$property1
            }
            elseif ([string]::IsNullOrEmpty($_.$property3))
            {
                "{0}{1}{2}" -f $_.$property1, $seperator, $_.$property2
            }
            else
            {
                "{0}{1}{2}({3})" -f $_.$property1, $seperator, $_.$property2, $_.$property3
            }
        }
        $FailedResourceCritical = $nonSuccessCritical |
        Select-Object @{ label = 'SourceDest'; Expression = $sourceDestsb } -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty SourceDest |
        Sort-Object |
        Get-Unique

        $FailedResourceWarning = $nonSuccessWarning |
        Select-Object @{ label = 'SourceDest'; Expression = $sourceDestsb } -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty SourceDest |
        Sort-Object |
        Get-Unique

        $FailedResourceInformational = $nonSuccessInformational |
        Select-Object @{ label = 'SourceDest'; Expression = $sourceDestsb } -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty SourceDest |
        Sort-Object |
        Get-Unique

        $summary = New-Object -Type PsObject -Property @{
            successCount                = $success.Count
            nonSuccessCount             = $nonSuccess.Count
            successPercentage           = $successPercentage
            HelpLinks                   = $HelpLinks
            FailedResourceCritical      = $FailedResourceCritical
            FailedResourceWarning       = $FailedResourceWarning
            FailedResourceInformational = $FailedResourceInformational
        }
        return $summary
    }
    catch
    {
        throw "Unable to calculate summary. Error $($_.exception.message)"
    }
}

# Symbols
$global:greenTickSymbol = @{
    Object          = [Char]0x2713     #8730
    ForegroundColor = 'Green'
    NoNewLine       = $true
}
$global:redCrossSymbol = @{
    Object          = [Char]0x2622 #0x00D7
    ForegroundColor = 'Red'
    NoNewLine       = $true
}

$global:WarningSymbol = @{
    Object          = [char]0x26A0
    ForegroundColor = 'Yellow'
    NoNewLine       = $true
}

$global:bulletSymbol = @{
    Object    = [Char]0x25BA
    NoNewLine = $true
}

# Text
$global:needsAttention = @{
    object          = $lTxt.NeedsAttention;
    ForegroundColor = 'Yellow'
    NoNewLine       = $true
}

$global:needsRemediation = @{
    object          = $lTxt.NeedsRemediation;
    ForegroundColor = 'Red'
    NoNewLine       = $true
}

$global:ForInformation = @{
    object    = $lTxt.ForInformation;
    NoNewLine = $true
}

$global:expandDownSymbol = @{
    object    = [Char]0x25BC # expand down
    NoNewLine = $true
}

$global:expandOutSymbol = @{
    object    = [Char]0x25BA # expand out
    NoNewLine = $true
}

$global:helpSymbol = @{
    object    = [char]0x270E   #0x263C # sunshine
    NoNewLine = $true
    #ForegroundColor = 'Yellow'
}

$global:Critical = @{
    object          = $lTxt.Critical;
    ForegroundColor = 'Red'
    NoNewLine       = $true
}

$global:Warning = @{
    object          = $lTxt.Warning;
    ForegroundColor = 'Yellow'
    NoNewLine       = $true
}

$global:Information = @{
    object    = $lTxt.Informational;
    NoNewLine = $true
}

$global:isHealthy = @{
    object    = $lTxt.Healthy
    NoNewLine = $true
}

function Write-StatusSymbol
{
    param ($status, $severity)
    switch ($status)
    {
        "Succeeded" { Write-Host @greenTickSymbol }
        "Failed"
        {
            switch ($Severity)
            {
                'Critical' { Write-Host @redCrossSymbol }
                'Warning' { Write-Host @warningSymbol }
                Default { Write-Host @redCrossSymbol }
            }
        }
        Default { Write-Host @bulletSymbol }
    }
}

function Write-Severity
{
    param ($severity)
    switch ($severity)
    {
        'Critical' { Write-Host @needsRemediation }
        'Warning' { Write-Host @needsAttention }
        'Informational' { Write-Host @ForInformation }
        Default { Write-Host @Critical }
    }
}

function Set-AzStackHciIdentifier
{
    $ENV:EnvChkrId = $null
    if ([string]::IsNullOrEmpty($ENV:EnvChkrOp))
    {
        $ENV:EnvChkrOp = 'Manual'
    }
    $validatorCmd = Get-CmdletName
    if(-not [string]::IsNullOrWhiteSpace($validatorCmd))
    {
        $ENV:EnvChkrId = "{0}\{1}\{2}" -f $ENV:EnvChkrOp, $validatorCmd.matches.groups[1], (([system.guid]::newguid()) -split '-' | Select-Object -first 1)
    }
}

function Write-PsSessionInfo
{
    <#
    .SYNOPSIS
        Write some pertainent information to the log about any PsSessions passed
    #>
    [CmdletBinding()]
    param (
        $params
    )
    try {
        if ($params['PsSession'])
        {
            foreach ($session in $params['PsSession'])
            {
                Log-Info -Message ("PsSession info: {0}, {1}, {2}, {3}, {4}, {5}" -f $session.ComputerName, $session.Name, $session.Id, $session.Runspace.ConnectionInfo.credential.username, $session.Runspace.SessionStateProxy.LanguageMode, $session.Runspace.ConnectionInfo.AuthenticationMechanism)
            }
        }
        else
        {
            Log-Info -Message "No PsSession info to write"
        }
    }
    catch
    {
        Log-Info -Message "Failed to write PsSession info: $($_.exception.message)"
    }
}

function Write-AzStackHciResult
{
    <#
    .SYNOPSIS
        Displays results to screen
    .DESCRIPTION
        Displays test results to screen, highlighting failed tests.
    #>
    param (
        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [psobject]
        $result,

        $seperator = ' -> ',

        [switch]
        $Expand,

        [switch]
        $ShowFailedOnly
    )

    try
    {
        if (-not $result)
        {
            throw "Results missing. Ensure tests ran successfully."
        }
        Log-Info ("`n{0}:" -f $Title) -ConsoleOut


        foreach ($r in ($result | Sort-Object Status, Title, Description))
        {
            if ($r.status -ne 'Succeeded' -or $Expand)
            {
                Write-StatusSymbol -Status $r.Status -Severity $r.Severity
                Write-Host " " -NoNewline
                Write-Host @expandDownSymbol
                Write-Host " " -NoNewline
                if ($r.status -ne 'Succeeded')
                {
                    switch ($r.Severity)
                    {
                        Critical { Write-Host @needsRemediation }
                        Warning { Write-Host @needsAttention }
                        Informational { Write-Host @forInformation }
                        Default { Write-Host @Critical }
                    }
                }
                Write-Host " " -NoNewline
                Write-Host ($r.TargetResourceType + " - " + $r.Title + " " + $r.Description)
                foreach ($detail in ($r.AdditionalData | Sort-Object Status -Descending))
                {
                    if ($ShowFailedOnly -and $detail.Status -eq 'Succeeded')
                    {
                        continue
                    }
                    else
                    {
                        Write-Host "  " -NoNewline
                        Write-StatusSymbol -Status $detail.Status -Severity $r.Severity
                        Write-Host " " -NoNewline
                        Write-Host " " -NoNewline
                        Write-Host ("{0}{1}{2}" -f $detail.Source, $seperator, $detail.Resource)
                    }
                }
                if ($detail.Status -ne 'Succeeded')
                {
                    Write-Host "  " -NoNewline
                    Write-Host @helpSymbol
                    Write-Host ("  Help URL: {0}" -f $r.Remediation)
                    Write-Host ""
                }
            }
            else
            {
                if (-not $ShowFailedOnly)
                {
                    Write-Host @expandOutSymbol
                    Write-Host " " -NoNewline
                    Write-Host @greenTickSymbol
                    Write-Host " " -NoNewline
                    Write-Host @isHealthy
                    Write-Host " " -NoNewline
                    Write-Host ($r.TargetResourceType + " " + $r.Title + " " + $r.Description)
                }
            }
        }
    }
    catch
    {
        Log-Info "Unable to write results. Error: $($_.exception.message)" -Type Warning
    }
}


# Export-ModuleMember -function Get-AzStackHciArcIntegrationEvents
Export-ModuleMember -function Log-Info
Export-ModuleMember -function Set-AzStackHciOutputPath
Export-ModuleMember -function Write-AzStackHciFooter
Export-ModuleMember -function Write-AzStackHciHeader
Export-ModuleMember -function Write-AzStackHciResult
Export-ModuleMember -function Write-ETWLog
# Export-ModuleMember -function Write-ETWResult
Export-ModuleMember -function Write-Summary
