    Foreach($script in (Get-ChildItem $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue))
    {
        Try
        {
            . $script.fullname
        }
        Catch
        {
            Write-Error "Failed to import function $($script.fullname)"
        }
    }

    