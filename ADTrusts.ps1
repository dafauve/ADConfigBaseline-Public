############################
############################
#############
###   Hearder to copy/paste on all scripts (except DefaultOU_DC)
#############
############################
############################

try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
$DC_list = Import-Clixml $LogPath\DCList.xml
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
#########################################
#########################################

Function Get-TrustInfo 
{ 
[CmdletBinding()]             
 Param              
   ( 
    [parameter(mandatory=$true,position=0)]$Dom,
    [parameter(mandatory=$false,position=1)]$trust
   )#End Param 

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '1_DomainName' -Value $Dom
$Output | Add-Member -MemberType 'NoteProperty' -Name '2_Trustpartner' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'TrustDirection' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'TrustType' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Trustattributes' -Value "Domain unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Transitive' -Value "Default"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Quarantine' -Value "Default"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'TrustRelation' -Value "Default"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Encryption' -Value "Default"

$Output.'1_DomainName' = $Dom
$Output.'2_Trustpartner'= $trust.Trustpartner

Switch($trust.TrustDirection)
{
    "1" { $Output.TrustDirection = "Incoming"}
    "2" { $Output.TrustDirection = "Outgoing"}
    "3" { $Output.TrustDirection = "Bi-Directional"}
}

$Output.Encryption = $trust.'msDS-SupportedEncryptionTypes'
Switch($trust.'msDS-SupportedEncryptionTypes')
{
    $Null {$Output.Encryption = "RC4"}
    "4" {$Output.Encryption = "RC4"}
    "24" {$Output.Encryption = "AES128|AES256"}
    "28" {$Output.Encryption = "RC4|AES128|AES256"}

}

$TrustAttrib = $trust.TrustAttributes


$Output.TrustType= $trust.TrustType
$Output.Trustattributes= $TrustAttrib

#$Output.Transitive= ([int32]($trust.Trustattributes) -band 0x00000001)
#$Output.Quarantine= ([int32]($trust.Trustattributes) -band 0x00000004)

[string[]]$AttribOutput = @()

#### Order of mask validation is important for the Transitive option

If ([int32]$TrustAttrib -band 0x00000004)
    {
    $Output.Quarantine= "Quarantine (SID Filtering Enabled)"
    } 

If ([int32]$TrustAttrib -band 0x00800000) 
    {
    $AttribOutput += "W2K Tree Root"
    $Output.Transitive= $true
    }

If ([int32]$TrustAttrib -band 0x00000010) { $AttribOutput += "Cross Org selective authentication"}
If ([int32]$TrustAttrib -band 0x00000020) 
    {
    $AttribOutput += "Tree Root"
    $Output.Transitive= $true
    }
If (([int32]$TrustAttrib -band 0x00000040) -or ([int32]$TrustAttrib -band 0x00000004) -or ([int32]$TrustAttrib -eq 0)) 
    { 
    $AttribOutput += "External"
    $Output.Transitive= $false
    }
If ([int32]$TrustAttrib -band 0x00000008) 
    {
    $AttribOutput += "Forest"
    $Output.Transitive= $true
    }
If ([int32]$TrustAttrib -band 0x00000080) { $AttribOutput += "Uses RC4"}
If ([int32]$TrustAttrib -band 0x00000001) 
    {
    $Output.Transitive= $false
    }

$Output.TrustRelation = $AttribOutput

write-output $Output

}



    
Function Get-TrustperDomain 
{ 
[CmdletBinding()]             
 Param              
   ( 
    [String]$Dom
   )#End Param 


$trusts = Get-ADObject -Server $Dom -Filter {objectClass -eq "TrustedDomain"} -Properties TrustPartner,TrustDirection,TrustType,Trustattributes,msDS-SupportedEncryptionTypes

$Output=@()


foreach($trust in $trusts)
    {
    $output+=get-TrustInfo $Dom $trust 

    }

If (!$trusts)
    {
    $Output = Get-TrustInfo $Dom
    $Output.'2_Trustpartner' = "no trust or unreachable"
    $Output.TrustDirection = "NA"
    $Output.TrustType = "NA"
    $Output.Trustattributes = "NA"
    $Output.Transitive = "NA"
    $Output.Quarantine = "NA"
    $Output.TrustRelation = "NA"
    $Output.Encryption = "NA"
    }

write-output $Output

}




#$SchemaPartition = (Get-ADRootDSE).NamingContexts | Where-Object {$_ -like "*Schema*"}

$DomainList=""



$ForestName= Get-ADForest| Select-Object -Property Name

$DomainList=(Get-ADForest).Domains


[Array]$DomainInfo=@()


ForEach ($Domain in $DomainList)
{
    
    $DomainInfo += Get-TrustperDomain $Domain 
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $DomainInfo $XMLFile

Write-Output $DomainInfo | ft -AutoSize -Wrap

Write-Output $DomainInfo | ft -AutoSize -Wrap > $LogFile

