<#
.SYNOPSIS
    Unlock a phone
.DESCRIPTION
    Unlock a phone
.EXAMPLE
    Unlock-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9
        Unlock the phone by its UUID
.EXAMPLE
    Unlock-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -MACAddress ffffffffffff -Reason "Device was stolen"
        Unlock the phone by its MAC
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -User jdoe | Unlock-MIDevice -Server $MobileIronServer -Credential (Get-Credential)
        Unlock the devices of John Doe
#>
function Unlock-MIDevice {
    [CmdletBinding(DefaultParameterSetName="UUID")]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true, ParameterSetName="UUID")]
        [String]
        $UUID,
        [Parameter(Mandatory=$true, ParameterSetName="MACAddress")]
        [String]
        $MACAddress,
        [String]
        $Reason
    )
    
    process {
        $APIURI = "https://{0}/api/v1/" -f $Server
        $uri = $APIURI + "dm/devices/unlock/"
        If ($PsCmdlet.ParameterSetName -eq "UUID") {
            $uri = $uri + $UUID
        }
        If ($PsCmdlet.ParameterSetName -eq "MACAddress") {
            $uri = $uri + 'mac/' + $MACAddress
        }
        If ($Reason) {
            $uri = $uri + '?Reason=' + $([uri]::EscapeDataString($Reason))
        }
        Write-Verbose $uri
        try {
            $result = Invoke-RestMethod -URI $URI -Credential $Credential -Method GET -ErrorAction Stop 
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