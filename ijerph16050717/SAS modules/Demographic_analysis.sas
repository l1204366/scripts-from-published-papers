/*Table 1.demographics:  talc-exposed vs. unexposed
	age (at the start date of the study)
	sex (gender of the beneficiary)
	income (monthly income in TWD)
	fu_time: follow-up time
	urban: level of urbanization (high, medium, low) from the dataset "urban_3_level"
*/
	/* Paremeters:
		ID_list: target file containing the ID list
		depend: dependent variable for grouping
	*/
%macro demographic_analysis(ID_list, depend);
data &ID_list.;		set &ID_list.;
income = ins_amt;	if income = 0 then income = '.'; /*ins_amt: monthly income (TWD); if income = 0, then the beneficiary is in the dependent population*/
age = intck('year', id_birthday, mdy(1,1,1997)); /*calculate age at the start date of the study*/
format fu_date date9.; /*fu_date: follow-up endpoint*/
if ca_date NE '.' then fu_date = ca_date; /*define follow-up endpoint (fu_date) as cancer date or drop-out date or study endpoint, whichever came first*/
	else if id_out_date NE '.' then fu_date = id_out_date;
	else fu_date = mdy(12,31,2013);
	if fu_date > mdy(12,31,2013) then fu_date = mdy(12,31,2013); /*if the drop-out date > study endpoint, then the fu_date is set to the study endpoint*/
fu_time = intck('month', mdy(1,1,1997), fu_date); /*define follow-up time (fu_time) as months being followed from 1997 to follow-up endpoint*/
if fu_time <= 0 then delete; /*delete those already dead before the study*/
run;

proc freq DATA = &ID_list.; /*2*2 table: gender and talc exposure*/
tables id_sex*&depend.  / norow nopercent chisq; RUN; 
proc means n mean stderr; /*statistics of age by talc exposure*/ /*statistics of income by talc exposure*/
class &depend.;
var age income;  
proc ttest; /*statistics of age by talc exposure, with t-test*/
class &depend.;
var age; 
proc ttest; /*statistics of income by talc exposure, with t-test*/
class &depend.;
var income;
run;
proc ttest; /*statistics of follow-up time by talc exposure, with t-test*/
class &depend.;
var fu_time;
run;

/*acquiring the levels of urbanization (urban) from the area code (area_no_i)*/
	/*add trailing zeros to make all strings to have a length of 4, in order to map them to the level of urbanization*/
	data id_list; set talc.id_list;
	num = lengthn(area_no_i);
	area_no = cats(area_no_i, repeat('0', 4-num)); 
	area_no = substr(area_no,1,4); 
	drop num;	run;
	/*use LEFT JOIN to add "urban" to ID_LIST*/
	PROC SQL; create table id_list as
	select a.*, b.urban
	from ID_list as a left join drug.urban_3_level as b /*dataset "urban_3_level" contains the mapping of level of urbanization and the area codes*/
	on a.area_no = b.area_no;	QUIT;
	/*go back to talc.ID_LIST and check the frequency*/
	DATA &ID_list.;	SET id_list;
	PROC FREQ; /*2*2 table: level of urbanization and talc exposure*/
	tables urban * &depend. / norow nopercent chisq;
	RUN;

%mend demographic_analysis;
