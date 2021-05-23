<#
.SYNOPSIS
    Wipe a phone
.DESCRIPTION
    Wipe a phone.
    Cmdlet asks a confirmation
.EXAMPLE
    Clear-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -MACAddress ffffffffffff
        Wipe the phone with MAC address ff:ff:ff:ff:ff:ff
.EXAMPLE
    Clear-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9 -Reason "Device has been lost"
        Wipe the phone with UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9 because it was lost
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -User JDoe | Clear-MIDevice -Server $MobileIronServer -Credential (Get-Credential)
        Wipe all John Doe's phones   

#>
function Clear-MIDevice {
    [CmdletBinding(DefaultParameterSetName = "UUID", SupportsShouldProcess = $true)]
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
        $Reason,
        [switch]
        $Force
    )
    
    process {
        $APIURI = "https://{0}/api/v1/" -f $Server
        $uri = $APIURI + "dm/devices/wipe/"
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
            if ($PSCmdlet.ShouldContinue("Are you sure ?", "The phone will be wiped. All the data will be completeley removed.")) {
                $result = Invoke-RestMethod -URI $URI -Credential $Credential -Method PUT -ErrorAction Stop 
            }
        }
        catch {
            If ($PSItem.Exception.Response.StatusCode.value__) {
                Write-Warning $(Get-ResponseMessage -Code $PSItem.Exception.Response.StatusCode.value__)
                return
            }
            throw($PSItem)
        }  
        If ($result.messages.message) {
            Write-Warning $result.messages.message
        }
        return $result     
    }
}