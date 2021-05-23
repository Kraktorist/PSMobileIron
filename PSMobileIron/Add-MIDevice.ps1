<#
.SYNOPSIS
    Add a new MobileIron device
.DESCRIPTION
    Add a new MobileIron device
.EXAMPLE
    Add-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Platform A -UserId jdoe -ImportUserFromLDAP -PDA
        Adding new Android PDA device (without phone number) for user jdoe from LDAP
.EXAMPLE
    Add-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Platform Iphone -UserId jdoe -ImportUserFromLDAP -PhoneNumber 5551212 -CountryCode 0 -Operator none
        Adding new Iphone device with phone number 5551212 for user jdoe from LDAP
.EXAMPLE
    Add-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Platform A -UserId jdoe -PhoneNumber 5551212 -CountryCode 0 -Operator none
        Adding new Android device with phone number 5551212 for local user jdoe. The user must be created before the operation
.EXAMPLE
    Add-MIDevice -Server $MobileIronServer -Credential (Get-Credential) -Platform A -UserId jdoe -Firstname John -Surname Doe -Email jd@example.com -PDA
        Adding new Android device with phone number 5551212 for local user jdoe. If the uses doesn't exist it will be created.
#>
function Add-MIDevice {
    [CmdletBinding(DefaultParameterSetName="LDAP-PDA")]
    param(
        [Parameter( Mandatory=$true)]
        [string]
        $Server,
        [Parameter( Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter( Mandatory=$true)]
        [ValidateSet("A", "I", "E", "M", "L")]
        [string]
        $Platform,
        [Parameter( Mandatory=$true)]
        [string]
        $UserId,
        [Parameter( Mandatory=$true, ParameterSetName="LDAP-PDA")]
        [Parameter( Mandatory=$true, ParameterSetName="LDAP-PhoneNumber")]
        [switch]$ImportUserFromLDAP,
        [Parameter( Mandatory=$true, ParameterSetName="LDAP-PhoneNumber")]
        [Parameter( Mandatory=$true, ParameterSetName="Local-PhoneNumber")]
        [string]
        $PhoneNumber,
        [Parameter( Mandatory=$true, ParameterSetName="LDAP-PDA")]
        [Parameter( Mandatory=$true, ParameterSetName="Local-PDA")]
        [switch]$PDA,
        [Parameter( Mandatory=$true, ParameterSetName="LDAP-PhoneNumber")]
        [Parameter( Mandatory=$true, ParameterSetName="Local-PhoneNumber")]
        [int]
        $CountryCode,
        [Parameter( Mandatory=$true, ParameterSetName="LDAP-PhoneNumber")]
        [Parameter( Mandatory=$true, ParameterSetName="Local-PhoneNumber")]
        [string]
        $Operator,
        [Parameter( ParameterSetName="Local-PhoneNumber")]
        [Parameter( ParameterSetName="Local-PDA")]
        [string]
        $Firstname,
        [Parameter( ParameterSetName="Local-PhoneNumber")]
        [Parameter( ParameterSetName="Local-PDA")]
        [string]
        $Surname,
        [Parameter( ParameterSetName="Local-PhoneNumber")]
        [Parameter( ParameterSetName="Local-PDA")]
        [string]
        $Email,
        [Parameter()]
        [switch]$NotifyUser,
        [Parameter()]
        [switch]$NotifyUserBySMS
    )

    $APIURI = "https://{0}/api/v1/" -f $Server
    $uri = $APIURI + 'dm/register?userId={0}&platform={1}' -f $UserId, $Platform
    If ($PDA) {
        $uri = $uri + "&phoneNumber=pda&devicetype=pda"
    }
    else {
        if ($PhoneNumber) {
            $uri = $uri + "&phonenumber=$PhoneNumber"
        }
        If ($CountryCode -is [int] ) {
            $uri = $uri + "&countrycode=$CountryCode"
        }
        If ($Operator) {
            $uri = $uri + "&operator=$Operator"
        }
    }
    If ($ImportUserFromLDAP) {
        $uri = $uri + "&importuserfromldap=true"
    }
    else {
        if ($Firstname) {
            $uri = $uri + "&userfirstname=$Firstname"
        }
         if ($Surname) {
            $uri = $uri + "&userlastname=$Surname"
        }
        if ($Email) {
            $uri = $uri + "&userEmailAddress=$Email"
        }
    }
    If ($NotifyUser) {
        $uri = $uri + "&notifyuser=true"
    }
    If ($NotifyUserbysms) {
        $uri = $uri + "&notifyuserbysms=true"
    }
    Write-Verbose $uri
    try {
         $result = Invoke-RestMethod -Uri $uri -Method PUT -Credential $Credential -ErrorAction Stop
    }
    catch {
        If ($PSItem.Exception.Response.StatusCode.value__) {
            Write-Warning $(Get-ResponseMessage -Code $PSItem.Exception.Response.StatusCode.value__)
            return
        }
        throw($PSItem)
    }
    return $result.registration
}