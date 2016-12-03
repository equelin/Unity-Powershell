# Installation

Unity-Powershell is available on the Powershell Gallery. It can be easily installed from there.

1. Install the module
``` Powershell
Install-Module Unity-Powershell -Scope CurrentUser
```

2. Import the module in your powershell session
``` Powershell
Import-Module Unity-Powershell
```

3. Verify that the module is available by listing all the available commands
``` Powershell
Get-Command -Module Unity-Powershell
```

Alternatively you can download the module from GitHub

1. Download the repository
2. Unblock the zip
3. Extract the Unity-Powershell folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)