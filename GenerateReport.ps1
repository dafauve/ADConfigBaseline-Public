##########################
#####
##   Creation des fonctions
#####
##############################

function findfile {


[CmdletBinding()]             
 Param              
   ( 
    [parameter(mandatory=$true,position=0)][string]$FilePath  
    )#End Param 

    $fileexist=Test-Path $FilePath
    $fileexist
}

function get-properties {

[CmdletBinding(SupportsShouldProcess=$true)]
    param ( 
        [parameter(mandatory=$true,position=0)]$Var
    )
    $obj=@()
    $output = $var | Get-Member -MemberType NoteProperty | sort -Property Name
    foreach ($item in $Output)
    {
    $obj += $item.Name
    }
    $obj
}

function Compare-BSL {
Param              
   ( 
    [parameter(mandatory=$true,position=0)][string]$Script  
    )#End Param 

$BaseLine=Import-Clixml -Path .\Logs\$Script'_baseline.xml'
$NewDiff = Import-Clixml -Path .\Logs\$Script'_diff.xml'

$Properties = get-properties $BaseLine

$Compare=@()
$Compare=Compare-Object $BaseLine $NewDiff -Property $Properties | sort -Property $Properties[0],SideIndicator

If (($Script -eq "DomainAdmins") -and ($Compare))
{
    
    Foreach ($domain in ($BaseLine | select -ExpandProperty DomainName))
    {
        $replacebyadministrator = @()
        $replacebydomainadmins = @()
        $replacebyadministrator = Compare-Object ($BaseLine | Where-Object {$_.domainname -eq $domain} | select -ExpandProperty Administrators) ($NewDiff | Where-Object {$_.domainname -eq $domain} | select -ExpandProperty Administrators) | Select -ExpandProperty Inputobject
        $replacebydomainadmins = Compare-Object ($BaseLine | Where-Object {$_.domainname -eq $domain} | select -ExpandProperty DomainAdmins) ($NewDiff | Where-Object {$_.domainname -eq $domain} |select -ExpandProperty DomainAdmins) | Select -ExpandProperty Inputobject
        $ligne = $compare | Where-Object {($_.sideindicator -eq "=>") -and ($_.domainname -eq $domain)}
        
	    if($ligne.administrators)
		{
			$ligne.administrators = ""
	        foreach ($entry in $replacebyadministrator)
	        {
	        $ligne.Administrators += $entry +" "
	        }
		}
	    if($ligne.domainadmins)
		{
			$ligne.domainadmins = ""
	        foreach ($entry in $replacebydomainadmins)
	        {
	        $ligne.domainadmins += $entry +" "
	        }
		}
    }

}

If (($Script -eq "ForestAdmins") -and ($Compare))
{
    
    Foreach ($group in ($BaseLine | select -ExpandProperty GroupName))
    {
        $replacebyadmin = @()
        $replacebyadmin = Compare-Object ($BaseLine | Where-Object {$_.GroupName -eq $group} | select -ExpandProperty Users) ($NewDiff | Where-Object {$_.GroupName -eq $group} | select -ExpandProperty Users) | Select -ExpandProperty Inputobject
        #$replacebyadmin = Compare-Object ($BaseLine | Where-Object {$_.GroupName -eq $group}) ($NewDiff | Where-Object {$_.GroupName -eq $group}) -Property Users
        $ligne = $compare | Where-Object {($_.sideindicator -eq "=>") -and ($_.GroupName -eq $group)}

        if($ligne)
		{	
			$ligne.Users = ""
	        foreach ($entry in $replacebyadmin)
	        {
	        $ligne.Users += $entry +" "
	        }
		}
    }

}

foreach ($item in $compare)
{
    If ($item.sideindicator -eq "=>") {$item.sideindicator = "new"}
    If ($item.sideindicator -eq "<=") {$item.sideindicator = "old"}
}

##$output = ConvertTo-Html -Fragment -PreContent ("<h2>"+$Script+" - Baseline generee: "+$BSLGenerated.$Script+"</h2>") | Out-String
if ($BSLGenerated.$Script -eq "Oui") {$output = ConvertTo-Html -Fragment -PreContent ("<h2>" + $Script + "<b class=""bad"">" + " - Baseline generee " + "</b>" + "</h2>") | Out-String}
if ($BSLGenerated.$Script -eq "Non") {$output = ConvertTo-Html -Fragment -PreContent ("<h2>"+$Script+"</h2>") | Out-String}


if (!$Compare)
{
$output += ConvertTo-Html -Fragment -PreContent '<p class="good"> Pas de changement detecte par rapport a la baseline</p>' | Out-String
}
else
{
$output += $Compare | ConvertTo-Html -Fragment -PreContent ("<h3 class=""bad""> Etat Actuel pour " + $Script + ":</h3>") | Out-String
$output += $BaseLine | Select-Object -Property $Properties | ConvertTo-Html -Fragment -PreContent ("<h3 class=""good""> Baseline pour " + $Script + ":</h3>") | Out-String
}

Write-Output $output

}


###################
#################
###   CLEAR
#################
clear


#############################
###################################
############
############ Header pour CSS Expression
############
###################################
############################

$head = @' 
<style media='screen'> 
body { background-color:#dddddd; 
       font-family:Tahoma; 
       font-size:12pt; } 
td, th { border:1px solid black;  
         border-collapse:collapse; } 
th { color:white; 
     background-color:black; } 
table, tr, td, th { padding: 2px; margin: 0px } 
table { margin-left:50px; }
.good { color:green}
.bad { color:red}
</style> 
<style media='print'> 
// Put alternate hardcopy styles here 
</style> 
'@


#############################
#Generate & Export variables if Export_Var.xml does not exist, then load variables
#############################

$IfConfigXMLExist=findfile -FilePath .\Export_Var.ps1
    If (!$IfConfigXMLExist)
        {
        Invoke-Expression .\Export_Var.ps1
        }

$AllVar = Import-Clixml .\Export_Var.xml


#######################################
# Export dc list to be re-used by all scripts
######################################

Invoke-Expression .\get-domaincontroller.ps1

########################################
# Load Variables from $AllVar
#######################################


$ConfigFileLst=$AllVar.ConfigFileLst
$Logpath=$AllVar.LogPath
$SendEmail = $AllVar.SendEmail

############################################
# check if baselines need to be generated
#############################################


$BSLGenerated=@{}
$ConfigFile=""
$BSLCount=0

$EmailHeader="<h1>Baselines Active Directory</h1>"
$EmailHeader+="<h1>Listes des Baselines Regenerees</h1>"
$EmailBody=" "
$EmailAttachment=""
$SendBSLEmail="No"

$ConfigHeader="<h1>Configuration Actuelle Active Directory</h1>"
$ConfigHeader+="<h1>Listes des Configurations</h1>"
$ConfigBody=" "


$LogExist=findfile -FilePath .\Logs



If (!$LogExist)
{New-Item -Path ".\" -Name "Logs" -ItemType "Directory"}


##### Loop in all the scripts registered in Export_Var

ForEach ($ConfigFile in $ConfigFileLst)
{

########## Search for the baseline xml file and run script if it doesn't exist, then copy Diff to BSL

    
    $IfBSLExist=findfile -FilePath .\Logs\$ConfigFile'_baseline.xml'
    Write-Output $ConfigFile
    
    Invoke-Expression .\$ConfigFile'.ps1'

    ############ creation du fichier de configuration generale actuelle

    $COnfigBody+="<h2 class=""good"">Configuration etablie pour: "+$ConfigFile+"</h2>"
    $ConfigBodyXML = Import-Clixml .\Logs\$ConfigFile"_diff.xml"
    $ConfigBodyProperties = get-properties $ConfigBodyXML
#    $ConfigBody += $ConfigBodyXML | Select-Object -Property $ConfigBodyProperties | ConvertTo-Html -Fragment | Out-String
    $ConfigBody += $ConfigBodyXML | ConvertTo-Html -Fragment | Out-String
	
    ############ si la baseline n'existe pas, copie de la config actuelle en baseline

    If (!$IfBSLExist)
        {
        Copy-Item .\Logs\$ConfigFile'_diff.xml' .\Logs\$ConfigFile'_baseline.xml'
        $BSLGenerated +=@{$ConfigFile="Oui"}
        $SendBSLEmail="Yes"
        $EmailBody+="<h2 class=""bad"">Baseline Regeneree pour: "+$ConfigFile+"</h2>"
        $BSLCount+=1
        $EmailBodyXML = Import-Clixml .\Logs\$ConfigFile"_diff.xml"
        $EmailBodyProperties = get-properties $EmailBodyXML
        $EmailBody += $EmailBodyXML | Select-Object -Property $EmailBodyProperties | ConvertTo-Html -Fragment | Out-String

        }

############## If baseline exists, only run scripts
    Else
        {

        $BSLGenerated+=@{$ConfigFile="Non"}
        }
} 

ConvertTo-Html -head $head -PostContent $ConfigBody -Body $ConfigHeader -Title "<h1>Configuration Active Directory</h1>" | out-file .\current_config.html

ConvertTo-Html -head $head -PostContent $EmailBody -Body $EmailHeader -Title "<h1>Configuration Baseline</h1>" | out-file .\baselines.html
If (($SendEmail -eq "Yes") -and ($SendBSLEmail -eq "Yes"))
    {
    Send-MailMessage -to $AllVar.SendToAddress -from $AllVar.FromAddress -subject ("Generation des baselines AD - " +$BSLCount+ " Baselines generees") -SmtpServer $AllVar.Smtpserver -Attachments .\baselines.html -BodyAsHtml $EmailBody
    }



#########################################################################
#########################################################################
######
###     Loop through Each Script to compare Baseline and generate HTML output
#########
#########################################################################
##########################################################################

$ConfigFile=""
$b=""
$DeviationFlag = "No"


foreach ($ConfigFile in $ConfigFileLst)
{
    $b+=Compare-BSL $ConfigFile
    If ($b.contains('<h3 class="bad">'))
    {
        $DeviationFlag = "Yes"
    }
    }


ConvertTo-Html -Head $head -PostContent $b -Body "<h1>Configuration Baseline</h1>" -Title "<h1>test</h1>" | out-file .\Rapport_Comparatif_Baselines.html

If ($SendEmail -eq "Yes")
{
    If ($DeviationFlag -eq "Yes")
    {
    Send-MailMessage -to $AllVar.SendToAddress -from $AllVar.FromAddress -subject "Comparaison des baselines AD [A Verifier]" -SmtpServer $AllVar.Smtpserver -Attachments .\Rapport_Comparatif_Baselines.html -BodyAsHtml $b
    }
    Else
    {
    Send-MailMessage -to $AllVar.SendToAddress -from $AllVar.FromAddress -subject "Comparaison des baselines AD" -SmtpServer $AllVar.Smtpserver -Attachments .\Rapport_Comparatif_Baselines.html -BodyAsHtml $b
    }
} 

