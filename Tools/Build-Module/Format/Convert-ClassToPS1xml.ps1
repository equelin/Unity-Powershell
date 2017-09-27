<#
.SYNOPSIS
This is a really quick and dirty function for building .ps1xml files from class
.NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
.LINK
https://github.com/equelin/Unity-Powershell
.EXAMPLE
.\Convert-ClassToPS1xml.ps1 -TypeName 'UnityPool' -TableHeaderList id,name -OutputPath F:\

Build format file.
#>

#using module '..\..\Unity-Powershell\Unity-Powershell.psm1'

Function Convert-ClassToPS1xml {

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
    Param (
        [Parameter(Mandatory = $true)]
        [String]$TypeName,
        [Parameter(Mandatory = $true)]
        [String[]]$TableHeaderList,
        [Parameter(Mandatory = $false)]
        [String]$OutputPath = '.'
    )

    $NameTable = $TypeName + 'Table'
    $NameList = $TypeName + 'List'
    $FileName = 'Unity-Powershell.' + $TypeName + '.Format.ps1xml'

    $Object = New-Object -TypeName $TypeName

    $Header = "<?xml version=`"1.0`" encoding=`"utf-8`" ?>
    <Configuration>
        <ViewDefinitions>`n"

    $Footer = "    </ViewDefinitions>
    </Configuration>`n"

    $ViewTableHeader = "        <View>
        <Name>$($NameTable)</Name>
        <ViewSelectedBy>
            <TypeName>$($TypeName)</TypeName>
        </ViewSelectedBy>
        <TableControl>
            <AutoSize/>
            <TableHeaders>`n"

    $ViewTableMiddle = "        </TableHeaders>
            <TableRowEntries>
                <TableRowEntry>
                <Wrap/>
                    <TableColumnItems>`n"

    $ViewTableFooter = "                    </TableColumnItems>
                    </TableRowEntry>
                </TableRowEntries>
            </TableControl>
        </View>`n"

    $ViewListHeader = "<View>
        <Name>$($NameList)</Name>
        <ViewSelectedBy>
            <TypeName>$($TypeName)</TypeName>
        </ViewSelectedBy>
        <ListControl>
            <ListEntries>
            <ListEntry>
                <ListItems>`n"

    $ViewListFooter = "             </ListItems>
            </ListEntry>
            </ListEntries>
        </ListControl>
        </View>`n"

    $Document += $Header

    $Document += $ViewTableHeader

    Foreach ($item in $TableHeaderList) {

        $item = $item.substring(0,1).toupper()+$item.substring(1)

        $Document += "            <TableColumnHeader>
                    <Label>$item</Label>
                    <Alignment>Left</Alignment>
                </TableColumnHeader>`n"
    }

    $Document += $ViewTableMiddle

    Foreach ($item in $TableHeaderList) {
        $Document += "                    <TableColumnItem>
                            <PropertyName>$item</PropertyName>
                        </TableColumnItem>`n"
    }

    $Document += $ViewTableFooter

    $Document += $ViewListHeader

    $Object | get-member -type Property | foreach-object {

        $PropertyName = ($_.Name).substring(0,1).toupper()+($_.Name).substring(1)

        $Document += "                  <ListItem>
                        <Label>$PropertyName</Label>
                        <PropertyName>$($_.Name)</PropertyName>
                    </ListItem>`n"
    }

    $Document += $ViewListFooter

    $Document += $Footer

    $Output = $OutputPath+$FileName

    If (Test-Path $Output) {
        Remove-Item $Output -Force
    }

    $Document | Out-File $Output 

}