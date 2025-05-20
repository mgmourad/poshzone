function Get-BIOSConfig{

<#
.SYNOPSIS
    Retrieves Dell BIOS configuration information for a specified host or model from SCCM.

.DESCRIPTION
    The Get-BIOSConfig function queries the SCCM server using WMI to retrieve BIOS settings
    from the Dell DCIM BIOS Enumeration class. It supports two modes of operation:
    - By computer hostname
    - By computer model

    The function connects to SCCM Management Point and Namespace to perform WMI queries.

.PARAMETER HostName
    The name of a single computer to retrieve BIOS configuration for. This triggers a host-based query.

.PARAMETER Model
    The model name (or partial name) of computers to retrieve BIOS settings across multiple systems.
    Useful for comparing BIOS settings by model.

.EXAMPLE
    Get-BIOSConfig -HostName "PC-00123"

    Retrieves BIOS configuration details for the specified computer.

.EXAMPLE
    Get-BIOSConfig -Model "3591"

    Retrieves BIOS setting options across all devices matching the model "Latitude 3591".

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns one or more PowerShell objects containing BIOS setting names, descriptions,
    possible values, and current values.

.NOTES
    Author: Mohammed Mourad


    Dependencies:
    - Requires access to the specified SCCM WMI namespace.
    - Assumes Dell BIOS classes are present in SCCM.

.LINK
    https://learn.microsoft.com/en-us/powershell/scripting/

#>

    [CmdletBinding()]

        Param(
          [Parameter(Mandatory=$false, ParameterSetName='byHostName')]
          [String]$HostName,
          [Parameter(Mandatory=$false, ParameterSetName='byModel')]
          [String]$Model
        )

#Global Variables
$YourSCCMServer  ='Server.domain.local'
$NAMESPACE  ='root\sms\Site_Code'

#HostName Query
$byHostName =
@"
SELECT * FROM SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0
LEFT JOIN SMS_G_System_COMPUTER_SYSTEM
ON SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.resourceid
= SMS_G_System_COMPUTER_SYSTEM.resourceid
WHERE SMS_G_System_COMPUTER_SYSTEM.Name = '$HostName'
"@

#Model Query
$byModel =
@"
SELECT DISTINCT SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.attributename,
SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.possiblevaluesdescription,
SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.possiblevalues,
SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.currentvalue
FROM SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0
WHERE ResourceID in (SELECT ResourceID FROM
SMS_G_System_COMPUTER_SYSTEM WHERE Model like '%$Model%')
"@


        switch($PSCmdlet.ParameterSetName){

              'byHostName'{
                  $Query = $byHostName
                  $Results = Get-WmiObject -ComputerName $smsmp -Namespace $smsns -Query $Query
                  Write-Host "Gathering BIOS Information..." -ForegroundColor Yellow
                  $ResultsDisplayed =@()
                  if($Results -ne $null){
                    foreach ($result in $Results){

                          $Props = [Ordered]@{

                            BIOS_Setting= $result.SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.attributename
                            Value_Desc=$result.SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.possiblevaluesdescription
                            Value_NUM=$result.SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.possiblevalues
                            Value_Current=$result.SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0.currentvalue

                          }

                      $ResultsDisplayed += New-Object -TypeName PSObject -Property $Props
                    }
                      $ResultsDisplayed | sort BIOS_Setting
                  }
                }




              'byModel'{
              $Query = $byModel
              $Results = Get-WmiObject -ComputerName $smsmp -Namespace $smsns -Query $Query
              $ResultsCount= ($Results.SMS_G_System_DELL_DCIM_BIOSENUMERATION_1_0 | %{$_.resourceid} | Get-Unique).count
              Write-Host "Gathering BIOS Information..." -ForegroundColor Yellow
              Write-Host "[$($ResultsCount)] Devices Found..." -ForegroundColor Green


              if($Results -ne $null){
                    foreach ($result in $Results){

                          $Props = [Ordered]@{
                            #HostName = $result.SMS_G_System_COMPUTER_SYSTEM.Name
                            BIOS_Setting= $result.attributename
                            Value_Desc=$result.possiblevaluesdescription
                            Value_NUM=$result.possiblevalues
                            Value_Current=$result.currentvalue
                          }

                      New-Object -TypeName PSObject -Property $Props
                    }
                 }
              }
              default {

              write-host  "No Results Found!!!" -ForegroundColor red

              }
        }


}
