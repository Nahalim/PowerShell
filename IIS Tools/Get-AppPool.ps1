Function Get-AppPool{
    <#

    .SYNOPSIS
    Returns Remote App Pools in IIS

    .DESCRIPTION
    This command will return application pools from IIS using Web.Administration.

    .EXAMPLE
    Get-AppPool -ComputerName Server01 -AppPool "*Default*"
    Get-AppPool -ComputerName Server01, Server02 -AppPool "*Default*"
    Get-AppPool -ComputerName Server01 -AppPool "App Pool 1"

    .NOTES
    I need to replace object check with if it's the actual object... sloppy

    .LINK
    https://github.com/Nahalim/PowerShell

    #>

    Param (
        [CmdLetBinding()]
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeLine=$true)]
        [string[]]$ComputerName,        
        [string]$AppPool = "*"
    )
    Begin {
        [Reflection.Assembly]::LoadWithPartialName('Microsoft.Web.Administration') | Out-Null
    }
    Process { 
        Foreach ($PC in $ComputerName) {
            Write-Host "Checking $PC"
            Try {       
                $sm = [Microsoft.Web.Administration.ServerManager]::OpenRemote("$PC")
                $sm.ApplicationPools | ? {$_.Name -like $AppPool}
            }
            Catch {
                $_.Exception.Message
            }
        }
        
    }
}