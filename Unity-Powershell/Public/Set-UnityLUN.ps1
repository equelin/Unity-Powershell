Function Set-UnityLUN {

  <#
      .SYNOPSIS
      Modifies LUN parameters.
      .DESCRIPTION
      Modifies LUN parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityLUN -Name 'LUN01' -Description 'Modified description'

      Change the description of the LUN named LUN01
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name or LUN Object')]
    $Name,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the LUN')]
    [String]$NewName,
    [Parameter(Mandatory = $false,HelpMessage = 'New LUN Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'New LUN Size in Bytes')]
    [String]$Size
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
              $LUNName = $n
            }
            "UnityLUN" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $LUNName = $n.Name
              If (Get-UnityLUN -Session $Sess -Name $n.Name) {
                        $LUNID = $n.id
              }
            }
          }

          If ($LUNID) {

            $UnityStorageRessource = Get-UnitystorageResource -Session $sess | ? {($_.Name -like $LUNName) -and ($_.luns.id -like $LUNID)}

            # Creation of the body hash
            $body = @{}

            # Name parameter
            If ($NewName) {
              $body["name"] = "$($NewName)"
            }

            # Description parameter
            If ($Description) {
              $body["description"] = "$($Description)"
            }

            # lunParameters parameter
            If ($Size) {
              $body["lunParameters"] = @{}
              $lunParameters = @{}

              If ($Size) {
                $lunParameters["size"] = $($Size)
              }

              $body["lunParameters"] = $lunParameters
            }

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/storageResource/'+($UnityStorageRessource.id)+'/action/modifyLun'
            Write-Verbose "URI: $URI"

            #Sending the request
            If ($pscmdlet.ShouldProcess($LUNName,"Modify LUN")) {
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "LUN with ID: $LUNID has been modified"

              Get-UnityLUN -Session $Sess -id $LUNID

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
