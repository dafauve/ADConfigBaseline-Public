try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
$DC_list = Import-Clixml $LogPath\Get-DomainController_diff.xml
}
catch {
$LogPath=".\Logs\"
$DC_list = Invoke-Expression .\get-domaincontroller.ps1
}


Function get-DN {
[CmdletBinding()]             
 Param              
   ( 
    $DomContr 
   )#End Param 

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DCName' -Value "unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DCContainer' -Value "unknown"

$Output.DCName= $DomContr.DCName
$Output.DCContainer= $DomContr.DCContainer

Write-Output $Output
}


$DN=@()

ForEach ($DC in $DC_list)
{
$DN += get-DN $DC
}

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $DN $XMLFile

Write-Output $DN | ft -autosize | Out-Default
Write-Output $DN | ft -autosize | Out-Default >$LogFile


