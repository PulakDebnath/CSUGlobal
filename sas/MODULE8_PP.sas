
/******* Data Import *********/

     /*Import MEDICAL CONDITIONS data into H199 table*/                                                              
     FILENAME IN1 '/folders/myfolders/IMPORTS/H199.SSP';                                                
                                                                                                    
     PROC XCOPY IN=IN1 OUT=MIS500 IMPORT;                                                           
     RUN; 
     
     
     /*Import the Consolidated data into H201 table. This will contain Patient Demographics*/
     FILENAME IN1 '/folders/myfolders/IMPORTS/H201.SSP';                                                
                                                                                                    
     PROC XCOPY IN=IN1 OUT=MIS500 IMPORT;                                                           
     RUN;     
     
     
     PROC SQL NOPRINT; 
      	CREATE TABLE WORK.MEMBER_CONDITIONS AS 
     		SELECT DUID, PID, DOBMM, DOBYY, AGE17X, SEX,
     		EDUCYR, HIDEG, 
     		HIBPAGED, CHDAGED, ANGIAGED, OHRTAGED, CHOLAGED, DIABAGED, ARTHAGED, ASTHAGED
     		FROM MIS500.H201; 
			*WHERE EDUCYR GE 0; 
     QUIT;
     

     
     /*Build the dataset for analysis*/
	 DATA MCCDATA; SET WORK.MEMBER_CONDITIONS;
	 	FORMAT EDUCATION $20.;
	 		SELECT;
	 			WHEN (EDUCYR EQ 0) EDUCATION='0-NONE'; 
	 			WHEN (EDUCYR GE 1 AND EDUCYR LE 8) EDUCATION='1-ELEMENTARY';
	 			WHEN (EDUCYR GE 9 AND EDUCYR LE 12) EDUCATION='2-HIGHSCHOOL';
	 			WHEN (EDUCYR GE 13 AND EDUCYR LE 16) EDUCATION='3-COLLEGE';
	 			WHEN (EDUCYR GE 17) EDUCYR='4-UNIVERSITY';
	 			OTHERWISE EDUCATION='UNKNOWN';
	 		END;
     	IF EDUCATION='' OR EDUCATION='UNKNOWN' THEN DELETE;
     	
     	FORMAT AGEGROUP $10.;
     		SELECT;
     			WHEN (AGE17X LT 18) AGEGROUP='0-18';
     			WHEN (AGE17X GE 18 AND AGE17X LE 24) AGEGROUP='18-24';
     			WHEN (AGE17X GE 25 AND AGE17X LE 34) AGEGROUP='25-34';
     			WHEN (AGE17X GE 35 AND AGE17X LE 44) AGEGROUP='35-44';
     			WHEN (AGE17X GE 45 AND AGE17X LE 54) AGEGROUP='45-54';
     			WHEN (AGE17X GE 55 AND AGE17X LE 64) AGEGROUP='55-64';
     			WHEN (AGE17X GE 65 AND AGE17X LE 74) AGEGROUP='65-74';
     			WHEN (AGE17X GE 75 ) AGEGROUP='75+';
     			OTHERWISE AGEGROUP='UNKNOWN';
     		END;
     	IF AGEGROUP='' OR AGEGROUP='UNKNOWN' THEN DELETE;
     	
		FORMAT CHRONIC_COUNT 2.0;     	
     	CHRONIC_COUNT=0;
     		IF HIBPAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     		IF CHDAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     		IF ANGIAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     		IF OHRTAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     		IF CHOLAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     		IF DIABAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     		IF ARTHAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     		IF ASTHAGED GT 0 THEN  CHRONIC_COUNT=CHRONIC_COUNT+1;
     	
     	FORMAT IS_MCC 1.0;
     		IF CHRONIC_COUNT GT 1 THEN IS_MCC=1;
     		ELSE IS_MCC=0;
     		
     		
     /*Examine the data*/	
     PROC PRINT DATA=MCCDATA (FIRSTOBS=1 OBS=30); RUN;
     
     
 
 
/*Create a barchart between Age group and Chronic conditions*/ 
 
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.MCCDATA (WHERE=(CHRONIC_COUNT GT 0));
	vbar AGEGROUP / group=CHRONIC_COUNT groupdisplay=stack datalabel stat=percent;
	yaxis grid;
run;

/**/
proc sgplot data=WORK.MCCDATA (WHERE=(CHRONIC_COUNT GT 0));
	vbar EDUCATION / group=CHRONIC_COUNT groupdisplay=stack datalabel stat=percent;
	yaxis grid;
run;

ods graphics / reset;
 
 


/*Run the Logistic Regression*/
proc logistic data=WORK.MCCDATA ;
	model IS_MCC(event='1')=AGE17X EDUCYR / link=logit technique=fisher;
run;


/*test the goodness of fit*/ 
ods noproctitle;
ods graphics / imagemap=on;

proc logistic data=WORK.MCCDATA plots=all;
	model IS_MCC(event='1')=AGE17X EDUCYR / link=logit lackfit ctable 
		technique=fisher;
run;
     