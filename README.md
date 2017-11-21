| Branch | AppVeyor | Docs |
| ------ | -------- | ---- |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/y6w9s01j9ddqnsbi/branch/master?svg=true)](https://ci.appveyor.com/project/equelin/unity-powershell) | [![Documentation Status](https://readthedocs.org/projects/unity-powershell/badge/?version=latest)](http://unity-powershell.readthedocs.io/en/latest/?badge=latest) |
| develop | [![Build status](https://ci.appveyor.com/api/projects/status/y6w9s01j9ddqnsbi/branch/develop?svg=true)](https://ci.appveyor.com/project/equelin/unity-powershell) | [![Documentation Status](https://readthedocs.org/projects/unity-powershell/badge/?version=develop)](http://unity-powershell.readthedocs.io/en/develop/?badge=latest) |

Last release: [![GitHub version](https://badge.fury.io/gh/equelin%2FUnity-Powershell.svg)](https://github.com/equelin/Unity-Powershell/releases/latest)

# Unity-Powershell

This is a Powershell module for managing EMC Unity arrays (physical or virtual).
Unity-Powershell is a member of the DevHigh5 program from [{code} by Dell EMC(tm)](https://github.com/codedellemc/codedellemc.github.io/wiki/DevHigh5-Program-Overview-and-FAQ).

![](./Medias/Unity-Powershell-Demo-01.gif)

With this module you can manage:

- System (DNS, NTP...)
- Pools (virtual and physical deployments)
- Fast Cache (physical deployments only)
- LUN (block)
- VMware LUN (block and NFS)
- NASServer
- Filesystem
- CIFS Server and Shares
- NFS Server and Shares
- vCenter and ESXi servers
- iSCSI parameters
- Snapshots and snapshots schedules
- Performance metrics

More functionality will be added later.

# Usage

This module tries to mimic VMware PowerCLI usage. All resource management functions are available with the Powershell verbs GET, NEW, SET, REMOVE. 
For example, you can manage Pools with the following commands:

- `Get-UnityPool`
- `New-UnityPool`
- `Set-UnityPool`
- `Remove-UnityPool`

Some functions accept pipelining. For example, if you want to delete all existing LUNs you can do this:

```powershell
Get-UnityLUN | Remove-UnityLUN
```

# Requirements

- Powershell 5 (If possible get the latest version)
- An EMC Unity array! (virtual or physical)

# Instructions

### Install the module

```powershell
# Automated installation (Powershell 5):
    Install-Module Unity-Powershell

# Or manual setup
    # Download the repository
    # Unblock the zip
    # Extract the Unity-Powershell folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

# Import the module
    Import-Module Unity-Powershell # Alternatively, Import-Module \\Path\To\Unity-Powershell

# Get commands in the module
    Get-Command -Module Unity-Powershell

# Get help
    Get-Help Get-UnityUser -Full
    Get-Help Unity-Powershell
```

# Examples

### Connecting to the Unity array

The first thing to do is to connect to an EMC Unity array with the command `Connect-Unity`:

```powershell
# Connect to the Unity array
    Connect-Unity -Server 192.0.2.1

    Server       User  Name     Model    SerialNumber
    ------       ----  ----     -----    ------------
    192.0.2.1 admin UnityDemo UnityVSA VIRT1919K58MXM
```

The parameter `-TrustAllCerts` controls whether or not to accept untrusted certificates. It is set to `$True` by default.

```powershell
# Connect to the Unity array without allowing untrusted certificates
    Connect-Unity -Server 192.0.2.1 -TrustAllCerts $false

    Server       User  Name     Model    SerialNumber
    ------       ----  ----     -----    ------------
    192.0.2.1 admin UnityDemo UnityVSA VIRT1919K58MXM
```

### LUN Management

You can create a new LUN `New-UnityLUN`, retrieve its information `Get-UnityLUN`, modify its properties `Set-UnityLUN`, or delete it `Remove-UnityLUN`.

```powershell
# Create a block LUN
    New-UnityLUN -Name 'LUN01' -Pool 'pool_1' -Size '10GB'

    Id    Name  Pool          IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
    --    ----  ----          ------------- ------------- ---------   ------------- ----
    sv_94 LUN01 @{id=pool_1} True          Autotier_High 10737418240 0             Standalone


# Retrieve information about block LUN
    Get-UnityLUN

    Id    Name  Pool          IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
    --    ----  ----          ------------- ------------- ---------   ------------- ----
    sv_94 LUN01 @{id=pool_1} True          Autotier_High 10737418240 0             Standalone
    sv_95 LUN02 @{id=pool_1} True          Autotier_High 10737418240 0             Standalone


# Delete a LUN
    Remove-UnityLUN -ID 'sv_95'
```

### User Management

You can add a new user `New-UnityUser`, modify their properties `Set-UnityUser`, or delete them `Remove-UnityUser`.

```powershell
# Retrieve information about a specific user
    Get-UnityUser -Name 'demo'

    Id        Name Role
    --        ---- ----
    user_demo demo @{id=storageadmin}

# Change the role of a user from storageadmin to operator
    Get-UnityUser -Name 'demo' | Set-UnityUser -Role 'operator'

    Id        Name Role
    --        ---- ----
    user_demo demo @{id=operator}  

# Delete a user
    Remove-UnityUser -ID 'user_demo'
```

### Query resources

For testing purposes you can query all the resources of the array with the command `Get-UnityItem`. You have to provide the URI of the resource with the parameter `-URI`. It returns a Powershell object by default or a JSON item (with the parameter `-JSON`) without any formatting.

```powershell
# Retrieve information about NTP servers. Result is a Powershell object
    $response = Get-UnityItem -URI '/api/types/ntpServer/instances?fields=id,addresses'
    $response.entries.content

    id addresses
    -- ---------
    0  {pool.ntp.org}

# Retrieve information about NTP servers. Result is in the JSON format
    $response = Get-UnityItem -URI '/api/types/ntpServer/instances?fields=id,addresses' -JSON
```

### Disconnecting

```powershell
# Disconnect from the EMC Unity Array
    Disconnect-Unity
```

# Author

**Erwan Quélin**

- <https://github.com/equelin>
- <https://twitter.com/erwanquelin>

# Special Thanks

- David Muegge for his [blog post](http://muegge.com/blog/emc-unity-rest-api-powershell/) about using the EMC Unity API with Powershell
- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- [Chris Wahl](http://wahlnetwork.com) for his blog posts about Powershell and REST API.

# License

Copyright 2016-2017 Erwan Quelin and the community.

Licensed under the MIT License.
