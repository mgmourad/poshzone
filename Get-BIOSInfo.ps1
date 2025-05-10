function Get-BIOSInfo
  {
    <#
    .
    .SYNOPSIS
        Retrieves BIOS information from a system based on different filtering criteria.

    .DESCRIPTION
        The `Get-NTTABIOSInfo` function queries the WMI database to retrieve BIOS information, such as BIOS version, model, hostname, and username. It supports filtering the results based on various parameters, including host name, model, BIOS version, username, or resource ID. This function is helpful for system administrators who need to gather BIOS data across multiple systems in a network.

    .PARAMETER HostName
        The hostname of the computer system to query. The function filters results based on the exact match of the hostname.
        This parameter is mandatory when using the `ByHostName` parameter set.

    .PARAMETER Model
        The model of the computer system to query. The function filters results based on the model name (partial match).
        This parameter is mandatory when using the `ByModel` parameter set.

    .PARAMETER BIOSVersion
        The BIOS version to query. The function filters results based on the BIOS version (partial match).
        This parameter is mandatory when using the `ByBIOSVersion` parameter set.

    .PARAMETER UserName
        The username of the user logged into the system to query. The function filters results based on the username (partial match).
        This parameter is mandatory when using the `ByUserName` parameter set.

    .PARAMETER ResourceID
        The resource ID of the system to query. The function filters results based on an exact match of the resource ID.
        This parameter is optional and is used with the `ByResourceID` parameter set.

    .EXAMPLE
        Get-BIOSInfo -HostName DEVICE1

        HostName    : DEVICE1
        BIOSVersion : 1.28.0
        Model       : XPS 15 9575
        UserName    : mmourad
        ResourceID  : 16798401

    .EXAMPLE
        Get-NTTABIOSInfo -Model 'XPS 15 9575'

        HostName  BIOSVersion Model       UserName       ResourceID
        --------  ----------- -----       --------       ----------
        Device1 1.15.1      XPS 15 9575 HPotter          16792001
        Device2 1.28.0      XPS 15 9575 CWoman           16793692
        Device3 1.28.0      XPS 15 9575 WWoman           16795010
        Device4 1.10.0      XPS 15 9575 Sman             16795275
        Device5 1.28.0      XPS 15 9575 KWest            16795402
        Device6 1.10.0      XPS 15 9575 KKardashian      16795409


    .NOTES
        Author: Mohammed Mourad
        Date: 2025-05-06
        This function queries the WMI database of a system using various filtering criteria to gather BIOS-related information.
        The function will exclude VMware-based systems by checking that the manufacturer does not contain the string "vmware".
        If no matching results are found, a message will be displayed indicating that no BIOS information was found.


    #>
      [cmdletbinding()]

      param(

      [Parameter(Mandatory=$true, ParameterSetName="ByHostName")]
      $HostName,

      [Parameter(Mandatory=$true, ParameterSetName="ByModel")]
      $Model,

      [Parameter(Mandatory=$true, ParameterSetName="ByBIOSVersion")]
      $BIOSVersion,

      [Parameter(Mandatory=$true, ParameterSetName="ByUserName")]
      $UserName,

      [Parameter(Mandatory=$true, ParameterSetName="ByResourceID")]
      $ResourceID

      )


      $ByHostName =
      @"
      SELECT *
      FROM SMS_G_System_PC_BIOS
      LEFT JOIN SMS_G_System_COMPUTER_SYSTEM
      ON SMS_G_System_PC_BIOS.ResourceID =
      SMS_G_System_COMPUTER_SYSTEM.ResourceID
      WHERE SMS_G_System_COMPUTER_SYSTEM.Name ='$HostName'
      AND SMS_G_System_PC_BIOS.Manufacturer NOT LIKE '%vmware%'
"@


      $ByModel =
      @"
      SELECT *
      FROM SMS_G_System_PC_BIOS
      LEFT JOIN SMS_G_System_COMPUTER_SYSTEM
      ON SMS_G_System_PC_BIOS.ResourceID =
      SMS_G_System_COMPUTER_SYSTEM.ResourceID
      WHERE SMS_G_System_COMPUTER_SYSTEM.Model like '%$Model%'
      AND SMS_G_System_PC_BIOS.Manufacturer NOT LIKE '%vmware%'
"@


      $ByBIOSVersion =
      @"
      SELECT *
      FROM SMS_G_System_PC_BIOS
      LEFT JOIN SMS_G_System_COMPUTER_SYSTEM
      ON SMS_G_System_PC_BIOS.ResourceID =
      SMS_G_System_COMPUTER_SYSTEM.ResourceID
      WHERE SMS_G_System_PC_BIOS.BIOSVersion like '%$BIOSVersion%'
      AND SMS_G_System_PC_BIOS.Manufacturer NOT LIKE '%vmware%'
"@


      $ByUserName =
      @"
      SELECT *
      FROM SMS_G_System_PC_BIOS
      LEFT JOIN SMS_G_System_COMPUTER_SYSTEM
      ON SMS_G_System_PC_BIOS.ResourceID =
      SMS_G_System_COMPUTER_SYSTEM.ResourceID
      WHERE SMS_G_System_COMPUTER_SYSTEM.UserName like '%$UserName%'
      AND SMS_G_System_PC_BIOS.Manufacturer NOT LIKE '%vmware%'
"@


      $ByResourceID =
      @"
      SELECT *
      FROM SMS_G_System_PC_BIOS
      LEFT JOIN SMS_G_System_COMPUTER_SYSTEM
      ON SMS_G_System_PC_BIOS.ResourceID =
      SMS_G_System_COMPUTER_SYSTEM.ResourceID
      WHERE SMS_G_System_PC_BIOS.ResourceID ='$ResourceID'
      AND SMS_G_System_PC_BIOS.Manufacturer NOT LIKE '%vmware%'
"@

    Switch($PSCmdlet.ParameterSetName)
    {
        'ByHostName' { $Query = $ByHostName }
        'ByModel' { $Query = $ByModel }
        'ByBIOSVersion' { $Query = $ByBIOSVersion }
        'ByUserName' { $Query = $ByUserName }
        'ByResourceID' { $Query = $ByResourceID }
    }

      # Storing the query results
      $Results = Get-WmiObject -ComputerName $smsmp -Namespace $smsns -Query $Query -ErrorAction SilentlyContinue

      if ($Results -ne $null) {

          Write-Host "Gathering BIOS information..." -ForegroundColor Yellow
          Write-Host "[$($Results.count)] Results found." -ForegroundColor Yellow


          foreach ($singleresult in $Results){

            # removing 'SERVERNAME\' from usernames
          $UserNameClean = $singleresult.SMS_G_System_COMPUTER_SYSTEM.UserName -replace 'SERVERNAME\\',''

          $Props = [Ordered]@{
              'HostName' = $singleresult.SMS_G_System_COMPUTER_SYSTEM.Name
              'BIOSVersion' = $singleresult.SMS_G_System_PC_BIOS.SMBIOSBIOSVersion
              'Model' = $singleresult.SMS_G_System_COMPUTER_SYSTEM.Model
              'UserName' = $UserNameClean
              'ResourceID' = $singleresult.SMS_G_System_PC_BIOS.ResourceID
          }
          # Displaying structured results
          New-Object PSObject -Property $Props
        }
      }
      else {
        # Error Handling if no information found
          Write-Host "No BIOS information found!!!" -ForegroundColor Red

      }

  }
