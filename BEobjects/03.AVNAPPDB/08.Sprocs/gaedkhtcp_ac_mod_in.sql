/*filename = gaedkhtcp_ac_mod_in.sql*/
/********************************************************************************/
/* procedure      gaedkhtcp_ac_mod_in                                           */
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
/* Procedure		: gaedkhtcp_ac_mod_in 										*/
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

CREATE PROCEDURE gaedkhtcp_ac_mod_in
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
	@ac_reg_number                 	udd_documentno,
	@hidden_int                    	udd_int,
	@m_errorid                    	int output --to return execution status
as
Begin

	set nocount on

	set @m_errorid = 0

	SELECT @ctxt_role                    	= ltrim(rtrim(@ctxt_role))
	SELECT @ctxt_service                 	= ltrim(rtrim(@ctxt_service))
	SELECT @ctxt_user                    	= ltrim(rtrim(@ctxt_user))
	SELECT @ctxt_base_component           	= ltrim(rtrim(@ctxt_base_component))
	SELECT @ctxt_base_activity            	= ltrim(rtrim(@ctxt_base_activity))
	SELECT @ctxt_base_ui                  	= ltrim(rtrim(@ctxt_base_ui))
	SELECT @ctxt_extn_based_on            	= ltrim(rtrim(@ctxt_extn_based_on))
	SELECT @ac_reg_number                 	= ltrim(rtrim(@ac_reg_number))

	--null checking
	
	IF @ac_reg_number= '~#~'
		SELECT @ac_reg_number = null

	IF @hidden_int=-915
		SELECT @hidden_int = null
		

	/*
	--Errors
	*/

	/*
	--OutputList
	SELECT 
	null	'AC_MODEL'
	null	'AC_MODEL_HDN'		--GAEDKNSPR_NSPACM_IN*/


	SELECT 
	DISTINCT	
			MDL_MODEL_NO		'ac_model',
			MDL_MODEL_NO		'ac_model_hdn'	
	FROM				AC_MDL_AC_MODEL_DEFINITION	(NOLOCK)
	WHERE               MDL_OUINSTANCE   = @ctxt_ouinstance
	UNION 
	SELECT	null				'AC_MODEL',
			null				'ac_model_hdn'	

	SET NOCOUNT OFF

END



