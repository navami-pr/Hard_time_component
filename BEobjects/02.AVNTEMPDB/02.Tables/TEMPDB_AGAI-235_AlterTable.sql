/********************************************************************************/
/* FILENAME			:	TEMPDB_AGAI-235_AlterTable.sql							*/
/* VERSION			:	1.0														*/
/* DESCRIPTION		:															*/
/********************************************************************************/
/* PROJECT			:															*/
/**************************DEVELOPMENT HISTORY***********************************/  
/* COMPONENT			: BasInvReports   									    */
/* SCREENCODE			:									     	            */
/***************************DEVELOPMENT HISTORY**********************************/
/* AUTHOR				: NAVAMI												*/
/* DATE					: 11-JUN-2017											*/
/* RTRACK ID			: AGAI-20												*/      
/***************************MODIFICATION HISTORY*********************************/
/* MODIFIED BY                                                                  */
/* DATE                                                                         */
/* DESCRIPTION                                                                  */
/*****************************REVIEW HISTORY ************************************/
/* REVIEWED BY                      :  											*/    
/* NUMBER OF REVIEW DEFECTS         :   										*/
/* REVIEW ID                        :											*/
/* CONFIRMED MOVEMENT TO CONTROLLED SOURCE BY :  								*/    
/********************************************************************************/



IF NOT EXISTS (SELECT 'X' FROM SYS.SYSOBJECTS WHERE NAME='hard_time_comp_tmp')
BEGIN
create TABLE hard_time_comp_tmp
(	

	  htc_GUID								udd_guid,
	  htc_OUINSTANCE						udd_ctxt_ouinstance,	
	  htc_comp_id							udd_txt20,
	  ac_reg_no								udd_txt20,
	  ac_tsn								udd_value,
	  ac_csn								udd_value,
	  ac_Attach_Date                        datetime,
	  htc_part_no							udd_partno,
	  htc_serial_no							udd_txt20,
	  htc_ata_no							udd_partno,
	  htc_part_desc							udd_txt150,
	  PROGRAM_REVISION_NO                   varchar(40),
	  WORKUNIT_NO							varchar(40),
	  htc_task_desc							udd_txt150,
	  comp_pre_val							udd_decimal,
	  htc_parameter							udd_txt20,
	  htc_interval							udd_decimal,
	  htc_time_unit							udd_txt20,
	  htc_ac_usage_val						udd_decimal,
	  htc_due_in_terms_of_ac				udd_decimal,
	  htc_last_performed_date				datetime,
	  htc_last_performed_value				udd_value,
	  htc_next_scheduled_date				datetime,
	  htc_next_scheduled_value				udd_value,
	  htc_remaining_hours					Udd_date,
	  last_Complied_exec					udd_partno,
	  htc_sr_num							int,
	  htc_interval_txt						udd_flag,
	  htc_due_in_terms_of_ac_txt			udd_flag,
	  htc_last_performed_txt				udd_Flag,
	  htc_next_scheduled_txt				udd_flag,
	  htc_remaining_hours_txt				Udd_flag
	)
END

IF EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_ac_usage_val'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ALTER column htc_ac_usage_val udd_value
END

IF EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_last_performed_date'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ALTER column htc_last_performed_date datetime
END

IF EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_next_scheduled_date'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ALTER column htc_next_scheduled_date datetime
END

IF EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='comp_pre_val'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ALTER column comp_pre_val udd_value
END

IF NOT EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_interval_txt'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ADD  htc_interval_txt udd_flag
END


IF NOT EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_due_in_terms_of_ac_txt'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ADD  htc_due_in_terms_of_ac_txt udd_flag
END



IF NOT EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_last_performed_txt'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ADD  htc_last_performed_txt udd_flag
END

IF NOT EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_next_scheduled_txt'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ADD  htc_next_scheduled_txt udd_flag
END

IF NOT EXISTS (SELECT 'X' FROM SYS.OBJECTS OBJ
				INNER JOIN SYS.COLUMNS COL
				ON OBJ.OBJECT_ID=COL.OBJECT_ID
				AND OBJ.NAME='hard_time_comp_tmp'
				AND COL.NAME='htc_remaining_hours_txt'
			)

BEGIN 
ALTER TABLE hard_time_comp_tmp
ADD  htc_remaining_hours_txt udd_flag
END