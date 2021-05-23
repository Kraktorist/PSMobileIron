<#
.SYNOPSIS
    Get list of MobileIron Labels
.DESCRIPTION
    Get list of MobileIron Labels.
.EXAMPLE
    Get-MILabel -Server $MobileIronServer -Credential (Get-Credential)
        Get all the labels from MobileIron server
.EXAMPLE
    Get-MILabel -Server $MobileIronServer -Credential (Get-Credential) -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9
        Get all the labels applied to the device with the specific UUID
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -User jdoe | Get-MILabel -Server $MobileIronServer -Credential (Get-Credential)
        Get all the labels applied to the device with the specific UUID

#>
function Get-MILabel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]
        $UUID
    )
    process {
        $APIURI = "https://{0}/api/v1/" -f $Server
        If ($UUID) {
                $uri = $APIURI + "dm/labels/devices/$UUID"
        }
        else {
            $uri = $APIURI + "dm/labels"
        }
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
        return $result.Labels.Label
    }
}