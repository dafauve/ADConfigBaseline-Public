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

Function Get-IPConfig {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)



$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DCName' -Value $DCName
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'AdapterName' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'IPAddress' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'IPSubnet' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'MACAddress' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DNSServerSearchOder' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DNSDomainSuffixSearchOrder' -Value "Server Unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DNSEnabledForWinsResolution' -Value "Server Unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DomainDNSRegistrationEnabled' -Value "Server Unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FullDNSRegistrationEnabled' -Value "Server Unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DHCPEnabled' -Value "Server Unreachable"
        
$AdapterOutput=@()

$TestConnection = Test-Connection -ComputerName $DCName -Quiet -Count 1


If ($TestConnection)
{
    Try 
    {
        $NetAdapter_List = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" -ComputerName $DCName -ErrorAction SilentlyContinue

        ForEach ($NetAdapter in $NetAdapter_List)
        {
            $AdapterOutput += Get-ConfigAdapter $NetAdapter $DCName
            
        }
        
        Write-Output $AdapterOutput

    }
    Catch 
    {
        Write-Output $Output
    }
        
}
Else
{
Write-Output $Output
}
}


function Get-ConfigAdapter {
[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$Adapter,
[parameter(mandatory=$true,position=1)]$Machine
)

$indexadapter = $Adapter.Index
$Adapt = Get-WmiObject -Class Win32_NetworkAdapter -Filter "Index = $indexadapter" -ComputerName $Machine -ErrorAction SilentlyContinue


$Out = New-Object -TypeName psobject
$Out | Add-Member -MemberType 'NoteProperty' -Name 'DCName' -Value $Machine
$Out | Add-Member -MemberType 'NoteProperty' -Name 'AdapterName' -Value $Adapt.NetConnectionID
$Out | Add-Member -MemberType 'NoteProperty' -Name 'IPAddress' -Value ($Adapter.IPAddress -join "; ")
$Out | Add-Member -MemberType 'NoteProperty' -Name 'MACAddress' -Value $Adapter.MACAddress 
$Out | Add-Member -MemberType 'NoteProperty' -Name 'DNSServerSearchOrder' -Value ($Adapter.DNSServerSearchOrder -join "; ")
$Out | Add-Member -MemberType 'NoteProperty' -Name 'DNSDomainSuffixSearchOrder' -Value ($Adapter.DNSDomainSuffixSearchOrder -join "; ")
$Out | Add-Member -MemberType 'NoteProperty' -Name 'IPSubnet' -Value ($Adapter.IPSubnet[0])
$Out | Add-Member -MemberType 'NoteProperty' -Name 'DNSEnabledforWINSResolution' -Value $Adapter.DNSEnabledforWINSResolution
$Out | Add-Member -MemberType 'NoteProperty' -Name 'DomainDNSRegistrationEnabled' -Value $Adapter.DomainDNSRegistrationEnabled
$Out | Add-Member -MemberType 'NoteProperty' -Name 'FullDNSRegistrationEnabled' -Value $Adapter.FullDNSRegistrationEnabled
$Out | Add-Member -MemberType 'NoteProperty' -Name 'DHCPEnabled' -Value $Adapter.DHCPEnabled
                
Write-Output $Out
}

  
          

      

$DC_Settings=@()

ForEach ($DC in $DC_list )
{
$DC_Settings += Get-IPConfig $DC.DCShortName 
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $DC_Settings $XMLFile

Write-Output $DC_Settings | Select-Object -Property DCName,AdapterName,IPAddress,DNSServerSearchOrder,DNSDomainSuffixSearchOrder,IPSubnet,DNSEnabledforWINSResolution,DomainDNSRegistrationEnabled,FullDNSRegistrationEnabled,DHCPEnabled | ft -Wrap | Out-Default
Write-Output $DC_Settings | Export-Csv $LogPath\config_IP.csv -Delimiter ";" -NoTypeInformation
#Write-Output $DC_Settings | ft -wrap >$LogFile 

