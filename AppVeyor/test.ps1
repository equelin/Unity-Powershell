# Find the build folder based on build system
$ProjectRoot = $ENV:BHProjectPath

if(-not $ProjectRoot) {
    $ProjectRoot = $PSScriptRoot
}

# Set some usefull varialbes
$Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
$BaseFileName = "TestResults_PS$PSVersion`_$TimeStamp"

# Gather test results. Store them in a variable and a NUnitXml file
Add-AppVeyorLog -Message 'Run pester tests' -Category 'Information'
$TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\AppVeyor\$TestFile"

# Document the pester results using module Format-Pester
Add-AppVeyorLog -Message "Documenting the pester's results with Format-Pester" -Category 'Information'
$FormatPesterResultFile = $TestResults | Format-Pester -Format 'Text' -BaseFileName $BaseFileName

# In Appveyor?  Upload our tests and documentation! 
Add-AppVeyorLog -Message 'Uploading tests and documentation on Appveyor' -Category 'Information'

#Upload NUnitXml tests results
(New-Object 'System.Net.WebClient').UploadFile(
    "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
    "$ProjectRoot\AppVeyor\$TestFile")

#Upload Format-Pester tests results   
Push-AppveyorArtifact $FormatPesterResultFile

# Stop the build if a pester test fails 
If ($TestResults.FailedCount -gt 0) {
    Add-AppVeyorLog -Message "Tests failed, stop the build" -Category 'Error' -Details "Number of tests failed: $($TestResults.FailedCount)"
    Throw
}