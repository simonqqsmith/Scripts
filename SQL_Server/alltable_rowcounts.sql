---------------------------------------------------------
-- alltable_rowcounts.sql
--
-- Author: Simon Smith
--
-- Purpose: Quick rowcount of tables in a database using the index count
--
-- Usage:
--
---------------------------------------------------------
--select * from sys.tables

SELECT 
    [TableName] = so.name, 
    [RowCount] = MAX(si.rows) 
FROM 
    sysobjects so, 
    sysindexes si 
WHERE 
    so.xtype = 'U' 
    AND 
    si.id = OBJECT_ID(so.name) 
GROUP BY 
    so.name 
ORDER BY 
    2 DESC