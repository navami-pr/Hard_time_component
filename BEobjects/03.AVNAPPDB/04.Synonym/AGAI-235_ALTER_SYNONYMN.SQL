/* FILENAME						 : AGAI-235_ALTERSYNONYM.SQL		    */
/* VERSION                       : 1.0	                            */
/********************************************************************/
/* COMPONENT		  :  											*/
/* ACTIVITY			  :  											*/
/* ILBO CODE		  :	 											*/
/********************************************************************/
/*	CREATED BY	:  NAVAMI			 								*/
/*	CREATED DATE:  17 JUN 2017										*/
/*	DESCRIPTION :  SYNONYM FOR TEMP TABLE							*/
/*	CR ID		:  AGAI-235										    */
/********************************************************************/
IF  NOT EXISTS (SELECT 'Y' FROM sys.sysobjects WHERE name = 'hard_time_comp_tmp' AND TYPE = 'SN')
BEGIN
       CREATE SYNONYM  hard_time_comp_tmp FOR AVNAPPDB_TEMPDB.dbo.hard_time_comp_tmp
END
GO