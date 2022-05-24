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
    [String]$Dom 
   )#End Param 


$Output=New-Object psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainName' -Value $Dom
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainAdmins' -Value "Empty"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Administrators' -Value "Empty"

try{
$Output.DomainAdmins = Get-ADGroupMember -Server $Dom -Identity "Domain Admins" -Recursive | ForEach-Object {(ExtractDomain $_.'DistinguishedName')+"\"+$_.Name}

If ($Output.DomainAdmins -eq "empty")
{
    $Output.DomainAdmins = Get-ADGroupMember -Server $Dom -Identity "Admins du domaine" -Recursive | ForEach-Object {(ExtractDomain $_.'DistinguishedName')+"\"+$_.Name}
}
    $Output.Administrators = Get-ADGroupMember -Server $Dom -Identity "Administrators" -Recursive | ForEach-Object {(ExtractDomain $_.'DistinguishedName')+"\"+$_.Name}
Write-Output $Output
}
catch
{
$Output.DomainAdmins = "not accessible"
}
}


$SchemaPartition = (Get-ADRootDSE).NamingContexts | Where-Object {$_ -like "*Schema*"}

$DomainList=""

$DomainList=(Get-ADForest).Domains

$DomainAdmins=@()

ForEach ($Domain in $DomainList)
{
    
    $DomainAdmins += Get-GroupMember $Domain
}


$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $DomainAdmins $XMLFile


$DAoutput = @{Expression={$_.DomainName};Label="DomainName"},@{Expression={$_.DomainAdmins -join ", "};Label="DomainAdmins"},@{Expression={$_.Administrators -join ", "};Label="Administrators"}

Write-Output $DomainAdmins | ft $DAoutput  -Wrap | Out-Default

Write-Output $DomainAdmins | ft $DAoutput  -Wrap | Out-Default >$LogFile


