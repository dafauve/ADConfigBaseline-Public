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
$DC_list = Import-Clixml $LogPath\Get-DomainController_diff.xml
}
catch {
$LogPath=".\Logs\"
$DC_list = Invoke-Expression .\get-domaincontroller.ps1
}


#########################################
#########################################
#############
#### End of Header
#############
########################################
############################################

Function Get-Domainpwdpolicy 
{ 
[CmdletBinding()]             
 Param              
   ( 
    [String]$Dom 
   )#End Param 

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainName' -Value $Dom
$Output | Add-Member -MemberType 'NoteProperty' -Name 'MaxPwdAge' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'MinPwdAge' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'PwdHistoryLength' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'MinPwdLength' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LockoutDuration' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LockoutObservationWindow' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LockoutThreshold' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'PwdComplexity' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ReversEncryption' -Value "Unknown"

$RootDSE= Get-ADRootDSE -Server $Dom
$DN= (Get-ADDomain -Identity $Dom | Select-Object -Property DistinguishedName).DistinguishedName
$DomObject = get-adobject $RootDSE.DefaultNamingContext -Properties * -Partition $DN -Server $Dom
$Output.MaxPwdAge = ($DomObject.MaxPwdAge) / -864000000000
$Output.MinPwdAge = $DomObject.MinPwdAge / -864000000000
$Output.PwdHistoryLength = $DomObject.pwdHistoryLength
$Output.MinPwdLength = $DomObject.MinPwdLength
$Output.LockoutDuration = $DomObject.LockoutDuration / -600000000
$Output.LockoutObservationWindow = $DomObject.LockoutObservationWindow / -600000000
$Output.LockoutThreshold = $DomObject.LockoutThreshold

If (($DomObject.PwdProperties -band "0x1") -eq "1")
{
    $Output.PwdComplexity = "true"
}
Else {$Output.PwdComplexity = "false"}

If (($DomObject.PwdProperties -band "0x10") -eq "16")
{
    $Output.ReversEncryption = "true"
}
Else {$Output.ReversEncryption = "false"}

write-output $Output

}




$ForestName= Get-ADForest| Select-Object -Property Name

$DomainList=(Get-ADForest).Domains


$Domainpwdpolicy=@()


ForEach ($Domain in $DomainList)
{
    
    $Domainpwdpolicy += Get-Domainpwdpolicy $Domain
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $Domainpwdpolicy $XMLFile

Write-Output $Domainpwdpolicy | ft -AutoSize | Out-Default

Write-Output $Domainpwdpolicy | ft -AutoSize > $LogFile


