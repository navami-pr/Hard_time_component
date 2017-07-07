/*filename = gaedkhtcp_genera_hr.sql*/
/********************************************************************************/
/* procedure      gaedkhtcp_genera_hr                                           */
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

CREATE procedure gaedkhtcp_genera_hr
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

	DECLARE	@COMPCODE_TMP				  VARCHAR(10)
	DECLARE	@COMPNAME_TMP				  VARCHAR(40)
	DECLARE	@location_tmp				  VARCHAR(200)



	SELECT @ctxt_role                    	= ltrim(rtrim(@ctxt_role))
	SELECT @ctxt_service                 	= ltrim(rtrim(@ctxt_service))
	SELECT @ctxt_user                    	= ltrim(rtrim(@ctxt_user))
	SELECT @ctxt_base_component           	= ltrim(rtrim(@ctxt_base_component))
	SELECT @ctxt_base_activity            	= ltrim(rtrim(@ctxt_base_activity))
	SELECT @ctxt_base_ui                  	= ltrim(rtrim(@ctxt_base_ui))
	SELECT @ctxt_extn_based_on            	= ltrim(rtrim(@ctxt_extn_based_on))
	SELECT @ac_model                      	= ltrim(rtrim(@ac_model))
	select @ac_model_hdn                  	= ltrim(rtrim(@ac_model_hdn))
	SELECT @ac_reg_number                 	= ltrim(rtrim(@ac_reg_number))

	--null checking


	IF @ac_model= '~#~'
		SELECT @ac_model = null

	if @ac_model_hdn= '~#~'
		select @ac_model_hdn = null

	IF @ac_reg_number= '~#~'
		SELECT @ac_reg_number = null

	IF @hidden_int=-915
		SELECT @hidden_int = null
	


	DECLARE		 @guid				udd_guid
	DECLARE		 @CSN				udd_value
	DECLARE		 @TSN				udd_value
	DECLARE      @currentdate       udd_datetime1
	DECLARE		 @hdrdate                 udd_datetime1	
	DECLARE      @ac_num            udd_documentno
	SELECT		 @guid		=		NEWID()



	--ERROR

		IF @ac_reg_number IS NOT NULL AND @ac_model IS NULL
			
				BEGIN
					IF  not EXISTS (SELECT 'X' 
						   FROM	 AC_ACI_AIRCRAFT_INFO WITH(NOLOCK)
						   WHERE ACI_AIRCRAFT_REG_NO		= @ac_reg_number
						   ) 
			BEGIN
						  RAISERROR('Please Enter Valid Aircraft Reg #',16,1)
						  RETURN
			END
		END
	
		IF @ac_reg_number IS NOT NULL AND  @ac_model IS NOT NULL
				BEGIN
					IF  not EXISTS (SELECT 'X' 
						   FROM	 AC_ACI_AIRCRAFT_INFO WITH(NOLOCK)
						   WHERE ACI_MDL_MODEL   = @ac_model
						   and   ACI_AIRCRAFT_REG_NO		= @ac_reg_number
						   ) 
			BEGIN
						  RAISERROR('Please Enter Valid Aircraft Reg #',16,1)
						  RETURN
			END
			END
		IF @ac_reg_number IS NULL AND  @ac_model IS NULL
		BEGIN
				RAISERROR('Please Enter Valid Aircraft Reg # or Aircraft Model',16,1)
		END



		SELECT 	@COMPCODE_TMP	=	 company_code  
		FROM	EMOD_OU_MST_VW	 WITH (NOLOCK)
		WHERE	ou_id	=	@ctxt_ouinstance	

		SELECT 	@COMPNAME_TMP		=  LTRIM(RTRIM(COMPANY_NAME)) ,
				@location_tmp		= LTRIM(RTRIM(address1))+','+ CHAR(13) + ISNULL(address2 + ',','') + ISNULL(address3 + CHAR(13),'') +
									  CASE WHEN ISNULL((LTRIM(RTRIM(CITY))) ,'') = '' THEN '' ELSE CITY + Char(13) END +
									  CASE WHEN ISNULL((LTRIM(RTRIM(state))) ,'') = '' THEN '' ELSE state + '-'  END +
									  CASE WHEN ISNULL(zip_code,'') = '' THEN '' ELSE zip_code+ ','+ Char(13) END +
									  CASE WHEN UPPER(ISNULL(LTRIM(RTRIM(country)),'')) = '' THEN  '' ELSE UPPER(country) + '.'  END  
									  
		FROM   EMOD_COMPANY_MST WITH (NOLOCK)     
		WHERE   company_code  = LTRIM(RTRIM(@COMPCODE_TMP))

		SELECT  @Location_tmp	=	REPLACE(@location_tmp,',,',',')
		
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
	SELECT @currentdate			= dbo.ras_getdate(@ctxt_ouinstance)	
	SELECT @hdrdate				   = Convert(Date , @currentdate)

	/*
	--Errors
	*/

	/*
	--OutputList
	SELECT 
	null	'AC_MODEL',
	null	'AC_REG_NUMBER',
	null	'AIRCRAFT_REG_NO_HDR',
	null	'CSN_HDR',
	null	'DUMMY_HDR',
	null	'DUMMY_HDR2',
	null	'DUMMY_HDR3',
	null	'DUMMY_HDR4',
	null	'DUMMY_HDR5',
	null	'DUMMY_HDR6',
	null	'HIDDEN_INT',
	null	'HTC_ADD1_HDR',
	null	'HTC_ADD2_HDR',
	null	'RPT_GEN_DATE_HDR',
	null	'TSN_HDR'	*/

	SELECT 
	@ac_model	'AC_MODEL',
	@ac_reg_number	'AC_REG_NUMBER',
	@ac_reg_number	'AIRCRAFT_REG_NO_HDR',
	@CSN	'CSN_HDR',
	null	'DUMMY_HDR',
	null	'DUMMY_HDR2',
	null	'DUMMY_HDR3',
	null	'DUMMY_HDR4',
	null	'DUMMY_HDR5',
	null	'DUMMY_HDR6',
	null	'HIDDEN_INT',
	@COMPNAME_TMP	'HTC_ADD1_HDR',
	@location_tmp	'HTC_ADD2_HDR',
	CONVERT(VARCHAR(11),@hdrdate,@DtFormatInt)	'RPT_GEN_DATE_HDR',
	@CSN	'TSN_HDR'



	SET NOCOUNT OFF

END



