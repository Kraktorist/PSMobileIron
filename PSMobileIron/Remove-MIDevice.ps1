<#
.SYNOPSIS
    Retire a device from MobileIron
.DESCRIPTION
    Retire a device from MobileIron
.EXAMPLE
    Remove-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9
        Retire the phone by its UUID
.EXAMPLE
    Remove-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -MACAddress ffffffffffff -Reason "Device was stolen"
        Retire the phone by its MAC
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -User jdoe | Remove-MIDevice -Server $MobileIronServer -Credential (Get-Credential)
        Retire the devices of John Doe
#>
function Remove-MIDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="UUID")]
        [String]
        $UUID,
        [parameter(Mandatory=$true,ParameterSetName="MAC")]
        [String]
        $MACAddress,
        [String]
        $Reason
    )
    Process {
        $APIURI = "https://{0}/api/v1/" -f $Server
        If ($PSCmdlet.ParameterSetName -eq 'UUID') {
            $uri = $APIURI + "dm/devices/retire/{0}" -f $UUID
        }
        elseIf ($PSCmdlet.ParameterSetName -eq 'MAC') {
            $uri = $APIURI + "dm/devices/retire/mac/{0}" -f $MAC
        }
        else {
            throw("Wrong parameter set")
        }
        If ($Reason) {
            $uri = $uri + '?Reason=' + $([uri]::EscapeDataString($Reason))
        }
        Write-Verbose $uri
        try {
            $result = Invoke-RestMethod -URI $URI -Credential $Credential -Method PUT -ErrorAction Stop
        }
        catch {
            If ($PSItem.Exception.Response.StatusCode.value__) {
                Write-Warning $(Get-ResponseMessage -Code $PSItem.Exception.Response.StatusCode.value__)
                return
            }
            throw($PSItem)
        }
        Write-Warning $result.messages.message
        return $result
    }
}
