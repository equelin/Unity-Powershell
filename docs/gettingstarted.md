# Getting Started

Welcome to the Getting Started page!

In this page we will walk you through your connection to an EMC Unity, and show off the basics of the major features Unity-Powershell has to offer.

Before going further, please read the [Introduction](prerequisites.md) page and verify that you met all the prerequisites and that the module is correctly installed.

### Connection to an array

Before being able to manage your Unity you will need to be connected to an array. The connection is handled by the command `Connect-Unity`

```PowerShell
> Connect-Unity -Server 192.0.2.1

Server       User  Name     Model    SerialNumber
------       ----  ----     -----    ------------
192.0.2.1   admin UnityDemo UnityVSA VIRT1919K58MXM
```

Now that you are connected to an Unity, you can run commands to retrieve informations and configure your array.

### Get informations from the array

All the commands to retrieve informations start with the verb `Get` like `Get-UnityStoragePool` or `Get-UnityVMwareLUN`.

For example, if you want to list all the existing VMware LUN you can run this command:

```Powershell
> Get-UnityVMwareLUN

Id   Name        Pool         IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
--   ----        ----         ------------- ------------- ---------   ------------- ----
sv_2 DATASTORE01 @{id=pool_1} True          Autotier_High 10737418240 28221440      VMwareISCSI
sv_3 DATASTORE02 @{id=pool_1} True          Autotier_High 10737418240 0             VMwareISCSI
```

You can filter your request if you know the ID or the name of the item you're looking for by adding the `-ID` or `-Name` parameters to your command:

```Powershell
> Get-UnityVMwareLUN -Name *01*

Id   Name        Pool         IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
--   ----        ----         ------------- ------------- ---------   ------------- ----
sv_2 DATASTORE01 @{id=pool_1} True          Autotier_High 10737418240 28221440      VMwareISCSI

> Get-UnityVMwareLUN -ID sv_2

Id   Name        Pool         IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
--   ----        ----         ------------- ------------- ---------   ------------- ----
sv_2 DATASTORE01 @{id=pool_1} True          Autotier_High 10737418240 28221440      VMwareISCSI
```

As you can see in the above commands, you can use regular expressions.

### Creation of a new item

Now that we can get data from our array, we may want to configure it. We might want to create a new LUN or a user. All the commands that could be used to create an item starts with the verb `New` like `New-UnityVmwareLUN` or `New-UnityUSer`.

You can run the next command if you want to create a VMWare LUN on the pool 'pool_1, named DATASTORE02 and with a size of 10 GB:

```Powershell
> New-UnityVMwareLUN -Name 'DATASTORE03' -Size 10GB -Pool 'pool_1'
```

You will be asked to confirm your choice and a few seconds later, you'll see informations about the newly created LUN:

```Powershell
Id   Name        Pool         IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
--   ----        ----         ------------- ------------- ---------   ------------- ----
sv_4 DATASTORE03 @{id=pool_1} True          Autotier_High 10737418240 0             VMwareISCSI
```

### Modification of an item

The configuration of almost all items can be modified with the commands started with the verb `Set` like `Set-VMwareUnityLUN` or `Set-UnityUser`.
To modify an item you'll have to know its ID or alternatively, you can use powershell's pipelining possibilities.

Modify the previously created LUN by providing is ID:

```Powershell
> Set-UnityVMwareLUN -ID sv_4 -Size 20GB

Id   Name        Pool         IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
--   ----        ----         ------------- ------------- ---------   ------------- ----
sv_4 DATASTORE03 @{id=pool_1} True          Autotier_High 21474836480 0             VMwareISCSI
```

Modify the previously created LUN with pipelining:

```Powershell
> Get-UnityVMwareLUN -Name DATASTORE03 | Set-UnityVMwareLUN -Description 'New fancy description'

Id   Name        Pool         IsThinEnabled TieringPolicy SizeTotal   SizeAllocated Type
--   ----        ----         ------------- ------------- ---------   ------------- ----
sv_4 DATASTORE03 @{id=pool_1} True          Autotier_High 21474836480 0             VMwareISCSI
```

### Deletion of an item

If you need to delete an item you can look at commands that starts with the verb `Remove`. Please be aware that this kind of operations can lead to data unavailability...

As well as the `Set` commands, you can specify which item you want to delete by providing is ID or by using pipelining functionalities.

Delete the VMware LUN by providing is ID:

```Powershell
> Remove-UnityVMwareLUN -ID sv_4
```

Delete the VMware LUN with pipelining:

```Powershell
> Get-UnityVMwareLUN -Name DATASTORE03 | Remove-UnityVMwareLUN
```

### Disconnection from the array

You can close the connection by using the command `Disconnect-Unity`.
