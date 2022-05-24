try {
$AllVar = Import-Clixml .\Export_Var.xml
$LogPath=$AllVar.LogPath
}
catch {
$LogPath=".\Logs\"
}

$ForestInfo = New-Object psobject
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'ForestName' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'SchemaVersion' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'ForestMode' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'ForestPrep' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'RecycleBin' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'RODCPrep' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'DSHeuristics' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'TombstoneLifeTime' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'DeletedObjectLifeTime' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'SchemaMaster' -Value "Empty"
$ForestInfo | Add-Member -MemberType 'NoteProperty' -Name 'DomainNamingMaster' -Value "Empty"


$SchemaPartition = (Get-ADRootDSE).NamingContexts | Where-Object {$_ -like "*Schema*"}


$ForestName= Get-ADForest| Select-Object -Property Name
$SchemaVersion= (Get-ADObject $SchemaPartition -Property objectversion) | Select-Object -Property Objectversion
$ForestMode= Get-ADForest| Select-Object -Property ForestMode

$DomainList=(Get-ADForest).Domains

$ForestPrep = get-adobject "cn=ActiveDirectoryUpdate,cn=ForestUpdates,$(([adsi]("LDAP://RootDSE")).configurationNamingContext)" -Properties revision | Select-Object -Property Revision
$RODCPrep = get-adobject "cn=ActiveDirectoryRodcUpdate,cn=ForestUpdates,$(([adsi]("LDAP://RootDSE")).configurationNamingContext)" -Properties revision | Select-Object -Property Revision


$DSHeuristics = get-adobject "cn=Directory Service,cn=Windows NT,cn=Services,$(([adsi]("LDAP://RootDSE")).configurationNamingContext)" -Properties dSHeuristics | Select-Object -Property dSHeuristics


$TSL = get-adobject "cn=Directory Service,cn=Windows NT,cn=Services,$(([adsi]("LDAP://RootDSE")).configurationNamingContext)" -Properties tombstoneLifetime | Select-Object -Property tombstoneLifetime


$DOL = get-adobject "cn=Directory Service,cn=Windows NT,cn=Services,$(([adsi]("LDAP://RootDSE")).configurationNamingContext)" -Properties msDS-DeletedObjectLifetime | Select-Object -Property msDS-DeletedObjectLifetime

$RecycleBin = Get-ADOptionalFeature -Filter {Name -eq "Recycle Bin Feature"}
If ($RecycleBin.EnabledScopes[0] -like "CN=Partitions*")
{
    $ForestInfo.RecycleBin = "Enabled"
}
Else { $ForestInfo.RecycleBin = "Disabled" }



$ForestInfo.ForestName=$ForestName.Name
$ForestInfo.SchemaVersion=$SchemaVersion.Objectversion
$ForestInfo.ForestMode=$ForestMode.ForestMode
$ForestInfo.ForestPrep=$ForestPrep.Revision
$ForestInfo.RODCPrep=$RODCPrep.Revision
$ForestInfo.DSHeuristics=$DSHeuristics.dSHeuristics
$ForestInfo.TombstoneLifetime=$TSL.tombstoneLifetime
$ForestInfo.DeletedObjectLifeTime=$DOL.'msDS-DeletedObjectLifetime'
$ForestInfo.SchemaMaster= (Get-adforest | Select-Object -Property SchemaMaster).SchemaMaster
$ForestInfo.DomainNamingMaster= (Get-adforest | Select-Object -Property DomainNamingMaster).DomainNamingMaster


$LogFile = split-path $MyInvocation.MyCommand.Definition -Leaf
$XMLFile = $LogPath + $LogFile.split('\.')[-2] + "_diff.xml"
$LogFile = $LogPath + $LogFile.split('\.')[-2] + ".txt"

Export-Clixml -InputObject $ForestInfo $XMLFile

Write-Output $ForestInfo

Write-Output $ForestInfo > $LogFile

