---------------------------------------------------------
-- set_noarchive.sql
--
-- Author: Simon Smith
--
-- Purpose: Puts Oracle database into NOARCHIVELOG mode
--
-- Usage: @set_noarchive.sql
--
---------------------------------------------------------
SHUTDOWN IMMEDIATE; 
STARTUP MOUNT EXCLUSIVE;
ALTER DATABASE NOARCHIVELOG;
ALTER DATABASE OPEN;
select 'Database '||name||' is in '||log_mode from V$database;
select 'Instance '||instance_name||' is '||status from v$instance;

