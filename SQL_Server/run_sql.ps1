 <#
        .DESCRIPTION
            Snippet to connect to a SQL Server instance and run some SQL
        .AUTHOR
            Simon Smith
    #>
## Connect to db and execute query

$SQLServer = "MySQLServer" #use Server\Instance for named SQL instances! 
$SQLDBName = "MyDBName"
$SqlQuery = "select * from authors WHERE Name = 'John Simon'"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

$SqlConnection.Close()

clear

$DataSet.Tables[0]