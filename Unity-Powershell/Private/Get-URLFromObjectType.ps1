function Get-URLFromObjectType {
  [CmdletBinding()]
  Param (
      [parameter(Mandatory = $true, HelpMessage = "IP/FQDN of the array")]
      [UnitySession]$Session,
      [Parameter(Mandatory = $true,HelpMessage = 'URI')]
      [string]$URI,
      [parameter(Mandatory = $true, HelpMessage = 'Type associated to the item')]
      [string]$TypeName,
      [parameter(Mandatory = $false, HelpMessage = 'Ressource Filter')]
      [string]$Filter,
      [parameter(Mandatory = $false, HelpMessage = 'Compact the response')]
      [switch]$Compact,
      [parameter(Mandatory = $false, HelpMessage = 'Exceptions')]
      [string[]]$Exception = ''
  )

  Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
  Write-Debug -Message "[$($MyInvocation.MyCommand)] Object Type: $Typename"

  # Deal with the exceptions! UnityVMwareLUn and UnityVMwareNFS are in fact UnityLUN and UnityFilesystem objects
  Switch ($Typename) {
    'UnityVMwareLUN' {$type = 'LUN'}
    'UnityVMwareNFS' {$type = 'Filesystem'}
    default {$type = $TypeName -replace 'Unity',''}
  }

  ($Session.types | where-object {$_.name -eq $type}).Attributes | foreach-object {$fields += $_.Name + ','}

  #Remove last ,
  $fields = $fields -replace '.$'

  #Build URL
  $URL = 'https://'+$($Session.Server)+$URI+'?fields='+$fields

  #Add filter if needed
  If ($Filter) {
    $URL = $URL + '&filter=' + $Filter
  }

  #Add compact if needed
  If ($Compact) {
    $URL = $URL + '&compact=true'
  }

  Write-Debug -Message "[$($MyInvocation.MyCommand)] Returning URL: $URL"

  return $URL
}
