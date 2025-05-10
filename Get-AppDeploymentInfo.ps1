
function Get-AppDeploymentInfo
{
    <#
    .SYNOPSIS
        Function that collects information about app deployment  with more context
        in app enforcement state.
    .DESCRIPTION
        This function retrieves the deployment information for a specified application.
        Specifying an app is optional. Otherwise, if using other parameter such as HostName,
        UserName or CollectionID, the function will gather all possible information about all
        deployments with their deployment status within the scope of the specified parameter.
    .PARAMETER AppName
        The name of the application to retrieve deployment information for. Use single quotes for
        longer app names such as 'Google Chrome', otherwise a single word could be used without
        quotes (No wild cards needed as it's applied automatically)
    .PARAMETER CollectionID
        The CollectionID parameter is used to retrieve information about deployment errors
        within the members of the specified CollectionID (App Collections.)
    .PARAMETER UserName
        The UserName parameter has to be exact (No wildcard match accepted)
    .PARAMETER HostName
        The HostName parameter used to retrieve all the deployment error informatin of all
        apps deployed to that hostname (if an app name wasn't specified). Otherwise, use AppName
        parameter combined with HostName to narrow down the function results.
    .PARAMETER Status
        The Status parameter is used to narrow down the function results to be within the
        specified deployment status. [you can tab (cycle) through the available statuses]
    .EXAMPLE
        Get-AppDeploymentInfo -AppName chrome -HostName DEVICE1

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.60
        Status           : Error
        EnforcementState : Deployment failed
        CollectionID     : XYZ00123
        CollectionName   : Active Workstations with Google Chrome
        HostName         : DEVICE1
        UserName         : JDOE

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.60 - SWC
        Status           : UNKNOWN_STATUS
        EnforcementState : UNKNOWN_STATE
        CollectionID     : XYZ00128
        CollectionName   : All Workstations Active
        HostName         : DEVICE1
        UserName         : JDOE

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.142
        Status           : Success
        EnforcementState : Success
        CollectionID     : XYZ00123
        CollectionName   : Active Workstations with Google Chrome
        HostName         : DEVICE1
        UserName         : JDOE

        AppName          : Google Chrome 136.0.7103.49 (x86)
        Status           : InProgress
        EnforcementState : Content downloaded
        CollectionID     : XYZ00123
        CollectionName   : Active Workstations with Google Chrome
        HostName         : DEVICE1
        UserName         : JDOE


        Get-AppDeploymentInfo -CollectionID XYZ00123 -Status Error

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.142
        Status           : Error
        EnforcementState : Deployment failed
        CollectionID     : XYZ00123
        CollectionName   : Active Workstations with Google Chrome
        HostName         : Workstation1
        UserName         : HPotter

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.142
        Status           : Error
        EnforcementState : Deployment failed
        CollectionID     : XYZ00123
        CollectionName   : Active Workstations with Google Chrome
        HostName         : Workstation2
        UserName         : SMan

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.142
        Status           : Error
        EnforcementState : Deployment failed
        CollectionID     : XYZ00123
        CollectionName   : Active Workstations with Google Chrome
        HostName         : Workstation3
        UserName         : IMan

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.142
        Status           : Error
        EnforcementState : Deployment failed
        CollectionID     : XYZ00123
        CollectionName   : Active Workstations with Google Chrome
        HostName         : workstation4
        UserName         : BMan
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "ByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByHostNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByHostNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByStatusByHostNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByStatusByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionIDByAppName") ]
        [string]$AppName,

        [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionID") ]
        [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionIDByStatus") ]
        [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionIDByAppName") ]
        [string]$CollectionID,

        [Parameter(Mandatory = $true, ParameterSetName = "ByStatus")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByStatusByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByStatusByHostName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByStatusByHostNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionIDByStatus") ]
        [ValidateSet("Success", "InProgress", "RequirementsNotMet", "Unknown", "Error")]
        [string]$Status,

        [Parameter(Mandatory = $true, ParameterSetName = "ByHostName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByHostNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByHostNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByStatusByHostName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByStatusByHostNameByAppName")]
        [string]$HostName,

        [Parameter(Mandatory = $true, ParameterSetName = "ByUserName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByAppName")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByHostNameByAppName")]
        [string]$UserName

    )

Switch($Status)
{
    "Success" { $StatusNUM = '1' }
    "InProgress" { $StatusNUM = '2' }
    "RequirementsNotMet" { $StatusNUM = '3' }
    "Unknown" { $StatusNUM = '4' }
    "Error" { $StatusNUM = '5' }
}

# ByAppName - This will query based on AppName
$ByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.AppName like '%$AppName%'
"@

# ByUserNameByAppName - This will query based on both UserName and AppName
$ByUserNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.AppName like '%$AppName%'
AND SMS_CM_RES_COLL_SMS00001.UserName = '$UserName'
"@

# ByUserNameByHostNameByAppName - This will query based on UserName, HostName, and AppName
$ByUserNameByHostNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.AppName like '%$AppName%'
AND SMS_CM_RES_COLL_SMS00001.UserName = '$UserName'
AND SMS_AppDeploymentAssetDetails.MachineName = '$HostName'
"@

# ByHostNameByAppName - This will query based on HostName and AppName
$ByHostNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.AppName like '%$AppName%'
AND SMS_CM_RES_COLL_SMS00001.Name = '$HostName'
"@

# ByStatusByHostNameByAppName - This will query based on Status, HostName, and AppName
$ByStatusByHostNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.AppName like '%$AppName%'
AND SMS_AppDeploymentAssetDetails.StatusType = '$StatusNUM'
AND SMS_CM_RES_COLL_SMS00001.Name = '$HostName'
"@

# ByCollectionID - This will query based on CollectionID
$ByCollectionID = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.CollectionID = '$CollectionID'
"@

# ByCollectionIDByStatus - This will query based on CollectionID and Status
$ByCollectionIDByStatus = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.CollectionID = '$CollectionID'
AND SMS_AppDeploymentAssetDetails.StatusType = '$StatusNUM'
"@

# ByStatus - This will query based on Status
$ByStatus = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.StatusType = '$StatusNUM'
"@

$ByStatusByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.StatusType = '$StatusNUM'
AND SMS_AppDeploymentAssetDetails.AppName = '$AppName'
"@

# ByStatusByHostName - This will query based on Status and HostName
$ByStatusByHostName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.StatusType = '$StatusNUM'
AND SMS_AppDeploymentAssetDetails.MachineName = '$HostName'
"@

# ByStatusByHostNameByAppName - This will query based on Status, HostName, and AppName
$ByStatusByHostNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.StatusType = '$StatusNUM'
AND SMS_AppDeploymentAssetDetails.MachineName = '$HostName'
AND SMS_AppDeploymentAssetDetails.AppName like '%$AppName%'
"@

# ByHostName - This will query based on HostName
$ByHostName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.MachineName = '$HostName'
"@

# ByUserName - This will query based on UserName
$ByUserName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_CM_RES_COLL_SMS00001.UserName = '$UserName'
"@


$ByCollectionIDByAppName = @"
SELECT *
FROM SMS_AppDeploymentAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentAssetDetails.CollectionID = '$CollectionID'
AND SMS_AppDeploymentAssetDetails.AppName like '%$AppName%'
"@

 switch ($PSCmdlet.ParameterSetName) {
    'ByAppName' { $Query = $ByAppName }
    'ByUserNameByAppName' { $Query = $ByUserNameByAppName }
    'ByUserNameByHostNameByAppName' { $Query = $ByUserNameByHostNameByAppName }
    'ByHostNameByAppName' { $Query = $ByHostNameByAppName }
    'ByStatusByHostNameByAppName' { $Query = $ByStatusByHostNameByAppName }
    'ByCollectionID' { $Query = $ByCollectionID }
    'ByCollectionIDByStatus' { $Query = $ByCollectionIDByStatus }
    'ByCollectionIDByAppName' { $Query = $ByCollectionIDByAppName }
    'ByStatus' { $Query = $ByStatus }
    'ByStatusByHostName' { $Query = $ByStatusByHostName }
    'ByStatusByAppName' { $Query = $ByStatusByAppName }
    'ByHostName' { $Query = $ByHostName }
    'ByUserName' { $Query = $ByUserName }

 }

 Write-Host 'Gathering results. Please wait...' -Fore Yellow

 $Results = Get-WmiObject -ComputerName $smsmp -Namespace $smsns -Query $Query -ErrorAction SilentlyContinue

    if ($Results -ne $null) {

        $ResultsCount = ($Results | Measure-Object).Count
        Write-Host ''
        Write-Host "Results:[$ResultsCount]" -Fore Yellow

        # Loop through the results and create a custom object for each
        foreach ($result in $Results) {
            $resultAppName          = $result.SMS_AppDeploymentAssetDetails.AppName
            $resultStatus           = $result.SMS_AppDeploymentAssetDetails.StatusType
            $resultEnforcementState = $result.SMS_AppDeploymentAssetDetails.EnforcementState
            $resultCollectionID     = $result.SMS_AppDeploymentAssetDetails.CollectionID
            $resultCollectionName   = $result.SMS_AppDeploymentAssetDetails.CollectionName
            $resultHostName         = $result.SMS_AppDeploymentAssetDetails.MachineName
            $resultUserName         = $result.SMS_CM_RES_COLL_SMS00001.UserName


        # Convert the StatusType to a more readable format
        Switch($resultStatus) {
            1 { $resultStatus = 'Success' }
            2 { $resultStatus = 'InProgress' }
            3 { $resultStatus = 'RequirementsNotMet' }
            4 { $resultStatus = 'Unknown' }
            5 { $resultStatus = 'Error' }
            default {$resultStatus ='UNKNOWN_STATUS'}
        }


        # Convert the EnforcementState to a more readable format
        Switch($resultEnforcementState) {
            1000 { $resultEnforcementState = 'Success' }
            1001 { $resultEnforcementState = 'Already Compliant' }
            1002 { $resultEnforcementState = 'Simulate Success' }
            2000 { $resultEnforcementState = 'In progress' }
            2001 { $resultEnforcementState = 'Waiting for content' }
            2002 { $resultEnforcementState = 'Installing' }
            2003 { $resultEnforcementState = 'Restart to continue' }
            2004 { $resultEnforcementState = 'Waiting for maintenance window' }
            2005 { $resultEnforcementState = 'Waiting for schedule' }
            2006 { $resultEnforcementState = 'Downloading dependent content' }
            2007 { $resultEnforcementState = 'Installing dependent content' }
            2008 { $resultEnforcementState = 'Restart to complete' }
            2009 { $resultEnforcementState = 'Content downloaded' }
            2010 { $resultEnforcementState = 'Waiting for update' }
            2011 { $resultEnforcementState = 'Waiting for user session reconnect' }
            2012 { $resultEnforcementState = 'Waiting for user logoff' }
            2013 { $resultEnforcementState = 'Waiting for user logon' }
            2014 { $resultEnforcementState = 'Waiting To Install' }
            2015 { $resultEnforcementState = 'Waiting Retry' }
            2016 { $resultEnforcementState = 'Waiting For Presentation Mode' }
            2017 { $resultEnforcementState = 'Waiting For Orchestration' }
            2018 { $resultEnforcementState = 'Waiting For Network' }
            2019 { $resultEnforcementState = 'Pending App-V Virtual Environment Update' }
            2020 { $resultEnforcementState = 'Updating App-V Virtual Environment' }
            3000 { $resultEnforcementState = 'Requirements not met' }
            3001 { $resultEnforcementState = 'Host Platform Not Applicable' }
            4000 { $resultEnforcementState = 'Unknown' }
            5000 { $resultEnforcementState = 'Deployment failed' }
            5001 { $resultEnforcementState = 'Evaluation failed' }
            5002 { $resultEnforcementState = 'Deployment failed' }
            5003 { $resultEnforcementState = 'Failed to locate content' }
            5004 { $resultEnforcementState = 'Dependency installation failed' }
            5005 { $resultEnforcementState = 'Failed to download dependent content' }
            5006 { $resultEnforcementState = 'Conflicts with another application deployment' }
            5007 { $resultEnforcementState = 'Waiting Retry' }
            5008 { $resultEnforcementState = 'Failed to uninstall superseded deployment type' }
            5009 { $resultEnforcementState = 'Failed to download superseded deployment type' }
            5010 { $resultEnforcementState = 'Failed to updating App-V Virtual Environment' }
            default {$resultEnforcementState= 'UNKNOWN_STATE'}
        }

        # Create a custom object to store the results
        $Props=[Ordered]@{
            AppName          = $resultAppName
            Status           = $resultStatus
            EnforcementState = $resultEnforcementState
            CollectionID     = $resultCollectionID
            CollectionName   = $resultCollectionName
            HostName         = $resultHostName
            UserName         = $resultUserName
        }

        New-Object -TypeName PSObject -Property $Props

        }
    }
    else {
        Write-Host "No results found for the specified criteria." -ForegroundColor Red
    }



}
