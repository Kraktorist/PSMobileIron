# PSMobileIron
Powershell wrapper module for MobileIron MDM Core API.
https://help.ivanti.com/mi/help/en_us/CORE/10.8.0.0/api1/LandingPage.htm
This was created to work with on-premise MobileIron service (not for Cloud edition)

```
PS C:\tmp> Get-Command -Module PSMobileIron

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Add-MIDevice                                       0.0        PSMobileIron
Function        Clear-MIDevice                                     0.0        PSMobileIron
Function        Get-MIDevice                                       0.0        PSMobileIron
Function        Get-MILabel                                        0.0        PSMobileIron
Function        Get-MIUser                                         0.0        PSMobileIron
Function        Lock-MIDevice                                      0.0        PSMobileIron
Function        Remove-MIDevice                                    0.0        PSMobileIron
Function        Remove-MILabel                                     0.0        PSMobileIron
Function        Send-MIMessage                                     0.0        PSMobileIron
Function        Set-MILabel                                        0.0        PSMobileIron
Function        Unlock-MIDevice                                    0.0        PSMobileIron
```

# How to get help
```
PS C:\tmp> Get-Help Add-MIDevice

NAME
    Add-MIDevice

SYNOPSIS
    Add a new MobileIron device


SYNTAX
    Add-MIDevice -Server <String> -Credential <PSCredential> -Platform <String> -UserId <String> -ImportUserFromLDAP
    -PDA [-NotifyUser] [-NotifyUserBySMS] [<CommonParameters>]

    Add-MIDevice -Server <String> -Credential <PSCredential> -Platform <String> -UserId <String> -ImportUserFromLDAP
    -PhoneNumber <String> -CountryCode <Int32> -Operator <String> [-NotifyUser] [-NotifyUserBySMS] [<CommonParameters>]

    Add-MIDevice -Server <String> -Credential <PSCredential> -Platform <String> -UserId <String> -PhoneNumber <String>
    -CountryCode <Int32> -Operator <String> [-Firstname <String>] [-Surname <String>] [-Email <String>] [-NotifyUser]
    [-NotifyUserBySMS] [<CommonParameters>]

    Add-MIDevice -Server <String> -Credential <PSCredential> -Platform <String> -UserId <String> -PDA [-Firstname
    <String>] [-Surname <String>] [-Email <String>] [-NotifyUser] [-NotifyUserBySMS] [<CommonParameters>]


DESCRIPTION
    Add a new MobileIron device


RELATED LINKS

REMARKS
    To see the examples, type: "get-help Add-MIDevice -examples".
    For more information, type: "get-help Add-MIDevice -detailed".
    For technical information, type: "get-help Add-MIDevice -full".
```
