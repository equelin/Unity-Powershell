Function Remove-UnityLUNResource {

  <#
      .SYNOPSIS
      Delete a LUN.
      .DESCRIPTION
      Delete a LUN ressource (LUN, VMWare VMFS LUN, VMware NFS LUN).
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityLUNResource -Name 'LUN01'

      Delete the LUN named 'LUN01'
      .EXAMPLE
      Get-UnityLUNResource -Name 'LUN01' | Remove-UnityLUNResource

      Delete the LUN named 'LUN01'. The LUN's informations are provided by the Get-UnityLUNResource through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID or Object')]
    $ID
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/storageResource/<id>'
    $Type = 'LUN Resource'
    $TypeName = 'UnityLUN'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          Switch ($i.GetType().Name)
          {
            "String" {
              $Object = get-UnityLUN -Session $Sess -ID $i
              $ObjectID = $Object.id
              If ($Object.Name) {
                $ObjectName = $Object.Name
              } else {
                $ObjectName = $ObjectID
              }
            }
            "$TypeName" {
              Write-Verbose "Input object type is $($i.GetType().Name)"
              $ObjectID = $i.id
              If ($Object = Get-UnityLUN -Session $Sess -ID $ObjectID) {
                If ($Object.Name) {
                  $ObjectName = $Object.Name
                } else {
                  $ObjectName = $ObjectID
                }          
              }
            }
          } # End Switch

          If ($ObjectID) {

            $UnityStorageRessource = Get-UnitystorageResource -Session $sess | ? {($_.Name -like $LUNName) -and ($_.luns.id -like $LUNID)}

            #Building the URL
            $URI = $URI -replace '<id>',$UnityStorageRessource.id

            $URL = 'https://'+$sess.Server+$URI
            Write-Verbose "URL: $URL"

            if ($pscmdlet.ShouldProcess($Sess.Name,"Delete $Type $ObjectName")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been deleted"

            } # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
