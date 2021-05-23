<#
.SYNOPSIS
    Send a message to a phone
.DESCRIPTION
    Send a message to a phone. Email, sms and push notification are possible options
.EXAMPLE
    Send-MIMessage -Server $MobileIronServer -Credential (Get-Credential) -Mode sms -Message "Have a good day" -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9
        Send sms to the phone
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Status Active | Send-MIMessage -Server $MobileIronServer -Credential (Get-Credential) -Mode pns -Subject "New policy" -Message "Please be informed about new policy."
        send push notification to all active users 
#>
function Send-MIMessage {
    [CmdletBinding(DefaultParameterSetName="UUID")]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$true)]
        [ValidateSet("sms", "email", "pns")]
        $Mode,
        [Parameter(Mandatory=$true)]
        [String]
        $Message,
        [Parameter()]
        [String]
        $Subject,
        [parameter(Mandatory=$true, ParameterSetName="UUID")]
        [String[]]
        $UUID,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="MACAddress")]
        [String[]]
        $MACAddress
    )
    
    process {
        $APIURI = "https://{0}/api/v1/" -f $Server
        $uri = $APIURI + "dm/bulk/sendmessage/"
        If ($Mode) {
            $uri = $uri + "?mode=$Mode"
        }
        If ($Message) {
            $uri = $uri + "&message={0}" -f $([uri]::EscapeDataString($Message))
        }
        If ($Subject) {
            $uri = $uri + "&subject={0}" -f $([uri]::EscapeDataString($Subject))
        }        
        Foreach ($id in $UUID) {
            $uri = $uri + "&deviceUuid=$id"
        }
        Foreach ($mac in $MACAddress) {
            $uri = $uri + "&deviceWiFiMacAddress=$mac"
        }
        Write-Verbose $uri
        try {
            $result = Invoke-RestMethod -URI $URI -Credential $Credential -Method POST -ErrorAction Stop 
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