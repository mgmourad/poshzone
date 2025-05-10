# PowerShell Utility Scripts

This repository contains a collection of PowerShell scripts designed to assist with system administration tasks, including retrieving hardware specifications, BIOS information, and application deployment details. Each script is tailored to provide detailed and actionable insights into specific areas of system management.

## Scripts Overview

### 1. `Get-AppDeploymentErrorInfo.ps1`

**Purpose**: Retrieves detailed information about application deployment errors, including error codes, enforcement states, and associated metadata.

**Key Features**:

- Query deployment errors by application name, hostname, username, or collection ID.
- Provides detailed error descriptions and enforcement states.
- Supports multiple parameter sets for flexible querying.

**Example Usage**:

```powershell

Get-AppDeploymentErrorInfo -AppName 'Google Chrome' -HostName DEVICE1
```

---

### 2. Get-AppDeploymentInfo.ps1

**Purpose**: Collects information about application deployments, including their status and enforcement states.

**Key Features**:

- Query deployment details by application name, hostname, username, collection ID, or status.
- Converts status and enforcement state codes into human-readable formats.
- Supports filtering by deployment status (e.g., Success, Error, InProgress).
- Example Usage:

```powershell

  Get-AppDeploymentInfo -CollectionID XYZ00123 -Status Error

```

---

### 3. Get-BIOSInfo.ps1

Purpose: Retrieves BIOS information for systems based on various filtering criteria.

**Key Features**:

- Query BIOS details by hostname, model, BIOS version, username, or resource ID.
- Excludes VMware-based systems by default.
- Provides structured output, including hostname, BIOS version, model, and username.

**Example Usage**:

```powershell

Get-BIOSInfo -HostName DEVICE1

```

---

### 4. Get-DeviceSpecs.ps1

**Purpose**: Retrieves detailed hardware specifications for devices, including CPU, RAM, storage, GPU, and network adapters.

**Key Features**:

- Query hardware specs by hostname or collection ID.
- Supports exporting results to a CSV file.
- Provides both formatted and raw output options.

**Example Usage**:

```POWERSHELL
Get-DeviceSpecs -HostName DEVICE1
```

---

#### Requirements

- PowerShell 5.1 or later.
- Access to the WMI database for querying system information.
- Administrative privileges may be required for certain queries.

#### Usage

- Clone the repository to your local machine.
- Open a PowerShell session with the necessary permissions.
- Import the desired script using the . operator or run it directly.
- Use the provided examples or refer to the script's inline documentation for parameter details.

---

### Contributing

Contributions are welcome! If you have suggestions for improvements or additional functionality, feel free to submit a pull request.

### License

This repository is licensed under the MIT License. See the LICENSE file for more details.
