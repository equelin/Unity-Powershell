Deploy Module {
    By PSGalleryModule {
        FromSource $ENV:BHPSModulePath
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:NugetApiKey
        }
    }
}
