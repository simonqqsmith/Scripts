---------------------------------------------------------
-- Create DROP table script.sql
--
-- Author: Simon Smith
--
-- Purpose: Creates DROP table script
--
-- Usage:
--
---------------------------------------------------------
/*** Create DROP table script *****/

DECLARE @SqlStatement VARCHAR(MAX)
SELECT @SqlStatement = 
    COALESCE(@SqlStatement, '') + 'DROP TABLE [matis].' + QUOTENAME(TABLE_NAME) + ';' + CHAR(13)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'matis'

PRINT @SqlStatement