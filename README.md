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

The first thing to do is to connect to an array:

```PowerShell
# Connect to the Unity array
    Connect-Unity -Server 192.168.0.1

    Server       User  Name     Model    SerialNumber
    ------       ----  ----     -----    ------------
    192.168.0.1 admin UnityDemo UnityVSA VIRT1919K58MXM
```

### LUN management

```PowerShell
# Connect to the Unity array
    Get-UnityLUN

    Name  ID   pool   isThinEnabled tieringPolicy sizeTotal  sizeUsed sizeAllocated
    ----  --   ----   ------------- ------------- ---------  -------- -------------
    LUN01 sv_1 pool_1 True          Autotier_High 1073741824 0        0
    LUN02 sv_2 pool_1 True          Autotier_High 1073741824 0        0
```

### Users management

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

### Testing queries

For testing purpose you can query all the items of the array if you know the URI associated. It will return a powershell object or a JSON item without any formatting.

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
- Get-UnityItem
- Get-UnityLUN
- Get-UnitySession
- Get-UnitySystem
- Get-UnityUser
- New-UnityUser
- Set-UnityUser
- Remove-UnityUser

# Author

**Erwan Quélin**
- <https://github.com/equelin>
- <https://twitter.com/erwanquelin>

# Special Thanks

- David Muegge for is [blog post](http://muegge.com/blog/emc-unity-rest-api-powershell/) about using EMC Unity API with powershell
- Warren F. for is [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- [Chris Wahl](http://wahlnetwork.com) for is blog posts about powershell and REST API.

# License

Copyright 2016 Erwan Quelin.

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
