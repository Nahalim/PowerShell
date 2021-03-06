Function Stop-AppPool{
    <#

    .SYNOPSIS
    Stops IIS App Pools

    .DESCRIPTION
    This command will Stop remote application pools. Requires Get-AppPool to function. 
    You can pipe Get-AppPool into it or specify a search string to have it call out.

    .EXAMPLE
    Stop-AppPool -ComputerName Server01 -AppPool "*Default*"
    Stop-AppPool -ComputerName Server01, Server02 -AppPool "*Default*"
    Stop-AppPool -ComputerName Server01 -AppPool "App Pool 1"

    Get-AppPool -ComputerName Server01 -AppPool "*Default*" | Stop-AppPool

    .NOTES
    

    .LINK
    https://github.com/Nahalim/PowerShell

    #>

    Param (
        [CmdLetBinding()]
        [Parameter(ValueFromPipeline)]        
        $AppPool = "*",

        [string[]]$ComputerName = "localhost"
    )

    Begin {
        
        [Reflection.Assembly]::LoadWithPartialName('Microsoft.Web.Administration') | Out-Null        
    }

    Process { 
        If ($AppPool -is [string] -or $AppPool -is [String[]]) {
            
            foreach ($PC in $ComputerName) {
                $tmpAppPool = Get-AppPool -ComputerName $PC -AppPool $AppPool                                    
            }
            foreach ($pool in $tmpAppPool) {
                Write-Host "Stopping $($pool.name)" -ForegroundColor Red
                $pool.Stop()   
            }
        }
        else {
            
            $tmpAppPool = $AppPool
            
            foreach ($pool in $tmpAppPool) {
                Write-Host "Stopping $($pool.name)" -ForegroundColor Red
                $pool.Stop()                
            }
        }

    }   
}