try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}
Import-Module ActiveDirectory

Function Get-AdminSDHolder
{ 
[CmdletBinding()]             
 Param              
   ( 
    [String]$Dom 
   )#End Param 
$location = Get-Location
New-PSDrive -Name ADDrive -PSProvider ActiveDirectory -root "//RootDSE/" -Server $Dom | Out-Null
Set-Location ADDrive:

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainName' -Value $Dom
$Output | Add-Member -MemberType 'NoteProperty' -Name 'AdminSDHolderDN' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'AdminSDHolderSDDL' -Value "Domain unreachable"


$Output.AdminSDHolderDN = "CN=AdminSDHolder,"+(Get-ADDomain $Dom).SystemsContainer

$AdminSDHolder = (Get-ADObject -Identity $Output.AdminSDHolderDN)
$Output.AdminSDHolderSDDL = (get-acl ADDrive:\$AdminSDHolder).sddl

Write-Output $Output
set-location $location
Remove-PSDrive ADDrive

}


$DomainList=@()

$DomainList=(Get-ADForest).Domains


$ADHolders=@()


ForEach ($Domain in $DomainList)
{
    
    
    $ADHolders += Get-AdminSDHolder $Domain
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $ADHolders $XMLFile

Write-Output $ADHolders | ft -Wrap -AutoSize | Out-Default
