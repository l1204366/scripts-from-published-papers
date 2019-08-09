/* Data exclusion:
The exclusion criteria were: 
	- patients younger than 20, 
	- patients with diagnosis of cancer in 1997, 
Parameters:
	lib_from: library containing HV files (Registry for catastrophic illness patients)
	cancer_icd: icd-9-cm code of the cancer of interest (stomach cancer in our case)
	ID_list: target file containing the "ID list" to be marked for cancer diagnosis
*/

%macro exclusion_cancer_mark(lib_from, cancer_icd, ID_list);
/*excluding patients younger than 20*/
data &ID_list.; set &ID_list.;
if intck('year', id_birthday, mdy(1,1,1997)) < 20 then delete; /*calculating age (year) from Jan.01.1997; exclude if age < 20*/
RUN;


/*Identify patients with diagnosis of cancer*/
data cancer_id;
set &lib_from..hv1997-&lib_from..hv2013; /*HV: Registry for catastrophic illness patients*/
keep ID icd9cm_code HV_TYPE APPL_DATE; 	
	/* Variables:
	ID: Holder identification
	icd9cm_code: diagnoses of catastrophic illness
	HV_TYPE: type of catastrophic illness (01 = cancer)
	APPL_DATE: date of application
	*/
if HV_TYPE not in ('01') then delete; /*Identify patients with cancer*/
proc sort;	by id;	run;

/*Identify patients with diagnosis of cancer of interest*/
DATA case_id;	
SET cancer_id;
if substr( icd9cm_code,1,3) in (&cancer_icd.) then output case_id; /*keep the ID if icd-9-cm matches the cancer of interest*/
proc sort;	by id;	run;
DATA case_id;		SET case_id;	by id;	if first.id then output;	run; /*remove duplicates*/

/*Identify patients with diagnosis of cancer of interest AT THE BEGINNING of the study*/
DATA cancer_id_1997;
set &lib_from..hv1997;
keep ID icd9cm_code HV_TYPE APPL_DATE; 	
if HV_TYPE not in ('01') then delete; 
proc sort;	by id;	run;
data cancer_id_1997;		set cancer_id_1997;	by id;	if first.id then output;	run;

/*Excluding patients with cancer in 1997; stored in a temporary dataset*/
PROC SQL;  create table ID_LIST as
select * from &ID_LIST.
where id not in (select id from cancer_id_1997); 
QUIT;

 /*Marking patients in id_list with diagnosis of cancer of interest (ca = 1), 
and marking the date of that cancer (ca_date)*/
PROC SQL;		create table ID_LIST as
select a.*, 1 as ca, b.appl_date as ca_date
from ID_list as a LEFT JOIN case_id as b
on a.id = b.id;		QUIT; 
proc sort data = ID_LIST;		by id;
run;
DATA &id_list.; SET id_list; /*if the date of the cancer exists, then he/she has cancer (ca = 1)*/
ca = ca_date;	if ca = '.' then ca = 0; 	else ca = 1;	
RUN;

%mend exclusion_cancer_mark;
