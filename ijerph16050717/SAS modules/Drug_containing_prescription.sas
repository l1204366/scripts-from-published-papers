/* using the drug code to identify all ambulatory care orders containing the target medication,
and store the results in the dataset "ooCE"*/
	/* Parameters
	(OO = the NHIRD dataset containing the details of ambulatory care orders)
	lib_from: the library where OO files exist.	
	file_drug: the file with required drug number
	lib_out: the library to output the target file ooCE
	year_from: starting year of OO files 
	year_to: ending year of OO files
	*/
%macro drug_containing_prescription_1(lib_from, file_drug, lib_out, year_from, year_to);
%do i=&year_from. %to &year_to.;
PROC SQL;
CREATE TABLE &lib_out..ooCE&i. AS                                    /*stored in ooCE&i. for the results in each year (denoted by i)  */     
SELECT a.FEE_YM, a.HOSP_ID, a.APPL_TYPE, a.APPL_DATE, a.CASE_TYPE, a.SEQ_NO, a.total_qty, a.drug_no, a.drug_use, a.drug_fre, b.talc_frc 
FROM &lib_from..oo&i. as a, &file_drug. as b                                                        /*reading the OO file of each year (denoted by i) */
WHERE a.drug_no = b.drug_no;      
QUIT;
%end;
%mend drug_containing_prescription_1;

/*Using the "ooCE" dataset (ambulatory care orders containing target medication) to identify corresponding CD files,
in order to find out the ID and the diagnoses*/
	/*Parameters
	(CD = the NHIRD dataset containing the ambulatory care expenditures by visits)
	lib_from: the library where CD files exist.	
	lib_out: the library to output the target file cdooCE
	year_from: starting year of CD files 
	year_to: ending year of CD files
	*/
%macro drug_containing_prescription_2 (lib_from, lib_out, year_from, year_to);
%do i=&year_from. %to &year_to.;
PROC SQL;
CREATE TABLE &lib_out..cdooCE&i. AS
SELECT a.ID, a.icd9_1, a.icd9_2, a.icd9_3, a.drug_day, a.id_sex, a.func_date, b.*
FROM &lib_from..cd&i.  as a, &lib_out..ooCE&i. as b
WHERE a.FEE_YM=b.FEE_YM and a.hosp_id=b.hosp_id and a.APPL_TYPE=b.APPL_TYPE and 
      a.APPL_DATE=b.APPL_DATE and a.CASE_TYPE=b.CASE_TYPE and a.SEQ_NO=b.SEQ_NO;
QUIT;
%end;
%mend drug_containing_prescription_2;
