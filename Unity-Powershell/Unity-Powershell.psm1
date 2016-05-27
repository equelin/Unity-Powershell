
#Get public and private function definition files
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        Write-Verbose "Import file: $($import.fullname)"
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import file $($import.fullname): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.Basename

#Variable initialization

[UnitySession[]]$global:DefaultUnitySession = @()

#Custom Classes

Class UnitySession {
  [bool]$IsConnected
  [string]$Server
  [System.Collections.Hashtable]$Headers
  [System.Net.CookieCollection]$Cookies
  [string]$SessionId
  [string]$User
  [string]$Name
  [string]$model
  [string]$SerialNumber
}

Class UnitySystem {
  [string]$id
  $health
  [string]$Name
  [string]$Model
  [string]$serialNumber
  [string]$internalModel
  [string]$platform
  [string]$macAddress
}

Class UnityUser {
  [string]$id
  [string]$Name
  $Role
}

Enum LUNTypeEnum {
  GenericStorage = 1
  Standalone = 2
  VMwareISCSI = 3
}

Enum TieringPolicyEnum {
  Autotier_High = 0
  Autotier = 1
  Highest = 2
  Lowest = 3
  No_Data_Movement = 4
  Mixed = 0xffff

}

Class UnityLUN {
  [string]$id
  $health
  [string]$Name
  [string]$description
  [LUNTypeEnum]$type
  [long]$sizeTotal
  [long]$sizeUsed
  [long]$sizeAllocated
  $perTierSizeUsed
  [bool]$isThinEnabled
  $storageResource
  $pool
  [string]$wwn
  [TieringPolicyEnum]$tieringPolicy
  $defaultNode
  [bool]$isReplicationDestination
  $currentNode
  $snapSchedule
  [bool]$isSnapSchedulePaused
  $ioLimitPolicy
  [long]$metadataSize
  [long]$metadataSizeAllocated
  [string]$snapWwn
  [long]$snapsSize
  [long]$snapsSizeAllocated
  $hostAccess
  [int]$snapCount
}
