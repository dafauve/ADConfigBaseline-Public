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


Function Get-ADService {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)



$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value $DCName
$Output | Add-Member -MemberType 'NoteProperty' -Name 'NTDS' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ADWS' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DFS' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DFSR' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DHCP' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DNScache' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Gpsvc' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'IsmServ' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Kdc' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'KdsSvc' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'KPSSVC' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Netlogon' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'NtFrs' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'W32Time' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'WinRM' -Value "Server unreachable"


$ADService = "NTDS","ADWS","DFS","DFSR","DHCP","DNScache","GpSvc","IsmServ","Kdc","KdsSvc","KPSSVC","Netlogon","NtFrs","W32Time","WinRM"
$TestConnection = Test-Connection -ComputerName $DCName -Quiet -Count 1


If ($TestConnection)
{
    Try{
        $ListServices = get-service -ComputerName $DCName | select -Property Name,StartType
        foreach ($service in $ADService)
        {
            Switch -Wildcard (($ListServices | where {$_.Name -eq $Service}).StartType)
            {
                "*Automatic*"
                {
                    $Output.$service = "Automatic"
                }
                "*Manual*"
                {
                    $Output.$service = "Manual"
                }
                "*Disabled*"
                {
                    $Output.$service = "Disabled"
                }
                Default
                {
                    $Output.$service = "N/A"
                }
            }


        }
                
    }

    Catch
    {
    }
}

Write-Output $Output

}


$DC_Services=@()

ForEach ($DC in $DC_list )
{
$DC_Services += Get-ADService $DC.DCShortname
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".csv"

Export-Clixml -InputObject $DC_Services $XMLFile

Write-Output $DC_Services | Export-Csv $LogFile -Delimiter ";" -NoTypeInformation

Write-Output $DC_Services | fl


