try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}

Function Get-LDAPPolicy {
[CmdletBinding()]             
 Param              
   ( 
    [Parameter(Mandatory=$true,position=0)]$Policy 
   )#End Param 
$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LDAPPolicyName' -Value "Unknown"

$Output.LDAPPolicyName = $Policy.Name
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LDAPAdminLimits' -Value ((($Policy.LDAPAdminLimits) | sort) -join ", ")

$Output
}


$PolicyList = Get-ADObject -Filter 'objectClass -eq "queryPolicy"' -Searchbase (Get-ADRootDSE).ConfigurationNamingContext -Property * 
$PolicyObjects=@()

ForEach ($LDAPPol in $PolicyList) 
{ 
	$PolicyObjects += Get-LDAPPolicy $LDAPPol
}

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $PolicyObjects $XMLFile

Write-Output $PolicyObjects | Format-Table * -Wrap -AutoSize | Out-Default
Write-Output $PolicyObjects | Format-Table * -wrap -AutoSize >$LogFile
