try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}

Function Get-DomainInfo 
{ 
[CmdletBinding()]             
 Param              
   ( 
    [String]$Dom 
   )#End Param 

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainName' -Value $Dom
$Output | Add-Member -MemberType 'NoteProperty' -Name 'InfrastructureMaster' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'RIDMaster' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'PDCEmulator' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainMode' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainPrep' -Value "Domain Unreachable"

$DN=""
$DN= (Get-ADDomain -Identity $Dom | Select-Object -Property DistinguishedName).DistinguishedName
$DomPrep = get-adobject "cn=ActiveDirectoryUpdate,cn=DomainUpdates,cn=System,$DN" -Partition $DN -Server $Dom -Properties revision | Select-Object -Property revision
$DomName = Get-ADDomain -Identity $Dom | Select-Object -Property DNSRoot
$DomMode = Get-ADDomain -Identity $Dom | Select-Object -Property Domainmode


$Output.DomainName=$DomName.DNSRoot
$Output.InfrastructureMaster= (Get-ADDomain -Identity $Dom | Select-Object -Property InfrastructureMaster).InfrastructureMaster
$Output.RIDMaster= (Get-ADDomain -Identity $Dom | Select-Object -Property RIDMaster).RIDMaster
$Output.PDCEmulator= (Get-ADDomain -Identity $Dom | Select-Object -Property PDCEmulator).PDCEmulator
$Output.DomainMode=$DomMode.DomainMode
$Output.DomainPrep=$DomPrep.revision


write-output $Output

}




$SchemaPartition = (Get-ADRootDSE).NamingContexts | Where-Object {$_ -like "*Schema*"}

$DomainList=""



$ForestName= Get-ADForest| Select-Object -Property Name

$DomainList=(Get-ADForest).Domains


[Array]$DomainInfo=@()


ForEach ($Domain in $DomainList)
{
    
    $DomainInfo += Get-DomainInfo $Domain #| Select-Object -Property DomainName,InfrastructureMaster,PDCEmulator,RIDMaster,DomainMode,DomainPrep
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $DomainInfo $XMLFile

Write-Output $DomainInfo | ft -autosize | Out-Default

Write-Output $DomainInfo | ft -autosize | Out-Default > $LogFile


