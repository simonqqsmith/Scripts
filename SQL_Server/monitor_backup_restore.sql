---------------------------------------------------------
-- Database monitor_backup_restore.sql
--
-- Author: Simon Smith
--
-- Purpose: Reports on backup and restore operations
--
-- Usage:
--
---------------------------------------------------------
SELECT session_id as SPID, command, a.text AS Query, start_time, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time 
FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a 
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE');

SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name,  
   msdb.dbo.backupset.backup_start_date,  
   msdb.dbo.backupset.backup_finish_date, 
   msdb.dbo.backupset.expiration_date, 
   CASE msdb..backupset.type  
       WHEN 'D' THEN 'Database'  
       WHEN 'L' THEN 'Log'  
   END AS backup_type,  
   msdb.dbo.backupset.backup_size,  
   msdb.dbo.backupmediafamily.logical_device_name,  
   msdb.dbo.backupmediafamily.physical_device_name,   
   msdb.dbo.backupset.name AS backupset_name, 
   msdb.dbo.backupset.description 
FROM   msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
WHERE  (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7)  
ORDER BY  
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_finish_date desc;

   select * from sysprocesses order by waittime desc;

   select * from sys.dm_os_wait_stats order by wait_time_ms desc;

   SELECT sqlserver_start_time FROM sys.dm_os_sys_info; 