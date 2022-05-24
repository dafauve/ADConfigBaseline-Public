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

Function Get-DiskConfig {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)



$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'DCName' -Value $DCName
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'C_DriveFreeSpace' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'C_Threshold10FreeSpace' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'C_DriveTotalSpace' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'D_DriveFreeSpace' -Value "drive unavailable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'D_Threshold10FreeSpace' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'D_DriveTotalSpace' -Value "drive unavailable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'E_DriveFreeSpace' -Value "drive unavailable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'E_Threshold10FreeSpace' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'E_DriveTotalSpace' -Value "drive unavailable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OtherDrives' -Value "drive unavailable"

        

$TestConnection = Test-Connection -ComputerName $DCName -Quiet -Count 1


If ($TestConnection)
{
    Try 
    {
        $drivelist = @()
        $DriveList = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID != 'Null'" -ComputerName $DCName -ErrorAction SilentlyContinue
        $Output.OtherDrives = ""
        
        foreach ($drive in $drivelist)

        {

            Switch ($drive.DeviceID)
            {
            "C:"
                {
                $output.C_DriveFreeSpace = [string]([math]::truncate($drive.FreeSpace/1MB)) + " MB"
                $Output.C_DriveTotalSpace = [string]([math]::truncate($drive.Size/1MB)) + " MB"
                If (($drive.FreeSpace/$drive.Size) -lt 0.11)
                {
                    $output.C_Threshold10FreeSpace = " < 11%"
                }
                Else {$output.C_Threshold10FreeSpace = " > 11%"}
                }
            "D:"
                {
                $output.D_DriveFreeSpace = [string]([math]::truncate($drive.FreeSpace/1MB)) + " MB"
                $Output.D_DriveTotalSpace = [string]([math]::truncate($drive.Size/1MB)) + " MB"
                If (($drive.FreeSpace/$drive.Size) -lt 0.11)
                {
                    $output.D_Threshold10FreeSpace = " < 11%"
                }
                Else {$output.D_Threshold10FreeSpace = " > 11%"}
                }
            "E:"
                {
                $output.E_DriveFreeSpace = [string]([math]::truncate($drive.FreeSpace/1MB)) + " MB"
                $Output.E_DriveTotalSpace = [string]([math]::truncate($drive.Size/1MB)) + " MB"
                If (($drive.FreeSpace/$drive.Size) -lt 0.11)
                {
                    $output.E_Threshold10FreeSpace = " < 11%"
                }
                Else {$output.E_Threshold10FreeSpace = " > 11%"}
                }
            default 
                {
                If (!(($drive.description -like "network*") -or ($drive.description -like "reseau*")))
                {
                    $Output.OtherDrives += $drive.DeviceID + " " 
                }
                }
            }
        }
            
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

$Disk_Config=@()

ForEach ($DC in $DC_list )
{
$Disk_Config += Get-DiskConfig $DC.DCShortName 
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject ($Disk_Config | Select-Object -property DCName,C_Threshold10FreeSpace,C_DriveTotalSpace,D_Threshold10FreeSpace,D_DriveTotalSpace,E_Threshold10FreeSpace,E_DriveTotalSpace,OtherDrives)  $XMLFile

#Write-Output $Disk_Config | Select-Object -Property DCName,C_DriveFreeSpace,C_Threshold10FreeSpace,C_DriveTotalSpace,D_DriveFreeSpace,D_Threshold10FreeSpace,D_DriveTotalSpace,E_DriveFreeSpace,E_Threshold10FreeSpace,E_DriveTotalSpace,OtherDrives | ft -Wrap | Out-Default
Write-Output $Disk_Config | Export-Csv $LogPath\Disk_Config.csv -Delimiter ";" -NoTypeInformation
Write-Output $Disk_Config | ft -wrap | Out-Default
Write-Output $Disk_Config | ft -wrap >$LogFile 
