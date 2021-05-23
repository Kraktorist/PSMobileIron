<#
.SYNOPSIS
    Get devices from MobileIron Core API
.DESCRIPTION
    Get phones from MobileIron Core API. You can request 
      - all the phones
      - only the phones with the specific status
      - the phones with specific label applied
      - the phones of specific user
      - the phone with specific UUID, phone number or MACaddress 
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential)
        Get all the devices excluding retired
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential)
        Get all the devices (retired included)
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Status Active, VERIFICATION_PENDING, EXPIRED
        Get the device by the Status
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -UUID 3a45b4d5-d2e5-468c-bf4f-149efff463a9
        Get the device by UUID
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Phone 5551212
        Get the device by phone number
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -User jdoe
        Get the device by the user name
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Label Android
        Get the device by the label
.EXAMPLE
    Get-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -MACAddress ffffffffffff
        Get the device by the MAC address
#>
function Get-MIDevice {
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Server,
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$true, ParameterSetName="UUID")]
        [String]
        $UUID,
        [Parameter(Mandatory=$true, ParameterSetName="Phone")]
        [String]
        $Phone,
        [Parameter(Mandatory=$true, ParameterSetName="User")]
        [String]
        $User,
        [Parameter(Mandatory=$true, ParameterSetName="Label")]
        [String]
        $Label,
        [Parameter(Mandatory=$true, ParameterSetName="MACAddress")]
        [String]
        $MACAddress,
        [Parameter( ParameterSetName="All")]
        [switch]$IncludeRetired,
        [Parameter(ParameterSetName="Status")]
        [ValidateSet("ACTIVE", "IENROLL_VERIFIED", "IENROLL_INPROGRESS", "IENROLL_INPROGRESS", "IENROLL_COMPLETE",
        "INFECTED", 'LOST', "RETIRED", 'VERIFIED', 'VERIFICATION_PENDING', 'EXPIRED', 'WIPED')]
        $Status = @(
            'ACTIVE',
            'IENROLL_VERIFIED',
            'IENROLL_INPROGRESS',
            'IENROLL_COMPLETE',
            'INFECTED',
            'LOST',
            'VERIFIED',
            'VERIFICATION_PENDING',
            'EXPIRED',
            'WIPED'
        )
    )

    $APIURI = "https://{0}/api/v1/" -f $Server
    switch ($PsCmdlet.ParameterSetName) {
        "UUID" {
            $uri = @($APIURI + "dm/devices/{0}" -f $UUID)
        }
        "Phone" {
            $uri = @($APIURI + "dm/phones/{0}" -f $Phone)
        }
        "User" {
            $uri = @($APIURI + "dm/users/{0}" -f $User)
        }
        "Label" {
            $uri = @($APIURI + "dm/labels/{0}" -f $Label)
        }
        "MACAddress" {
            $uri = @($APIURI + "dm/devices/mac/{0}" -f $MACAddress)
        }
        Default { #for ALL or -Status
            if ($IncludeRetired) {
                $Status += 'RETIRED'
            }
            foreach ($CurrentStatus in $Status) {
                $uri += @(,($APIURI + "dm/devices?status={0}" -f $CurrentStatus))
            }
        }
    }
    $devices = @()
    foreach ($CurrentURI in $uri) {
        Write-Verbose "URI: $CurrentURI"
        try {
            $result = Invoke-RESTMethod -URI $CurrentURI -Credential $Credential -ErrorAction Stop
            if ($PsCmdlet.ParameterSetName -in @("ALL", "Status", "Phone", "User", "Label")) {
                $converted_result = $result.Devices.Device
            }
            else {
                $converted_result = $result.Device
            }
            $devices += @(,$converted_result)
            Write-Verbose "Count: $(($converted_result | Measure-Object).count)"
         }
        catch {
            If ($PSItem.Exception.Response.StatusCode.value__) {
                Write-Warning $(Get-ResponseMessage -Code $PSItem.Exception.Response.StatusCode.value__)
            }
            if ($PSItem.Exception.Response.StatusCode.value__ -ne 404) {
                # MobileIron Core API returns 404 code when no devices found. 
                # We don't need to stop the cmdlet in this case
                throw($PSItem)
            }

        }
    }
    return $devices
}