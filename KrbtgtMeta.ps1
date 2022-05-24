############################
############################
#############
###   Hearder to copy/paste on all scripts (except DefaultOU_DC)
############ https://blogs.technet.microsoft.com/heyscriptingguy/2011/02/16/use-powershell-and-net-to-find-expired-certificates/
##########################
##########################


try {
Set-Location "c:\scripts"
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


Function Get-KrbtgtMeta
{
<########### 
###### Get property for one DC which FPQDN is given as an arg
#>#########


[CmdletBinding()]             
 Param              
   ( 
    [parameter(mandatory=$true,position=0)]$PDC
   )#End Param 

#$Attributes="UserCertificate","WhenCreated","UserAccountControl","dBCSPwd","UnicodePwd","ntPwdHistory","pwdLastSet","primaryGroupID","supplementalCredentials","accountExpires","lmPwdHistory","sAMAccountName","sAMAcountType","operatingSystem","rIDSetReferences","servicePrincipalName","isCriticalSystemObject","msDS-SupportedEncryptionTypes"
$Attributes = [PSCustomObject]@{
DOmainName="unknown"
AttributeName = "accountexpires","admincount","isCriticalSystemObject","WhenCreated","UserAccountControl","dBCSPwd","UnicodePwd","ntPwdHistory","pwdLastSet","primaryGroupID","supplementalCredentials","lmPwdHistory","sAMAccountName","sAMAcountType","profilepath","primaryGroupID","profilePath","scriptpath","servicePrincipalName","isCriticalSystemObject","msDS-SupportedEncryptionTypes"
Version ="unknown"
AttributeValue="unknown"
LocalChangeUsn="unknown"
LastOriginatingChangeDirectoryServerIdentity="unknown"
LastOriginatingChangeDirectoryServerInvocationId="unknown"
LastOriginatingChangeTime="unknown"
}

$Output = @()

Try
{
    $DN = (Get-ADUser -Identity krbtgt -Server $PDC).DistinguishedName
    $domain= (Get-ADDomain -Server $PDC).DNSRoot
    $KRBMeta = Get-ADReplicationAttributeMetadata -Object $DN -Server $PDC

    foreach ($attrib in $Attributes.AttributeName)
    {
        $Output += $KRBMeta | where {$_.AttributeName -eq $Attrib} | select @{Name='krbtgt';expression={$domain}},AttributeName,Version,AttributeValue,LocalChangeUsn,LastOriginatingChangeDirectoryServerIdentity,LastOriginatingChangeDirectoryServerInvocationId,LastOriginatingChangeTime  
    }
}
catch
{
    $KRBMeta=@{}
    $KRBMeta = $Attributes
    $KRBMeta.AttributeName = "server unreachable"
    $KRBMeta.Domain = (Get-ADDomain -Server $PDC).DNSRoot
    $Output += $KRBMeta
}

Write-Output $Output

}

try 
    { 
    $Forest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()     
    } 
catch 
    { 
    "Cannot connect to current forest." 
    }
# All domains in forest 
$krbtgtaccounts = @()

$Domain_List = $Forest.domains
foreach ($Dom in $Domain_List)
    {
    $krbtgtaccounts += Get-KrbtgtMeta $Dom.PdcRoleOwner.Name
    }

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"
$CsvFile = $LogPath + $LogFile.split('\.')[-2] + ".csv"

Export-Clixml -InputObject $krbtgtaccounts $XMLFile

Write-Output $krbtgtaccounts | ft -AutoSize -Wrap

Write-Output $krbtgtaccounts | ft -AutoSize > $LogFile

Write-Output $krbtgtaccounts | Export-Csv $CsvFile -Delimiter ";" -NoTypeInformation