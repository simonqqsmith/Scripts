---------------------------------------------------------
-- Database log_ship_monitor_secondary.sql
--
-- Author: Simon Smith
--
-- Purpose: Monitors log shipping secondary database
--
-- Usage:
--
---------------------------------------------------------


select ls.primary_server,ls.primary_database,lsd.restore_delay,

DATEDIFF(mi,lms.last_restored_date,getdate()) as time_since_last_restore,

lms.last_copied_date,lms.last_restored_date,lms.last_copied_file,

lms.last_restored_file,

lsd.disconnect_users,ls.backup_source_directory,

ls.backup_destination_directory,ls.monitor_server

--,lsd.block_size,lsd.buffer_count,lsd.max_transfer_size 

from 

msdb.dbo.log_shipping_secondary ls

join 

msdb.dbo.log_shipping_secondary_databases lsd

on lsd.secondary_id=ls.secondary_id

join

msdb.dbo.log_shipping_monitor_secondary lms

on lms.secondary_id=lsd.secondary_id;

select led.database_name,led.log_time,led.message,led.sequence_number,

led.session_id,led.source

from msdb.dbo.log_shipping_monitor_error_detail led;


select top 10 database_name,log_time,message,session_status

from msdb.dbo.log_shipping_monitor_history_detail

order by log_time desc;