# Installation

Unity-Powershell is available on the Powershell Gallery. It can be easily installed from there.

* Install the module
``` Powershell
Install-Module Unity-Powershell -Scope CurrentUser
```

* Import the module in your powershell session
``` Powershell
Import-Module Unity-Powershell
```

* Verify that the module is available by listing all the exported commands
``` Powershell
Get-Command -Module Unity-Powershell
```

Alternatively you can download the module from GitHub

* Download the repository
* Unblock the zip
* Extract the Unity-Powershell folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)
* Import the module in your powershell session
``` Powershell
Import-Module Unity-Powershell
```
* Verify that the module is available by listing all the exported commands
``` Powershell
Get-Command -Module Unity-Powershell
```
