---------------------------------------------------------
-- Oracle linked server query.sql
--
-- Author: Simon Smith
--
-- Purpose: Oracle linked server examples
--
-- Usage:
--
---------------------------------------------------------
/** Get list of Oracle synonyms **/
SELECT * FROM ORCL..SYS.USER_SYNONYMS;

/** Select from Oracle synonym **/
SELECT * FROM OPENQUERY(ORCL,'SELECT * FROM SCOTT.EMPLOYEE');

/** Get count for each table **/

DECLARE @i int
DECLARE @numrows int
DECLARE @syn_table TABLE (RowID int not null primary key identity(1,1), syn_name VARCHAR(32),table_name VARCHAR(32))
DECLARE @result_table TABLE (table_name VARCHAR(32), numrows INT)
DECLARE @vsql VARCHAR(2000)
DECLARE @syn_name VARCHAR(32)
DECLARE @table_name VARCHAR(32)

INSERT @syn_table 
SELECT SYNONYM_NAME, TABLE_NAME FROM ORCL..SYS.USER_SYNONYMS;

SET @i = 1
SET @numrows = (SELECT MAX(RowID) FROM @syn_table)

WHILE (@i <= @numrows)
BEGIN
	SET @syn_name = (SELECT syn_name FROM @syn_table WHERE RowID = @i)
	SET @table_name = (SELECT table_name FROM @syn_table WHERE RowID = @i)
	SET @vsql = 'SELECT ''' + @table_name + ''', numrows FROM OPENQUERY(ORCL,''SELECT COUNT(*) AS numrows FROM SCOTT.' + @syn_name + ''')'
	INSERT @result_table 
	EXEC (@vsql)
    SET @i = @i + 1
END

SELECT * FROM @result_table

/** end of rowcount for each table **/
