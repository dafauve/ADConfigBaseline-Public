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

Function Get-RAMConfig {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value $DCName._DCName
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PAEEnabled' -Value $DCName.PAEEnabled
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FreePhysicalMemory' -Value $DCName.FreePhysicalMemory
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FreeVirtualMemory' -Value $DCName.FreeVirtualMemory
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'TotalVirtualMemorySize' -Value $DCName.TotalVirtualMemorySize
        #$Output | Add-Member -MemberType 'NoteProperty' -Name 'TotalVisibleMemorySize' -Value "Server unreachable"
        ## Specific to ComputerSYstem       
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'TotalPhysicalMemory' -Value $DCName.TotalPhysicalMemory
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NumberOfLogicalProcessors' -Value $DCName.NumberOfLogicalProcessors
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NumberOfProcessors' -Value $DCName.NumberOfProcessors


Write-Output $Output
}


$OS_RAM=@()

ForEach ($DC in $WMI_Attrib)
{
$OS_RAM += Get-RAMConfig $DC
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject ($OS_RAM | Select-Object -Property _DCName,PAEEnabled,TotalVirtualMemory,TotalPhysicalMemory,NumberOfLogicalProcessors,NumberOfProcessors) $XMLFile

Write-Output $OS_RAM | ft -Wrap | Out-Default
Write-Output $OS_RAM | Export-Csv $LogPath\WMI_RAM.csv -Delimiter ";" -NoTypeInformation 

