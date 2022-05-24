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
$ScriptsPath=$Allvar.ScriptPath
$DC_list = Import-Clixml $LogPath\get-domaincontroller_diff.xml
}
catch {
$LogPath=".\Logs\"
$AllVar = Import-Clixml .\Export_Var.xml
If (Get-ChildItem .\get-domaincontroller.ps1)
    {$DC_list = Invoke-Expression .\get-domaincontroller.ps1}
}

#########################################
#########################################
#############
#### End of Header
#############
########################################
############################################


$Shares=@()

$session = New-PSSession -ComputerName $DC_list.DCName 

$Shares = Invoke-Command -Session $session -ErrorAction SilentlyContinue -ScriptBlock {
Get-SMBShare -ErrorAction SilentlyContinue | Select-Object Name,ScopeName,Description,Path
}

Remove-PSSession $session

Write-Output "Start sorting and duplicate cleanup"
$Shares = $Shares | select @{Name='ComputerName';Expression={$_.PSComputerName}},Name,ScopeName,Description,Path


$csvFile = "SMB_Shares_"
$csvFile += get-date -Format "yyyy-MM-dd-HH\hmm"
$csvFile += ".csv"

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"
$csvFile = $LogPath + $csvFile

Export-Clixml -InputObject $Shares $XMLFile

Write-Output $Shares | ft -Wrap 
Write-Output $Shares | export-csv $csvFile -NoTypeInformation
