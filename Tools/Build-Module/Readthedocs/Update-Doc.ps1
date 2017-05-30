Function Update-Doc {
    [CmdletBinding()]
    Param()

    Process {

        Write-Host $ENV:BHModulePath

        $ProjectRoot = $ENV:BHProjectPath

        Import-Module $ENV:BHModulePath -Force

        #Build YAMLText starting with the header
        $YMLtext = (Get-Content "$ProjectRoot\header-mkdocs.yml") -join "`n"
        $YMLtext = "$YMLtext`n"
        $YMLText = "$YMLtext  - Functions References:`n"

        # Drain the swamp
        $parameters = @{
            Recurse = $true
            Force = $true
            Path = "$ProjectRoot\docs\References"
            ErrorAction = 'SilentlyContinue'
        }
        $null = Remove-Item @parameters

        $Params = @{
            Path = "$ProjectRoot\docs\References"
            type = 'directory'
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item @Params

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
            $Part
        }

        $YMLtext | Set-Content -Path "$ProjectRoot\mkdocs.yml"

        Remove-Module $ProjectName

    } # End Process
} # End Function