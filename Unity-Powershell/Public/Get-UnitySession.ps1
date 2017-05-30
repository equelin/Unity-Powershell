Function Get-UnitySession {

  <#
      .SYNOPSIS
      List the existing sessions.
      .DESCRIPTION
      List the existing sessions.
      .NOTES
      Written by Erwan Quelin under MIT licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Server
      IP or FQDN of the Unity array.
      .EXAMPLE
      Get-UnitySession

      List all the existing sessions.
      .EXAMPLE
      Get-UnitySession -Server 192.0.2.1'

      Lists sessions connected the the array '192.0.2.1'
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity IP or FQDN')]
    [String]$Server
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
  }

  Process {
    If ($Server) {
      Write-Verbose "Return DefaultUnitySession matching the Server IP or FQDN: $Server"
      return $global:DefaultUnitySession | where-object {$_.Server -match $Server}
    } else {
      Write-Verbose "Return DefaultUnitySessionclear"
      return $global:DefaultUnitySession
    }
  }

  End {}
}
