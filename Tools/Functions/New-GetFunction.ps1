Function New-GetFunctionIDName {

    [CmdletBinding()]
    [OutputType('System.IO.FileInfo')]
    param (
        $Typename,
        $URI,
        $Object,
        $Synopsis,
        $Path
    )

    Process {


    $FunctionName = "Get-$Typename"
    $FunctionPath = Join-Path -Path $Path -ChildPath "$FunctionName.ps1"
    $FunctionIDName ="Function $FunctionName {

  <#
      .SYNOPSIS
      $Synopsis
      .DESCRIPTION
      $Synopsis
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Name
      Specifies the object name.
      .PARAMETER ID
      Specifies the object ID.
      .EXAMPLE
      $FunctionName

      Retrieve information about all $Object
      .EXAMPLE
      $FunctionName -ID 'id01'

      Retrieves information about a specific $Object
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = `$false,HelpMessage = 'EMC Unity Session')]
    `$session = (`$global:DefaultUnitySession | where-object {`$_.IsConnected -eq `$true}),
    [Parameter(Mandatory = `$false,ParameterSetName='Name',ValueFromPipeline=`$True,ValueFromPipelinebyPropertyName=`$True,HelpMessage = '$Object Name')]
    [String[]]`$Name,
    [Parameter(Mandatory = `$false,ParameterSetName='ID',ValueFromPipeline=`$True,ValueFromPipelinebyPropertyName=`$True,HelpMessage = '$Object ID')]
    [String[]]`$ID
  )

  Begin {
    Write-Debug -Message `"[`$(`$MyInvocation.MyCommand)] Executing function`"

    #Initialazing variables
    `$URI = '$URI' #URI
    `$TypeName = '$Typename'
  }

  Process {
    Foreach (`$sess in `$session) {

      Write-Debug -Message `"[`$(`$MyInvocation.MyCommand)] Processing Session: `$(`$Session.Server) with SessionId: `$(`$Session.SessionId)`"

      Get-UnityItemByKey -Session `$Sess -URI `$URI -Typename `$Typename -Key `$PsCmdlet.ParameterSetName -Value `$PSBoundParameters[`$PsCmdlet.ParameterSetName]

    } # End Foreach (`$sess in `$session)
  } # End Process
} # End Function
"

Set-Content -Path $FunctionPath -Force -Value $FunctionIDName

    }
}
##############################################

Function New-GetFunctionID {


    [CmdletBinding()]
    [OutputType('System.IO.FileInfo')]
    param (
        $Typename,
        $URI,
        $Object,
        $Synopsis,
        $Path
    )

    Process {


    $FunctionName = "Get-$Typename"
    $FunctionPath = Join-Path -Path $Path -ChildPath "$FunctionName.ps1"
    $FunctionIDName ="Function $FunctionName {

  <#
      .SYNOPSIS
      $Synopsis
      .DESCRIPTION
      $Synopsis
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER ID
      Specifies the object ID.
      .EXAMPLE
      $FunctionName

      Retrieve information about all $Object
      .EXAMPLE
      $FunctionName -ID 'id01'

      Retrieves information about a specific $Object
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = `$false,HelpMessage = 'EMC Unity Session')]
    `$session = (`$global:DefaultUnitySession | where-object {`$_.IsConnected -eq `$true}),
    [Parameter(Mandatory = `$false,ParameterSetName='ID',ValueFromPipeline=`$True,ValueFromPipelinebyPropertyName=`$True,HelpMessage = '$Object ID')]
    [String[]]`$ID
  )

  Begin {
    Write-Debug -Message `"[`$(`$MyInvocation.MyCommand)] Executing function`"

    #Initialazing variables
    `$URI = '$URI' #URI
    `$TypeName = '$Typename'
  }

  Process {
    Foreach (`$sess in `$session) {

      Write-Debug -Message `"[`$(`$MyInvocation.MyCommand)] Processing Session: `$(`$Session.Server) with SessionId: `$(`$Session.SessionId)`"

      Get-UnityItemByKey -Session `$Sess -URI `$URI -Typename `$Typename -Key `$PsCmdlet.ParameterSetName -Value `$PSBoundParameters[`$PsCmdlet.ParameterSetName]

    } # End Foreach (`$sess in `$session)
  } # End Process
} # End Function
"

Set-Content -Path $FunctionPath -Force -Value $FunctionIDName

    }
}

##############################################

$JSON = Get-Content -Path F:\Code\GitHub\Unity-Powershell\Tests\Class\Data\Unity300-4_1.json | ConvertFrom-Json

$Content = $JSON.entries.content  | Where-Object {$_.Name -notlike "*Enum*"}

Foreach ($item in $Content) {

    $Typename = "Unity" + $item.name
    $URI = "/api/types/$($item.name)/instances"
    $Object = $Typename
    $Synopsis = $item.DESCRIPTION
    $Path = 'F:\Code\GitHub\Unity-Powershell\Tools\Functions\Result'


    If ($item.attributes | Where-Object {$_.Name -match 'name'}) {
        New-GetFunctionIDName -Typename $Typename -URI $URI -Object $Object -Synopsis $Synopsis -Path $Path
    } else {
        New-GetFunctionID -Typename $Typename -URI $URI -Object $Object -Synopsis $Synopsis -Path $Path
    }
}