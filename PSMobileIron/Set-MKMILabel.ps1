<#
.SYNOPSIS
    Apply MobileIron label(s) to a device or devices
.DESCRIPTION
    Apply MobileIron label(s) to a device or devices
.EXAMPLE
    Set-MILabel -Server $MobileIronServer -Credential (Get-Credential) -Label "iOS" -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9
        Apply the label with name iOS to the phone
.EXAMPLE
    Set-MILabel -Server $MobileIronServer -Credential (Get-Credential) -Label "iOS", "Corporate" -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9, 3a45b4d5-d2e5-xxxx-xxxx-149efff463a9
        Apply two labels to two device
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Status Active | Set-MILabel -Server $MobileIronServer -Credential (Get-Credential) -Name "iOS"
        Apply "iOS" label to all active phones
#>
#>
function Set-MILabel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias("Name")]
        [String[]]
        $Label,
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]
        $UUID
    )
    
    process {
        $APIURI = "https://{0}/api/v1/" -f $Server
        $uri = $APIURI + "dm/labels/{0}/{1}?action=apply" -f $([uri]::EscapeDataString($Label -join ',')), ($UUID -join ',')
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