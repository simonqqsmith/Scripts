 <#
        .DESCRIPTION
            Retrieves SQL server information using SCOM class
        .AUTHOR
            Simon Smith
    #>
    BEGIN{
 $SQLInstance = get-scomclass -Displayname 'SQL DB Engine' | get-scomclassinstance;
 $FTConf = @{Expression={$_.Computer};Label="Server Name"},@{Expression={$_.Instance};Label="Instance Name"};
 }
PROCESS{
ForEach ($i in $SQLInstance){
   [String]$SQLPrincipalName = $i.'[Microsoft.Windows.Computer].PrincipalName';
   [String]$SQLDisplayName = $i.DisplayName;
   [String]$SQLGetPath = $SQLPrincipalName + ";" +$SQLDisplayName;
##   $SQLGetPath;
   $SQLDatabase = Get-SCOMClass -name 'Microsoft.SQLServer.Database' | get-scomclassinstance | select DisplayName, Path, *.Collation, ID | Where Path -eq $SQLGetPath;
##   $SQLDatabase;
ForEach ($j in $SQLDatabase){
   $SQLProperties = @{

    'Computer'=$i.'[Microsoft.Windows.Computer].PrincipalName';

    'InstanceName'=$i.DisplayName;

    'ConnectionString'=$i.'[Microsoft.SQLServer.DBEngine].ConnectionString';

    'Version'=$i.'[Microsoft.SQLServer.DBEngine].Version';

    'Edition'=$i.'[Microsoft.SQLServer.DBEngine].Edition';

    'DatabaseName'=$j.DisplayName;

    'Path'=$j.Path;

    'Collation'=$j.'[Microsoft.SQLServer.Database].Collation'
   }
 ## $SQLHashTable = New-Object PSObject -Property $SQLProperties;
 ## $SQLProperties | select @{Label="Computer";Expression= {$_.Computer}}, @{Label="InstanceName";Expression= {$_.InstanceName}}, @{Label="DatabaseName";Expression= {$_.DatabaseName}}, @{Label="ConnectionString";Expression= {$_.ConnectionString}}, @{Label="Version";Expression= {$_.Version}}, @{Label="Edition";Expression= {$_.Edition}}, @{Label="Collation";Expression= {$_.Collation}}|ft ;
 $SQLProperties | select @{Expression= {$_.Computer}}, @{Expression= {$_.InstanceName}}, @{Expression= {$_.DatabaseName}}, @{Expression= {$_.ConnectionString}}, @{Expression= {$_.Version}}, @{Expression= {$_.Edition}}, @{Expression= {$_.Collation}}|FT -HideTableHeaders -auto | Export-Csv -append C:\scom\db.csv;
  } ## | Export-Csv C:\scom\db.csv
 }
}
##END{
##  $SQLHashTable | select InstanceName,Computer | where InstanceName -eq 'ARCH'| ft -auto;
##  }