Get-ChildItem -Path $PSScriptRoot\*.ps1 | Foreach-Object{ . $_.FullName }
Export-ModuleMember -Function "*-MI*"