# Unity-Powershell documentation

Welcome to the documentation page of Unity-Powershell! 

Unity-Powershell is a PowerShell module for managing EMC Unity arrays (physical or virtual). Unity-Powershell is a member of the DevHigh5 program from [{code} by Dell EMC(tm)](https://github.com/codedellemc/codedellemc.github.io/wiki/DevHigh5-Program-Overview-and-FAQ).

The Unity-Powershell project is hosted on [GitHub](https://github.com/equelin/Unity-Powershell) and can also be found on the [Powershell Gallery](https://www.powershellgallery.com/packages/Unity-Powershell/).

### Functionalities

With this module (version 0.11.0) you can manage:

- System (DNS,NTP...),
- Pools (Virtual and physical deployment),
- Fast Cache (Physical deployment only),
- LUN (block),
- VMware LUN (block and NFS),
- NASServer,
- Filesystem,
- CIFS Server and Shares,
- NFS Server and Shares,
- vCenter and ESXi servers,
- iSCSI parameters,
- Snapshots and snapshots schedules.

More functionalities will be added later.

### Usage

This module try to mimic VMware PowerCLI usage. All resources management functions are available with the powershell's verbs `GET`, `NEW`, `SET` and `REMOVE`. 

For example, you can manage Pools with the following commands:

- `Get-UnityPool`
- `New-UnityPool`
- `Set-UnityPool`
- `Remove-UnityPool`