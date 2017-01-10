# Unity-Powershell Frequently Asked Questions (FAQ)

Welcome on the Unity-Powershell FAQ page!

This document contains frequently asked questions about Unity-Powershell.

## General questions

**Q: What is Unity-Powershell ?**  
A: Unity-Powershell is a set of command on Windows PowerShell that provides management and automation for EMC Unity's arrays. It's shipped with more than 100 commands.

**Q: What can I do with Unity-Powershell ?**  
A: The ultimate goal of the module is to give the possibilities to completly manage an array with powershell commands, but for now, only the most useful commands are available.
New commands are added in every new versions of the module. 

**Q: Is the module ready for production ?**  
A: Unity-Powershell is currently a pre-released version. Even if the module is tested before releasing, please test it yourself before using it on a production environnement.
Also, alway use the most up-to-date version available as it adds new functionnalities and corrects bugs.

**Q: Where can I get the latest version of the module ?**  
A: The module is available on the Powershell gallery. It means that you can simply download it with this command

```Powershell
PS> Install-Module Unity-Powershell -Scope CurrentUser
```

Alternatively, you can download the code directly from the [GitHub repository](https://github.com/equelin/Unity-Powershell).

**Q: Which EMC Unity arrays can I manage with Unity-Powershell ?**  
A: The module is compatible with all existing Unity (Hybrid, Full flash and VSA). It as been tested with code version 4.0 and 4.1.

**Q: Which version of powershell do I need ?**  
A: Powershell 5 is mandatory. The module is build around new functionnalites provided by the 5th version of Powershell (Classes...)

**Q: Where can I find help about Unity-Powershell ?**  
A: Please read the [Getting Started](gettingstarted.md) page and don't hesitate to open an [issue on GitHub](https://github.com/equelin/Unity-Powershell/issues) or reach the [author on Twitter](https://twitter.com/erwanquelin)

## Module usage

**Q: How do I connect to an array ?**  
A: Use the `Connect-Unity` command and provide the FQDN or the IP of the array

 ```Powershell
PS> Connect-Unity unity01.example.com 
```

**Q: Can I manage more than one array ?**  
A: You can provide multiple array's IP or FQDN to the `Connect-Unity` command. Be warned that by default every command will be run against all connected arrays.

**Q: How can I find all available commands ?**  
A: Use this powershell command

 ```Powershell
PS> Get-Command -Module Unity-Powershell 
```

**Q: How can I find help about a specific command ?**  
A: Use his powershell command

 ```Powershell
PS> Get-Help New-UnityVMwareLUN
```