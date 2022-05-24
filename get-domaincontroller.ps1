[CmdletBinding()]             
 Param              
   ( 
    [String]$Domain 
    #$Forest 
    #[Switch]$CurrentForest  
    )#End Param 


try {
$AllVar = Import-Clixml .\ExportVar.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}

Function Get-DCInfo
{
<########### 
###### Get property for one DC which FPQDN is given as an arg
#>#########

[CmdletBinding()]             
 Param              
   ( 
    [parameter(mandatory=$true,position=0)]$DCItem,
    [parameter(mandatory=$true,position=1)]$DomainItem  
   )#End Param 

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainName' -Value $DomainItem
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DCName' -Value "DC unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DCShortName' -Value "DC unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DCContainer' -Value "Container unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value "Site unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'IsGlobalCatalog' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'OSVersion' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'IsRODC' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LDAPport' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LDAPSport' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'InvocationID' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DSAGuid' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'VMGenerationID' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'UserAccountControl' -Value "Unknown"

$DCShortname = $DCItem.split('.')[0]
$DCComputer = get-ADComputer -Identity $DCShortname -Server $DCItem -Properties *
$DC_NTDS = Get-ADDomainController -Identity $DCShortname -Server $DomainItem
$NTDS_Obj = Get-ADObject -Identity $DC_NTDS.NTDSSettingsObjectDN -server $DomainItem
$Output.DCName=$DCItem
$Output.DCShortName=$DCShortname
$Output.DCContainer=$DCComputer.DistinguishedName
$Output.Site=$DC_NTDS.Site
$Output.IsGlobalCatalog = $DC_NTDS.IsGlobalCatalog
$Output.IsRODC = $DC_NTDS.IsReadOnly
$Output.LDAPport = $DC_NTDS.LDAPPort
$Output.LDAPSport = $DC_NTDS.SSLport
$Output.DSAGuid = $NTDS_Obj.ObjectGUID
$Output.InvocationID = $DC_NTDS.InvocationID
$Output.UserAccountControl = $DCComputer.UserAccountControl
$Output.OSVersion = $DCComputer.OperatingSystem

try {
$Output.VMGenerationID = $DCComputer.'msDS-GenerationId' -join "-"
}
catch { 
$Output.VMGenerationID = "Inexistant"
}

$Output

}


Function Get-DCInfoInDomain 
{ 
[CmdletBinding()]             
 Param              
   ( 
    $DomainInput
   )#End Param 


$DCList = $DomainInput.DomainControllers.name | sort
$listoutput=@()

Foreach ($DC in $DCList)
    { 
    $listoutput += Get-DCInfo $DC $DomainInput.Name
    }
Write-Output $listoutput
}

$Domain_List=@()
$DCListOutput=@()


if ($Domain) 
   { 
    try 
        { 
            $Forest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()     
        } 
    catch 
        { 
            "Cannot connect to current forest." 
        } 
    # User specified domain OR Match 
    $Dom = $Forest.domains | Where-Object {$_.Name -eq $Domain}
    $DCListOutput = Get-DCInfoInDomain $Dom
   } 
       
else 
   {
   try 
        { 
            $Forest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()     
        } 
    catch 
        { 
            "Cannot connect to current forest." 
        }
    # All domains in forest 
    $Domain_List = $Forest.domains
    foreach ($Dom in $Domain_List)
    {
    $DCListOutput += Get-DCInfoInDomain $Dom
    }  
   } 

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"


Export-Clixml -InputObject $DCListOutput $XMLFile
Export-Clixml -InputObject $DCListOutput $LogPath\DClist.xml
Write-Output $DCListOutput

Write-Output $DCListOutput | Export-Csv $LogPath\get-domaincontroller.csv -Delimiter "," -NoTypeInformation


Write-Output $DCListOutput | Export-Csv $LogPath\DClist.txt -Delimiter ";" -NoClobber -NoTypeInformation

Write-Output $DCListOutput | ft  > $LogFile 



