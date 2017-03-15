#importing the module with the using statement, classes will be available in the session 
using module '..\..\Unity-Powershell'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#import module
$Module = Get-Module -Name 'Unity-Powershell'

# Get classes defined by the module
$ActualClasses = $Module.ImplementingAssembly.DefinedTypes | where-Object IsPublic | Where-Object {$_.Name -notlike '*Enum'}

$Datas  = @( Get-ChildItem -Path $here\Data\*.json -ErrorAction SilentlyContinue )

#Dot source the files - idea from https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
Foreach($Data in $Datas) {

    # Load the references datas
    $APITypes = Get-Content $Data.fullname | ConvertFrom-Json

    Describe -Name "Testing Class against file $($Data.Name)" {

        #Test all classes from module
        Foreach ($Class in $ActualClasses) {

            #Create an empty object in order to retrieve it's propoerties 
            $Object = New-Object -TypeName $Class.name

            #Get properties of the object
            $ObjectProperties = $Object | Get-Member | Where-Object {$_.MemberType -eq 'Property'}

            #Remove 'Unity' from the name of the class
            $APIClassName = ($Class.name) -replace 'Unity',''

            #Find the definition of the class in the API
            $APIClass = $APITypes.entries.content | Where-Object {$_.Name -eq $APIClassName}

            Context -Name "Class $($Class.name)" {

                foreach ($Attribute in $APIClass.attributes.name) {

                    It -Name "Attribute $Attribute is defined" {
                        $ObjectProperties.Name -contains $Attribute | Should Be $True
                    }
                }
            }
        }
    }
}

#Remove module
Remove-Module $Module



