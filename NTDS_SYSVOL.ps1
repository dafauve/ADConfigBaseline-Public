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
$DC_list = Import-Clixml $LogPath\get-domaincontroller_diff.xml
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

function Get-NtdsSysvolLocation {
<#
    .Synopsis
    Gets the NTDS and SYSVOL location as configured on a computer.
    .DESCRIPTION
    Gets the NTDS and SYSVOL location as configured on a computer.
    The default is localhost but can be used for remote computers.
    .EXAMPLE
    Get-NtdsSysvolLocation -ComputerName "Server1"
    .EXAMPLE
    Get-NtdsSysvolLocation -ComputerName "Server1","Server2"
    .EXAMPLE
    Get-NtdsSysvolLocation -Computer "Server1","Server2"
    .EXAMPLE
    Get-NtdsSysvolLocation "Server1","Server2"
    .NOTES
    Written by Damien Fauve, inspired from Jeff Wouters script Get-timeServer.
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ( 
        [parameter(mandatory=$true,position=0)][alias("computer")]$Computername=""
    )
    begin {
        $HKLM = 2147483650
    }
    process {
        $TestConnection = Test-Connection -ComputerName $Computername -Quiet -Count 1
        $Output = New-Object -TypeName psobject
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'ComputerName' -Value $Computername
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NTDSDitPath' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NTDSLogPath' -Value "Server unreachable"
        #$Output | Add-Member -MemberType 'NoteProperty' -Name 'NTDSSize' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'SysvolPath' -Value "Server unreachable"
    if ($TestConnection) {              
        try {

            # Determine where the AD DB file (ntds.dit) is stored 
                #$reg = [wmiclass]"\\$Computername\root\default:StdRegprov"
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computername)
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $valuename = “DSA Database file”
                $regkey = $reg.opensubkey($key)
                $NTDSDitPath = $regkey.getvalue($valuename)
                $LocationNTDSDit = $NTDSDitPATH.Remove($NTDSDitPATH.Length -9,9)

             <#   ## Get The AD DIT File Size in GB
                $DITRemotePath = $NTDSPATH.Replace(“:”, “$”)
                $DITFile = “\\$computer\$DITRemotePath”
                $DITsize = ([System.IO.FileInfo]$DITFile).Length
                $DITsize = ($DITsize/1GB)
                $DITsize = “{0:N3}” -f $DITsize
             #>
                # Determine where the AD tranaction logs are stored 
                #$key = “SYSTEM\CurrentControlSet\Services\NTDS\Parameters”
                $valuename = “Database log files path”
                #$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(‘LocalMachine’, $Computer)
                #$regkey = $reg.opensubkey($key)
                $LocationNTDSLogs = $regkey.getvalue($valuename)
                    
                # Determine where SYSVOL is stored and
                $SYSVOl=get-wmiobject -class win32_share -computer $Computername| where-object {$_.Name -eq “SYSVOL”}
                $SYSVOLPath = $SYSVOL.path
                $LocationSYSVOL = $SYSVOLPath.Remove($SYSVOLPATH.Length -7,7)

                } catch {
                $LocationNTDSDit="server unreachable or key unknown"
                $LocationNTDSLogs="server unreachable or key unknown"
                $SYSVOLPath="server unreachable or key unknown"
           }
            #output values
            $Output.NTDSDitPath = $LocationNTDSDit
            $Output.NTDSLogPath = $LocationNTDSLogs
            $Output.SysvolPath = $SYSVOLPath
            $Output
        } else {
            $Output
            }
    }
}




$NTDS_SYSVOL_BSL=@()

ForEach ($DC in $DC_list)
{


$NTDS_SYSVOL_BSL += Get-NtdsSysvolLocation -Computername $DC.DCName | Select-Object -Property ComputerName,NTDSDitPath,NTDSLogPath,SysvolPath

}


$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $NTDS_SYSVOL_BSL $XMLFile

Write-Output $NTDS_SYSVOL_BSL | ft -AutoSize 
Write-Output $NTDS_SYSVOL_BSL  >$LogFile

