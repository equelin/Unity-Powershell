Function Remove-UnityVMwareLUN {

  <#
      .SYNOPSIS
      Delete a VMware block LUN.
      .DESCRIPTION
      Delete a VMware block LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      VMware LUN ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityVMwareLUN -ID 'sv_15'

      Delete the VMware block LUN ID 'sv_15'
      .EXAMPLE
      Get-UnityVMwareLUN -ID 'sv_15' | Remove-UnityVMwareLUN

      Delete the VMware block LUN ID 'sv_15'. The LUN's informations are provided by the Get-UnityVMwareLUN through the pipeline.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'VMware LUN ID or Object')]
    $ID
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to UnityLUN object
          Switch ($i.GetType().Name)
          {
            "String" {
              $LUN = get-UnityVMwareLUN -Session $Sess -ID $i
              $LUNID = $LUN.id
              $LUNName = $i
            }
            "UnityLUN" {
              Write-Verbose "Input object type is $($i.GetType().Name)"
              $LUNName = $i.Name
              If ($LUN = Get-UnityVMwareLUN -Session $Sess -ID $i.id) {
                        $LUNID = $i.id
              }
            }
          }

          If ($LUNID) {
            if ($pscmdlet.ShouldProcess($LUNName,"Delete VMware LUN")) {
              $LUN | Remove-UnityLUNResource -Session $Sess -Confirm:$false
            }
          } else {
            Write-Verbose "VMware LUN $LUNName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}
