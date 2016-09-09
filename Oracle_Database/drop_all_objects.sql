---------------------------------------------------------
-- drop_all_objects.sql
--
-- Author: Simon Smith
--
-- Purpose: Creates a script to drops all objects for the user *** DO NOT RUN AS SYSTEM USERS ***
--
-- Usage: @drop_all_objects.sql then execute @DoDropObjects.sql after reviewing the output
--
---------------------------------------------------------
set echo off
set pages 0
set head off
set feedback off
set lines 500

spool DoDropObjects.sql
select 'set echo on' from dual;
select 'set feedback on' from dual;
select 'spool dropall.log' from dual;
select 'drop view '||view_name||';' from user_views;
select distinct 'drop sequence '||sequence_name|| ';'from user_sequences;
select distinct 'drop table '||table_name|| ';'from user_tables;
select distinct 'drop procedure '||name|| ';'from user_source where type = 'PROCEDURE';
select distinct 'drop function '||name|| ';'from user_source where type = 'FUNCTION';
select distinct 'drop package '||name|| ';'from user_source where type = 'PACKAGE';
select 'drop synonym '||synonym_name||';' from user_synonyms;
select 'spool off' from dual;
select 'exit;' from dual;
spool off
