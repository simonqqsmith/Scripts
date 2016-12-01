---------------------------------------------------------
-- Table counts.sql
--
-- Author: Simon Smith
--
-- Purpose: Gets row counts using count(*)
--
-- Usage:
--
---------------------------------------------------------
/*** Table counts ***/

CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts 
WHERE table_name like '_RCL%'
ORDER BY 2 DESC
DROP TABLE #counts