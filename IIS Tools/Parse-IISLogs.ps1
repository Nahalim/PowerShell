Function Parse-IISLogs {
    <#

    .SYNOPSIS
    View IIS logs on Remote Servers

    .DESCRIPTION
    A Primitive script that pulls IIS logs from a remote server and converts the time to local time.

    .EXAMPLE
    Parse-IISLogs -ComputerName "SERVER01" -StartDate (Get-Date).Adddays(-10)
    Parse-IISLogs -ComputerName "SERVER01" -WithinHours 4 | Out-GridView

    .NOTES
    It's primitive but works?

    .LINK
    https://github.com/Nahalim/PowerShell

    #>

    Param (
        [CmdLetBinding()]
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateScript({
            Test-Connection $_ -Quiet
        })]
        [string]$ComputerName,
        [string]$LogPath = "C:\inetpub\logs\LogFiles",
        [string]$StartDate = (Get-Date).AddDays(-1),
        [string]$EndDate = (Get-Date),
        [ValidateRange(0,24)]
        [int]$WithinHours = 0
    )
    
    If ($withinHours -gt 0) {
        #No sense in parsing older logs if we only want X hours
        $StartDate = (Get-Date).AddDays(-1)
        $EndDate = (Get-Date)
    }

    $Logs = Get-ChildItem $LogPath.Replace("C:", "\\$ComputerName\c$") -Filter *.log -Recurse | Where-Object { $_.CreationTime -ge $StartDate -and $_.CreationTime -le $EndDate }
    $IISData = @()

    $i = 0
    Write-Host "Reading $($Logs.Count) files..."
    foreach ($log in $Logs) {
        $i++; Write-Progress -Activity "Reading $($log.FullName)" -PercentComplete (($i / $logs.Count) * 100) -Id 0 
        $tmp = Get-Content $log.FullName | % {
            $tmpLine = $_
            If (-not $tmpLine.StartsWith("#")) { $tmpLine } 
        }
    

        $j = 0
        Write-Host "$($log.FullName) contains $($tmp.count) items)"
        foreach ($line in $tmp) {
            Write-Progress -Activity "Parsing entires" -PercentComplete (($j / $tmp.Count) * 100) -Id 1;$j++ 
            $tmpLSplit = $line.Split(" ")
            
            $realTime = ([datetime]::ParseExact("$($tmpLSplit[0]) $($tmpLSplit[1])", 'yyyy-MM-dd HH:mm:ss', $null))
            $realTime =  [datetime]::SpecifyKind($realTime,'Utc').ToLocalTime()
            $rObj = New-Object -TypeName PsObject
            $rObj | Add-Member -MemberType NoteProperty -Name TimeStamp -Value $realTime
            $rObj | Add-Member -MemberType NoteProperty -Name s_ip -Value $tmpLSplit[2]
            $rObj | Add-Member -MemberType NoteProperty -Name cs_Method -Value $tmpLSplit[3]
            $rObj | Add-Member -MemberType NoteProperty -Name cs_uri_stem -Value $tmpLSplit[4]
            $rObj | Add-Member -MemberType NoteProperty -Name cs_uri_query -Value $tmpLSplit[5]
            $rObj | Add-Member -MemberType NoteProperty -Name s_port -Value $tmpLSplit[6]
            $rObj | Add-Member -MemberType NoteProperty -Name cs_username -Value $tmpLSplit[7]
            $rObj | Add-Member -MemberType NoteProperty -Name c_ip -Value $tmpLSplit[8]
            $rObj | Add-Member -MemberType NoteProperty -Name cs_User_Agent -Value $tmpLSplit[9]
            $rObj | Add-Member -MemberType NoteProperty -Name cs_Referer -Value $tmpLSplit[10]
            $rObj | Add-Member -MemberType NoteProperty -Name sc_status -Value $tmpLSplit[11]
            $rObj | Add-Member -MemberType NoteProperty -Name sc_substatus -Value $tmpLSplit[12]
            $rObj | Add-Member -MemberType NoteProperty -Name sc_win32_status -Value $tmpLSplit[13]
            $rObj | Add-Member -MemberType NoteProperty -Name time_taken -Value $tmpLSplit[14]
            $IISData += $rObj    
        }
    }
    If ($withinHours -gt 0) {
        $IISData | ?{$_.TimeStamp -gt (Get-Date).AddHours($WithinHours * -1)}
    }
    Else {
        $IISData 
    }
}
