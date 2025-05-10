
Function Get-AppDeploymentErrorInfo{
<#
    .SYNOPSIS
        Function that collects information about app deployment errors with more context
        from app enforcement state.
    .DESCRIPTION
        This function retrieves the deployment error information for a specified application.
        Specifying an app is optional. Otherwise, if using other parameter such as HostName,
        UserName or CollectionID, the function will gather all possible information about all
        deploymnets with errors with the scope of the specified parameter.
    .PARAMETER AppName
        The name of the application to retrieve deployment error information for. Use single quotes for
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
    .EXAMPLE
        Get-AppDeploymentErrorInfo -AppName chrome -HostName DEVICE1

        AppName          : Google Chrome Enterprise x86 - v133.0.6943.60
        Error            : Fatal error during installation.
        EnforcementState : Deployment failed
        CollectionID     : XYZ12345
        CollectionName   : Active Workstations with Google Chrome
        HostName         : DEVICE1
        UserName         : JDOE


        Get-AppDeploymentErrorInfo -CollectionID XYZ12345

        AppName          : Adobe Acrobat Reader DC - 24.005.20414
        Error            : Deployment failed! Check content source and deployment configuration
        EnforcementState : Deployment failed
        CollectionID     : XYZ12345
        CollectionName   : Service Desk Workstations
        HostName         : DEVICE1
        UserName         : DJOE

        AppName          : Adobe Acrobat Reader DC - 24.005.20414
        Error            : Fatal error during installation.
        EnforcementState : Deployment failed
        CollectionID     : XYZ12345
        CollectionName   : Service Desk Workstations
        HostName         : DEVICE2
        UserName         : NTyson

        AppName          : Adobe Acrobat Reader DC - 24.005.20414
        Error            : Deployment failed! Check content source and deployment configuration
        EnforcementState : Deployment failed
        CollectionID     : XYZ12345
        CollectionName   : Service Desk Workstations
        HostName         : DEVICE13
        UserName         : HPotter

        AppName          : Adobe Acrobat Reader DC - 24.005.20414
        Error            : Deployment failed! Check content source and deployment configuration
        EnforcementState : Deployment failed
        CollectionID     : XYZ12345
        CollectionName   : Service Desk Workstations
        HostName         : DEVICE4
        UserName         : KSauron

    #>


  [CmdletBinding()]

    Param(
          [Parameter(Mandatory = $true, ParameterSetName = "ByAppName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByAppName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByHostNameByAppName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByHostNameByAppName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionIDByAppName") ]
          [String]$AppName,


          [Parameter(Mandatory = $true, ParameterSetName = "ByHostName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByHostNameByAppName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByHostNameByAppName")]
          [String]$HostName,

          [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionID") ]
          [Parameter(Mandatory = $true, ParameterSetName = "ByCollectionIDByAppName") ]
          [String]$CollectionID,

          [Parameter(Mandatory = $true, ParameterSetName = "ByUserName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByAppName")]
          [Parameter(Mandatory = $true, ParameterSetName = "ByUserNameByHostNameByAppName")]
          [String]$UserName

    )





$ByAppName = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.AppName like '%$AppName%'
"@

# ByUserNameByAppName - This will query based on both UserName and AppName
$ByUserNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.AppName like '%$AppName%'
AND SMS_CM_RES_COLL_SMS00001.UserName = '$UserName'
"@

# ByUserNameByHostNameByAppName - This will query based on UserName, HostName, and AppName
$ByUserNameByHostNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.AppName like '%$AppName%'
AND SMS_CM_RES_COLL_SMS00001.UserName = '$UserName'
AND SMS_AppDeploymentErrorAssetDetails.MachineName = '$HostName'
"@

# ByHostNameByAppName - This will query based on HostName and AppName
$ByHostNameByAppName = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.AppName like '%$AppName%'
AND SMS_CM_RES_COLL_SMS00001.Name = '$HostName'
"@

$ByHostName = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.MachineName = '$HostName'
"@

# ByUserName - This will query based on UserName
$ByUserName = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.UserName = '$UserName'
"@

# ByCollectionID - This will query based on CollectionID
$ByCollectionID = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.CollectionID = '$CollectionID'
"@

$ByCollectionIDByAppName = @"
SELECT *
FROM SMS_AppDeploymentErrorAssetDetails
LEFT JOIN SMS_CM_RES_COLL_SMS00001
ON SMS_AppDeploymentErrorAssetDetails.MachineName = SMS_CM_RES_COLL_SMS00001.Name
WHERE SMS_AppDeploymentErrorAssetDetails.CollectionID = '$CollectionID'
AND SMS_AppDeploymentErrorAssetDetails.AppName like '%$AppName%'
"@


switch ($PSCmdlet.ParameterSetName) {
'ByAppName' { $Query = $ByAppName }
'ByUserNameByAppName' { $Query = $ByUserNameByAppName }
'ByUserNameByHostNameByAppName' { $Query = $ByUserNameByHostNameByAppName }
'ByHostNameByAppName' { $Query = $ByHostNameByAppName }
'ByCollectionID' { $Query = $ByCollectionID }
'ByCollectionIDByAppName' { $Query = $ByCollectionIDByAppName }
'ByHostName' { $Query = $ByHostName }
'ByUserName' { $Query = $ByUserName }
}


Write-Host 'Gathering results. Please wait...' -Fore Yellow

$Results = Get-WmiObject -ComputerName $smsmp -Namespace $smsns -Query $Query -ErrorAction SilentlyContinue


if ($Results -ne $null) {

$ResultsCount = ($Results | Measure-Object).Count
Write-Host ''
Write-Host "Results:[$ResultsCount]" -Fore Yellow

foreach ($result in $Results) {
$resultAppName          = $result.SMS_AppDeploymentErrorAssetDetails.AppName
$resultError            = $result.SMS_AppDeploymentErrorAssetDetails.ErrorCode
$resultEnforcementState = $result.SMS_AppDeploymentErrorAssetDetails.EnforcementState
$resultCollectionID     = $result.SMS_AppDeploymentErrorAssetDetails.CollectionID
$resultCollectionName   = $result.SMS_AppDeploymentErrorAssetDetails.CollectionName
$resultHostName         = $result.SMS_AppDeploymentErrorAssetDetails.MachineName
$resultUserName         = $result.SMS_CM_RES_COLL_SMS00001.UserName



Switch($resultError) {

0     { $resultError = 'Success [Also check Enforcement State]' }
13    { $resultError = 'The data is invalid.' }
87    { $resultError = 'One of the parameters was invalid.' }
120   { $resultError = 'This function is not available for this platform. It is only available on Windows 2000 and Windows XP with Window Installer version 2.0.' }
1259  { $resultError = 'This error code only occurs with Windows Installer 2.0 and Windows XP or later. Returned if user chooses not to proceed after compatibility warning.' }
1601  { $resultError = 'The Windows Installer service could not be accessed. Contact your support personnel.' }
1602  { $resultError = 'User cancelled installation.' }
1603  { $resultError = 'Fatal error during installation.' }
1604  { $resultError = 'Installation suspended, incomplete.' }
1605  { $resultError = 'This action is only valid for products that are currently installed.' }
1606  { $resultError = 'Feature ID not registered.' }
1607  { $resultError = 'Component ID not registered.' }
1608  { $resultError = 'Unknown property.' }
1609  { $resultError = 'Handle is in an invalid state.' }
1610  { $resultError = 'The configuration data for this product is corrupt. Contact your support personnel.' }
1611  { $resultError = 'Component qualifier not present.' }
1612  { $resultError = 'The installation source is not available. Verify that the source exists and is accessible.' }
1613  { $resultError = 'This installation package cannot be installed by the Windows Installer service. Install a newer version.' }
1614  { $resultError = 'Product is uninstalled.' }
1615  { $resultError = 'SQL query syntax invalid or unsupported.' }
1616  { $resultError = 'Record field does not exist.' }
1618  { $resultError = 'Another installation is already in progress. Complete that before proceeding.' }
1619  { $resultError = 'This installation package could not be opened. Verify its existence and access.' }
1620  { $resultError = 'Installation package could not be opened. Contact the vendor.' }
1621  { $resultError = 'Error starting the Windows Installer service UI. Contact support.' }
1622  { $resultError = 'Error opening installation log file. Verify the log path exists and is writable.' }
1623  { $resultError = 'The language of this package is not supported by your system.' }
1624  { $resultError = 'Error applying transforms. Verify transform paths are valid.' }
1625  { $resultError = 'Installation is forbidden by system policy. Contact administrator.' }
1626  { $resultError = 'Function could not be executed.' }
1627  { $resultError = 'Function failed during execution.' }
1628  { $resultError = 'Invalid or unknown table specified.' }
1629  { $resultError = 'Data supplied is of wrong type.' }
1630  { $resultError = 'Data of this type is not supported.' }
1631  { $resultError = 'The Windows Installer service failed to start. Contact your support personnel.' }
1632  { $resultError = 'Temp folder is either full or inaccessible. Check permissions and space.' }
1633  { $resultError = 'Package is not supported on this platform. Contact the vendor.' }
1634  { $resultError = 'Component not used on this machine.' }
1635  { $resultError = 'Patch package could not be opened. Verify access and validity.' }
1636  { $resultError = 'Patch package could not be opened. Contact the vendor.' }
1637  { $resultError = 'Patch cannot be processed. Install a newer Windows Installer version.' }
1638  { $resultError = 'Another version of this product is already installed. Use Add/Remove Programs to modify or remove.' }
1639  { $resultError = 'Invalid command line argument. Refer to the Windows Installer SDK.' }
1640  { $resultError = 'Installation from a Terminal Server client session not permitted for current user.' }
1641  { $resultError = 'The installer has started a reboot. Not available on Windows Installer version 1.0.' }
1642  { $resultError = 'Installer cannot install the upgrade patch because the program being upgraded may be missing or is a different version.' }
1643  { $resultError = 'Patch package is not permitted by system policy. Requires Windows Installer 2.0 or later.' }
1644  { $resultError = 'One or more customizations are not permitted by system policy. Requires Windows Installer 2.0 or later.' }
3010  { $resultError = 'A reboot is required to complete the install. Not an error per se.' }
4294967295 { $resultError = 'Script execution failed with error code -1' }
10         { $resultError = 'The unit test error string' }
131072512  { $resultError = 'The client is successfully assigned with Group Policy Site Assignment' }
131073314  { $resultError = 'No more data' }
131073589  { $resultError = 'The scan was skipped because history was valid' }
2278689294 { $resultError = 'Shutdown received while compressing' }
2278689293 { $resultError = 'Unexpected error while compressing' }
2278689292 { $resultError = 'Already compressed' }
2278689291 { $resultError = 'Failed to create file header while compressing' }
2278689290 { $resultError = 'Failed to create file while compressing' }
2278689289 { $resultError = 'Failed to create folder while compressing' }
2278689288 { $resultError = 'Invalid compressed header in the file' }
2278689287 { $resultError = 'Invalid compressed file' }
2278689286 { $resultError = 'Failed to compress header' }
2278689285 { $resultError = 'The file is no more there to compress' }
2278689284 { $resultError = 'Invalid destination for compression' }
2278689283 { $resultError = 'Invalid source for compression' }
2278689282 { $resultError = 'Compression destination not found' }
2278689281 { $resultError = 'Compression source not found' }
2278689029 { $resultError = 'SEDO lock request timed out' }
2278689028 { $resultError = 'SEDO lock not found' }
2278689027 { $resultError = 'Invalid object path for SEDO' }
2278689026 { $resultError = 'SEDO request ID not found' }
2278689025 { $resultError = 'SEDO needs lock ID or Rel path' }
2278688778 { $resultError = 'Certificate not found' }
2278688777 { $resultError = 'Invalid data in the certificate' }
2278688776 { $resultError = 'Failed to find certificate' }
2278688775 { $resultError = 'Failed to decrypt the certificate' }
2278688774 { $resultError = 'Failed to delete certificate store' }
2278688773 { $resultError = 'Failed to write in the certificate store' }
2278688772 { $resultError = 'Failed to open the certificate store' }
2278688771 { $resultError = 'Error reading peers encoded certificate' }
2278688770 { $resultError = 'Error reading certificate' }
2278688769 { $resultError = 'Service Host Name property is either missing or invalid' }
2278688520 { $resultError = 'The specified item to update is not found in Site Control File' }
2278688519 { $resultError = 'Invalid FQDN found in Site Control File' }
2278688518 { $resultError = 'Legacy type item in Site Control File' }
2278688517 { $resultError = 'Site not found in Site Control File' }
2278688516 { $resultError = 'Bad data in Site Control File' }
2278688515 { $resultError = 'Item type not known in Site Control File' }
2278688514 { $resultError = 'Item not found in Site Control File' }
2278688513 { $resultError = 'Unknown property in Site Control File' }
2278688290 { $resultError = 'SRS data source has been modified or deleted' }
2278688289 { $resultError = 'SRS root folder is not present' }
2278688288 { $resultError = 'SRS is not installed or not properly configured' }
2278688277 { $resultError = 'SRS web service is not running' }
2278688018 { $resultError = 'The machine is not assigned to this site' }
2278688017 { $resultError = 'The machine is not an SMS client' }
2278688016 { $resultError = 'Machine not found foreign key constraint' }
2278687767 { $resultError = 'Auto Deployment Rule download failed' }
2278687766 { $resultError = 'No rule filters specified for the Auto Deployment Rule' }
2278687765 { $resultError = 'Auto Deployment Rule results exceeded the maximum number of updates' }
2278687764 { $resultError = 'Cannot Configure WU/MU as an upstream server on Peer Primary' }
2278687763 { $resultError = 'Active SUP not selected' }
2278687759 { $resultError = 'WSUS Server component failure' }
2278687758 { $resultError = 'WSUS Server Database connection failure' }
2278687757 { $resultError = 'Failed to set Parent WSUS Configuration on the child sites' }
2278687756 { $resultError = 'WSUS server not ready' }
2278687499 { $resultError = 'Device Setting Item not found Foreign Key Constraint' }
2278687242 { $resultError = 'SDM Type not found Foreign Key Constraint' }
2278687241 { $resultError = 'Related SDM Package not found Foreign Key Constraint' }
2278687240 { $resultError = 'SDM Package was not found Foreign Key Constraint' }
2278687239 { $resultError = 'SDM Type not found Foreign Key Constraint' }
2278687238 { $resultError = 'EULA is not found Foreign Key Constraint' }
2278687237 { $resultError = 'Update Source was not found Foreign Key Constraint' }
2278687236 { $resultError = 'CI Type not found Foreign Key Constraint' }
2278687235 { $resultError = 'The category was not found Foreign Key Constraint' }
2278687234 { $resultError = 'Configuration Item not found Foreign Key Constraint' }
2278687233 { $resultError = 'Operation on Old Configuration Item when a newer instance exists in the Database' }
2278686977 { $resultError = 'Collection not found foreign key constraint' }
2278686768 { $resultError = 'Error while creating inbox' }
2278686752 { $resultError = 'Thread is signaled to be stopped' }
2278686739 { $resultError = 'Registry write error' }
2278686738 { $resultError = 'Registry read error' }
2278686737 { $resultError = 'Registry connection error' }
2278686728 { $resultError = 'SQL send batch error' }
2278686727 { $resultError = 'SQL queue row error' }
2278686726 { $resultError = 'SQL table binding error' }
2278686725 { $resultError = 'SQL deadlock error' }
2278686724 { $resultError = 'SQL error while registering type' }
2278686723 { $resultError = 'SQL Error' }
2278686722 { $resultError = 'SQL connection error' }
2278686721 { $resultError = 'Invalid data' }
2278686189 { $resultError = 'Unsupported setting discovery source' }
2278686188 { $resultError = 'Referenced setting not found in CI' }
2278686187 { $resultError = 'Data type conversion failed' }
2278686186 { $resultError = 'Invalid parameter to CIM setting' }
2278686185 { $resultError = 'Not applicable for this device' }
2278686184 { $resultError = 'Remediation failed' }
2278626187 { $resultError = 'iOS device has returned an error' }
2278626186 { $resultError = 'iOS device has rejected the command due to incorrect format' }
2278626185 { $resultError = 'iOS device has returned an unexpected Idle status' }
2278626184 { $resultError = 'iOS device is currently busy' }
2278623288 { $resultError = '(1404): Certificate access denied' }
2278623287 { $resultError = '(1403): Certificate not found' }
2278623286 { $resultError = 'DCMO(1402): The Operation failed' }
2278623285 { $resultError = 'DCMO(1401): User chose not to accept the operation when prompted' }
2278623284 { $resultError = 'DCMO(1400): Client error' }
2278623188 { $resultError = 'DCMO(1204): Device Capability is disabled, and the User is allowed to re-enable it' }
2278623187 { $resultError = 'DCMO(1203): Device Capability is disabled, and the User is not allowed to re-enable it' }
2278623186 { $resultError = 'DCMO(1202): Enable operation is successful, but the Device Capability is currently detached' }
2278623185 { $resultError = 'DCMO(1201): Enable operation is successful, and the Device Capability is currently attached' }
2278623184 { $resultError = 'DCMO(1200): Operation is performed successfully' }
2278623099 { $resultError = 'Operation not implemented on the client' }
2278623098 { $resultError = 'The package is an invalid upgrade' }
2278623097 { $resultError = 'The target location of the package is not accessible' }
2278623096 { $resultError = 'The installer is busy doing some other operation' }
2278623095 { $resultError = 'Network failure aborted the operation' }
2278623094 { $resultError = 'The package has no right to perform the operation' }
2278623093 { $resultError = 'Install/Uninstall Unknown error' }
2278623092 { $resultError = 'Mandatory file is in use and prevents the operation' }
2278623091 { $resultError = 'Package cannot be installed due to missing dependency' }
2278623090 { $resultError = 'Package cannot be installed due to a security error' }
2278623089 { $resultError = 'Package validation failed' }
2278623088 { $resultError = 'Installation of the package is not supported' }
2278623087 { $resultError = 'Insufficient free memory in the drive to perform the operation' }
2278623086 { $resultError = 'File is corrupted' }
2278623085 { $resultError = 'User canceled the operation' }
2278623084 { $resultError = 'The application was successfully installed' }
2278622784 { $resultError = 'An invalid OMA download descriptor received' }
2278622703 { $resultError = 'A maximum number of HTTP redirections has been reached' }
2278622702 { $resultError = 'Non-download specific error' }
2278622701 { $resultError = 'Internal error occurred. Likely a programming error' }
2278622700 { $resultError = 'An error occurred in the transaction' }
2278622699 { $resultError = 'General storage error' }
2278622698 { $resultError = 'Not enough disk space for the content' }
2278622697 { $resultError = 'Moving content file failed' }
2278622696 { $resultError = 'Invalid download drive' }
2278622695 { $resultError = 'File not found error' }
2278622694 { $resultError = 'File write failed' }
2278622693 { $resultError = 'Media where the download is being persisted was removed' }
2278622692 { $resultError = 'Download Manager cannot handle this URL' }
2278622691 { $resultError = 'Error in the destination filename' }
2278622690 { $resultError = 'Destination file cannot be opened/created' }
2278622689 { $resultError = 'Unhandled HTTP error code' }
2278622688 { $resultError = '404: Object not found' }
2278622687 { $resultError = '412: Partial content cannot be downloaded' }
2278622686 { $resultError = 'Paused content is expired' }
2278622685 { $resultError = 'Resuming progressive download failed' }
2278622585 { $resultError = 'Connection failed. No network coverage' }
2278622583 { $resultError = 'Unknown error related to protocol' }
2278622486 { $resultError = 'The requested operation is invalid for this protocol' }
2278622485 { $resultError = 'The requested protocol is not known' }
2278622483 { $resultError = 'Unknown error related to remote content' }
2278622389 { $resultError = 'Content needed to be resent, but this failed' }
2278622388 { $resultError = 'Remote server required authentication, but supplied credentials were not accepted' }
2278622387 { $resultError = 'Remote content was not found at the server' }
2278622386 { $resultError = 'The operation requested on remote content is not permitted' }
2278622385 { $resultError = 'Access to remote content denied' }
2278622383 { $resultError = 'Unknown proxy related error' }
2278622289 { $resultError = 'Proxy authentication required or proxy refused supplied credentials' }
2278622288 { $resultError = 'Connection to the proxy timed out' }
2278622287 { $resultError = 'Invalid proxy hostname' }
2278622286 { $resultError = 'The proxy server closed the connection prematurely' }
2278622285 { $resultError = 'Connection to the proxy server was refused' }
2278622235 { $resultError = 'Detection rules not present' }
2278622233 { $resultError = 'Unknown network error' }
2278622193 { $resultError = 'Remote server unavailable' }
2278622192 { $resultError = 'Network authentication failed' }
2278622191 { $resultError = 'Temporary network failure' }
2278622190 { $resultError = 'The encrypted channel could not be established' }
2278622189 { $resultError = 'The operation was canceled before it was finished' }
2278622188 { $resultError = 'Connection to the remote server timed out' }
2278622187 { $resultError = 'Invalid hostname' }
2278622186 { $resultError = 'The remote server closed the connection prematurely' }
2278622185 { $resultError = 'The remote server refused the connection' }
2278622184 { $resultError = 'Error Unknown' }
2278621701 { $resultError = 'SyncML: Response to atomic command too large for a single message' }
2278621700 { $resultError = 'SyncML: Command inside Atomic failed and was not rolled back successfully' }
2278621698 { $resultError = 'SyncML: Command not completed — operation was canceled before processing' }
2278621697 { $resultError = 'SyncML: The recipient does not support or refuses to support the specified version of SyncML Synchronization Protocol used in the request SyncML Message' }
2278621696 { $resultError = 'SyncML: An application error occurred during the synchronization session' }
2278621695 { $resultError = 'SyncML: A severe error occurred in the server while processing the request' }
2278621694 { $resultError = 'SyncML: An error occurred while processing the request. The error is related to a failure in the recipient data store' }
2278621693 { $resultError = 'SyncML: Reserved for future use' }
2278621692 { $resultError = 'SyncML: An error that necessitates a refresh of the current synchronization state of the client with the server' }
2278621691 { $resultError = 'SyncML: The error caused all SyncML commands within an Atomic element type to fail' }
2278621690 { $resultError = 'SyncML: An application error occurred while processing the request' }
2278621689 { $resultError = 'SyncML: The recipient does not support or refuses to support the specified version of SyncML DTD used in the request SyncML Message' }
2278621688 { $resultError = 'SyncML: The recipient, while acting as a gateway or proxy, did not receive a timely response from the upstream recipient specified by the URI (e.g., HTTP FTP LDAP) or some other auxiliary recipient (e.g., DNS) it needed to access in attempting to complete the request' }
2278621687 { $resultError = 'SyncML: The recipient is currently unable to handle the request due to a temporary overloading or maintenance' }
2278621686 { $resultError = 'SyncML: The recipient, while acting as a gateway or proxy, received an invalid response from the upstream recipient it accessed to fulfill the request' }
2278621685 { $resultError = 'SyncML: The recipient does not support the command required to fulfill the request' }
2278621684 { $resultError = 'SyncML: The recipient encountered an unexpected condition that prevented it from fulfilling the request' }
2278621612 { $resultError = 'SyncML: Move failed' }
2278621611 { $resultError = 'SyncML: Parent cannot be deleted since it contains children' }
2278621610 { $resultError = 'SyncML: Partial item not accepted' }
2278621609 { $resultError = 'SyncML: The requested command failed because the sender does not have adequate access control permissions (ACL) on the recipient' }
2278621608 { $resultError = 'SyncML: The chunked object was received, but the size of the received object did not match the size declared within the first chunk' }
2278621607 { $resultError = 'SyncML: The requested command failed because the “Soft Deleted” item was previously “Hard Deleted” on the server' }
2278621606 { $resultError = 'SyncML: The requested command failed on the server because the CGI scripting in the LocURI was incorrectly formed' }
2278621605 { $resultError = 'SyncML: The requested command failed on the server because the specified search grammar was not known' }
2278621604 { $resultError = 'SyncML: The recipient has no more storage space for the remaining synchronization data' }
2278621603 { $resultError = 'SyncML: The client request created a conflict which was resolved by the server command winning' }
2278621602 { $resultError = 'SyncML: The requested Put or Add command failed because the target already exists' }
2278621601 { $resultError = 'SyncML: The request failed at this time, and the originator should retry the request later' }
2278621600 { $resultError = 'SyncML: The request failed because the specified byte size in the request was too big' }
2278621599 { $resultError = 'SyncML: Unsupported media type or format' }
2278621598 { $resultError = 'SyncML: The requested command failed because the target URI is too long for what the recipient is able or willing to process' }
2278621597 { $resultError = 'SyncML: The recipient refuses to perform the requested command because the requested item is larger than the recipient is able or willing to process' }
2278621596 { $resultError = 'SyncML: The requested command failed on the recipient because it was incomplete or incorrectly formed' }
2278621595 { $resultError = 'SyncML: The requested command must be accompanied by byte size or length information in the Meta element type' }
2278621594 { $resultError = 'SyncML: The requested target is no longer on the recipient, and no forwarding URI is known' }
2278621593 { $resultError = 'SyncML: The requested failed because of an update conflict between the client and server versions of the data' }
2278621592 { $resultError = 'SyncML: An expected message was not received within the required period of time' }
2278621591 { $resultError = 'SyncML: The requested command failed because the originator must provide proper authentication' }
2278621590 { $resultError = 'SyncML: The requested command failed because an optional feature in the request was not supported' }
2278621589 { $resultError = 'SyncML: The requested command is not allowed on the target' }
2278621588 { $resultError = 'SyncML: The requested target was not found' }
2278621587 { $resultError = 'SyncML: The requested command failed, but the recipient understood the requested command' }
2278621586 { $resultError = 'SyncML: The requested command failed because proper payment is needed' }
2278621585 { $resultError = 'SyncML: The requested command failed because the requestor must provide proper authentication' }
2278621584 { $resultError = 'SyncML: The requested command could not be performed because of malformed syntax in the command' }
2278621489 { $resultError = 'SyncML: The requested target must be accessed through the specified proxy URI' }
2278621488 { $resultError = 'SyncML: The requested SyncML command was not executed on the target' }
2278621487 { $resultError = 'SyncML: The requested target can be found at another URI' }
2278621486 { $resultError = 'SyncML: The requested target has temporarily moved to a different URI' }
2278621485 { $resultError = 'SyncML: The requested target has a new URI' }
2278621484 { $resultError = 'SyncML: The requested target is one of several multiple alternatives requested target' }
2278621285 { $resultError = 'SyncML: The specified SyncML command is being carried out but has not yet been completed' }
2278563844 { $resultError = 'The software distribution policy was not found' }
2278563842 { $resultError = 'The software distribution policy for this program was not found' }
2278560402 { $resultError = 'The virtual application is in use' }
2278560401 { $resultError = 'The virtual environment is not applicable' }
2278560400 { $resultError = 'An error occurred when querying the App-V WMI provider' }
2278560399 { $resultError = 'The App-V time command returned failure' }
2278560398 { $resultError = 'I could not uninstall the App-V deployment type because of conflict. The published components in this DT are still published by other DTs. This DT will always be detected as long as other DTs are still installed' }
2278560396 { $resultError = 'I could not find a streaming distribution point for the App-V package' }
2278560395 { $resultError = 'The App-V application is not installed' }
2278560394 { $resultError = 'The App-V client has reported a launch error' }
2278560390 { $resultError = 'The App-V package has already installed a higher version by another deployment type, so we cannot install a lower version of the package' }
2278560389 { $resultError = 'A dependent App-V package is not installed' }
2278560385 { $resultError = 'A supported App-V client is not installed' }
2278560384 { $resultError = 'The virtual application is currently in use' }
2278560337 { $resultError = 'The application deployment type handler could not be initialized. The deployment type might not be supported on this system' }
2278560336 { $resultError = 'The computer restart cannot be initiated because a software installation job is in progress' }
2278560272 { $resultError = 'Failed to get content locations' }
2278560260 { $resultError = 'No distribution points were found for the requested content' }
2278560259 { $resultError = 'The client cache is currently in use by a running program or by a download in progress' }
2278560258 { $resultError = 'The content download cannot be performed because the total size of the client cache is smaller than the size of the requested content' }
2278560257 { $resultError = 'The content download cannot be performed because there is not enough available space in the cache or the disk is full' }
2278560256 { $resultError = 'No content request was found with the given handle' }
2278560010 { $resultError = 'A fatal error occurred while preparing to execute the program, for example, when creating the program execution environment, making a network connection, impersonating the user, determining the file association information, or when attempting to launch the program. This program execution will not be retried' }
2278560009 { $resultError = 'Failed to verify that the given file is a valid installation package' }
2278560008 { $resultError = 'Failed to access all the provided program locations. This program will not retry' }
2278560007 { $resultError = 'Failed to access all the provided program locations. This program may retry if the maximum retry count has not been reached' }
2278560006 { $resultError = 'Failed to verify the executable file is valid or to construct the associated command line' }
2278560005 { $resultError = 'An error was encountered while getting the process information for the launched program, and the program execution will not be monitored' }
2278560004 { $resultError = 'The command line for this program is invalid' }
2278560003 { $resultError = 'A nonfatal error occurred while preparing to execute the program, for example, when creating the program execution environment, making a network connection, impersonating the user, determining the file association information, or when attempting to launch the program. This program execution will be retried if the retry count has not been exceeded' }
2278560002 { $resultError = 'An error occurred while creating the execution context' }
2278560001 { $resultError = 'A fatal error has been encountered while attempting to run the program. The program execution will not be retried' }
2278560000 { $resultError = 'A non-fatal error has been encountered while attempting to run the program. The program execution will be retried if the retry count has not been exceeded' }
2278559768 { $resultError = 'The program cannot run at this time because the client is on the internet' }
2278559767 { $resultError = 'The content hash string or hash version is empty or incorrect in the software distribution policy, or the hash verification failed' }
2278559765 { $resultError = 'Failed to notify the caller that software distribution is paused because the paused state or paused cookie does not match' }
2278559764 { $resultError = 'The program cannot run because it is targeted to a user that requires user input or is set to run in the user context' }
2278559763 { $resultError = 'This program cannot run because it depends on another program that has not run successfully before' }
2278559762 { $resultError = 'There is no program currently running' }
2278559761 { $resultError = 'The execution request was not found' }
2278559760 { $resultError = 'A system restart is in progress, or there is a pending execution for this program that requires a computer restart' }
2278559753 { $resultError = 'Failed to get data from WMI' }
2278559752 { $resultError = 'Failed to indicate the client cache is currently in use' }
2278559750 { $resultError = 'The requested program is not currently pending' }
2278559749 { $resultError = 'The policy for this program does not exist or is invalid' }
2278559748 { $resultError = 'The program is disabled' }
2278559746 { $resultError = 'Another execution for this program is already pending' }
2278559745 { $resultError = 'Another software execution is in progress, or a restart is pending' }
2278557708 { $resultError = 'No WDS session is available' }
2278557707 { $resultError = 'MCS Encountered WDS error' }
2278557706 { $resultError = 'Invalid MCS configuration' }
2278557705 { $resultError = 'The package is not multicast enabled' }
2278557704 { $resultError = 'The package is not multicast shared' }
2278557703 { $resultError = 'The invalid path is specified for Package' }
2278557702 { $resultError = 'MCS Server is Busy with many clients' }
2278557701 { $resultError = 'MCS Encryption is empty' }
2278557700 { $resultError = 'Error performing MCS health check' }
2278557699 { $resultError = 'Error opening MCS session' }
2278557698 { $resultError = 'MCS protocol version mismatch' }
2278557697 { $resultError = 'General MCS Failure' }
2278557696 { $resultError = 'The content transfer manager job is in an unexpected state' }
2278557461 { $resultError = 'No updates specified in the requested job' }
2278557460 { $resultError = 'User-based install not allowed as system restart is pending' }
2278557459 { $resultError = 'Software updates detection results have not been received yet' }
2278557458 { $resultError = 'A system restart is required to complete the installation' }
2278557457 { $resultError = 'Software updates deployment not active yet, i.e., start time is in future' }
2278557456 { $resultError = 'Failed to compare process creation time' }
2278557455 { $resultError = 'Invalid updates installer path' }
2278557454 { $resultError = 'The empty command line specified' }
2278557453 { $resultError = 'The software update failed when attempted' }
2278557452 { $resultError = 'Software update execution timeout' }
2278557451 { $resultError = 'Failed to create a process' }
2278557450 { $resultError = 'Invalid command line' }
2278557449 { $resultError = 'Failed to resume the monitoring of the process' }
2278557448 { $resultError = 'Software Updates Install not required' }
2278557447 { $resultError = 'Job Id mismatch' }
2278557446 { $resultError = 'No active job exists' }
2278557445 { $resultError = 'Pause state required' }
2278557444 { $resultError = 'A hard reboot is pending' }
2278557443 { $resultError = 'Another software updates install job is in progress. Only one job is allowed at a time' }
2278557442 { $resultError = 'Assignment policy not found' }
2278557441 { $resultError = 'Software updates download not allowed at this time' }
2278557440 { $resultError = 'Software updates installation not allowed at this time' }
2278557337 { $resultError = 'The scan is already in progress' }
2278557336 { $resultError = 'Software update being attempted is not actionable' }
2278557335 { $resultError = 'The software update is already installed but just requires a reboot to complete the installation' }
2278557334 { $resultError = 'The software update is already installed' }
2278557333 { $resultError = 'Incomplete scan results' }
2278557332 { $resultError = 'WSUS source already exists' }
2278557331 { $resultError = 'Windows Updates Agent version too low' }
2278557330 { $resultError = 'Group policy conflict' }
2278557329 { $resultError = 'Software update source not found' }
2278557328 { $resultError = 'The software update is not applicable' }
2278557297 { $resultError = 'Waiting for a third-party orchestration engine to initiate the installation' }
2278557290 { $resultError = 'None of the child software updates of a bundle are applicable' }
2278557289 { $resultError = 'Not able to get software updates content locations at this time' }
2278557288 { $resultError = 'Software update still detected as actionable after apply' }
2278557287 { $resultError = 'No current or future service window exists to install software updates' }
2278557286 { $resultError = 'Software updates cannot be installed outside the service window' }
2278557285 { $resultError = 'No updates to process in the job' }
2278557284 { $resultError = 'Updates handler job was canceled' }
2278557283 { $resultError = 'Failed to report installation status of software updates' }
2278557282 { $resultError = 'Failed to trigger the installation of software updates' }
2278557281 { $resultError = 'Error while detecting updates status after installation success' }
2278557280 { $resultError = 'Unable to monitor a software updates execution' }
2278557273 { $resultError = 'An error occurred reading policy for software update' }
2278557272 { $resultError = 'Software updates processing was canceled' }
2278557271 { $resultError = 'Error while detecting software updates status after scan success' }
2278557270 { $resultError = 'Updates handler was unable to continue due to some generic internal error' }
2278557269 { $resultError = 'Failed to install one or more software updates' }
2278557268 { $resultError = 'Software update install failure occurred' }
2278557267 { $resultError = 'Software update download failure occurred' }
2278557266 { $resultError = 'Software update policy was not found' }
2278557265 { $resultError = 'Post-install scan failed' }
2278557264 { $resultError = 'Pre-install scan failed' }
2278557236 { $resultError = 'Legacy scanner not supported' }
2278557235 { $resultError = 'The offline scan is pending' }
2278557234 { $resultError = 'The online scan is pending' }
2278557233 { $resultError = 'Scan retry is pending' }
2278557232 { $resultError = 'Maximum retries exhausted' }
2278557225 { $resultError = 'Rescan of the updates is pending' }
2278557224 { $resultError = 'Invalid content location' }
2278557223 { $resultError = 'Process instance not found' }
2278557222 { $resultError = 'Invalid process instance information' }
2278557192 { $resultError = 'Invalid instance type' }
2278557191 { $resultError = 'Content not found' }
2278557190 { $resultError = 'Offline scan tool history not found' }
2278557189 { $resultError = 'The scan tool has been removed' }
2278557188 { $resultError = 'The ScanTool not found in the job queue' }
2278557187 { $resultError = 'The ScanTool Policy has been removed, so cannot complete scan operation' }
2278557186 { $resultError = 'Content location request timeout occurred' }
2278557185 { $resultError = 'Scanning for updates timed out' }
2278557184 { $resultError = 'Scan Tool Policy not found' }
2278556738 { $resultError = 'An enforcement action (install/uninstall) was attempted for a simulated deployment' }
2278556737 { $resultError = 'The deployment metadata is not available on the client' }
2278556736 { $resultError = 'Expected policy documents are incomplete or missing' }
2278556704 { $resultError = 'The detection rules refer to an unsupported WMI namespace' }
2278556675 { $resultError = 'The detection rules contain an unsupported datatype' }
2278556674 { $resultError = 'The detection rules contain an invalid operator' }
2278556673 { $resultError = 'An incorrect XML expression was found when evaluating the detection rules' }
2278556672 { $resultError = 'An unexpected error occurred when evaluating the detection rules' }
2278556464 { $resultError = 'This application deployment type does not support being enforced with a required deployment' }
2278556458 { $resultError = 'The uninstall command line is invalid' }
2278556457 { $resultError = 'Application requirement evaluation or detection failed' }
2278556456 { $resultError = 'Configuration item digest not found' }
2278556455 { $resultError = 'The script is not signed' }
2278556454 { $resultError = 'The application deployment metadata was not found in WMI' }
2278556453 { $resultError = 'The application was still detected after uninstalling was completed' }
2278556452 { $resultError = 'The application was not detected after the installation was completed' }
2278556451 { $resultError = 'No user is logged on' }
2278556450 { $resultError = 'Rule conflict' }
2278556449 { $resultError = 'The script execution has timed out' }
2278556448 { $resultError = 'The script host has not been installed yet' }
2278556447 { $resultError = 'Script for discovery returned invalid data' }
2278556446 { $resultError = 'Unsupported configuration. The application is configured to Install for User but has been targeted to a mechanical device instead of the user' }
2278556445 { $resultError = 'Unsupported configuration. The application is targeted to a user but is configured to install when no user is logged in' }
2278556438 { $resultError = 'CI Agent job was canceled' }
2278556437 { $resultError = 'The CI version info data is not available' }
2278556436 { $resultError = 'CI Version Info timed out' }
2278556313 { $resultError = 'The client does not recognize this type of signature' }
2278556312 { $resultError = 'The clients database record could not be validated' }
2278556311 { $resultError = 'Invalid key' }
2278556310 { $resultError = 'The client failed to process one or more CI documents' }
2278556309 { $resultError = 'Registration certificate is either missing or invalid' }
2278556308 { $resultError = 'Unable to verify Policy' }
2278556307 { $resultError = 'Client unable to Refresh Site server signing certificate' }
2278556306 { $resultError = 'Client unable to compute message signature for InBand Auth' }
2278556305 { $resultError = 'No task sequence policies assigned' }
2278556304 { $resultError = 'The job contains no items' }
2278556297 { $resultError = 'Failed to decompress CI documents' }
2278556296 { $resultError = 'Failed to decompress configuration item' }
2278556295 { $resultError = 'The signing certificate is missing' }
2278556294 { $resultError = 'Invalid SMS authority' }
2278556293 { $resultError = 'Search criteria verb is either missing or invalid' }
2278556292 { $resultError = 'Missing subject name' }
2278556291 { $resultError = 'Missing private key' }
2278556290 { $resultError = 'More than one certificate was found, but select first cert was not set' }
2278556289 { $resultError = 'No certificate matching criteria specified' }
2278556288 { $resultError = 'Empty certificate store' }
2278556287 { $resultError = 'SHA could not bind as NAP Agent might not be running' }
2278556286 { $resultError = 'Bad HTTP status code' }
2278556285 { $resultError = 'CI documents download failed due to hash mismatch' }
2278556284 { $resultError = 'CI documents download timed out' }
2278556283 { $resultError = 'General CI documents download failure' }
2278556282 { $resultError = 'Configuration item download failed due to hash mismatch' }
2278556281 { $resultError = 'Configuration item download timed out' }
2278556280 { $resultError = 'General configuration item download failure' }
2278556279 { $resultError = 'Insufficient resources to complete the operation' }
2278556278 { $resultError = 'A system restart is required' }
2278556277 { $resultError = 'Failed to acquire the lock' }
2278556276 { $resultError = 'No callback completion interface specified' }
2278556275 { $resultError = 'The component has already been requested to pause' }
2278556274 { $resultError = 'Component is disabled' }
2278556273 { $resultError = 'Component is paused' }
2278556272 { $resultError = 'The component is not paused' }
2278556271 { $resultError = 'Pause cookie did not match' }
2278556270 { $resultError = 'Pause duration too big' }
2278556269 { $resultError = 'Pause duration too small' }
2278556268 { $resultError = 'Status not found' }
2278556267 { $resultError = 'Agent type not found' }
2278556266 { $resultError = 'Key type not found' }
2278556265 { $resultError = 'Required management point not found' }
2278556264 { $resultError = 'Compilation failed' }
2278556263 { $resultError = 'Download failed' }
2278556262 { $resultError = 'Inconsistent data' }
2278556261 { $resultError = 'Invalid store state' }
2278556260 { $resultError = 'Invalid operation' }
2278556259 { $resultError = 'Invalid message received from DTS' }
2278556258 { $resultError = 'The type of DTS message received is unknown' }
2278556257 { $resultError = 'Failed to persist configuration item definition' }
2278556256 { $resultError = 'Job state is not valid for the action being requested' }
2278556255 { $resultError = 'Client disconnected' }
2278556254 { $resultError = 'Encountered a message which was not sufficiently trusted to forward to an endpoint for processing' }
2278556253 { $resultError = 'Encountered invalid XML document which could not be validated by its corresponding XML schema(s)' }
2278556236 { $resultError = 'Encountered invalid XML schema document' }
2278556235 { $resultError = 'Name already exists' }
2278556234 { $resultError = 'The job is already connected' }
2278556233 { $resultError = 'Property is not valid for the given configuration item type' }
2278556232 { $resultError = 'There was an error in network communication' }
2278556231 { $resultError = 'A component required to perform the operation was missing or not registered' }
2278556230 { $resultError = 'There was an error evaluating the health of the client' }
2278556229 { $resultError = 'The objector subsystem has already been initialized' }
2278556228 { $resultError = 'The object or subsystem has not been initialized' }
2278556227 { $resultError = 'Public key mismatch' }
2278556226 { $resultError = 'Stored procedure failed' }
2278556225 { $resultError = 'Failed to connect to database' }
2278556224 { $resultError = 'Insufficient disk space' }
2278556217 { $resultError = 'Client id not found' }
2278556216 { $resultError = 'Public key not found' }
2278556215 { $resultError = 'Reply mode incompatible' }
2278556214 { $resultError = 'Low memory' }
2278556213 { $resultError = 'Syntax error occurred while parsing' }
2278556212 { $resultError = 'An internal endpoint cannot receive a remote message' }
2278556211 { $resultError = 'Message not trusted' }
2278556210 { $resultError = 'Message not signed' }
2278556209 { $resultError = 'Transient error' }
2278556208 { $resultError = 'Error logging on as given credentials' }
2278556201 { $resultError = 'Failed to get credentials' }
2278556200 { $resultError = 'Invalid endpoint' }
2278556199 { $resultError = 'Functionality disabled' }
2278556198 { $resultError = 'Invalid protocol' }
2278556197 { $resultError = 'Invalid address type' }
2278556196 { $resultError = 'Invalid message' }
2278556195 { $resultError = 'Version mismatch' }
2278556194 { $resultError = 'Operation canceled' }
2278556193 { $resultError = 'Invalid user' }
2278556192 { $resultError = 'Invalid type' }
2278556185 { $resultError = 'Global service not set' }
2278556184 { $resultError = 'Invalid service settings' }
2278556183 { $resultError = 'Data is corrupt' }
2278556182 { $resultError = 'Invalid service parameter' }
2278556181 { $resultError = 'Item not found' }
2278556180 { $resultError = 'Invalid name length' }
2278556179 { $resultError = 'Timeout occurred' }
2278556178 { $resultError = 'Context is closed' }
2278556177 { $resultError = 'Invalid Address' }
2278556176 { $resultError = 'Invalid Translator' }
2278556169 { $resultError = 'Data type mismatch' }
2278556168 { $resultError = 'Invalid command' }
2278556167 { $resultError = 'Parsing error' }
2278556166 { $resultError = 'Invalid file' }
2278556165 { $resultError = 'Invalid path' }
2278556164 { $resultError = 'Data too large' }
2278556163 { $resultError = 'No data supplied' }
2278556162 { $resultError = 'Service is shutting down' }
2278556161 { $resultError = 'Incorrect name format' }
2278556160 { $resultError = 'Name not found' }
2149908479 { $resultError = 'There was a reporter error not covered by another error code.' }
2149904389 { $resultError = 'The specified callback cookie is not found.' }
2149904388 { $resultError = 'The server rejected an event because the server was too busy.' }
2149904387 { $resultError = 'The XML in the event namespace descriptor could not be parsed.' }
2149904386 { $resultError = 'The XML in the event namespace descriptor could not be parsed.' }
2149904385 { $resultError = 'The event cache file was defective.' }
2149904383 { $resultError = 'There was an expression evaluator error not covered by another WU_E_EE_* error code.' }
2149900295 { $resultError = 'An expression evaluator operation could not be completed because the cluster state of the computer could not be determined.' }
2149900294 { $resultError = 'An expression evaluator operation could not be completed because there was an invalid attribute.' }
2149900293 { $resultError = 'The expression evaluator could not be initialized.' }
2149900292 { $resultError = 'An expression evaluator operation could not be completed because the version of the serialized expression data is invalid.' }
2149900291 { $resultError = 'An expression evaluator operation could not be completed because an expression contains an incorrect number of metadata nodes.' }
2149900290 { $resultError = 'An expression evaluator operation could not be completed because an expression was invalid.' }
2149900289 { $resultError = 'An expression evaluator operation could not be completed because an expression was unrecognized.' }
2149900287 { $resultError = 'Windows Update Agent could not be updated because of an error not covered by another WU_E_SETUP_* error code.' }
2149896214 { $resultError = 'Windows Update Agent could not be updated because of an unknown error.' }
2149896213 { $resultError = 'Windows Update Agent is successfully updated, but a reboot is required to complete the setup.' }
2149896212 { $resultError = 'Windows Update Agent is successfully updated, but a reboot is required to complete the setup.' }
2149896211 { $resultError = 'Windows Update Agent could not be updated because the server does not contain updated information for this version.' }
2149896210 { $resultError = 'Windows Update Agent must be updated before a search can continue. An administrator is required to perform the operation.' }
2149896209 { $resultError = 'Windows Update Agent must be updated before a search can continue.' }
2149896208 { $resultError = 'Windows Update Agent could not be updated because the registry contains invalid information.' }
2149896207 { $resultError = 'Windows Update Agent could not be updated because the setup handler failed during execution.' }
2149896206 { $resultError = 'Windows Update Agent setup package requires a reboot to complete installation.' }
2149896205 { $resultError = 'Windows Update Agent setup is already running.' }
2149896204 { $resultError = 'Windows Update Agent could not be updated because a restart of the system is required.' }
2149896203 { $resultError = 'Windows Update Agent could not be updated because the system is configured to block the update.' }
2149896202 { $resultError = 'Windows Update Agent could not be updated because the current system configuration is not supported.' }
2149896201 { $resultError = 'An update to the Windows Update Agent was skipped due to a directive in the wuident.cab file.' }
2149896200 { $resultError = 'An update to the Windows Update Agent was skipped because previous attempts to update have failed.' }
2149896199 { $resultError = 'Windows Update Agent could not be updated because regsvr32.exe returned an error.' }
2149896198 { $resultError = 'Windows Update Agent could not be updated because a WUA file on the target system is newer than the corresponding source file.' }
2149896197 { $resultError = 'Windows Update Agent could not be updated because the versions specified in the INF do not match the actual source file versions.' }
2149896196 { $resultError = 'Windows Update Agent could not be updated because setup initialization was never completed successfully.' }
2149896195 { $resultError = 'Windows Update Agent could not be updated because of an internal error that caused set up initialization to be performed twice.' }
2149896194 { $resultError = 'Windows Update Agent could not be updated because the wuident.cab file contains invalid information.' }
2149896193 { $resultError = 'Windows Update Agent could not be updated because an INF file contains invalid information.' }
2149896191 { $resultError = 'A driver error not covered by another WU_E_DRV_* code.' }
2149892103 { $resultError = 'Information required for the synchronization of applicable printers is missing.' }
2149892102 { $resultError = 'Driver synchronization failed.' }
2149892101 { $resultError = 'The driver update is missing a required attribute.' }
2149892100 { $resultError = 'The driver update is missing metadata.' }
2149892099 { $resultError = 'The registry type read for the driver does not match the expected type.' }
2149892098 { $resultError = 'A property for the driver could not be found. It may not conform to the required specifications.' }
2149892097 { $resultError = 'A driver was skipped.' }
2149888005 { $resultError = 'Cannot cancel a non-scheduled install.' }
2149888004 { $resultError = 'The task was stopped and needs to be rerun to complete.' }
2149888003 { $resultError = 'The operation cannot be completed since the task is not yet started.' }
2149888002 { $resultError = 'The operation cannot be completed since the task status is currently disabled.' }
2149888001 { $resultError = 'The task is currently in progress.' }
2149887999 { $resultError = 'An Automatic Updates error is not covered by another WU_E_AU * code.' }
2149883910 { $resultError = 'The default service registered with AU changed during the search.' }
2149883909 { $resultError = 'No unmanaged service is registered with AU.' }
2149883908 { $resultError = 'Automatic Updates was unable to process incoming requests because it was paused.' }
2149883907 { $resultError = 'The old version of the Automatic Updates client was disabled.' }
2149883906 { $resultError = 'The old version of the Automatic Updates client has stopped because the WSUS server has been upgraded.' }
2149883904 { $resultError = 'Automatic Updates was unable to service incoming requests.' }
2149879813 { $resultError = 'A WMI error occurred when enumerating the instances for a particular class.' }
2149879812 { $resultError = 'There was an inventory error not covered by another error code.' }
2149879811 { $resultError = 'Failed to upload inventory results to the server.' }
2149879810 { $resultError = 'Failed to get the requested inventory type from the server.' }
2149879809 { $resultError = 'Parsing of the rule file failed.' }
2149879807 { $resultError = 'A data store error is not covered by another WU_E_DS_* code.' }
2149875741 { $resultError = 'A data store operation did not complete because it was requested with an impersonated identity.' }
2149875740 { $resultError = 'The data store requires a session reset; release the session and retry with a new session.' }
2149875739 { $resultError = 'The schema of the current data store and the schema of a table in a backup XML document do not match.' }
2149875738 { $resultError = 'A request was declined because the operation is not allowed.' }
2149875737 { $resultError = 'A request to remove the Windows Update service or to unregister it with Automatic Updates was declined because it is a built-in service, and/or Automatic Updates cannot fall back to another service.' }
2149875736 { $resultError = 'A table was not closed because it is not associated with the session.' }
2149875735 { $resultError = 'A table was not closed because it is not associated with the session.' }
2149875734 { $resultError = 'A request to hide an update was declined because it is a mandatory update or because it was deployed with a deadline.' }
2149875733 { $resultError = 'An operation did not complete because the registration of the service has expired.' }
2149875732 { $resultError = 'An operation did not complete because the service is not in the data store.' }
2149875731 { $resultError = 'The server sent the same update to the client with two different revision IDs.' }
2149875729 { $resultError = 'I could not create a datastore object in another process.' }
2149875728 { $resultError = 'The datastore is not allowed to be registered with COM in the current process.' }
2149875727 { $resultError = 'The data store could not be initialized because it was locked by another process.' }
2149875726 { $resultError = 'The row was not added because an existing row has the same primary key.' }
2149875725 { $resultError = 'The category was not added because it contains no parent categories and is not a top-level category itself.' }
2149875724 { $resultError = 'The data store section could not be locked within the allotted time.' }
2149875723 { $resultError = 'The update was not deleted because it is still referenced by one or more services.' }
2149875722 { $resultError = 'The update was not processed because its update handler could not be recognized.' }
2149875721 { $resultError = 'The datastore is missing required information or references missing license terms file localized property or linked row.' }
2149875720 { $resultError = 'The datastore is missing required information or has a NULL in a table column that requires a non-null value.' }
2149875719 { $resultError = 'The information requested is not in the data store.' }
2149875718 { $resultError = 'The current and expected versions of the datastore do not match.' }
2149875717 { $resultError = 'A table could not be opened because the table is not in the data store.' }
2149875716 { $resultError = 'The data store contains a table with unexpected columns.' }
2149875715 { $resultError = 'The datastore is missing a table.' }
2149875714 { $resultError = 'The current and expected states of the datastore do not match.' }
2149875713 { $resultError = 'An operation failed because the datastore was in use.' }
2149875712 { $resultError = 'An operation failed because Windows Update Agent is shutting down.' }
2149875711 { $resultError = 'Search using the scan package failed.' }
2149871621 { $resultError = 'The service is not registered.' }
2149871620 { $resultError = 'The size of the event payload submitted is invalid.' }
2149871619 { $resultError = 'An invalid event payload was specified.' }
2149871618 { $resultError = 'An operation could not be completed because the scan package requires a greater version of the Windows Update Agent.' }
2149871617 { $resultError = 'An operation could not be completed because the scan package was invalid.' }
2149871615 { $resultError = 'There was a download manager error not covered by another WU_E_DM_* error code.' }
2149867532 { $resultError = 'A download failed because the current network limits downloads by update size for the update service.' }
2149867531 { $resultError = 'A download must be restarted because the updated content changed in a new revision.' }
2149867530 { $resultError = 'A download must be restarted because the location of the source of the download has changed.' }
2149867529 { $resultError = 'A download manager operation failed because of an unspecified Background Intelligent Transfer Service (BITS) transfer error.' }
2149867528 { $resultError = 'A download manager operation failed because the download manager could not connect the Background Intelligent Transfer Service (BITS).' }
2149867527 { $resultError = 'The update has not been downloaded.' }
2149867526 { $resultError = 'A download manager operation could not be completed because the version of Background Intelligent Transfer Service (BITS) is incompatible.' }
2149867525 { $resultError = 'A download manager operation could not be completed because the network connection was unavailable.' }
2149867524 { $resultError = 'An operation could not be completed because a download request is required from the download handler.' }
2149867523 { $resultError = 'A download manager operation could not be completed because the file metadata requested an unrecognized hash algorithm.' }
150201  {$resultError = 'Deployment failed! Check content source and deployment configuration'}
default {$resultError = 'UNKNOWN ERROR! PLEASE CHECK ENFORCEMENT STATE.'}
}

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

#Displaying the results
$Props=[Ordered]@{

AppName          = $resultAppName
Error            = $resultError
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

#Uncomment the following line to test the function
#Get-AppDeploymentErrorInfo -AppName chrome -HostName DEVICE1