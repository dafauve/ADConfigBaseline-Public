try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}

Function Get-SiteLinkInfo {

[CmdletBinding()]             
 Param              
   ( 
    $SiteLink 
   )#End Param 

$Output = New-Object -TypeName System.object
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SiteLinkName' -Value $SiteLink.Name
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SiteCount' -Value $SiteLink.SiteList.Count
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Cost' -Value $SiteLink.Cost 
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ReplInterval' -Value $SiteLink.ReplInterval
    
If ($SiteLink.Schedule) {
   If (($SiteLink.Schedule -Join " ").Contains("240")) {
       $Output | Add-Member -MemberType 'NoteProperty' -Name 'Schedule' -Value "NonDefault"
   }
   Else { $Output | Add-Member -MemberType 'NoteProperty' -Name 'Schedule' -Value "24×7"}
   } 
   Else{ $Output | Add-Member -MemberType 'NoteProperty' -Name 'Schedule' -Value "24×7"}      

$Output | Add-Member -MemberType 'NoteProperty' -Name 'Options' -Value ([String] $SiteLink.Options )

Write-Output $Output

}


$SiteLists = Get-ADObject -Filter 'objectClass -eq "siteLink"' -Searchbase (Get-ADRootDSE).ConfigurationNamingContext -Property Options, Cost, ReplInterval, SiteList, Schedule
$SiteLinks=@()

ForEach ($item in $SiteLists) 
{ 

    $SiteLinks += Get-SiteLinkInfo $item
}

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $SiteLinks $XMLFile

Write-Output $SiteLinks | Format-Table * -AutoSize | Out-Default
Write-Output $SiteLinks | Format-Table * -AutoSize >$LogFile


