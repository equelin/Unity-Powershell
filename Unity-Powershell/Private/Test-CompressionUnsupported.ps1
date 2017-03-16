<#
    .SYNOPSIS
    Test if Pool is compatible with compression
    .DESCRIPTION
    Test if Pool is compatible with compression.
    Test if OS version is -ge 4.1
    Test if compression licence is available
    Test if compression feature is enabled
    Test if Pool is Extreme_Performance only
#>


Function Test-CompressionUnsupported {
  [CmdletBinding()]
  Param(
    [parameter(Mandatory = $true)]
    $Session,
    [parameter(Mandatory = $true)]
    $Pool
  )

  Process {

    [bool]$Result = $True

    If ($Session.SoftwareVersion -lt [version]'4.1') {
      #Write-Verbose "Software version lesser than 4.1.0"
      $Result = $false
    }
    If ($Session.isUnityVSA()) {
      #Write-Verbose "Array is an UnityVSA"
      $Result = $false
    }
    If (-not (Get-UnityPool -Session $Session -Id $Pool -ErrorAction SilentlyContinue).isExtremePerformance()) {
      #Write-Verbose "Pool is not Extreme Performance only"
      $Result = $false
    }
    If ((Get-UnityFeature -Session $Session -id INLINE_COMPRESSION -ErrorAction SilentlyContinue).State -ne 'FeatureStateEnabled') {
      #Write-Verbose "Feature INLINE_COMPRESSION is disabled"
      $Result = $false
    }
    If ((Get-UnityLicense -Session $Session -id INLINE_COMPRESSION -ErrorAction SilentlyContinue).isValid -ne $True) {
      #Write-Verbose "Licence INLINE_COMPRESSION is not valid"
      $Result = $false
    }

    Write-Verbose "Is compression supported: $Result"
    Return $Result
  }
}