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

try {
$WMI_Attrib = Import-Clixml $LogPath\WMI_Config_diff.xml
}
catch {
$WMI_Attrib = Invoke-Expression .\WMI_Config.ps1
}

###########################################

Function Get-PFConfig {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value $DCName._DCName
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FreeSpaceInPagingFiles' -Value $DCName.FreeSpaceInPagingFiles
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'SizeStoredInPagingFiles' -Value $DCName.SizeStoredInPagingFiles
        ###Specific to page file
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PageFileLocation' -Value $DCName.PageFileLocation
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PFPeakUsage' -Value $DCName.PFPeakUsage
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'TempPageFile' -Value $DCName.TempPageFile
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PFInstallDate' -Value $DCName.PFInstallDate
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PFAllocatedBaseSize' -Value $DCName.PFAllocatedBaseSize
        ## Specific to ComputerSYstem       
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'AutomaticManagedPageFile' -Value $DCName.AutomaticManagedPageFile

Write-Output $Output
}


$OS_PF=@()

ForEach ($DC in $WMI_Attrib)
{
$OS_PF += Get-PFConfig $DC
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject ($OS_PF | Select-Object -Property _DCName,SizeStoredInPagingFiles,PageFileLocation,TempPageFile,PFInstallDate,PFAllocatedBaseSize,AutomaticManagedPageFile) $XMLFile

Write-Output $OS_PF | ft -wrap | Out-Default
Write-Output $OS_PF | Export-Csv $LogPath\WMI_PF.csv -Delimiter ";" -NoTypeInformation 

