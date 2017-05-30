Include -fileNamePathToInclude "$PSScriptRoot\Readthedocs\Update-Doc.ps1"
Include -fileNamePathToInclude "$PSScriptRoot\Format\Convert-ClassToPS1xml.ps1"

properties {
    # Importing config file
    . "$PSScriptRoot\Configs\Config.ps1"

    Set-BuildEnvironment -Path $cfg.ProjectRoot -Force
}

task default -depends format,functions

task docs {
    Try {
        Update-Doc
    } Catch {
        # If unable to proceed, stop
        #Write-Error -Message 'Error while updating the docs. Build cannot continue!' 
        $_
    }
}

task format {

    Remove-Module $ENV:BHProjectName

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
        #Write-Error -Message 'Error while updating the docs. Build cannot continue!' 
        $_
    }

    Write-Host "Update Module Manifest" -ForegroundColor Blue
    Set-ModuleFormats -Name $ENV:BHModulePath -FormatsRelativePath '.\Format'
}

task functions {

   # Remove-Module $ENV:BHProjectName -Force

    Try {

        $Parent = $ENV:BHModulePath
        $File = "$ENV:BHProjectName.psd1"
        $ModulePSD1Path = Join-Path $Parent $File

        Write-Host $ModulePSD1Path

        Update-MetaData -Path $ModulePSD1Path -PropertyName FunctionsToExport -Value "*"

        #Remove-Module $ENV:BHProjectName

        Set-ModuleFunctions -Name $ENV:BHModulePath
    } Catch {
        $_
    }
}
