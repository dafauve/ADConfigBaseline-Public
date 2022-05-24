############################################
############################################
############################################
###   Header to copy/paste on all scripts (except DefaultOU_DC)
############################################
############################################
############################################
 
try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
$DC_list = Import-Clixml $LogPath\get-domaincontroller_diff.xml
}
catch {
$LogPath=".\Logs\"
$DC_list = Invoke-Expression .\get-domaincontroller.ps1
}
 
 
############################################
############################################
############################################
#### End of Header
############################################
############################################
############################################
 
 
Function Get-WMILogSize {
 
[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)
 
 
 
$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value $DCName
 
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ApplicationLogCurrentSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ApplicationLogMaxSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ApplicationLogOverSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ApplicationLogPath' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ApplicationLogPolicy' -Value "Server unreachable"
 
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SecurityLogCurrentSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SecurityLogMaxSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SecurityLogOverSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SecurityLogPath' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SecurityLogPolicy' -Value "Server unreachable"
 
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemLogCurrentSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemLogMaxSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemLogOverSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemLogPath' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemLogPolicy' -Value "Server unreachable"
 
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DirectoryServiceLogCurrentSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DirectoryServiceLogMaxSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DirectoryServiceLogOverSize' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DirectoryServiceLogPath' -Value "Server unreachable"
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DirectoryServiceLogPolicy' -Value "Server unreachable"
 
 
$TestConnection = Test-Connection -ComputerName $DCName -Quiet -Count 1
 
 
If ($TestConnection)
{
    Try 
    {
        $ApplicationLog = Get-WmiObject Win32_NTEventLogFile -Filter "LogFileName = 'Application'" -ComputerName $DCName -ErrorAction SilentlyContinue
        $SystemLog = Get-WmiObject -Class Win32_NTEventLogFile -Filter "LogFileName = 'System'" -ComputerName $DCName -ErrorAction SilentlyContinue
        $SecurityLog = Get-WmiObject -Class Win32_NTEventLogFile -Filter "LogFileName = 'Security'" -ComputerName $DCName -ErrorAction SilentlyContinue
        $DirectoryServiceLog = Get-WmiObject -Class Win32_NTEventLogFile -Filter "LogFileName = 'Directory Service'" -ComputerName $DCName -ErrorAction SilentlyContinue
        
        $Output.ApplicationLogCurrentSize = [string]([math]::truncate($ApplicationLog.FileSize/1MB))
        $Output.ApplicationLogMaxSize = [string]([math]::truncate($ApplicationLog.MaxFileSize/1MB))
        If ([int]$Output.ApplicationLogCurrentSize -le [int]$Output.ApplicationLogMaxSize)
        { $Output.ApplicationLogOverSize = "OK"}
        Else { $Output.ApplicationLogOverSize = "Warning" }
        $Output.ApplicationLogPath = ($ApplicationLog.Name).tolower()
        $Output.ApplicationLogPolicy = $ApplicationLog.OverWritePolicy
        
        $Output.SecurityLogCurrentSize = [string]([math]::truncate($SecurityLog.FileSize/1MB))
        $Output.SecurityLogMaxSize = [string]([math]::truncate($SecurityLog.MaxFileSize/1MB))
        If ([int]$Output.SecurityLogCurrentSize -le [int]$Output.SecurityLogMaxSize)
        { $Output.SecurityLogOverSize = "OK"}
        Else { $Output.SecurityLogOverSize = "Warning" }
        $Output.SecurityLogPath = $SecurityLog.Name.tolower()
        $Output.SecurityLogPolicy = $SecurityLog.OverWritePolicy
               
        $Output.SystemLogCurrentSize = [string]([math]::truncate($SystemLog.FileSize/1MB))
        $Output.SystemLogMaxSize = [string]([math]::truncate($SystemLog.MaxFileSize/1MB))
        If ([int]$Output.SystemLogCurrentSize -le [int]$Output.SystemLogMaxSize)
        { $Output.SystemLogOverSize = "OK"}
        Else { $Output.SystemLogOverSize = "Warning" }
        $Output.SystemLogPath = $SystemLog.Name.tolower()
        $Output.SystemLogPolicy = $SystemLog.OverWritePolicy
 
        $Output.DirectoryServiceLogCurrentSize = [string]([math]::truncate($DirectoryServiceLog.FileSize/1MB))
        $Output.DirectoryServiceLogMaxSize = [string]([math]::truncate($DirectoryServiceLog.MaxFileSize/1MB))
        If ([int]$Output.DirectoryServiceLogCurrentSize -le [int]$Output.DirectoryServiceLogMaxSize)
        { $Output.DirectoryServiceLogOverSize = "OK"}
        Else { $Output.DirectoryServiceLogOverSize = "Warning" }
        $Output.DirectoryServiceLogPath = $DirectoryServiceLog.Name.tolower()
        $Output.DirectoryServiceLogPolicy = $DirectoryServiceLog.OverWritePolicy
        
        Write-Output $Output
 
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
 
 
$LogSize=@()
 
ForEach ($DC in $DC_list )
{
$LogSize += Get-WMILogSize $DC.DCShortname
}
 
 
 
$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"
 
Export-Clixml -InputObject ($LogSize | select -Property _DCName,ApplicationLogMaxSize,ApplicationLogOverSize,ApplicationLogPath,ApplicationLogPolicy,SecurityLogMaxSize,SecurityLogOverSize,SecurityLogPath,SecurityLogPolicy,SystemLogMaxSize,SystemLogOverSize,SystemLogPath,SystemLogPolicy,DirectoryServiceLogMaxSize,DirectoryServiceLogOverSize,DirectoryServiceLogPath,DirectoryServiceLogPolicy) $XMLFile
 
Write-Output $LogSize | Export-Csv $LogPath\WMI_LogSize.csv -Delimiter ";" -NoTypeInformation 
Write-Output $LogSize
