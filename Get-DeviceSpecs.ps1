<##

Get-DeviceSpecs


Hardware Information (SMS Classes)
===================================
- CPU Type → SMS_G_System_PROCESSOR (ResourceID)
    >Name
    >NumberofCores


- RAM → SMS_G_System_X86_PC_MEMORY (ResourceID)
    >TotalPhysicalMemory
    >TotalVirtualMemory

- Hard Drive Capacity & Available Space → SMS_G_System_LOGICAL_DISK (ResourceID)
    > Name (Drive Letter)
    > Description (Drive Type)
    > size
    > FreeSpace
    > FileSystem (NTFS, FAT32,..etc)


- Graphics Cards (Names & GPU Memory) → SMS_G_System_VIDEO_CONTROLLER (ResourceID)
    > AdapterRAM (GPU Memory)
    > CurrentHorizontalResolution x > CurrentVerticalResolution
    > Name


- Audio Adapter → SMS_G_System_SOUND_DEVICE (ResourceID)
    > Name

- Modem Adapter (Network) → SMS_G_System_NETWORK_ADAPTER (ResourceID)
    > Name
    > MACAddress
    > AdapterType

=======================================
Operating System & Manufacturer Details
=======================================
- OS Name → SMS_G_System_OPERATING_SYSTEM (ResourceID)
    >Caption
    >Version

- Manufacturer & Model → SMS_G_System_COMPUTER_SYSTEM (ResourceID)
    >Manufacturer
    >Model

=============
logo - figlet
=============

'##::::'##::::::'##::::'##::'#######::'##::::'##:'########:::::'###::::'########::
 ###::'###:::::: ###::'###:'##.... ##: ##:::: ##: ##.... ##:::'## ##::: ##.... ##:
 ####'####:::::: ####'####: ##:::: ##: ##:::: ##: ##:::: ##::'##:. ##:: ##:::: ##:
 ## ### ##:::::: ## ### ##: ##:::: ##: ##:::: ##: ########::'##:::. ##: ##:::: ##:
 ##. #: ##:::::: ##. #: ##: ##:::: ##: ##:::: ##: ##.. ##::: #########: ##:::: ##:
 ##:.:: ##:'###: ##:.:: ##: ##:::: ##: ##:::: ##: ##::. ##:: ##.... ##: ##:::: ##:
 ##:::: ##: ###: ##:::: ##:. #######::. #######:: ##:::. ##: ##:::: ##: ########::
..:::::..::...::..:::::..:::.......::::.......:::..:::::..::..:::::..::........:::


#>


function Get-DeviceSpecs {
    <#
        .SYNOPSIS
        This function get information about the hardware components for each hostname entered in the command.
        .DESCRIPTION
        This function retrieves specs info about several hardware components within a single hostname (if hostname parameter used)
        or several hostnames within a collection (if a collectionID is provided). The specs provided are:
        - Device Model
        - Operating System Name
        - Operating System Version
        - CPU make and clock.
        - CPU cores
        - Hard Drive Names (letters)
        - Hard Drive Capacity
        - Hard Drive FreeSpace
        - RAM (Physical and Virtual)
        - Graphics Drivers
        - Graphics Memory
        - Network Modems (Names, MAC-Addresses, Adapters)

        If you decide to run the command using hostnames only, you will be presented with a pleasant graphically formatted output.
        Should you decide to use CollectionID or ExportCSV, outputs should be displayed in raw format.
        .PARAMETER HostName
        Use hostname parameter to get specs information about different hardware components. The parameter accepts a single hostname
        or an array of hostnames. If you choose to use ExportCSV with this parameter, results will be displayed in raw format.
        .PARAMETER CollectionID
        Use CollectionID parameter to get specs ingo about all the devices in that collection one device at a time. The results
        will be displayed in a raw format. ExportCSV can be used in combination to export results to a .CSV file after providing
        PATH.
        .PARAMETER EXPORTCSV
        Use EXPORTCSV parameter to export results in a .CSV file. PATH parameter must be used to specify the destination of the export.
        .EXAMPLE
        Get-NTTADeviceSpecs -collectionID PGE00616

        [46] DEVICES FOUND IN THIS COLLECTION...
        DISPLAYING SPECS OF....[1/46] MACHINES


        HostName       : Workstation1
        OS_NAME        : Microsoft Windows 10 Enterprise
        OS_Version     : 10.0.19045
        CPU_NAME       : Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz
        CPU_CORES      : 4
        HDD_FILESYSTEM : NTFS
        HDD_DRIVE      : C:
        HDD_CAPACITY   : 236.73 GB
        HDD_FREESPACE  : 16.4 GB
        RAM_Physical   : 15.89 GB
        RAM_Virtual    : 31.79 GB
        GPU_DRIVER     : Intel(R) HD Graphics 530
                         NVIDIA Quadro K420
        GPU_MEMORY     : 1 GB
                         2 GB
        AUDIO          : NVIDIA High Definition Audio
                         Intel(R) Display Audio
                         Realtek Audio
        NETWORK_MODEM  : Microsoft Kernel Debug Network Adapter
                         Intel(R) Ethernet Connection (2) I219-LM
                        Hyper-V Virtual Switch Extension Adapter
                        Hyper-V Virtual Ethernet Adapter
                        WAN Miniport (SSTP)
                        WAN Miniport (IKEv2)
                        WAN Miniport (L2TP)
                        WAN Miniport (PPTP)
                        WAN Miniport (PPPOE)
                        WAN Miniport (IP)
                        WAN Miniport (IPv6)
                        WAN Miniport (Network Monitor)
        MAC_ADDRESS    : 48:4D:7E:DB:70:17
                         00:15:5D:4F:E4:1A
                         66:33:20:52:41:53
                         6E:58:20:52:41:53
                         76:E3:20:52:41:53
        MODEM_ADAPTER  : Ethernet 802.3
                         Ethernet 802.3
                         Ethernet 802.3
                         Ethernet 802.3
                         Ethernet 802.3
                         Ethernet 802.3

        DISPLAYING SPECS OF....[2/46] MACHINES
        HostName       : SERVERNAME1
        OS_NAME        : Microsoft Windows 10 Enterprise
        OS_Version     : 10.0.19045
        CPU_NAME       : Intel(R) Xeon(R) CPU E5-2697A v4 @ 2.60GHz
                        Intel(R) Xeon(R) CPU E5-2697A v4 @ 2.60GHz
        CPU_CORES      : 1
                         1
        HDD_FILESYSTEM : NTFS
        HDD_DRIVE      : C:
                         A:
                         D:
        HDD_CAPACITY   : 99.02 GB
                         0 GB
                         0 GB
        HDD_FREESPACE  : 42.6 GB
                         0 GB
                         0 GB
        RAM_Physical   : 4 GB
        RAM_Virtual    : 13.89 GB
        GPU_DRIVER     : Horizon Indirect Display Driver
                        VMware Horizon Indirect Display Driver
                        VMware SVGA 3D
        GPU_MEMORY     : 0 GB
                         0 GB
                         0.12 GB
        AUDIO          : Horizon Virtual Audio (DevTap)
        NETWORK_MODEM  : Microsoft Kernel Debug Network Adapter
                         Intel(R) 82574L Gigabit Network Connection
        MAC_ADDRESS    : 00:50:56:9C:FF:12
        MODEM_ADAPTER  : Ethernet 802.3



    #>

        [CmdletBinding()]

                Param(

                [String[]]$HostName,
                [String]$CollectionID,
                [SWITCH]$ExportCSV,
                [String]$PATH

                )

                #Global Variables - change these to your environment

                $smsmp='SERVER.DOMAIN.local'
                $smsns='root\sms\Site'

    function Get-DeviceSpecs{

                [CmdletBinding()]

                Param(
                [String]$PCNAME,
                [SWITCH]$DisplaySpecTable
                )

                $WMIParams = @{
                               ComputerName = $smsmp
                               Namespace = $smsns
                               }

#Global Queries for specs
$CPUQuery =@"
SELECT SMS_G_System_PROCESSOR.Name,
SMS_G_System_PROCESSOR.NumberOfCores
FROM SMS_G_System_PROCESSOR
WHERE ResourceID = '$ResourceID'
"@


$RAMQuery =@"
SELECT SMS_G_System_X86_PC_MEMORY.TotalPhysicalMemory,
SMS_G_System_X86_PC_MEMORY.TotalVirtualMemory
FROM SMS_G_System_X86_PC_MEMORY
WHERE ResourceID = '$ResourceID'
"@


$HDDQuery=@"
SELECT SMS_G_System_LOGICAL_DISK.Name,
SMS_G_System_LOGICAL_DISK.Description,
SMS_G_System_LOGICAL_DISK.Size,
SMS_G_System_LOGICAL_DISK.FreeSpace,
SMS_G_System_LOGICAL_DISK.FileSystem
FROM SMS_G_System_LOGICAL_DISK
WHERE ResourceID = '$ResourceID'
"@


$GPUQuery=@"
SELECT SMS_G_System_VIDEO_CONTROLLER.AdapterRAM,
SMS_G_System_VIDEO_CONTROLLER.CurrentHorizontalResolution,
SMS_G_System_VIDEO_CONTROLLER.CurrentVerticalResolution,
SMS_G_System_VIDEO_CONTROLLER.Name
FROM SMS_G_System_VIDEO_CONTROLLER
WHERE ResourceID = '$ResourceID'
"@


$AudioQuery=@"
SELECT SMS_G_System_SOUND_DEVICE.Name
FROM SMS_G_System_SOUND_DEVICE
WHERE ResourceID = '$ResourceID'
"@


$ModemQuery=@"
SELECT SMS_G_System_NETWORK_ADAPTER.Name,
SMS_G_System_NETWORK_ADAPTER.MACAddress,
SMS_G_System_NETWORK_ADAPTER.AdapterType
FROM SMS_G_System_NETWORK_ADAPTER
WHERE ResourceID = '$ResourceID'
"@


$OSQuery=@"
SELECT SMS_G_System_OPERATING_SYSTEM.Caption,
SMS_G_System_OPERATING_SYSTEM.Version
FROM SMS_G_System_OPERATING_SYSTEM
WHERE ResourceID = '$ResourceID'
"@


$ModelQuery=@"
SELECT SMS_G_System_COMPUTER_SYSTEM.Manufacturer,
SMS_G_System_COMPUTER_SYSTEM.Model
FROM SMS_G_System_COMPUTER_SYSTEM
WHERE ResourceID = '$ResourceID'
"@

                #WMI query for specs
                $OS     = Get-WmiObject @WMIParams -Query $OSQuery -ErrorAction SilentlyContinue
                $CPU    = Get-WmiObject @WMIParams -Query $CPUQuery -ErrorAction SilentlyContinue
                $RAM    = Get-WmiObject @WMIParams -Query $RAMQuery -ErrorAction SilentlyContinue
                $HDD    = Get-WmiObject @WMIParams -Query $HDDQuery -ErrorAction SilentlyContinue
                $GPU    = Get-WmiObject @WMIParams -Query $GPUQuery -ErrorAction SilentlyContinue
                $Audio  = Get-WmiObject @WMIParams -Query $AudioQuery -ErrorAction SilentlyContinue
                $Modem  = Get-WmiObject @WMIParams -Query $ModemQuery -ErrorAction SilentlyContinue
                $Model  = Get-WmiObject @WMIParams -Query $ModelQuery -ErrorAction SilentlyContinue



                #OS and Model Information
                $OSName     = $OS.Caption
                $OSVersion  = $OS.Version
                $ModelBrand = $Model.Manufacturer
                $ModelModel = $Model.Model


                #CPU Information
                $CPUName    = $CPU.Name
                $CPUCores   = $CPU.NumberofCores

                #RAM Information
                $RAMPhysical            = $RAM.TotalPhysicalMemory
                $RAMVirtual             = $RAM.TotalVirtualMemory
                $RAMPhysicalCalculated  = [math]::Round($RAMPhysical/(1024*1024), 2).ToString() + " GB"
                $RAMVirtualCalculated   = [math]::Round($RAMVirtual/(1024*1024), 2).ToString() + " GB"

                #Hard Drive Information
                $HDDResults = @() # Initialize empty array

                    #Looping through HDD specs for possible multiple disks
                    foreach($result in $HDD){
                    $HDDDrive               = $result.Name
                    $Capacity               = $result.size
                    $FreeSpace              = $result.FreeSpace
                    $FileSystem             = $result.FileSystem
                    $CapacityCalculated     = $capacity| ForEach-Object { ([math]::Round($_ /1024, 2)).ToString() + " GB"}
                    $FreeSpaceCalculated    = $FreeSpace| ForEach-Object { ([math]::Round($_ /1024, 2)).ToString() + " GB"}

                    #Storing relative HDD info in a hashtable
                    $HDDInfo = @{
                                Drive=$HDDDrive
                                FileSystem=$FileSystem
                                Capacity=$CapacityCalculated
                                FreeSpace=$FreeSpaceCalculated
                                }
                    $HDDResults += $HDDInfo
                    }

                    #Graphics Information
                    $GPUResults = @()
                    foreach($result in $GPU){
                    $GPUName          = $result.Name
                    $GPUResolutionW   = $result.CurrentHorizontalResolution
                    $GPUResolutionH   = $result.CurrentVerticalResolution
                    $GPUMemRAM        = $result.AdapterRAM
                    $GPUMemCalculated = $GPUMemRAM| ForEach-Object { ([math]::Round($_ /(1024*1024), 2)).ToString() + " GB"}
                    $GPUResolution    = $GPUResolutionW.toString() + " X " + $GPUResolutionH.toString()

                    $GPUInfo = @{
                                GPU_Name       = $GPUName
                                GPU_Resolution = $GPUResolution
                                GPU_Memory     = $GPUMemCalculated
                                }
                    $GPUResults += $GPUInfo
                    }

                    #Audio Information
                    $AudioDevices = @()
                    foreach($device in $Audio){
                    $AudioDevices += $device.Name #AudioName
                    }


                    #Network Information
                    $NetworkDevices = @()
                    foreach($result in $Modem){
                    $ModemName    = $result.Name
                    $ModemMAC     = $result.MACAddress
                    $ModemAdapter = $result.AdapterType

                    $ModemInfo = @{
                                Modem_Name    = $ModemName
                                MAC_Address   = $ModemMAC
                                Modem_Adapter = $ModemAdapter
                                    }
                    $NetworkDevices += $ModemInfo
                    }


                   #Condition to differentiate between formatted output vs. RAW (this is formatted)
                   if (-not $DisplaySpecTable){

                $LOGO=@"
'##::::'##::::::'##::::'##::'#######::'##::::'##:'########:::::'###::::'########::
 ###::'###:::::: ###::'###:'##.... ##: ##:::: ##: ##.... ##:::'## ##::: ##.... ##:
 ####'####:::::: ####'####: ##:::: ##: ##:::: ##: ##:::: ##::'##:. ##:: ##:::: ##:
 ## ### ##:::::: ## ### ##: ##:::: ##: ##:::: ##: ########::'##:::. ##: ##:::: ##:
 ##. #: ##:::::: ##. #: ##: ##:::: ##: ##:::: ##: ##.. ##::: #########: ##:::: ##:
 ##:.:: ##:'###: ##:.:: ##: ##:::: ##: ##:::: ##: ##::. ##:: ##.... ##: ##:::: ##:
 ##:::: ##: ###: ##:::: ##:. #######::. #######:: ##:::. ##: ##:::: ##: ########::
..:::::..::...::..:::::..:::.......::::.......:::..:::::..::..:::::..::........:::
"@
                Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
                Write-Host $LOGO -ForegroundColor Magenta -BackgroundColor Black
                Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
                Write-Host "HostName:" -ForegroundColor Yellow -NoNewline
                Write-Host "$Machine" -NoNewline
                Write-Host "`tModel:" -ForegroundColor Yellow -NoNewline
                Write-Host "$ModelModel" -NoNewline
                Write-Host "`tManufacturer:" -ForegroundColor Yellow -NoNewline
                Write-Host "$ModelBrand"
                Write-Host "-------------------------------------------------------------------" -ForegroundColor DarkGray

                Write-Host "OS:" -ForegroundColor Yellow -NoNewline
                Write-Host $OSName -NoNewline
                Write-Host "`t`tVersion:" -ForegroundColor Yellow -NoNewline
                Write-Host $OSVersion
                Write-Host "-------------------------------------------------------------------" -ForegroundColor DarkGray
                Write-Host "CPU:" -ForegroundColor Yellow -NoNewline
                Write-Host "$CPUName" -NoNewline
                Write-Host "`tCores:" -ForegroundColor Yellow -NoNewline
                Write-Host "$CPUCores"
                Write-Host "====================================================================" -ForegroundColor Gray
                Write-Host "----------------------------[  HDD  ]-------------------------------" -ForegroundColor Yellow
                Write-Host "====================================================================" -ForegroundColor Gray
                foreach($info in $HDDResults){
                Write-Host "`t............................................................" -ForegroundColor DarkYellow
                Write-Host "[Drive]:" -ForegroundColor Green -NoNewline
                Write-Host "`t`t$($info.Drive)"
                Write-Host "[FileSystem]:" -ForegroundColor Green -NoNewline
                Write-Host "`t$($info.FileSystem)"
                Write-Host "[Capacity]:" -ForegroundColor Green -NoNewline
                Write-Host "`t`t$($info.Capacity)"
                Write-Host "[FreeSpace]:" -ForegroundColor Green -NoNewline
                Write-Host "`t$($info.FreeSpace)"
                }
                Write-Host "====================================================================" -ForegroundColor Gray
                Write-Host "----------------------------[  RAM  ]-------------------------------" -ForegroundColor Yellow
                Write-Host "====================================================================" -ForegroundColor Gray
                Write-Host "Physical Memory(RAM):" -ForegroundColor Green -NoNewline
                Write-Host $RAMPhysicalCalculated
                Write-Host "Virtual Memory (RAM):" -ForegroundColor Green -NoNewline
                Write-Host $RAMVirtualCalculated
                Write-Host "====================================================================" -ForegroundColor Gray
                Write-Host "----------------------------[GRAPHICS]------------------------------" -ForegroundColor Yellow
                Write-Host "====================================================================" -ForegroundColor Gray
                foreach($info in $GPUResults){
                Write-Host "`t............................................................" -ForegroundColor DarkYellow
                Write-Host "[Graphics Driver]:" -ForegroundColor Green -NoNewline
                Write-Host "`t`t$($info.GPU_Name)"
                Write-Host "[Graphics Memory]:" -ForegroundColor Green -NoNewline
                Write-Host "`t`t$($info.GPU_Memory)"
                Write-Host "[Graphics Resolution]:" -ForegroundColor Green -NoNewline
                Write-Host "`t$($info.GPU_Resolution)"
                }
                Write-Host "====================================================================" -ForegroundColor Gray
                Write-Host "-----------------------------[AUDIO]--------------------------------" -ForegroundColor Yellow
                Write-Host "====================================================================" -ForegroundColor Gray
                foreach($info in $AudioDevices){
                Write-Host "`t$($info)"}


                Write-Host "====================================================================" -ForegroundColor Gray
                Write-Host "----------------------------[NETWORK]-------------------------------" -ForegroundColor Yellow
                Write-Host "====================================================================" -ForegroundColor Gray

                foreach($info in $NetworkDevices){
                Write-Host "`t............................................................" -ForegroundColor DarkYellow
                Write-Host "[Modem Name]:" -ForegroundColor Green -NoNewline
                Write-Host "`t`t$($info.Modem_Name)"
                Write-Host "[MAC Address]:" -ForegroundColor Green -NoNewline
                Write-Host "`t`t$($info.MAC_Address)"
                Write-Host "[Modem Adapter]:" -ForegroundColor Green -NoNewline
                Write-Host "`t$($info.Modem_Adapter)"
                }
                Write-Host "--------------------------------------------------------------------" -ForegroundColor Gray
                }


                #Condition to display RAW info
                if($DisplaySpecTable){

               $CollectionSpecsInfo=[Ordered]@{
                HostName       = $Machine
                OS_NAME        = $OSName
                OS_Version     = $OSVersion
                CPU_NAME       = ($CPUName) -join "`n"
                CPU_CORES      = ($CPUCores) -join "`n"
                HDD_FILESYSTEM = ($HDDResults|ForEach-Object{$_.FileSystem}| Where-Object { $_ }) -join "`n"
                HDD_DRIVE      = ($HDDResults|ForEach-Object{$_.Drive}| Where-Object { $_ }) -join "`n"
                HDD_CAPACITY   = ($HDDResults|ForEach-Object{$_.Capacity}| Where-Object { $_ }) -join "`n"
                HDD_FREESPACE  = ($HDDResults|ForEach-Object{$_.FreeSpace}| Where-Object { $_ }) -join "`n"

                RAM_Physical = $RAMPhysicalCalculated
                RAM_Virtual  = $RAMVirtualCalculated
                GPU_DRIVER   = ($GPUResults | ForEach-Object{$_.GPU_Name}| Where-Object { $_ }) -join "`n"
                GPU_MEMORY   = ($GPUResults | ForEach-Object{$_.GPU_Memory}| Where-Object { $_ }) -join "`n"

                AUDIO         = ($AudioDevices) -join "`n"
                NETWORK_MODEM = ($NetworkDevices | ForEach-Object{$_.Modem_Name}| Where-Object { $_ }) -join "`n"
                MAC_ADDRESS   = ($NetworkDevices | ForEach-Object{$_.MAC_Address}| Where-Object { $_ }) -join "`n"
                MODEM_ADAPTER = ($NetworkDevices | ForEach-Object{$_.Modem_Adapter}| Where-Object { $_ }) -join "`n"
                }

                New-Object -TypeName PSObject -Property $CollectionSpecsInfo
                }


                }

    # Should the command uses hostname parameter

        if($HostName){

        $COUNTER =0 #to count the hostnames

        #looping through the hostnames as the parameter is an array
        foreach($Machine in $HostName){

        $COUNTER += 1

        $HostNametoResourceID = @{
                                ComputerName = $smsmp
                                Namespace = $smsns
                                Class = "SMS_CM_RES_COLL_SMS00001"
                                Filter = "Name = '$Machine'"
                                }

        #ResourceID from HostName
        $ResourceID = (Get-WmiObject @HostNametoResourceID).ResourceID

        if(-not $ExportCSV){ #display formatted output if no export is chosen

        Get-DeviceSpecs -PCNAME $Machine -ErrorAction SilentlyContinue
        }
        else{
        Write-Host "EXPORTING THE FOLLOWING RESULTS....[$($COUNTER)/$(($HostName|measure).count)]" -ForegroundColor Yellow
        Get-DeviceSpecs -PCNAME $Machine -DisplaySpecTable -ErrorAction SilentlyContinue}
        }

        }

        # should the command uses collection ID parameter
        elseif($CollectionID){

                [String]$CollectionClass = "SMS_CM_RES_COLL_" + "$CollectionID" #concat the collection ID to the class to get the hostnames in a collection

                #Query the hostnames in a collection
                $DevicesInCollection = (gwmi -ComputerName $smsmp -NS $smsns -class $CollectionClass).Name



                     $HostName = $DevicesInCollection

                     Write-Host "[$(($DevicesInCollection|measure).count)] DEVICES FOUND IN THIS COLLECTION..." -ForegroundColor Yellow

                     $COUNTER = 0

                     foreach($Machine in $HostName){

                     $COUNTER += 1

                     $HostNametoResourceID = @{
                                             ComputerName = $smsmp
                                             Namespace    = $smsns
                                             Class        = "SMS_CM_RES_COLL_SMS00001"
                                             Filter       = "Name = '$Machine'"
                                             }

                     #ResourceID from HostName
                     $ResourceID = (Get-WmiObject @HostNametoResourceID).ResourceID


                     if(-not $ExportCSV){

                        Write-Host "DISPLAYING SPECS OF....[$($counter)/$(($DevicesInCollection|measure).count)] MACHINES" -ForegroundColor Yellow

                        Get-DeviceSpecs -PCNAME $Machine -DisplaySpecTable -ErrorAction SilentlyContinue
                        }

                        else{

                        Write-Host "EXPORTING THE FOLLOWING RESULTS....[$($counter)/$(($DevicesInCollection|measure).count)]" -ForegroundColor Yellow

                        Get-DeviceSpecs -PCNAME $Machine -DisplaySpecTable -ErrorAction SilentlyContinue}

                     }

                }


        if($ExportCSV -and $PATH){

        #Starting an empty array to store the results to be exported to CSV
        $CSVContent = @()

        foreach($Machine in $HostName){

                        $HostNametoResourceID = @{
                                                ComputerName = $smsmp
                                                Namespace    = $smsns
                                                Class        = "SMS_CM_RES_COLL_SMS00001"
                                                Filter       = "Name = '$Machine'"
                                                }
        #ResourceID from HostName
        $ResourceID = (Get-WmiObject @HostNametoResourceID).ResourceID

        $result = Get-DeviceSpecs -PCNAME $Machine -DisplaySpecTable -ErrorAction SilentlyContinue

        $CSVContent += $result

        }
        $CSVContent | Export-Csv -NoTypeInformation -Path $PATH

        #Confirmation that the export is done
        Write-Host "*** EXPORT HAS BEEN COMPLETED SUCCESSFULLY TO [$($PATH)] ***" -ForegroundColor BLACK -BackgroundColor Green

        }



    }


    #End of function