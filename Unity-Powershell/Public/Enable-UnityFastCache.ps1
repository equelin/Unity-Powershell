Function Enable-UnityFastCache {

  <#
      .SYNOPSIS
      Enable FAST Cache.
      .DESCRIPTION
      Enable FAST Cache using specified disk group and number of disks and if specified, Enable FAST Cache on all existing pools. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER diskgroup
      Specify the disk group ID to include in the FAST Cache.
      .PARAMETER numberOfDisks
      Specify the number of disks to include in the FAST Cache.
      .PARAMETER enableOnAllPools
      Specify whether FAST Cache is enabled on all existing pools.
      .EXAMPLE
      Enable-UnityFastCache -diskgroup 'DG_1' -numberOfDisks 2

      Enable Fast Cache with 2 disk from the disk group 'DG_1'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #FastCache enable parameters
    [Parameter(Mandatory = $true,HelpMessage = 'Disk group ID from which to take disks for FAST cache')]
    [string]$diskgroup,
    [Parameter(Mandatory = $true,HelpMessage = 'Number of disks')]
    [int]$numberOfDisks,
    [Parameter(Mandatory = $false,HelpMessage = 'Enable FAST Cache for all existing pools')]
    [switch]$enableOnAllPools
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

          # Creation of the body hash
          $body = @{}
          
          #diskgroup
          $body['diskgroup'] = @{}
            $diskgroupParam = @{}
            $diskgroupParam['id'] = $diskgroup
          $body['diskgroup'] = $diskgroupParam

          #numberOfDisks
          $body['numberOfDisks'] = $numberOfDisks

          # enableOnAllPools
          If ($PSBoundParameters.ContainsKey('enableOnAllPools')) {
            $body["enableOnAllPools"] = $true
          }

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/fastCache/0/action/enable?timeout=0' #run async
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($($Sess.Server),"Enable Fast Cache")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '202') {
            Write-Host "Fast Cache is currently enabling"
          }

      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}
