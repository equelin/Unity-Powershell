<#
    .SYNOPSIS
        Retrieve GitHub release.

    .DESCRIPTION
        Retrieve GitHub release.

#>

Function Get-GitHubCommit {
    [cmdletbinding()]
    param(
        #GitHub user name.
        [Parameter(Mandatory=$true)]
        [string]$username,

        #GitHub repository name.
        [Parameter(Mandatory=$true)]
        [string]$repository,

        #SHA or branch to start listing commits from. Default: the repository’s default branch (usually master).
        [Parameter(Mandatory=$false)]
        [string]$sha = 'master',
        
        #Only commits containing this file path will be returned.
        [Parameter(Mandatory=$false)]
        [string]$path,
        
        #GitHub login or email address by which to filter by commit author.
        [Parameter(Mandatory=$false)]
        [string]$author,
        
        #Only commits after this date will be returned. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
        [Parameter(Mandatory=$false)]
        [string]$since,
        
        #Only commits before this date will be returned. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
        [Parameter(Mandatory=$false)]
        [string]$until
    )

    Process {

        #Building URI
        $URI = 'https://api.github.com/repos/'+$username+'/'+$repository+'/commits?sha='+$sha

        If ($path) {
            $query = $query+'&path='+$path
        }

        If ($author) {
            $query = $query+'&author='+$author
        }

        If ($since) {
            $query = $query+'&since='+$since
        }

        If ($until) {
            $query = $query+'&until='+$until
        }

        If ($query) {
            $URI = $URI+$query
        }

        Write-Verbose $URI

        Try {
            Invoke-RestMethod -Uri $URI -Method 'Get'
        }
        Catch {
            Throw "Error... $_"
        }
    }
}

<#
    .SYNOPSIS
        Retrieve GitHub release.

    .DESCRIPTION
        Retrieve GitHub release.

#>

Function Get-GitHubRelease {
    [cmdletbinding()]
    param(
        #GitHub user name.
        [Parameter(Mandatory=$true)]
        [string]$username,

        #GitHub repository name.
        [Parameter(Mandatory=$true)]
        [string]$repository,

        #The name of the tag.
        [Parameter(Mandatory=$false)]
        [switch]$latest
    )

    Process {

        #Building URI
        $URI = 'https://api.github.com/repos/'+$username+'/'+$repository+'/releases'

        If ($latest) {
            $URI = $URI+'/latest'
        }

        Write-Verbose $URI

        Try {
            Invoke-RestMethod -Uri $URI -Method 'Get'
        }
        Catch {
            Throw "Error... $_"
        }
    }
}

<#
    .SYNOPSIS
        Creates a GitHub release.

    .DESCRIPTION
        Creates a GitHub release.
        Users with push access to the repository can create a release.

#>
Function New-GitHubRelease {

    [cmdletbinding()]
    param(
        #GitHub user name.
        [Parameter(Mandatory=$true)]
        [string]$username,

        #GitHub repository name.
        [Parameter(Mandatory=$true)]
        [string]$repository,

        #GitHub authentication token
        [Parameter(Mandatory=$true)]
        [string]$token,

        #The name of the tag.
        [Parameter(Mandatory=$true)]
        [string]$tag_name,

        #The name of the release.
        [Parameter(Mandatory=$false)]
        [string]$Name, 

        #Specifies the commitish value that determines where the Git tag is created from.
        [Parameter(Mandatory=$false)]
        [string]$target_commitish, 

        #Text describing the contents of the tag.
        [Parameter(Mandatory=$false)]
        [string]$body,

        #true to create a draft (unpublished) release, false to create a published one. Default: false
        [Parameter(Mandatory=$false)]
        [bool]$draft = $false,

        #true to identify the release as a prerelease. false to identify the release as a full release. Default: false
        [Parameter(Mandatory=$false)]
        [bool]$prerelease = $false
    )

    Process {

        #GitHub authentication
        $BasicToken = $username+':'+$token
        $Base64BasicToken = [System.Convert]::ToBase64String([char[]]$BasicToken)

        #Building URI
        $URI = 'https://api.github.com/repos/'+$username+'/'+$repository+'/releases'

        #Building header
        $Headers = @{
            Authorization = 'Basic {0}' -f $Base64BasicToken
        }

        #Building body
        $RequestBody = @{}

        $RequestBody["tag_name"] = $tag_name

        If ($PSBoundParameters.ContainsKey('name')) {
            $Requestbody["name"] = "$name"
        }

        If ($PSBoundParameters.ContainsKey('target_commitish')) {
            $Requestbody["target_commitish"] = "$target_commitish"
        }

        If ($PSBoundParameters.ContainsKey('body')) {
            $Requestbody["body"] = "$body"
        }

        If ($PSBoundParameters.ContainsKey('draft')) {
            $Requestbody["draft"] = $draft
        }

        If ($PSBoundParameters.ContainsKey('prerelease')) {
            $Requestbody["prerelease"] = $prerelease
        }

        $RequestBody = $RequestBody | ConvertTo-JSON

        Write-Verbose $RequestBody

        Invoke-RestMethod -Headers $Headers -Uri $URI -Body $RequestBody -Method 'Post'

    }
}

function Resolve-Module
{
    [Cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]$Name
    )
    Process
    {
        foreach ($ModuleName in $Name)
        {
            $Module = Get-Module -Name $ModuleName -ListAvailable
            Write-Verbose -Message "Resolving Module $($ModuleName)"

            if ($Module)
            {
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                $GalleryVersion = Find-Module -Name $ModuleName -Repository PSGallery | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum

                if ($Version -lt $GalleryVersion)
                {
                    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

                    Write-Verbose -Message "$($ModuleName) Installed Version [$($Version.tostring())] is outdated. Installing Gallery Version [$($GalleryVersion.tostring())]"
                    Install-Module -Name $ModuleName -Force
                    Import-Module -Name $ModuleName -Force -RequiredVersion $GalleryVersion
                }
                else
                {
                    Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
                    Import-Module -Name $ModuleName -Force -RequiredVersion $Version
                }
            }
            else
            {
                Write-Verbose -Message "$($ModuleName) Missing, installing Module"
                Install-Module -Name $ModuleName -Force 
                Import-Module -Name $ModuleName -Force -RequiredVersion $Version
            }
        }
    }
}

Function Add-AppVeyorLog {
    [cmdletbinding()]
    param(
        # Message
        [Parameter(Mandatory=$true)]
        [string]$Message,

        #Category
        [Parameter(Mandatory=$false)]
        [string]$Category = 'Information',

        #Category
        [Parameter(Mandatory=$false)]
        [string]$Details
    )

    Process {

        $Timestamp = Get-date -uformat "%Y/%m/%d-%Hh%Mm%Ss"

        Switch ($Category) {
            'Information' {$CategoryColor = 'Green'}
            'Warning' {$CategoryColor = 'Yellow'}
            'Error' {$CategoryColor = 'Red'}
        }

        If ($Details) {
            Add-AppveyorMessage -Message $Message -Category $Category -Details $Details
            Write-Host "[$Timestamp] - [$Category] - $Message" -Foreground $CategoryColor
            Write-Host "$Details" -ForegroundColor $CategoryColor     
        } else {
            Add-AppveyorMessage -Message $Message -Category $Category
            Write-Host "[$Timestamp] - [$Category] - $Message" -Foreground $CategoryColor    
        }
    }
}