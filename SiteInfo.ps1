try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}

Function Get-SiteInfo {

[CmdletBinding()]             
 Param              
   ( 
    $SiteInput 
   )#End Param 

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SiteName' -Value $SiteInput.Name
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SiteDN' -Value $SiteInput.DistinguishedName
$Output | Add-Member -MemberType 'NoteProperty' -Name 'gPLink' -Value $SiteInput.gPLink
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SiteObjectBL' -Value $SiteInput.SiteObjectBL 
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemFlags' -Value $SiteInput.SystemFlags
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Schedule' -Value "24x7 1xh"

$NTDSSite = Get-ADObject -Identity ("CN=NTDS Site Settings,"+$SiteInput.DistinguishedName) -Property *

$Output | Add-Member -MemberType 'NoteProperty' -Name 'NTDSSiteDN' -Value $NTDSSite.DistinguishedName
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ISTG' -Value $NTDSSite.interSiteTopologyGenerator
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Options' -Value $NTDSSite.Options

If ($NTDSSite.Schedule) {
   If ((($NTDSSite.Schedule[20..187]) -notlike("1")) -and (($NTDSSite.Schedule[20..187]) -notlike ("17"))) {
       $Output.Schedule = "NonDefault"
   }
   Else { $Output.Schedule = "24x7 1xh"}
   } 
   Else{ $Output.Schedule = "24x7 1xh"}      

Write-Output $Output

}


$SiteLists = Get-ADObject -Filter 'objectClass -eq "site"' -Searchbase (Get-ADRootDSE).ConfigurationNamingContext -Property *
$Sites=@()

ForEach ($item in $SiteLists) 
{ 

    $Sites += Get-SiteInfo $item | Select-Object -Property SiteName,Schedule,Options
}

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $Sites $XMLFile

$Sites |Sort-Object SiteName | Write-Output | ft * -AutoSize | Out-Default
$Sites |Sort-Object SiteName | ft * -AutoSize >$LogFile 

