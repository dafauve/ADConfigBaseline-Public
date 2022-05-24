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
$DC_list = Import-Clixml $Logpath\Get-DomainController_diff.xml
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


function Get-RegKeys {
<#
    .Synopsis
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ( 
        [parameter(mandatory=$false,position=0)][alias("computer")]$Computername
    )

    If (!$computername) {$computername = "localhost"}

    $HKLM = 2147483650

        #$TestConnection = Test-Connection -ComputerName $Computername -Quiet -Count 1
        $Output = New-Object -TypeName psobject
        #$Output | Add-Member -MemberType 'NoteProperty' -Name '_DCName' -Value $env:Computername
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'StrictReplicationConsistency' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'SupportedEncryptionTypes' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'MaxTokenSize' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DFSR_StopReplOnAutoRecovery' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DFSR_RPCPortAssignement' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'TCPIP_port' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'DCTcpipPort' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'IPV6Disabled' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NSPI_Max_Session_per_User' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'SIDCompression' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'WhiteSpaceLoging' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'LDAPInterfaceLoging' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'LdapEnforceChannelBinding' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'FullSecureChannelProtection' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'NonForwardableDelegation' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PerformTicketSignature' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'LDAPServerIntegrity' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'ldapclientintegrity' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'AvoidPDCOnWan' -Value "Server unreachable"
        $Output | Add-Member -MemberType 'NoteProperty' -Name 'PacRequestorEnforcement' -Value "Server unreachable"
                
   
    
    
            ######################## supported Kerberos Encrpytion Types            
            try {

            # Determine Encryption Type 
                #$reg = [wmiclass]"\\$Computername\root\default:StdRegprov"
                $reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine',0)
                $key = "Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\parameters"
                $valuename = "SupportedEncryptionTypes"
                $regkey = $reg.opensubkey($key)
                [string]$EncryptionTypes = $regkey.getvalue($valuename)
                if (!$EncryptionTypes) {$EncryptionTypes = "Value does not exist"}
                
            } catch {
                $EncryptionTypes="key unknown"
            }

            ######################## MaxTokenSize            
            try {

            ## MaxTokenSize 
                $key = "System\CurrentControlSet\Control\LSA\Kerberos\Parameters"
                $valuename = "MaxTokenSize"
                $regkey = $reg.opensubkey($key)
                [string]$MaxTokenSize = $regkey.getvalue($valuename)
                if (!$MaxTokenSize) {$MaxTokenSize = "Value does not exist"}
                
            } catch {
                $MaxTokenSize="Server unreachable or key unknown"
            }


            ###################### Strict replication consistency
            try {    
                ## Get The Strict Replication Consistency
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $valuename = "Strict Replication Consistency"
                $regkey = $reg.opensubkey($key)
                [string]$ReplicationConsistency = $regkey.getvalue($valuename)
                if (!$ReplicationConsistency) {$ReplicationConsistency = "Value does not exist"}
                }
            catch {
                $ReplicationConsistency="Server unreachable or key unknown"
            }

            ####################### WhiteSpace Loging Enabled
            try {    
                ## Get The WhiteSpace Logging enabled by Garbage Collector 
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics"
                $valuename = "6 Garbage Collection"
                $regkey = $reg.opensubkey($key)
                [string]$WhiteSpaceLoging = $regkey.getvalue($valuename)
                if (!$WhiteSpaceLoging) {$WhiteSpaceLoging = "Value does not exist"}
                }
            catch {
                $WhiteSpaceLoging="Server unreachable or key unknown"
            }

            ####################### 16 LDAP Interface Events
            try {    
                ## Get The WhiteSpace Logging enabled by Garbage Collector 
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics"
                $valuename = "16 LDAP Interface Events"
                $regkey = $reg.opensubkey($key)
                [string]$LDAPInterfaceLoging = $regkey.getvalue($valuename)
                if (!$LDAPInterfaceLoging) {$LDAPInterfaceLoging = "Value does not exist"}
                }
            catch {
                $LDAPInterfaceLoging="Server unreachable or key unknown"
            }

            ####################### LdapEnforceChannelBinding
            try {    
                ## Get The WhiteSpace Logging enabled by Garbage Collector 
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $valuename = "LdapEnforceChannelBinding"
                $regkey = $reg.opensubkey($key)
                [string]$LdapEnforceChannelBinding = $regkey.getvalue($valuename)
                if (!$LdapEnforceChannelBinding) {$LdapEnforceChannelBinding = "Value does not exist"}
                }
            catch {
                $LdapEnforceChannelBinding="Server unreachable or key unknown"
            }

            ####################### FullSecureChannelProtection
            try {    
                ## Get The WhiteSpace Logging enabled by Garbage Collector 
                $key = "SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
                $valuename = "FullSecureChannelProtection"
                $regkey = $reg.opensubkey($key)
                [string]$FullSecureChannelProtection = $regkey.getvalue($valuename)
                if (!$FullSecureChannelProtection) {$FullSecureChannelProtection = "Value does not exist"}
                }
            catch {
                $FullSecureChannelProtection="Server unreachable or key unknown"
            }

            ####################### PerformTicketSignature
            try {    
                ## Get The CVE-2020-17049 Enforcement Mode (0=disabled,1=mode compatible,2=enforced)
                $key = "SYSTEM\CurrentControlSet\Services\Kdc"
                $valuename = "PerformTicketSignature"
                $regkey = $reg.opensubkey($key)
                [string]$PerformTicketSignature = $regkey.getvalue($valuename)
                if (!$PerformTicketSignature) {$PerformTicketSignature = "Value does not exist"}
                }
            catch {
                $PerformTicketSignature="Server unreachable or key unknown"
            }

             ####################### NonForwardableDelegation 
            try {    
                ## Get The CVE-2020-16996 Enforcement Mode (0=enable enforcement,1=disable enforcement)
                $key = "SYSTEM\CurrentControlSet\Services\Kdc"
                $valuename = "NonForwardableDelegation"
                $regkey = $reg.opensubkey($key)
                [string]$NonForwardableDelegation = $regkey.getvalue($valuename)
                if (!$NonForwardableDelegation) {$NonForwardableDelegation = "Value does not exist"}
                }
            catch {
                $NonForwardableDelegation="Server unreachable or key unknown"
            }

            ####################### LDAPServerIntegrity
            try {    
                ## Get The WhiteSpace Logging enabled by Garbage Collector 
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $valuename = "LDAPServerIntegrity"
                $regkey = $reg.opensubkey($key)
                [string]$LDAPServerIntegrity = $regkey.getvalue($valuename)
                if (!$LDAPServerIntegrity) {$LDAPServerIntegrity = "Value does not exist"}
                }
            catch {
                $LDAPServerIntegrity="Server unreachable or key unknown"
            }

            ####################### ldapclientintegrity
            try {    
                ## Get The WhiteSpace Logging enabled by Garbage Collector 
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $valuename = "ldapclientintegrity"
                $regkey = $reg.opensubkey($key)
                [string]$ldapclientintegrity = $regkey.getvalue($valuename)
                if (!$ldapclientintegrity) {$ldapclientintegrity = "Value does not exist"}
                }
            catch {
                $ldapclientintegrity="Server unreachable or key unknown"
            }

            ######################## DFSR AutoRecovery
            try {
                    
                ## Get The DFSR AutoRecovery
                $key = "SYSTEM\CurrentControlSet\Services\DFSR\Parameters"
                $valuename = "StopReplicationOnAutoRecovery"
                $regkey = $reg.opensubkey($key)
                [string]$DFSRAutoRecovery = $regkey.getvalue($valuename)
                if (!$DFSRAutoRecovery) {$DFSRAutoRecovery = "Value does not exist"}
                
            } catch {
                $DFSRAutoRecovery = "Server unreachable or key unknown"
            }

            ######################## DFSR RPC port assignment
            try {
                    
                ## Get The DFSR port
                
                [string]$DFSR_RPCPortAssignement = (Get-WmiObject -Namespace Root\MicrosoftDFS -Class DFSRMachineConfig -ErrorAction SilentlyContinue).RPCPortAssignment
                if (!$DFSR_RPCPortAssignement) {$DFSR_RPCPortAssignement = "Value does not exist"}
                
            } catch {
                $DFSR_RPCPortAssignement = "Server unreachable or key unknown"
            }

            ######################## AD Replication NTDS port assignment
            try {
                    
                ## Get The AD NTDS port
                
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $valuename = "TCP/IP Port"
                $regkey = $reg.opensubkey($key)
                [string]$TCPIP_port = $regkey.getvalue($valuename)
                if (!$TCPIP_port) {$TCPIP_port = "Value does not exist"}
                
            } catch {
                $TCPIP_port = "Server unreachable or key unknown"
            }

            ######################## AD Replication Netlogon port assignment
            try {
                    
                ## Get The AD Netlogon port
                
                $key = "SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
                $valuename = "DCTcpipPort"
                $regkey = $reg.opensubkey($key)
                [string]$DCTcpipPort = $regkey.getvalue($valuename)
                if (!$DCTcpipPort) {$DCTcpipPort = "Value does not exist"}
                
            } catch {
                $DCTcpipPort = "Server unreachable or key unknown"
            }

            ########################## NSPI MAPI connections
            try {
                    
                ## Get NSPI MAPI
                $key = "SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
                $valuename = "NSPI max sessions per user"
                $regkey = $reg.opensubkey($key)
                [string]$NSPI_Max_Session_per_User = $regkey.getvalue($valuename)
                if (!$NSPI_Max_Session_per_User) {$NSPI_Max_Session_per_User = "Value does not exist"}
                
            } catch {
                $NSPI_Max_Session_per_User = "Server unreachable or key unknown"
            }

            ########################## SID Compression
            try {
                    
                ## Get SID Compression option
                $key = "SOFTWARE\Microsoft\WIndows\CurrentVersion\Policies\System\Kdc\Parameters"
                $valuename = "DisableResourceGroupsFields"
                $regkey = $reg.opensubkey($key)
                [string]$SIDCompression = $regkey.getvalue($valuename)
                if (!$SIDCompression) {$SIDCompression = "Value does not exist"}
                
            } catch {
                $SIDCompression = "Server unreachable or key unknown"
            }

            ########################## IPv6 Disabled
            try {
                    
                ## Get The IPV6 DisabledComponents
                $key = "SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
                $valuename = "DisabledComponents"
                $regkey = $reg.opensubkey($key)
                [string]$IPv6 = $regkey.getvalue($valuename)
                if (!$IPv6) {$IPv6 = "Value does not exist"}
                
            } catch {
                $IPv6 = "Server unreachable or key unknown"
            }

            ########################## AvoidPDCOnWAN
            try {
                    
                ## Get The AvoidPDCOnWAN
                $key = "SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
                $valuename = "AvoidPdcOnWan"
                $regkey = $reg.opensubkey($key)
                [string]$AvoidPDCOnWan = $regkey.getvalue($valuename)
                if (!$AvoidPDCOnWan) {$AvoidPDCOnWan = "Value does not exist"}
                
            } catch {
                $AvoidPDCOnWan = "Server unreachable or key unknown"
            }

            ########################## PacRequestorEnforcement 
            try {
                    
                ## Get The PacRequestorEnforcement version
                $key = "System\CurrentControlSet\Services\Kdc"
                $valuename = "PacRequestorEnforcement"
                $regkey = $reg.opensubkey($key)
                [string]$PacRequestorEnforcement = $regkey.getvalue($valuename)
                if (!$PacRequestorEnforcement) {$PacRequestorEnforcement = "Value does not exist"}
                
            } catch {
                $PacRequestorEnforcement = "Server unreachable or key unknown"
            }

            ##################### output values
            $Output.SupportedEncryptionTypes = $EncryptionTypes
            $Output.MaxTokenSize = $MaxTokenSize
            $Output.StrictReplicationConsistency = $ReplicationConsistency
            $Output.WhiteSpaceLoging = $WhiteSpaceLoging
            $Output.LDAPInterfaceLoging = $LDAPInterfaceLoging
            $Output.LdapEnforceChannelBinding = $LdapEnforceChannelBinding
            $Output.FullSecureChannelProtection = $FullSecureChannelProtection
            $Output.PerformTicketSignature=$PerformTicketSignature
            $Output.NonForwardableDelegation=$NonForwardableDelegation
            $Output.LDAPServerIntegrity = $LDAPServerIntegrity
            $Output.ldapclientintegrity = $ldapclientintegrity
            $Output.DFSR_StopReplOnAutoRecovery = $DFSRAutoRecovery
            $Output.DFSR_RPCPortAssignement = $DFSR_RPCPortAssignement
            $Output.IPv6Disabled = $IPv6
            $Output.NSPI_Max_Session_per_User = $NSPI_Max_Session_per_User
            $Output.DCTcpipPort = $DCTcpipPort
            $Output.TCPIP_port = $TCPIP_port
            $Output.SIDCompression = $SIDCompression
            $Output.AvoidPDCOnWan = $AvoidPDCOnWan
            $Output.PacRequestorEnforcement = $PacRequestorEnforcement
            $Output
}
    


$RegKeys_BSL=@()

<#ForEach ($DC in $DC_List)
{
$RegKeys_BSL += Get-RegKeys -Computername $DC.DCShortName
}#>

$session = New-PSSession -ComputerName $DC_list.DCName 
$RegKeys_BSL = Invoke-Command -Session $session -ErrorAction SilentlyContinue -ScriptBlock ${Function:Get-RegKeys}

Remove-PSSession $session
$RegKeys_BSL = $RegKeys_BSL | select @{Name='_DCname';Expression='PSComputerName'},StrictReplicationConsistency,SupportedEncryptionTypes,MaxTokenSize,DFSR_StopReplOnAutoRecovery,DFSR_RPCPortAssignement,TCPIP_port,DCTcpipPort,IPV6Disabled,NSPI_Max_Session_per_User,SIDCompression,WhiteSpaceLoging,LDAPInterfaceLoging,LdapEnforceChannelBinding,LDAPServerIntegrity,ldapclientintegrity,FullSecureChannelProtection,PerformTicketSignature,NonForwardableDelegation,AvoidPDCOnWan,PacRequestorEnforcement

$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"
$CSVFile = $LogPath + $LogFile.split('\.')[-2] + ".csv"

Export-Clixml -InputObject $RegKeys_BSL $XMLFile

Write-Output $RegKeys_BSL | Export-Csv $CSVFile -NoTypeInformation
Write-Output $RegKeys_BSL | fl * | Out-Default
Write-Output $RegKeys_BSL >$LogFile

