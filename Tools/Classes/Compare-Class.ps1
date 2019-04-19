#importing the module with the using statement, classes will be available in the session 
using module '..\..\Unity-Powershell'

[CmdletBinding()]
Param ()

Function Format-Type {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [String]$Type
    )

    Process {
        Switch -Wildcard ($Type) {
            'Integer' {$output = 'Object'}
            'Boolean' {$output = 'Bool'}
            'String' {$output = 'String'}
            'List<*>' {
                $Type = ($Type.Substring(5)) -replace '>',''
                $output = (Format-Type -Type $Type)+'[]'
            }
            'Datetime' {$output = 'DateTime'}
            'health' {$output = 'UnityHealth'}
            'float' {$output = 'Float'}
            '*Enum' {$Output = $Type}
            Default {$Output = 'Object'}
        }

        $Output
    }    
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#import module
$Module = Get-Module -Name 'Unity-Powershell'

# Get classes defined by the module
$ActualClasses = $Module.ImplementingAssembly.DefinedTypes | where-Object IsPublic | Where-Object {$_.Name -notlike '*Enum'}
$Datas  = @( Get-ChildItem -Path C:\Users\erwan\Documents\Code\Unity-Powershell\Tests\Class\Data\*.json -ErrorAction SilentlyContinue )

Foreach($Data in $Datas) {

    Write-Host $Data.fullname

    # Load the references datas
    $APITypes = Get-Content $Data.fullname | ConvertFrom-Json
        #Test all classes from module
        Foreach ($Class in $ActualClasses) {

            Write-Host "Class: $($Class.Name)"

            #Create an empty object in order to retrieve it's propoerties 
            $Object = New-Object -TypeName $Class.name

            #Get properties of the object
            $ObjectProperties = $Object | Get-Member | Where-Object {$_.MemberType -eq 'Property'}

            #Remove 'Unity' from the name of the class
            $APIClassName = ($Class.name) -replace 'Unity',''

            #Find the definition of the class in the API
            $APIClass = $APITypes.entries.content | Where-Object {$_.Name -eq $APIClassName}

            foreach ($Attribute in $APIClass.attributes) {
                
                If (-not($ObjectProperties.Name -contains $Attribute.Name)) {

                    $Type = Format-Type -Type $Attribute.type
                    Write-Host "[$Type]`$$($Attribute.name) #$($Attribute.description)" -ForegroundColor Red

                }
            }
        }
    }

#Remove module
Remove-Module $Module



