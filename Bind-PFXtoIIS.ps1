Function Bind-PFXtoIIS {
    <#

    .SYNOPSIS
    Installs and Binds a PFX to an IIS Web Site

    .DESCRIPTION
    This script copys a PFX locally to C:\windows\temp. Then installs it and binds it in IIS. Then removes the file from the temp directory.

    .EXAMPLE
    Bind-PFXtoIIS -ComputerName Server01 -Certificate "C:\temp\myCert.pfx" -Password "Password1"

    $servers = 1..10 | %{"HSWeb-WEB-$_"}
    $servers | Bind-PFXtoIIS -Certificate "c:\temp\myCert.pfx" -Password "Password1"

    .NOTES
    Need to add CER support.

    .LINK
    https://github.com/Nahalim/PowerShell

    #>

    Param (
        [CmdLetBinding()]
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeLine=$true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true)]
        [ValidateScript({
            Test-Path $_ 
        })]
        [string]$Certificate,
        [Parameter(Mandatory=$true)]                
        [string]$Password,
        [string]$WebSite = "Default Web Site",
        [string]$Port = 443
    )


    Begin {   
    }

    Process {
        foreach ($PC in $ComputerName) {
            Try {
                Write-Verbose "Copying $Certificate to $PC"
                Copy-Item -Path $Certificate -Destination "\\$PC\c$\Windows\Temp\bindiis.pfx" -Force
                Invoke-Command -ComputerName $PC -ArgumentList $Password, $WebSite, $Port  {
                    Import-Module WebAdministration
                    Write-Verbose "    Importing Certificate to Computer Local Store"
                    $import = Import-PfxCertificate -FilePath "c:\Windows\Temp\bindiis.pfx" -CertStoreLocation 'cert:\LocalMachine\MY' -Password (ConvertTo-SecureString $Args[0] -AsPlainText -force)            
                    Write-Verbose "    Binding to IIS"
                    New-WebBinding -Name $Args[1] -IP "*" -Port $Args[2] -Protocol https
                    (Get-WebBinding -Name $Args[1] -Port $Args[2] -Protocol "https").AddSSlCertificate($import.Thumbprint,"My")
                }

                
            }
            catch {
                Write-Host "$($_.Exception.Message)" -ForegroundColor Red
            }
            Finally {
                Write-Verbose "    Removing cert from temp"
                Remove-Item "\\$PC\c$\Windows\Temp\bindiis.pfx" -Force | Out-Null
            }
        }
    }

    End {

    }

}