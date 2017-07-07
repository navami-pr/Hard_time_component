/* FILENAME						 : AGAI-235_ALTERINDEX.SQL			*/
/* VERSION                       : 1.0	                            */
/********************************************************************/
/* Component	: basinvreports										*/
/* Activity     : compremovaltracking								*/
/* ILBO CODE		  :	 											*/
/********************************************************************/
/*	CREATED BY	:  NAVAMI 				 							*/
/*	CREATED DATE:  12 JUN 2017										*/
/*	DESCRIPTION :  INDEX FOR TEMP TABLE								*/
/*	CR ID		:  AGAI-235										    */
/********************************************************************/

IF NOT EXISTS (	SELECT	'X'
				FROM	SYSINDEXES	
				WHERE	name	=	'hard_time_comp_tmp_INX' 
				AND		id		=	OBJECT_ID('hard_time_comp_tmp'))
BEGIN
	CREATE CLUSTERED INDEX hard_time_comp_tmp_INX
	ON hard_time_comp_tmp(htc_GUID)
END

