
/*filename = gaedkhtcp_genera_hr.sql*/
/********************************************************************************/
/* procedure      gaedkhtcp_genera_grd1_gr                                      */
/* description                                                                  */
/********************************************************************************/
/* project            GOAIR                                                     */
/* version              1                                                       */
/********************************************************************************/
/* referenced                                                                   */
/* tables                                                                       */
/********************************************************************************/
/* Component		: bascapplng												*/
/* Activity			: Hard Time Component Report								*/
/* Task				: Hard Time Component Report								*/
/* Procedure		: gaedkhtcp_genera_hr 										*/
/* DescriptiON		: Hard Time Component Report (AGAI-235)						*/
/* development history                                                          */
/********************************************************************************/
/* development history                                                          */
/********************************************************************************/
/* author         NAVAMI                                                        */
/* date           5/29/2017														*/
/********************************************************************************/
/* modIFication history                                                         */
/********************************************************************************/
/* modIFied by                                                                  */
/* date                                                                         */
/* description                                                                  */
/********************************************************************************/

CREATE procedure gaedkhtcp_genera_grd1_gr
	@ctxt_language                	udd_ctxt_language,
	@ctxt_ouinstance              	udd_ctxt_ouinstance,
	@ctxt_role                    	udd_ctxt_role,
	@ctxt_service                 	udd_ctxt_service,
	@ctxt_user                    	udd_ctxt_user,
	@ctxt_base_component           	udd_desc40,
	@ctxt_base_activity            	udd_desc40,
	@ctxt_base_ou                  	udd_ctxt_ouinstance,
	@ctxt_base_ui                  	udd_ctxt_component,
	@ctxt_extn_based_on            	udd_ctxt_component,
	@ac_model                      	udd_desc40,
	@ac_model_hdn                  	udd_desc40,
	@ac_reg_number                 	udd_documentno,
	@hidden_int                    	udd_int,
	@m_errorid                    	int output --to return execution status
AS
BEGIN

	SET NOCOUNT ON

	SET @m_errorid = 0

	select @ctxt_role                    	= ltrim(rtrim(@ctxt_role))
	select @ctxt_service                 	= ltrim(rtrim(@ctxt_service))
	select @ctxt_user                    	= ltrim(rtrim(@ctxt_user))
	select @ctxt_base_component           	= ltrim(rtrim(@ctxt_base_component))
	select @ctxt_base_activity            	= ltrim(rtrim(@ctxt_base_activity))
	select @ctxt_base_ui                  	= ltrim(rtrim(@ctxt_base_ui))
	select @ctxt_extn_based_on            	= ltrim(rtrim(@ctxt_extn_based_on))
	select @ac_model                      	= ltrim(rtrim(@ac_model))
	select @ac_model_hdn                  	= ltrim(rtrim(@ac_model_hdn))
	select @ac_reg_number                 	= ltrim(rtrim(@ac_reg_number))

	--null checking
	IF @ac_model= '~#~' Or @ac_model ='' Or @ac_model is null
		SELECT @ac_model = '%'
	
	if @ac_model_hdn= '~#~'
		select @ac_model_hdn = null

	IF @ac_reg_number= '~#~' Or @ac_reg_number='' Or @ac_reg_number is null
		SELECT @ac_reg_number = '%'

	if @hidden_int=-915
		select @hidden_int = null




	DECLARE		 @guid				udd_guid
	DECLARE      @currentdate       datetime	
	DECLARE		 @no				INT = 0

	DECLARE @count			INT = 0
	DECLARE @id				INT = 1
	DECLARE @ac_num			udd_Aircraftnumber
	DECLARE @ac_attach_dt	datetime

	DECLARE 
			@Dateformat_Tmp				 udd_dtformat,
            @DateformatInt_Tmp			 udd_dtformatint,
            @TimeFormat_Out              udd_timeformat,
            @TimeFormatInt_Out           udd_timeformatint,
            @DtFormatInt				 udd_seqno
	EXEC BASUPF_DATETIME_FORMAT_FET_SP
            @ctxt_ouinstance,
            @ctxt_language, 
			@ctxt_user, 
			@ctxt_ouinstance, 
            'bascapplng', 
			@DateFormatInt_TMp      OUTPUT, 
			@DateFormat_TMp         OUTPUT, 
			@TimeFormatInt_out      OUTPUT, 
			@TimeFormat_out         OUTPUT
    SELECT	@DtFormatInt		= dbo.FetchSqlDtFormat(@DateFormat_TMp)

	SELECT		 @guid			=		NEWID()
	select		 @currentdate	=    dbo.ras_getdate(@ctxt_ouinstance)

	DECLARE	@Aircraft_Reg		Table (Aircraft_no	udd_Aircraftnumber,
									Model_no		udd_model,
									TSN				udd_value, 
									CSN				udd_value)

	INSERT INTO @Aircraft_Reg (Aircraft_no,Model_no)
	SELECT		ACI_AIRCRAFT_REG_NO,ACI_MDL_MODEL
	FROM		AC_ACI_AIRCRAFT_INFO WITH (NOLOCK)
	WHERE		aci_ouinstance			=		@ctxt_ouinstance
	and			ACI_AIRCRAFT_REG_NO		like	@ac_reg_number
	AND			ACI_MDL_MODEL			like	@ac_model

	UPDATE		@Aircraft_Reg
	SET			TSN = ACPRC_PRESENT_VALUE
	FROM		AC_ACPRC_AC_RNGCON_PRM_LIST WITH (NOLOCK)
	WHERE		ACPRC_OUINSTANCE			= @ctxt_ouinstance
	AND			ACPRC_AIRCRAFT_REG_NO		= Aircraft_no
	AND			ACPRC_PARAM_CODE			='FH'

	UPDATE		@Aircraft_Reg
	SET			CSN = ACPRC_PRESENT_VALUE
	FROM		AC_ACPRC_AC_RNGCON_PRM_LIST WITH (NOLOCK)
	WHERE		ACPRC_OUINSTANCE		= @ctxt_ouinstance
	AND			ACPRC_AIRCRAFT_REG_NO	= Aircraft_no
	AND			ACPRC_PARAM_CODE			='FC'

		INSERT INTO   hard_time_comp_tmp ( 
					  ac_reg_no,														htc_part_no ,									htc_serial_no,				
					  htc_comp_id,														htc_GUID,										htc_OUINSTANCE,
					  htc_interval,														htc_last_performed_value,						htc_next_scheduled_value,	 
					  htc_parameter,													PROGRAM_REVISION_NO,							WORKUNIT_NO,
					  htc_last_performed_date,											htc_next_scheduled_date,						htc_time_unit, 
					  ac_Attach_Date,													ac_tsn,											ac_csn)
					  																													 
		SELECT		CFGACH_AIRCRAFT_REG_NO,												ac.CMPID_PART_NO,								ac.CMPID_SERIAL_NO,	    
					cfg.CFGACH_COMPONENT_ID,											@guid,											@ctxt_ouinstance,
					CUS_INTERVAL	,													C.CUS_LAST_PERFORMED_VALUE,						CUS_NEXT_PERFORMED_VALUE,
					C.CUS_PARAMETER, 													B.CPD_PROGRAM_REVISION_NO,						B.CPD_WORKUNIT,	
					NULL,																NULL,											NULL,
					cfg.CFGACH_ATTACH_DATE,												TSN,											CSN
		FROM		 @Aircraft_Reg
		JOIN		CFG_CFGACH_ACTIVE_POS_DTL_VW cfg  WITH(NOLOCK)
		ON			CFGACH_AIRCRAFT_REG_NO = Aircraft_no
		JOIN		AC_CMPID_Component_id_info ac
		on			CFGACH_OUINSTANCE = CMPID_OUINSTANCE	
		AND			CFGACH_COMPONENT_ID = CMPID_COMPONENT_ID
		JOIN		  cmp_mpd_maint_process_det    cmp  WITH(NOLOCK)
		ON			  cmp.MPD_PART					 =       ac.CMPID_PART_NO  
		AND			  cmp.MPD_PART_CREATED_OU		 =       ac.CMPID_PART_OU
		AND			  cmp.MPD_MAINTAIN_PROCESS       =       'HT' 
		JOIN		  CMP_CPH_COMP_PRG_HDR				D	WITH(NOLOCK)
		ON			  D.CPH_OUINSTANCE				 =	cfg.CFGACH_OUINSTANCE
		AND			  D.CPH_COMPONENT				 =	cfg.CFGACH_COMPONENT_ID
		AND			CPH_PROGRAM_STATUS	='A'
		JOIN		  CMP_CPD_COMP_PRG_DETAIL			B WITH (NOLOCK)
		ON			  B.CPD_COMPONENT				 =	D.CPH_COMPONENT
		AND			  B.CPD_OUINSTANCE				 =	D.CPH_OUINSTANCE
		AND			  B.CPD_PROGRAM_REVISION_NO      =   D.CPH_PROGRAM_REVISION_NO
		JOIN		  CMP_CUS_COMP_UB_SCH					C WITH (NOLOCK)
		ON			  B.CPD_COMPONENT				=	C.CUS_COMPONENT		
		AND			  B.CPD_OUINSTANCE				=	C.CUS_OUINSTANCE
		AND			  B.CPD_PROGRAM_REVISION_NO		=	C.CUS_PROGRAM_REVISION_NO
		AND			  B.CPD_WORKUNIT_LINE_NO		=	C.CUS_WORKUNIT_LINENO
		WHERE         B.CPD_WORKUNIT_STATUS		=	'A'
		AND			CFGACH_OUINSTANCE= @ctxt_ouinstance
		
		INSERT INTO   hard_time_comp_tmp ( 
					  ac_reg_no,														htc_part_no ,									 htc_serial_no,				
					  htc_comp_id,														htc_GUID,										 htc_OUINSTANCE,
					  htc_interval,														htc_last_performed_value,						 htc_next_scheduled_value,	 
					  htc_parameter,													PROGRAM_REVISION_NO,							  WORKUNIT_NO,
					  htc_last_performed_date,											htc_next_scheduled_date,						 htc_time_unit, 
					  ac_Attach_Date,													ac_tsn,											ac_csn)
		
		SELECT			CFGACH_AIRCRAFT_REG_NO,											cfg.CFGACH_POS_PART_NO,							cfg.CFGACH_SERIAL_NO,	    
						cfg.CFGACH_COMPONENT_ID,											@guid,											@ctxt_ouinstance,
					   C.CDS_INTERVAL,													null,											null,          
					  null, 															B.CPD_PROGRAM_REVISION_NO,						B.CPD_WORKUNIT,
					 CDS_LAST_PERFORMED_DATE ,											CDS_NEXT_SCHEDULED_DATE ,						CDS_TIMEUNIT,		
						cfg.CFGACH_ATTACH_DATE,											TSN,											CSN
		FROM		  @Aircraft_Reg
		JOIN		CFG_CFGACH_ACTIVE_POS_DTL_VW cfg  WITH(NOLOCK)
		ON			CFGACH_AIRCRAFT_REG_NO = Aircraft_no
		JOIN		AC_CMPID_Component_id_info ac
		on			CFGACH_OUINSTANCE = CMPID_OUINSTANCE	
		AND			CFGACH_COMPONENT_ID = CMPID_COMPONENT_ID
		JOIN		  cmp_mpd_maint_process_det    cmp  WITH(NOLOCK)
		ON			  cmp.MPD_PART					 =       ac.CMPID_PART_NO  
		AND			  cmp.MPD_PART_CREATED_OU		 =       ac.CMPID_PART_OU
		AND			  cmp.MPD_MAINTAIN_PROCESS       =       'HT' 
		JOIN		  CMP_CPH_COMP_PRG_HDR				D	WITH(NOLOCK)
		ON			  D.CPH_OUINSTANCE				 =	cfg.CFGACH_OUINSTANCE
		AND			  D.CPH_COMPONENT				 =	cfg.CFGACH_COMPONENT_ID
		AND			  CPH_PROGRAM_STATUS	='A'
		JOIN		  CMP_CPD_COMP_PRG_DETAIL			B  WITH(NOLOCK)
		ON			  B.CPD_COMPONENT				 =	D.CPH_COMPONENT
		AND			  B.CPD_OUINSTANCE				 =	D.CPH_OUINSTANCE
		AND			  B.CPD_PROGRAM_REVISION_NO      =   D.CPH_PROGRAM_REVISION_NO
		JOIN		  CMP_CDS_COMP_DB_SCH					C WITH (NOLOCK)
		ON			  B.CPD_COMPONENT				 =	C.CDS_COMPONENT		
		AND			  B.CPD_OUINSTANCE				 =	C.CDS_OUINSTANCE
		AND			  B.CPD_PROGRAM_REVISION_NO		 =	C.CDS_PROGRAM_REVISION_NO
		AND			  B.CPD_WORKUNIT_LINE_NO		 =	C.CDS_WORKUNIT_LINENO
		WHERE         B.CPD_WORKUNIT_STATUS		=	'A'
		AND			CFGACH_OUINSTANCE= @ctxt_ouinstance


		----UPDATING TASK DESCRIPTION

		UPDATE		A	
		SET			A.htc_task_desc					=	B.TSK_DESCRIPTION,
					A.htc_ata_no					=   B.TSK_ATA_NO
		FROM		hard_time_comp_tmp					A   WITH(NOLOCK)	
		JOIN		BAS_TSK_TSK_TASK_MASTER				B	WITH(NOLOCK)
		ON			B.TSK_TASK_NO					=	A.WORKUNIT_NO
		AND			B.TSK_OUINSTANCE               =	A.htc_OUINSTANCE
		WHERE		A.htc_GUID						=	@GUID
		AND			A.htc_OUINSTANCE                =   @ctxt_ouinstance

		--UPDATING PART DESCRIPTION
		UPDATE    temp
		SET       temp.htc_part_desc				=	PM.PRCRL_PART_DESC
		FROM	  hard_time_comp_tmp temp				WITH(NOLOCK)
		JOIN      PRT_PRCRL_CENTRALREFLIST_INFO			PM	WITH(NOLOCK)
		ON        temp.htc_part_no					=	PM.PRCRL_PART_NO
		AND		  temp.htc_OUINSTANCE				=	PM.PRCRL_CREATED_OUINSTANCE
		WHERE	  temp.htc_GUID						=	@GUID
		AND		  temp.htc_OUINSTANCE               =   @ctxt_ouinstance

		UPDATE	hard_time_comp_tmp
		SET		comp_pre_val						=	 CMPRC_TSN
		FROM	AC_CMPRC_CMP_RNGCON_PRMLIST
		WHERE	CMPRC_OUINSTANCE					= htc_OUINSTANCE
		AND		CMPRC_COMPONENT_ID	= htc_comp_id
		AND		CMPRC_PARAM_CODE= htc_parameter
		AND		htc_GUID					=	@GUID					
		AND		htc_OUINSTANCE               =   @ctxt_ouinstance

		
		

		----UPDATING Aircraft Usage Value at Component Installation
		SELECT @no =0

		UPDATE	hard_time_comp_tmp 
		SET		htc_sr_num = @no ,
				@no = @no+1
		FROM	hard_time_comp_tmp		 WITH(NOLOCK)		
		WHERE	htc_GUID				=	@GUID					
		AND		htc_OUINSTANCE			=	@ctxt_ouinstance

		SELECT @count = @no
		--SELECT @no = 1


	    WHILE @id <= @count
		BEGIN
		
				SELECT @ac_num		 = ac_reg_no ,
						@ac_attach_dt = ac_Attach_Date
				FROM hard_time_comp_tmp 
				WHERE	htc_GUID				=	@GUID					
				AND		htc_OUINSTANCE			=	@ctxt_ouinstance
				AND	htc_sr_num = @id
					

					EXEC Ac_Derive_Param_value_SP
					@ctxt_ouinstance,
					@ctxt_user,
					@ctxt_language,
					'BASAIRCRAFT',
					@ctxt_ouinstance,
					'A',
					@ctxt_ouinstance,
					@ac_num,
					null,
					@ac_attach_dt,
					@GUID,
					null,
					null,
					null
	    
		UPDATE	A 
		SET		A.htc_ac_usage_val			=	ISNULL(B.PRMVAL_TSN,0)
		FROM	hard_time_comp_tmp				A  WITH(NOLOCK) 	
		JOIN    ac_prmval_param_value_tmp       B  WITH(NOLOCK)
		ON		B.PRMVAL_AIRCRAFT_NO			=	A.ac_reg_no   
		AND     B.PRMVAL_PARAMCODE     			=   A.htc_parameter
		AND     B.PRMVAL_ACTUALDATE				=   A.ac_Attach_Date	
		WHERE	A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		A.htc_GUID					=	@guid

		
		UPDATE	A 
		SET		A.htc_ac_usage_val			= 0 
		FROM	hard_time_comp_tmp				A  WITH(NOLOCK) 	
		WHERE	A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		A.htc_GUID					=	@guid
		AND		htc_parameter				= @ac_num
		AND		ac_Attach_Date				= @ac_attach_dt
		AND		htc_ac_usage_val is null

		DELETE FROM ac_prmval_param_value_tmp
		WHERE  prmval_guid = @GUID

		SELECT @id = 0

		SELECT @id		 = MIN(htc_sr_num)
				FROM hard_time_comp_tmp			WITH(NOLOCK)
				WHERE	htc_GUID				=	@GUID					
				AND		htc_OUINSTANCE			=	@ctxt_ouinstance
				AND	htc_ac_usage_val is NULL
				AND	htc_parameter IS NOT NULL
		
		IF	@id = 0
			set @id = @count + 1
		
	END

		----UPDATING Due in terms of A/C usage
		UPDATE	A 
		SET		A.htc_interval_txt		=	DBO.Cmn_Time_FromDecToUsr_Fmt_Fn(@ctxt_ouinstance, @ctxt_user, @ctxt_language, NULL, 'Bascapplng' , htc_interval, htc_parameter)
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		htc_interval  IS NOT NULL

		UPDATE	A 
		SET		A.htc_ac_usage_val		=	DBO.Cmn_Time_FromDecToUsr_Fmt_Fn(@ctxt_ouinstance, @ctxt_user, @ctxt_language, NULL, 'Bascapplng' , htc_ac_usage_val, htc_parameter)
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		htc_ac_usage_val  IS NOT NULL

		UPDATE	A 
		SET		A.htc_due_in_terms_of_ac_txt		=	ISNULL(A.htc_ac_usage_val,0) +  ISNULL(A.htc_interval,0),
				A.htc_ac_usage_val              =   CASE WHEN A.htc_ac_usage_val = 0 THEN null ELSE A.htc_ac_usage_val END
		FROM	hard_time_comp_tmp					A WITH(NOLOCK)
		WHERE	A.htc_GUID						=	@GUID					
		AND		A.htc_OUINSTANCE				=	@ctxt_ouinstance

		UPDATE	A 
		SET		A.htc_due_in_terms_of_ac		=	 CASE WHEN A.htc_due_in_terms_of_ac = 0 THEN null ELSE A.htc_due_in_terms_of_ac END
		FROM	hard_time_comp_tmp					A WITH(NOLOCK)
		WHERE	A.htc_GUID						=	@GUID					
		AND		A.htc_OUINSTANCE				=	@ctxt_ouinstance

		UPDATE	A 
		SET		A.htc_time_unit                 =   B.CMP_PARAM_DESC
		FROM	hard_time_comp_tmp					A WITH(NOLOCK)
		JOIN    CMP_PARAMETER_DETAILS               B WITH(NOLOCK)
		ON      CMP_PARAM_CODE					=   A.htc_time_unit
		AND     CMP_PARAM_TYPE					=	'TIMEUNIT'
		WHERE	A.htc_GUID						=	@GUID					
		AND		A.htc_OUINSTANCE				=	@ctxt_ouinstance

		
		-----UPDATING Remaining value
		UPDATE	A 
		SET		A.htc_remaining_hours		=	htc_next_scheduled_value - ISNULL(A.comp_pre_val,0) 
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		htc_next_scheduled_value  IS NOT NULL

		

		UPDATE	A 
		SET		A.htc_next_scheduled_txt		=	 DBO.Cmn_Time_FromDecToUsr_Fmt_Fn(@ctxt_ouinstance, @ctxt_user, @ctxt_language, NULL, 'Bascapplng' , htc_next_scheduled_value, htc_parameter)
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND     htc_parameter               = 'FH'
		AND		htc_next_scheduled_value  IS NOT NULL

		 UPDATE	A 
		SET		A.htc_last_performed_txt		=	 DBO.Cmn_Time_FromDecToUsr_Fmt_Fn(@ctxt_ouinstance, @ctxt_user, @ctxt_language, NULL, 'Bascapplng' , htc_last_performed_value, htc_parameter)
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND     htc_parameter               = 'FH'
		AND		htc_last_performed_value  IS NOT NULL
		
		
		UPDATE	A 
		SET		A.comp_pre_val		=	DBO.Cmn_Time_FromDecToUsr_Fmt_Fn(@ctxt_ouinstance, @ctxt_user, @ctxt_language, NULL, 'Bascapplng' , comp_pre_val, htc_parameter)
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND     htc_parameter               = 'FH'
		AND		comp_pre_val  IS NOT NULL		

		

		UPDATE	A 
		SET		A.htc_remaining_hours_txt		=	DBO.Cmn_Time_FromDecToUsr_Fmt_Fn(@ctxt_ouinstance, @ctxt_user, @ctxt_language, NULL, 'Bascapplng' , htc_remaining_hours, htc_parameter)
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND     htc_parameter               = 'FH'
		AND		htc_next_scheduled_value  IS NOT NULL

		


		UPDATE	A 
		SET		A.htc_due_in_terms_of_ac_txt		=	DBO.Cmn_Time_FromDecToUsr_Fmt_Fn(@ctxt_ouinstance, @ctxt_user, @ctxt_language, NULL, 'Bascapplng' , htc_due_in_terms_of_ac, htc_parameter)
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND     htc_parameter               = 'FH'
		AND		htc_due_in_terms_of_ac  IS NOT NULL
		
		
		
		UPDATE	A 
		SET		A.htc_next_scheduled_txt	=	Convert(VARCHAR(11),htc_next_scheduled_date,@DtFormatInt)+'##'
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		htc_next_scheduled_date  IS NOT NULL

		-----UPDATING Remaining hours
		UPDATE	A 
		SET		--A.htc_remaining_hours		=	DATEDIFF(dd,htc_next_scheduled_date , GETDATE())
		        A.htc_remaining_hours_txt		=	dbo.Cmn_Rem_days_format_fn (@currentdate,htc_next_scheduled_date,@ctxt_ouinstance,@ctxt_language),
				A.htc_parameter				=  'Cal'
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		htc_next_scheduled_date  IS NOT NULL
		
		UPDATE	A 
		SET		A.htc_last_performed_txt		=	Convert(VARCHAR(11),htc_last_performed_date,@DtFormatInt)+'##'
		FROM	hard_time_comp_tmp			A	
		WHERE	A.htc_GUID					=	@GUID					
		AND		A.htc_OUINSTANCE			=	@ctxt_ouinstance
		AND		htc_last_performed_date  IS NOT NULL


		;WITH SQLCTE(OU,COMP_No,WU_no, Comp_date)
		AS( SELECT CMPHIS_OUINSTANCE,CMPHIS_COMPONENT_NO,CMPHIS_WU_NO, MAX(CMPHIS_COMPLIANCE_DATE)
		FROM	hard_time_comp_tmp   WITH(NOLOCK)
		JOIN	MP_CMPHIS_WUS_CMPL_HISTORY WITH(NOLOCK)
		ON		CMPHIS_OUINSTANCE	= htc_OUINSTANCE
		AND		CMPHIS_COMPONENT_NO	= htc_comp_id
		AND		CMPHIS_WU_NO		= WORKUNIT_NO
		WHERE	htc_GUID			=	@GUID					
		AND		htc_OUINSTANCE		=	@ctxt_ouinstance
		GROUP BY CMPHIS_OUINSTANCE,CMPHIS_COMPONENT_NO,CMPHIS_WU_NO)

		UPDATE	Tmp
		SET		last_Complied_exec	= CMPHIS_DOCUMENT_NO
		FROM	hard_time_comp_tmp Tmp	 WITH(NOLOCK)
		JOIN	SQLCTE					 WITH(NOLOCK)
		ON		OU					= htc_OUINSTANCE
		AND		COMP_No				= htc_comp_id
		AND		WU_no				= WORKUNIT_NO	
		JOIN	MP_CMPHIS_WUS_CMPL_HISTORY	 WITH(NOLOCK)
		ON		CMPHIS_OUINSTANCE	= htc_OUINSTANCE
		AND		CMPHIS_COMPONENT_NO	= htc_comp_id
		AND		CMPHIS_WU_NO		= WORKUNIT_NO
		AND		CMPHIS_COMPLIANCE_DATE = Comp_date
		WHERE	htc_GUID			=	@GUID					
		AND		htc_OUINSTANCE		=	@ctxt_ouinstance	

	/*
	--Errors
	*/
			
		
	--OutputList
	Select 
	null																			'DUMMYS_DTL1',
	null																			'DUMMYS_DTL2', 
	null																			'DUMMYS_DTL3',
	null																			'DUMMYS_DTL4',
	null																			'DUMMYS_DTL5',
	Convert(Numeric(13,2) ,ac_tsn)													'htc_tcn',
	Convert(Numeric(13,2) ,ac_csn)													'htc_csn',
	last_Complied_exec																'htc_last_Complied_exec',
	ac_reg_no																		'htc_ac_reg_no',
	Convert(Numeric(13,2) ,htc_ac_usage_val)										'HTC_AC_USAGE_VAL',
	htc_ata_no																		'HTC_ATA_NO',
	Convert(Numeric(13,2) ,htc_due_in_terms_of_ac_txt)								'HTC_DUE_IN_TERMS_OF_AC',
	htc_interval_txt																	'HTC_INTERVAL',
	htc_last_performed_txt															'HTC_LAST_PERFORMED_DATE',
	htc_last_performed_value														'HTC_LAST_PERFORMED_VALUE',
	htc_next_scheduled_txt															'HTC_NEXT_SCHEDULED_DATE',
	htc_next_scheduled_value														'HTC_NEXT_SCHEDULED_VALUE',
	ISNULL(htc_time_unit,htc_parameter)												'HTC_PARAMETER',
	htc_part_desc																	'HTC_PART_DESC',
	htc_part_no																		'HTC_PART_NO',
	htc_remaining_hours_txt															'HTC_REMAINING_HOURS',
	htc_serial_no																	'HTC_SERIAL_NO',
	htc_sr_num																		'HTC_SR_NO',
	htc_task_desc																	'HTC_TASK_DESC',
	htc_time_unit																	'HTC_TIME_UNIT',	
	Convert(Numeric(13,2) ,comp_pre_val)											'DUMMYS_DTL'

	FROM	hard_time_comp_tmp				WITH(NOLOCK)
	WHERE   htc_OUINSTANCE				=	@ctxt_ouinstance
	AND		htc_GUID					=	@GUID
	ORDER BY htc_sr_num,htc_comp_id,htc_part_no,htc_serial_no,ac_reg_no

	DELETE 
	FROM	hard_time_comp_tmp					
	WHERE   htc_OUINSTANCE				=	@ctxt_ouinstance
	AND		htc_GUID					=	@GUID 

	DELETE 
	FROM	ac_prmval_param_value_tmp	
	WHERE   prmval_guid = @GUID


	SET NOCOUNT OFF

END






	   