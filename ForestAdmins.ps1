try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}

Function ExtractDomain
{
[CmdletBinding()]             
 Param              
   ( 
    [parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,position=0)]$DistinguishedName
   )#End Param 

   $output = ($DistinguishedName -split 'DC=')[1] -replace ','
   #$output = "\" +($DistinguishedName -split 'CN=')[1] -replace ','
   
   
   Write-Output $output

}


Function Get-GroupMember 
{
[CmdletBinding()]             
 Param              
   ( 
    [String]$Id 
   )#End Param 


$Output=New-Object psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'GroupName' -Value "No Name"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Users' -Value "Unknwow"

$Forest=Get-ADForest

$Output.GroupName = $Id
$Output.Users = Get-ADGroupMember -Server $Forest.name -Identity $Id -Recursive | ForEach-Object {(ExtractDomain $_.'DistinguishedName')+"\"+$_.Name}

Write-Output $Output
}

$GroupMember = @()

$GroupMember += Get-GroupMember -Id "Schema Admins"
$GroupMember += Get-GroupMember -Id "Enterprise Admins"

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $GroupMember $XMLFile

$FAoutput = @{Expression={$_.GroupName};Label="GroupName"},@{Expression={$_.Users -join ", "};Label="Users"}

Write-Output $GroupMember | ft $FAoutput -wrap | Out-Default

Write-Output $GroupMember | ft $FAoutput -wrap >$LogFile


