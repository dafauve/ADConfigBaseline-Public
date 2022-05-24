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


function Get-TimeServer {
<#
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ( 
        [parameter(mandatory=$true,position=0)][alias("computer")]$ComputerName
    )
    begin {
        $HKLM = 2147483650
    }
    process {
        
        $TestConnection = Test-Connection -ComputerName $Computername -Quiet -Count 1
        $Output = New-Object -TypeName psobject
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'ComputerName' -Value $Computername
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NTPServer' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Type' -Value "Server Unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'IsRootPDC' -Value "Server Unreachable"
        if ($TestConnection) {              
              try {
                  $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computername)
                  $key = "SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
                  $valuename = "NtpServer"
                  $regkey = $reg.opensubkey($key)
                  $TimeServer=$regkey.getvalue($valuename)
                  $valuename = "Type"
                  $type = $regkey.getvalue($valuename)
                } catch {
                $TimeServer = "Server unreachable or key unknown"
                $type = "Server unreachable or key unknown"
                }
            } else {
            $TimeServer = "Server unreachable"
            $type = "Server unreachable"
       
            }
            $Output.NTPServer = $TimeServer
            $Output.Type = $type   
            $Output
       }
}


$ForestName= Get-ADForest| Select-Object -Property Name
$RootPDC = (Get-ADDomain -Identity $ForestName.Name | Select-Object -Property PDCEmulator).PDCEmulator



$time_BSL=@()

ForEach ($DC in $DC_list)
{
$isRootPDC=" "
    If ($RootPDC -eq $DC.DCName)
    {
    $isRootPDC = "X"
    }

$time_object=Get-TimeServer -ComputerName $DC.DCName
$time_object.isRootPDC=$isRootPDC
$time_BSL += $time_object

}


$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $time_BSL $XMLFile

Write-Output $time_BSL 
Write-Output $time_BSL >$LogFile 

