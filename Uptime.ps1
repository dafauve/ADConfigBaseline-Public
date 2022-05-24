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

Function Get-UpTime {
Param ([string]$server) 
   
     If (Test-Connection -ComputerName $server -Count 1 -ErrorAction SilentlyContinue)
     {
        try
        {
            $os = Get-WmiObject -class win32_OperatingSystem -cn $server -ErrorAction SilentlyContinue
            $LBTime=$os.convertToDateTime($os.lastbootuptime)
            [String]$Uptime_TH=""
            [TimeSpan]$uptime_DC= New-TimeSpan $LBTime $(get-date)
            $Uptime=$uptime_DC.Days
            If ($uptime_DC.Days -lt 60)
            {
                $Uptime_TH = "< 60 days"
            }
            Else
            {
                $Uptime_TH = "> 60 days"
            }
        } 
        catch
        {
            $Uptime_TH = "WMI object unreachable"
            $Uptime = "WMI object unreachable"
        }
     }
     Else
     {   
     $Uptime_TH = "unreachable"
     $Uptime= "unreachable"
        
     }    
     New-Object psobject -Property @{Computer=$server; Uptime_Days = $Uptime ; Threshold60=$Uptime_TH} 
}



$Uptime_BSL=@()


ForEach ($DC in $DC_list)
{
$Uptime_BSL += Get-Uptime $DC.DCName | Select-Object -Property computer,Uptime_Days,Threshold60
}


$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject ($Uptime_BSL | Select-Object -Property computer,Threshold60) $XMLFile

Write-Output $Uptime_BSL 
Write-Output $Uptime_BSL >$LogFile 

