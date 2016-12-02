Deploy DeveloperBuild {
    By AppVeyorModule {
        FromSource $ENV:BHPSModulePath
        To AppVeyor
        WithOptions @{
            Version = $env:BHModuleVersion
        }
    }
}
