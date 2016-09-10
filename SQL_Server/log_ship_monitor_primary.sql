---------------------------------------------------------
-- Database log_ship_monitor_primary.sql
--
-- Author: Simon Smith
--
-- Purpose: Monitors log shipping primary database
--
-- Usage:
--
---------------------------------------------------------
select lmp.primary_server,lp.primary_database,lps.secondary_server,

lps.secondary_database,lp.backup_directory,

lp.backup_share,lp.monitor_server,lp.last_backup_date,

datediff(mi,lp.last_backup_date,getdate()) time_since_last_backup_min,

lp.last_backup_file,lp.backup_retention_period backup_retention_period_min,

lmp.backup_threshold backup_threshold_min,lmp.threshold_alert threshold_alert_min,

lmp.history_retention_period history_retention_period_min

from 

msdb.dbo.log_shipping_primary_databases lp

join 

msdb.dbo.log_shipping_monitor_primary lmp

on 

lp.primary_id=lmp.primary_id

join 

msdb..log_shipping_primary_secondaries lps

on 

lmp.primary_id=lps.primary_id;


select top 10 database_name,log_time,message,session_status

from msdb.dbo.log_shipping_monitor_history_detail

order by log_time desc;

