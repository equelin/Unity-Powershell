Function Update-Doc {
    [CmdletBinding()]
    Param()

    Process {

        Write-Host $ENV:BHModulePath

        $ProjectRoot = $ENV:BHProjectPath

        # Import module. platyPS + AppVeyor requires the module to be loaded in Global scope
        Import-Module $ENV:BHModulePath -Force -Global

        #Build YAMLText starting with the header
        $YMLtext = (Get-Content "$ProjectRoot\header-mkdocs.yml") -join "`n"
        $YMLtext = "$YMLtext`n"
        $YMLText = "$YMLtext  - Functions References:`n"

        # Delete all existing files in $ProjectRoot\docs\References
        $parameters = @{
            Recurse = $true
            Force = $true
            Path = "$ProjectRoot\docs\References"
            ErrorAction = 'SilentlyContinue'
        }
        $null = Remove-Item @parameters

        # Create directory for functions markdown help files
        $Params = @{
            Path = "$ProjectRoot\docs\References"
            type = 'directory'
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item @Params

        # Create all md help files and update 
        $Params = @{
            Module = $ENV:BHProjectName
            Force = $true
            OutputFolder = "$ProjectRoot\docs\References"
            NoMetadata = $true
        }
        New-MarkdownHelp @Params | foreach-object {
            $Function = $_.Name -replace '\.md', ''
            $Part = "    - {0}: References/{1}" -f $Function, $_.Name
            $YMLText = "{0}{1}`n" -f $YMLText, $Part
            Write-Host $Part
        }

        $YMLtext | Set-Content -Path "$ProjectRoot\mkdocs.yml"

        Remove-Module $ENV:BHProjectName

    } # End Process
} # End Function