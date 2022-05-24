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


Function Get-WMIConfig {

[CmdletBinding()]
param (
[parameter(mandatory=$true,position=0)]$DCName
)



$Output = New-Object -TypeName psobject
$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value ($DCName -split "\.")[0]
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSCaption' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_32BitApplications' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_Available' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_Drivers' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DEP_SupportPolicy' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'MUILanguages' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSLanguage' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Locale' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSInstallDate' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'OSStatus' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Version' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PAEEnabled' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FreePhysicalMemory' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FreeSpaceInPagingFiles' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FreeVirtualMemory' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'SizeStoredInPagingFiles' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'TotalVirtualMemorySize' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'SystemDirectory' -Value "Server unreachable"
        #$Output | Add-Member -MemberType 'NoteProperty' -Name 'TotalVisibleMemorySize' -Value "Server unreachable"
        ###Specific to page file
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PageFileLocation' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PFPeakUsage' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'TempPageFile' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PFInstallDate' -Value "Server unreachable" 
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PFAllocatedBaseSize' -Value "Server unreachable"
        ## Specific to ComputerSYstem       
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'TotalPhysicalMemory' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'AutomaticManagedPageFile' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Manufacturer' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'Model' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NumberOfLogicalProcessors' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NumberOfProcessors' -Value "Server unreachable"
        

$TestConnection = Test-Connection -ComputerName $DCName -Quiet -Count 1


If ($TestConnection)
{
    Try 
    {
        $OSinfo = @()
        $OSinfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $DCName -ErrorAction SilentlyContinue
        $PFinfo = Get-WmiObject -Class Win32_PageFileUsage -ComputerName $DCName -ErrorAction SilentlyContinue
        $CSinfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $DCName -ErrorAction SilentlyContinue
        $Output.OSCaption = $OSinfo.Caption
        $Output.DEP_32BitApplications = $OSinfo.DataExecutionPrevention_32BitApplications
        $Output.DEP_Available = $OSinfo.DataExecutionPrevention_Available
        $Output.DEP_Drivers = $OSinfo.DataExecutionPrevention_Drivers
        $Output.DEP_SupportPolicy = $OSinfo.DataExecutionPrevention_SupportPolicy
        $Output.MUILanguages = $OSinfo.MUILanguages -join ";"
        $Output.OSLanguage = $OSinfo.OSLanguage
        $Output.Locale = $OSinfo.Locale
        $Output.OSInstallDate = $OSinfo.converttodatetime($OSinfo.InstallDate)
        $Output.OSStatus = $OSinfo.Status
        $Output.Version = $OSinfo.Version
        $Output.PAEEnabled = $OSinfo.PAEEnabled
        $Output.FreePhysicalMemory = [string]([math]::round($OSinfo.FreePhysicalMemory/1MB,2)) + "GB "
        $Output.FreeSpaceInPagingFiles = [string]([math]::round($OSinfo.FreeSpaceInPagingFiles/1MB,2)) + "GB "
        $Output.FreeVirtualMemory = [string]([math]::round($OSinfo.FreeVirtualMemory/1MB,2)) + "GB "
        $Output.SizeStoredInPagingFiles = [string]([math]::round($OSinfo.SizeStoredInPagingFiles/1MB,2))+ "GB "
        $Output.TotalVirtualMemorySize = [string]([math]::round($OSinfo.TotalVirtualMemorySize/1MB,2))+"GB "
        $Output.SystemDirectory = $OSinfo.SystemDirectory
        #$Output.TotalVisibleMemorySize = $OSinfo.TotalVisibleMemorySize/1MB
        $Output.TotalVirtualMemorySize = [string]([math]::round($OSinfo.TotalVirtualMemorySize/1MB,2)) + "GB "

        ### Specific to Page File
        $Output.PageFileLocation = ""
        $output.PFPeakUsage = ""
        $Output.TempPageFile = ""
        $Output.PFInstallDate = ""
        $Output.PFAllocatedBaseSize = ""
        foreach ($PF in $PFinfo)
        {
        
        $Output.PageFileLocation += $PF.Description + "; "
        
        $Output.PFPeakUsage += [string]($PF.PeakUsage)+"MB; "
        
        $Output.TempPageFile += [string]$PF.TempPageFile + "; "
        $Output.PFInstallDate += [string]($PF.converttodatetime(($PF.InstallDate))) + "; "
       $Output.PFAllocatedBaseSize += [string]([math]::round(($PF.AllocatedBaseSize)/1KB,2)) +"GB; "
        }
        ## Specific to Computer System
        $Output.AutomaticManagedPageFile = $CSinfo.AutomaticManagedPageFile
        $Output.Manufacturer = $CSinfo.Manufacturer
        $Output.Model = $CSinfo.Model
        $Output.TotalPhysicalMemory = [string]([math]::round($CSinfo.TotalPhysicalMemory/1GB,2)) + "GB "
        $Output.NumberOfLogicalProcessors = $CSinfo.NumberOfLogicalProcessors
        $Output.NumberOfProcessors = $CSinfo.NumberOfProcessors
        
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


$OS_Config=@()

ForEach ($DC in $DC_list )
{
$OS_Config += Get-WMIConfig $DC.DCName
}



$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $OS_Config $XMLFile

Write-Output $OS_Config | Export-Csv $LogPath\WMI_Config.csv -Delimiter ";" -NoTypeInformation 
Write-Output $OS_Config
