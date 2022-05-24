############################
############################
#############
###   Hearder to copy/paste on all scripts (except DefaultOU_DC)
############ https://blogs.technet.microsoft.com/heyscriptingguy/2011/02/16/use-powershell-and-net-to-find-expired-certificates/
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

Function Get-DCCert {
Param ([string]$server) 


Function Get-CertInfo{
param (
    $certif,
    $DCName

)

$Output = New-Object -TypeName psobject
#$Output | Add-Member -MemberType 'NoteProperty' -Name 'ComputerName' -Value $DCName
$Output | Add-Member -MemberType 'NoteProperty' -Name 'EKU' -Value ($certif.enhancedKeyUsageList.friendlyname -join ", ")
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Issuer' -Value $certif.Issuer
$Output | Add-Member -MemberType 'NoteProperty' -Name 'ExpirationDate' -Value $certif.NotAfter
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Subject' -Value $certif.Subject
$Output | Add-Member -MemberType 'NoteProperty' -Name 'Thumbprint' -Value $certif.thumbprint
$Output | Add-Member -MemberType 'NoteProperty' -Name 'SerialNumber' -Value $certif.serialnumber



If ($certif.notafter -gt (get-date).AddDays("60"))
{
    $Output | Add-Member -MemberType 'NoteProperty' -Name 'ExpireIn60Days' -Value "False"
}
Else 
{
    $Output | Add-Member -MemberType 'NoteProperty' -Name 'ExpireIn60Days' -Value "True"
}

Write-Output $Output
}



#If (!$server) {$server = "localhost"}
   
    $output = @()
    try
    {
        
        $store=new-object System.Security.Cryptography.X509Certificates.X509Store("my","LocalMachine")
        $store.open("ReadOnly")
                 

        Foreach ($cert in $store.Certificates)
        {
            $ServerCert=@()
            $ServerCert = Get-CertInfo $cert $server
            $output += $ServerCert
        }
   } 
    catch
    {
        $err = New-Object -TypeName psobject 
        #$err | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $server
        $err | Add-Member -MemberType NoteProperty -Name 'Thumbprint' -value "None"
        $err | Add-Member -MemberType NoteProperty -Name 'SerialNumber' -value "None"
        $err | Add-Member -MemberType NoteProperty -Name 'ExpirationDate' -Value "unknown"
        $err | Add-Member -MemberType NoteProperty -Name 'ExpireIn60Days' -value "unknown"
        $err | Add-Member -MemberType NoteProperty -Name 'Subject' -value "unknown"
        $err | Add-Member -MemberType NoteProperty -Name 'Issuer' -value "unknown"
        $err | Add-Member -MemberType NoteProperty -Name 'EKU' -Value "unknown"


        $output +=$err
            
    }
    $output
}

$CertInfo=@()

$session = New-PSSession -ComputerName $DC_list.DCName 
$CertInfo = (Invoke-Command -Session $session -ErrorAction SilentlyContinue -ScriptBlock ${Function:Get-DCCert} -ArgumentList $session.ComputerName) | select @{Name='ComputerName';expression='PSComputerName'},Subject,EKU,Issuer,ExpirationDate,ExpireIn60Days,Thumbprint,SerialNumber

Remove-PSSession $session

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"
$CsvFile = $LogPath + $LogFile.split('\.')[-2] + ".csv"

Export-Clixml -InputObject $CertInfo $XMLFile

Write-Output $CertInfo | ft -AutoSize -Wrap

Write-Output $CertInfo | ft -AutoSize > $LogFile

Write-Output $CertInfo | Export-Csv $CsvFile -Delimiter ";" -NoTypeInformation
