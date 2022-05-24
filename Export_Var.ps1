#Create Hash Table to store variables
$AllVar=@{}

########################
#Define variables here
########################
$ScriptsPath="C:\scripts"
$LogPath=".\Logs\"
$SendEmail = "No"
$smtpserver=""
$SendToAddress=""
$FromAddress=""
$ConfigFileLst="Get-DomainController","ForestInfo","AdminSDHolder","DomainInfo","LdapPolicy","ForestAdmins","DomainAdmins","SiteLink","SiteInfo","DefaultOU_DC","RegKeys","Config_IP","Time_Config","Uptime","NTDS_SYSVOL","PwdPolicy","Disk_Config","WMI_CS","WMI_PF","WMI_RAM","ADServices","ADTrusts","WMI_LogSize","SMB_Shares","KrbtgtMeta","DCCert"
#$ConfigFileLst="WMI_CS","WMI_PF","WMI_RAM"
#$ConfigFileLst="ADTrusts"
########################


#Export Variables in XML file
$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = ".\" + $LogFile.split('\.')[-2] + ".xml"


$AllVar=@{ScriptsPath=$ScriptsPath;LogPath=$LogPath;SendEmail=$SendEmail;Smtpserver=$smtpserver;SendToAddress=$SendToAddress;FromAddress=$FromAddress;ConfigFileLst=$ConfigFileLst}

Export-Clixml -InputObject $AllVar $XMLFile 


