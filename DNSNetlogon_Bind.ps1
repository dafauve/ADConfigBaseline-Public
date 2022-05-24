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


Function Get-DNSRec {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$Record
)

$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value ($Record.Server -split "\.")[0]
#$Output | Add-Member -MemberType 'NoteProperty' -Name 'SameAsParent' -Value $false
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ServerA' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LdapIpAddress' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Ldap' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'LdapAtSite' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Pdc' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Gc' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'GcAtSite' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DcByGuid' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'GcIpAddress' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DsaCname' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Kdc' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'KdcAtSite' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Dc' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DcAtSite' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Rfc1510Kdc' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Rfc1510KdcAtSite' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'GenericGc' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'GenericGcAtSite' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Rfc1510UdpKdc' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Rfc1510Kpwd' -Value "Unknown"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Rfc1510UdpKpwd' -Value "Unknown"

$Output.ServerA=(Resolve-DnsName $Record.Server -ErrorAction SilentlyContinue -DnsOnly -QuickTimeout  | Where-Object{$_.Section -eq "Answer" -and $_.Type -eq "A"}).IPAddress
#$Output.SameAsParent= $Output.ServerA -in (Resolve-DnsName $Record.LdapIpAddress -ErrorAction SilentlyContinue -DnsOnly -QuickTimeout | Where-Object{$_.Section -eq "Answer"}).IPAddress
$Output.LdapIpAddress= $Output.ServerA -in (Resolve-DnsName $Record.LdapIpAddress -ErrorAction SilentlyContinue -DnsOnly -QuickTimeout | Where-Object{$_.Section -eq "Answer"}).IPAddress
#$Output.LdapIpAddress= $record.server -in (Resolve-DnsName $Record.LdapIpAddress -ErrorAction SilentlyContinue -DnsOnly -QuickTimeout)
$Output.Ldap=$record.server -in (Resolve-DnsName $Record.Ldap -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.LdapAtSite=$record.server -in (Resolve-DnsName $Record.LdapAtSite -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Pdc=$record.server -in (Resolve-DnsName $Record.Pdc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Gc=$record.server -in (Resolve-DnsName $Record.Gc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.GcAtSite=$record.server -in (Resolve-DnsName $Record.GcAtSite -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.DcByGuid=$record.server -in (Resolve-DnsName $Record.DcByGuid -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.GcIpAddress=$Output.ServerA -in (Resolve-DnsName $Record.GcIpAddress -ErrorAction SilentlyContinue -DnsOnly -QuickTimeout).IPAddress
$Output.DsaCname=$record.server -in (Resolve-DnsName $Record.DsaCname -ErrorAction SilentlyContinue -DnsOnly -QuickTimeout).NameHost
$Output.Kdc=$record.server -in (Resolve-DnsName $Record.Kdc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.KdcAtSite=$record.server -in (Resolve-DnsName $Record.KdcAtSite -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Pdc=$record.server -in (Resolve-DnsName $Record.Pdc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Dc=$record.server -in (Resolve-DnsName $Record.Dc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.DcAtSite=$record.server -in (Resolve-DnsName $Record.DcAtSite -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Rfc1510Kdc=$record.server -in (Resolve-DnsName $Record.Rfc1510Kdc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Rfc1510KdcAtSite=$record.server -in (Resolve-DnsName $Record.Rfc1510KdcAtSite -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.GenericGc=$record.server -in (Resolve-DnsName $Record.GenericGc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.GenericGcAtSite=$record.server -in (Resolve-DnsName $Record.GenericGcAtSite -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Rfc1510UdpKdc=$record.server -in (Resolve-DnsName $Record.Rfc1510UdpKdc -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Rfc1510Kpwd=$record.server -in (Resolve-DnsName $Record.Rfc1510Kpwd -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget
$Output.Rfc1510UdpKpwd=$record.server -in (Resolve-DnsName $Record.Rfc1510UdpKpwd -ErrorAction SilentlyContinue -DnsOnly -Type SRV -QuickTimeout).NameTarget

Write-Output $Output
}


$DC_DNS=@()
$DnsForestName = (Get-ADForest).Name
$DnsDomainName=""
$DomainGuid=""

ForEach ($DC in $DC_list )
{

If ($DC.DomainName -ne $DnsDomainName)
    {
    $DnsDomainName=$DC.DomainName
    $DomainGuid = (Get-ADDomain -Identity $DnsDomainName -Server $DnsDomainName).ObjectGUID
    }

$SiteName=$DC.Site
$DsaGuid = $DC.DSAGuid

$DCRecords = @{
    Server=$DC.DCName
    LdapIpAddress=$DnsDomainName
    Ldap="_ldap._tcp.$DnsDomainName"
    LdapAtSite="_ldap._tcp.$SiteName._sites.$DnsDomainName"
    Pdc="_ldap._tcp.pdc._msdcs.$DnsDomainName"
    Gc="_ldap._tcp.gc._msdcs.$DnsForestName"
    GcAtSite="_ldap._tcp.$SiteName._sites.gc._msdcs.$DnsForestName"
    DcByGuid="_ldap._tcp.$DomainGuid.domains._msdcs.$DnsForestName"
    GcIpAddress="gc._msdcs.$DnsForestName"
    DsaCname= "$DsaGuid._msdcs.$DnsForestName"
    Kdc= "_kerberos._tcp.dc._msdcs.$DnsDomainName"
    KdcAtSite="_kerberos._tcp.$SiteName._sites.dc._msdcs.$DnsDomainName"
    Dc="_ldap._tcp.dc._msdcs.$DnsDomainName"
    DcAtSite="_ldap._tcp.$SiteName._sites.dc._msdcs.$DnsDomainName"
    Rfc1510Kdc="_kerberos._tcp.$DnsDomainName"
    Rfc1510KdcAtSite="_kerberos._tcp.$SiteName._sites.$DnsDomainName"
    GenericGc="_gc._tcp.$DnsForestName"
    GenericGcAtSite="_gc._tcp.$SiteName._sites.$DnsForestName"
    Rfc1510UdpKdc="_kerberos._udp.$DnsDomainName"
    Rfc1510Kpwd="_kpasswd._tcp.$DnsDomainName"
    Rfc1510UdpKpwd="_kpasswd._udp.$DnsDomainName"
}


$DC_DNS += Get-DNSRec -Record $DCRecords  
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"
$CsvFile = $LogPath + $LogFile.split('\.')[-2] + ".csv"

Export-Clixml -InputObject $DC_DNS $XMLFile

Write-Output $DC_DNS
Write-Output $DC_DNS | Export-Csv $CsvFile -Delimiter ";" -NoTypeInformation
#Write-Output $DC_DNS | Export-Csv $LogPath\DC_DNS.csv -Delimiter ";" -NoTypeInformation