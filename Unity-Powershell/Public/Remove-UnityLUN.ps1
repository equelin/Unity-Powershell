Function Remove-UnityLUN {

  <#
      .SYNOPSIS
      Delete a LUN.
      .DESCRIPTION
      Delete a LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Name
      LUN Name or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityLUN -Name 'LUN01'

      Delete the LUN named 'LUN01'
      .EXAMPLE
      Get-UnityLUN -Name 'LUN01' | Remove-UnityLUN

      Delete the LUN named 'LUN01'. The LUN's informations are provided by the Get-UnityLUN through the pipeline.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name or LUN Object')]
    $Name
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($n in $Name) {

          # Determine input and convert to UnityLUN object
          Switch ($n.GetType().Name)
          {
            "String" {
              $LUN = get-UnityLUN -Session $Sess -Name $n
              $LUNID = $LUN.id
              $LUNName = $LUN.Name
            }
            "UnityLUN" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $LUNName = $n.Name
              If ($LUN = Get-UnityLUN -Session $Sess -Name $LUNName) {
                        $LUNID = $n.id
              }
            }
          }

          If ($LUNID) {
            if ($pscmdlet.ShouldProcess($LUNName,"Delete LUN")) {
              $LUN | Remove-UnityLUNResource -Session $Sess -Confirm:$false
            }
          } else {
            Write-Verbose "LUN $LUNName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}
