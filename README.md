[![GitHub version](https://badge.fury.io/gh/equelin%2FUnity-Powershell.svg)](https://badge.fury.io/gh/equelin%2FUnity-Powershell)

# Unity-Powershell

This is a PowerShell module for querying EMC Unity array's API. This is at an early stage of the development and it may be seen more like a proof of concept.

# Requirements

You will need to have Powershell 5 to use this module.

# Instructions
### Install the module
```powershell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the Unity-Powershell folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

    #Simple alternative:
        Install-Module Unity-Powershell

# Import the module
    Import-Module Unity-Powershell    #Alternatively, Import-Module \\Path\To\Unity-Powershell

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

### LUN management

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

### Users management

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

# Available functions

- Connect-Unity
- Disconnect-Unity
- Get-UnityBasicSystemInfo
- Get-UnityItem
- New-UnityLUN
- Set-UnityLUN
- Remove-UnityLUN
- Get-UnityLUN
- New-UnityVMwareLUN
- Set-UnityVMwareLUN
- Remove-UnityVMwareLUN
- Get-UnityVMwareLUN
- Get-UnityStorageResource
- Get-UnityPool
- Get-UnitySession
- Get-UnitySystem
- Get-UnityUser
- New-UnityUser
- Set-UnityUser
- Remove-UnityUser
- Get-UnityFeatures
- Get-UnityLicnse

# Author

**Erwan Quélin**
- <https://github.com/equelin>
- <https://twitter.com/erwanquelin>

# Special Thanks

- David Muegge for his [blog post](http://muegge.com/blog/emc-unity-rest-api-powershell/) about using EMC Unity API with powershell
- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- [Chris Wahl](http://wahlnetwork.com) for his blog posts about powershell and REST API.

# License

Copyright 2016 Erwan Quelin.

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
