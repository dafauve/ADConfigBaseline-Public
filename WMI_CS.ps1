############################
############################
#############
###   Hearder to copy/paste on all scripts (except DefaultOU_DC)
############
##########################
##########################

try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
$DC_list = Import-Clixml $LogPath\get-domaincontroller_diff.xml
}
catch {
$LogPath=".\Logs\"
$DC_list = Invoke-Expression .\get-domaincontroller.ps1
}


#########################################
#########################################
#############
#### End of Header
#############
########################################
############################################

$WMI_Attrib = Invoke-Expression .\WMI_Config.ps1

###########################################

Function Get-CSConfig {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value $DCName._DCName
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSCaption' -Value $DCName.OSCaption
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_32BitApplications' -Value $DCName.DEP_32BitApplications
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_Available' -Value $DCName.DEP_Available
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_Drivers' -Value $DCName.DEP_Drivers
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_SupportPolicy' -Value $DCName.DEP_SupportPolicy
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'MUILanguages' -Value $DCName.MUILanguages
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSLanguage' -Value $DCName.OSLanguage
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Locale' -Value $DCName.Locale
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSInstallDate' -Value $DCName.OSInstallDate
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSStatus' -Value $DCName.OSStatus
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemDirectory' -Value $DCName.SystemDirectory
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Version' -Value $DCName.Version
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Manufacturer' -Value $DCName.Manufacturer
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Model' -Value $DCName.Model


Write-Output $Output
}


$OS_CS=@()

ForEach ($DC in $WMI_Attrib)
{
$OS_CS += Get-CSConfig $DC
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $OS_CS $XMLFile

Write-Output $OS_CS | ft -Wrap | Out-Default
Write-Output $OS_CS | Export-Csv $LogPath\WMI_CS.csv -Delimiter ";" -NoTypeInformation 

