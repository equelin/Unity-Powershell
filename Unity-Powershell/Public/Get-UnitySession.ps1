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
      .EXAMPLE
      Get-UnitySession

      List all the existing sessions.
      .EXAMPLE
      Get-UnitySession -Server 192.168.0.1'

      Lists sessions connected the the array '192.168.0.1'
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity IP or FQDN')]
    [String]$Server
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
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
