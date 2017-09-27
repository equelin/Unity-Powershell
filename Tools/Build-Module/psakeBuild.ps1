Include -fileNamePathToInclude "$PSScriptRoot\Readthedocs\Update-Doc.ps1"
Include -fileNamePathToInclude "$PSScriptRoot\Format\Convert-ClassToPS1xml.ps1"

properties {
    # Importing config file
    . "$PSScriptRoot\Configs\Config.ps1"

    Set-BuildEnvironment -Path $cfg.ProjectRoot -Force
}

task default -depends format,functions,docs

# Generate .ps1xml format files and Update the content of the module's metadata
task format {

    If (Get-Module $ENV:BHProjectName -ErrorAction SilentlyContinue) {Remove-Module $ENV:BHProjectName}

    $scriptBody = "using module $ENV:BHModulePath"
    $script = [ScriptBlock]::Create($scriptBody)
    . $script | Out-Null

    Try {
        Foreach ($Class in ($cfg.classes)) {
            Write-Host "Processing class $($Class.TypeName)" -ForegroundColor Blue
            Convert-ClassToPS1xml -TypeName $Class.TypeName -TableHeaderList $Class.TableHeaderList -OutputPath $cfg.FormatOutputPath  
        }
    } Catch {
        # If unable to proceed, stop
        Write-Error $_
    }

    Write-Host "Update Module Manifest with all .ps1xml format files" -ForegroundColor Blue
    Set-ModuleFormats -Name $ENV:BHModulePath -FormatsRelativePath '.\Format'
}

# Update the content of the module's metadata with all the public functions to export
task functions {

   If (Get-Module $ENV:BHProjectName -ErrorAction SilentlyContinue) {Remove-Module $ENV:BHProjectName}

    Try {

        $Parent = $ENV:BHModulePath
        $File = "$ENV:BHProjectName.psd1"
        $ModulePSD1Path = Join-Path $Parent $File

        Write-Host "Update module manifest with exported functions $($Class.TypeName)" -ForegroundColor Blue

        Update-MetaData -Path $ModulePSD1Path -PropertyName FunctionsToExport -Value "*"

        Set-ModuleFunctions -Name $ENV:BHModulePath
    } Catch {
        # If unable to proceed, stop
        Write-Error $_
    }
}

# Update mkdocs.yml with all function's reference help files
task docs {
    Try {
        Update-Doc
    } Catch {
        # If unable to proceed, stop
        Write-Error $_
    }
}
