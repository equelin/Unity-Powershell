[![GitHub version](https://badge.fury.io/gh/equelin%2FUnity-Powershell.svg)](https://badge.fury.io/gh/equelin%2FUnity-Powershell)

# Unity-Powershell

This is a PowerShell module for querying EMC Unity array's API.

![](./Medias/Unity-Powershell-Demo-01.gif)

With this module (version 0.8.0) you can manage:

- System (DNS,NTP...)
- Pools (Virtual and physical deployment)
- Fast Cache (Physical deployment only)
- LUN (block)
- VMware LUN (block)
- NASServer
- Filesystem
- CIFS Server
- CIFS Shares
- vCenter and ESXi servers
- iSCSI parameters

More functionalities will be added later.

# Usage

This module try to mimic VMware PowerCLI usage. All resources management functions are available with the powershell's verbs GET, NEW, SET, REMOVE. 
For example, you can manage Pools with the following commands:
- Get-UnityPool
- New-UnityPool
- Set-UnityPool
- Remove-UnityPool

Some functions accept pipelining. If you want to delete all the existing LUNS you can do this:

```powershell
Get-UnityLUN | Remove-UnityLUN
```

# Requirements

- Powershell 5
- An EMC Unity array ! 

# Instructions
### Install the module
```powershell
#Automated installation (Powershell 5):
    Install-Module Unity-Powershell

# Or manual setup
    # Download the repository
    # Unblock the zip
    # Extract the Unity-Powershell folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

# Import the module
    Import-Module Unity-Powershell  #Alternatively, Import-Module \\Path\To\Unity-Powershell

# Get commands in the module
    Get-Command -Module Unity-Powershell

# Get help
    Get-Help Get-UnityUser -Full
    Get-Help Unity-Powershell
```

# Examples
### Connection to the Unity array

The first thing to do is to connect to an EMC Unity array with the command `Connect-Unity`:

```PowerShell
# Connect to the Unity array
    Connect-Unity -Server 192.168.0.1

    Server       User  Name     Model    SerialNumber
    ------       ----  ----     -----    ------------
    192.168.0.1 admin UnityDemo UnityVSA VIRT1919K58MXM
```

The parameter `-TrustAllCerts` allow to accept or not untrusted certificates. It is set to `$True` by default.

```PowerShell
# Connect to the Unity array without allowing untrusted certificates
    Connect-Unity -Server 192.168.0.1 -TrustAllCerts $false

    Server       User  Name     Model    SerialNumber
    ------       ----  ----     -----    ------------
    192.168.0.1 admin UnityDemo UnityVSA VIRT1919K58MXM
```

### LUN Management

You can create a new LUN `New-UnityLUN`, retrieves informations `Get-UnityLUN`, modify his properties `Set-UnityLUN` or delete it `Remove-UnityLUN`

```PowerShell
# Create a block LUN
    New-UnityLUN -Name 'LUN01' -Pool 'pool_1' -Size 1024000

    Name  id    pool   isThinEnabled tieringPolicy sizeTotal sizeUsed sizeAllocated
    ----  --    ----   ------------- ------------- --------- -------- -------------
    LUN01 sv_69 pool_1 True          Autotier_High 1024000   0        0


# Retrieve informations about block LUN
    Get-UnityLUN

    Name  ID   pool   isThinEnabled tieringPolicy sizeTotal  sizeUsed sizeAllocated
    ----  --   ----   ------------- ------------- ---------  -------- -------------
    LUN01 sv_1 pool_1 True          Autotier_High 1073741824 0        0
    LUN02 sv_2 pool_1 True          Autotier_High 1073741824 0        0


# Delete a LUN
    Remove-UnityLUN -Name 'LUN01'
```

### Users Management

You can add a new user `New-UnityUser`, modify his properties `Set-UnityUSer` or delete it `Remove-UnityUser`.

```PowerShell
# Retrieve informations about a specific user
    Get-UnityUser -Name 'demo'

    id        Name Role
    --        ---- ----
    user_demo demo storageadmin

# Change the role of the user from storageadmin to operator
    Get-UnityUser -Name 'demo' | Set-UnityUser -Role 'operator'

    id        Name Role
    --        ---- ----
    user_demo demo operator    

# Delete an user
    Remove-UnityUser -Name 'demo'
```

### Query ressources

For testing purpose you can query all the ressources of the array with the command `Get-UnityItem`. You have to provide the URI of the ressource with the parameter `-URI`. It will returns a powershell object or a JSON item (with the parameter `-JSON`)without any formatting.

```PowerShell
# Retrieve informations about ntp servers. Result is a powershell object
    $response = Get-UnityItem -URI '/api/types/ntpServer/instances?fields=id,addresses'
    $response.entries.content

    id addresses
    -- ---------
    0  {pool.ntp.org}

# Retrieve informations about ntp servers. result is in the JSON format
    $response = Get-UnityItem -URI '/api/types/ntpServer/instances?fields=id,addresses' -JSON
```

### Disconnection

```PowerShell
# Disconnect from the EMC Unity Array
    Disconnect-Unity
```

# Author

**Erwan Quélin**
- <https://github.com/equelin>
- <https://twitter.com/erwanquelin>

# Special Thanks

- David Muegge for his [blog post](http://muegge.com/blog/emc-unity-rest-api-powershell/) about using EMC Unity API with powershell
- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- [Chris Wahl](http://wahlnetwork.com) for his blog posts about powershell and REST API.

# License

Copyright 2016 Erwan Quelin and the community.

Licensed under the MIT License
