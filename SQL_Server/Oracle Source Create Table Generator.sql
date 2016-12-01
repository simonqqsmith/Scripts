---------------------------------------------------------
-- Oracle Source Create Table Generator.sql
--
-- Author: Simon Smith
--
-- Purpose: Generates create table script for SQL Server from an Oracle source access by synonyms
--
-- Usage:
--
---------------------------------------------------------
/******* Oracle Source Create Table Generator ********/
DECLARE @i int
DECLARE @numrows int
DECLARE @vsql VARCHAR(max)
DECLARE @syn_table TABLE (RowID int not null primary key identity(1,1), syn_name VARCHAR(32),table_name VARCHAR(32), table_owner VARCHAR(32))
DECLARE @syn_name VARCHAR(32)
DECLARE @table_name VARCHAR(32)
DECLARE @schema_name VARCHAR(32)
DECLARE @j int
DECLARE @jnumrows int
DECLARE @csql VARCHAR(max)
DECLARE @target_schema VARCHAR(32)

SET @target_schema = 'ORCL';

CREATE TABLE #result_table (thesql VARCHAR(max))

INSERT @syn_table 
SELECT SYNONYM_NAME, TABLE_NAME, table_owner FROM ORCL..SYS.USER_SYNONYMS;

SET @i = 1
SET @numrows = (SELECT MAX(RowID) FROM @syn_table)

WHILE (@i <= @numrows)
BEGIN
	-- set variables for within table loop
	SET @syn_name = (SELECT syn_name FROM @syn_table WHERE RowID = @i)
	SET @table_name = (SELECT table_name FROM @syn_table WHERE RowID = @i)
	SET @schema_name = (SELECT table_owner FROM @syn_table WHERE RowID = @i)
	SET @vsql = ''
	SET @csql = ''
	-- reset column loop
	CREATE TABLE #col_table (RowID int not null primary key identity(1,1), colsql VARCHAR(max))
	INSERT #col_table 
	SELECT column_name + ' ' + 
			(CASE 
				WHEN data_type = 'BFILE' THEN 'VARBINARY(MAX)'
				WHEN data_type = 'BLOB' THEN 'VARBINARY(MAX)'
				WHEN data_type = 'CHAR' THEN 'CHAR'
				WHEN data_type = 'CLOB' THEN 'VARCHAR(MAX)'
				WHEN data_type = 'DATE' THEN 'DATETIME'
				WHEN data_type = 'FLOAT' THEN 'FLOAT'
				WHEN data_type = 'INT' THEN 'NUMERIC(38)'
				WHEN data_type = 'INTERVAL' THEN 'DATETIME'
				WHEN data_type = 'LONG' THEN 'VARCHAR(MAX)'
				WHEN data_type = 'LONG RAW' THEN 'IMAGE'
				WHEN data_type = 'NCHAR' THEN 'NCHAR'
				WHEN data_type = 'NCLOB' THEN 'NVARCHAR(MAX)'
				WHEN data_type = 'NUMBER' THEN 'FLOAT'
				WHEN data_type = 'NVARCHAR2' THEN 'NVARCHAR'
				WHEN data_type = 'RAW' THEN 'VARBINARY'
				WHEN data_type = 'REAL' THEN 'FLOAT'
				WHEN data_type = 'ROWID' THEN 'CHAR(18)'
				WHEN data_type = 'TIMESTAMP' THEN 'DATETIME'
				WHEN data_type = 'TIMESTAMP WITH TIME ZONE' THEN 'VARCHAR(37)'
				WHEN data_type = 'TIMESTAMP WITH LOCAL TIME ZONE' THEN 'VARCHAR(37)'
				WHEN data_type = 'UROWID' THEN 'CHAR(18)'
				WHEN data_type = 'VARCHAR2' THEN 'VARCHAR'
			ELSE data_type
			END) +
			(CASE WHEN data_type = 'RAW' THEN '(' + CAST(data_length AS VARCHAR(10)) + ')'
			WHEN data_type LIKE '%CHAR%' THEN '(' + CAST(data_length AS VARCHAR(10)) + ')'
			ELSE ''
			END) FROM ORCL..SYS.ALL_TAB_COLS WHERE owner = @schema_name and table_name = @table_name
	SET @j = 1
	SET @jnumrows = (SELECT MAX(RowID) FROM #col_table)

	SET @csql = 'CREATE TABLE ' + @target_schema + '.'+ @table_name + ' ('+ CHAR(13)+CHAR(10)
	-- column loop
	WHILE (@j <= @jnumrows)
	BEGIN
		IF @j > 1 
		SET @csql = @csql + ',';

		SET @csql = @csql + (SELECT colsql FROM #col_table WHERE RowID = @j) 
		SET @csql = @csql + CHAR(13)+CHAR(10)
		SET @j = @j + 1
	END; -- end column loop
	SET @csql = @csql + ');'
	SET @vsql = @vsql + @csql
	SET @vsql = @vsql + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + ''
	INSERT INTO #result_table VALUES (@vsql) 
    SET @i = @i + 1
	DROP TABLE #col_table
END; -- end table loop
-- get results
SELECT thesql FROM #result_table
DROP TABLE #result_table
-- END of script