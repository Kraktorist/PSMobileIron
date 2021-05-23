<#
.SYNOPSIS
    Get MobileIron user
.DESCRIPTION
    Get MobileIron user
.EXAMPLE
    Get-MIUser -Server $MobileIronServer -Credential (Get-Credential) -Username jdoe
        returns profile of JDoe user
#>
function Get-MIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$true)]
        $Username
    )
    $APIURI = "https://{0}/api/v1/" -f $Server
    $uri = $APIURI + "sm/users/{0}" -f $Username
    Write-Verbose $uri
    try {
         $result = Invoke-RestMethod -Uri $uri -Credential $Credential -ErrorAction Stop
    }
    catch {
        If ($PSItem.Exception.Response.StatusCode.value__) {
            Write-Warning $(Get-ResponseMessage -Code $PSItem.Exception.Response.StatusCode.value__)
            return
        }
        throw($PSItem)
    }
    return $result.User
}