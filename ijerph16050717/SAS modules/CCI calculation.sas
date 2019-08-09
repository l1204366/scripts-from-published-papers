/**********************************************************************************************************************/
/*Inspired by https://healthcaredelivery.cancer.gov/seermedicare/considerations/charlson.comorbidity.macro.sas                                                                                  */
/*Reference:
    Klabunde, C. N., Potosky, A. L., Legler, J. M., & Warren, J. L. (2000). Development of a comorbidity index using physician claims data. Journal of clinical epidemiology, 53(12), 1258-1267.*/
/**********************************************************************************************************************/
/*Calculate the Charlson Comorbidity Index (CCI)*/
/* Calculate the CCI based on icd-9-cm codes (and three visits with the same diagnosis in one year)*/
	/*Prerequisite: 
		DRUG.cci (file with the ICD9 codes of the comorbidities)
		D102 or the CD files (datasets of ambulatory care expenditures by visit)
	*/
    /* input parameter:
			outfile: the target file containing the ID list
		ouput: "&outfile._ch" (marking the charlson score on the ID list)
	*/

%MACRO dx2times(outfile);
	/*For DRUG.cci (CCI diagnoses and their corresponding icd9): 
	output: work.cci*/
	DATA cci; SET DRUG.cci;
	run;

	/*creating macro: Create a 'look up' list for a where statement*/
	%macro comorblist(var);
		%global &var;
		proc sql;
			select quote(trim(&var.)) into :&var
			separated by " "
			from cci
			where &var. is not missing;
		quit;
	%mend comorblist;
	/*For diagnoses in CCI: Create 'look up' lists for comorbidities*/
	ods select none; /*NOPRINT */
	%comorblist(acute_mi);
	%comorblist(history_mi);
	%comorblist(chf);
	%comorblist(pvd);
	%comorblist(cvd);
	%comorblist(copd);
	%comorblist(dementia);
	%comorblist(paralysis);
	%comorblist(diabetes);
	%comorblist(diabetes_comp);
	%comorblist(renal_disease);
	%comorblist(mild_liver_disease);
	%comorblist(liver_disease);
	%comorblist(ulcers);
	%comorblist(rheum_disease);
	%comorblist(aids);
	ods select all; /*reopen ODS function*/

	/*For m.CD1997 (ambulatory care expenditures by visit): 
	1. add trailing zeros to the icd9 codes to make length = 5
	2. determine the comorbidities based on the icd9cm codes by using the look-up list of CCI
	output: dx1time
	*/
	DATA dx1time; 
	set 
	m.cd1997
	;
	array dxcode{3} icd9_1 icd9_2 icd9_3;
	do i= 1 to dim(dxcode);
		if dxcode(i) in :(&acute_mi) then acute_mi= 1;
		if dxcode(i) in :(&history_mi) then history_mi= 1;
		if dxcode(i) in :(&chf) then chf= 1;
		if dxcode(i) in :(&pvd) then pvd= 1;
		if dxcode(i) in :(&cvd) then cvd= 1;
		if dxcode(i) in :(&copd) then copd= 1;
		if dxcode(i) in :(&dementia) then dementia= 1;
		if dxcode(i) in :(&paralysis) then paralysis= 1;
		if dxcode(i) in :(&diabetes) then diabetes= 1;
		if dxcode(i) in :(&diabetes_comp) then diabetes_comp= 1;
		if dxcode(i) in :(&renal_disease) then renal_disease= 1;
		if dxcode(i) in :(&mild_liver_disease) then mild_liver_disease= 1;
		if dxcode(i) in :(&liver_disease) then liver_disease= 1;
		if dxcode(i) in :(&ulcers) then ulcers= 1;
		if dxcode(i) in :(&rheum_disease) then rheum_disease= 1;
		if dxcode(i) in :(&aids) then aids= 1;
	end;
	drop i; run;

	/*calculate the frequency of diagnoses: looking for >= 2 OPD visits*/
	proc means data=dx1time nway noprint;
	class id;
	var acute_mi--aids;
	output out=dx2times  sum = ;
	run;


	*** Calculate the CCI for prior conditions;
	DATA charlson; SET dx2times;
	array comorb{16} acute_mi--aids;
	do i = 1 to dim(comorb);
		if comorb(i) >= 2 then comorb(i) = 1;  /*diagnosis criteria:  >= 2 OPD visits*/
		else comorb(i) = 0;
	end;
	drop i; 
	Charlson = (acute_mi or history_mi) +
	           (chf) +
	           (pvd) +
	           (cvd) +
	           (copd) +
	           (dementia) +
	           (diabetes and not diabetes_comp) +
	           (mild_liver_disease and not liver_disease) +
	           (ulcers) +
	           (rheum_disease) +
	           (paralysis*2) +
	           (renal_disease*2) +
	           (diabetes_comp*2) +
	           (liver_disease*3) +
	           (aids*6);
	RUN;

	/*Paste Charlson score back to the outfile*/
	PROC SQL; CREATE TABLE &outfile. AS /*outfile: the target file for marking the diagnoses*/
		select a.*, b.charlson
		from &outfile. as a left join charlson as b
		on a.id = b.id; 
	QUIT;

%mend dx2times;
