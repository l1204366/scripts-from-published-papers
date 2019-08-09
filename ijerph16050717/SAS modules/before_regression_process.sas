/*Procedures before doing the regression*/
	/* Parameters:
	ID_list: target file containing the ID list
	drug_data: dataset with drug prescription data
	output_file: the name of the resulting output file for subsequent regression 
	*/
%macro before_regression_process(ID_list, drug_data, output_file);

/*Mapping the exposure data to the target cohort (the "id_list")*/
PROC SQL; /*exposed dataset: to be right-joined to drug_data*/
create table before_regression_exposed as
select a.*, b.*
from &ID_list. as a, &drug_data. as b
where a.id = b.id;
QUIT;
PROC SQL; /*non-exposed dataset*/
create table before_regression_nonexposed as
select *
from &ID_list.
where id not in (select id from &drug_data.);
QUIT;
DATA &output_file.; /*all = exposed + non-expossed*/ 
SET before_regression_exposed before_regression_nonexposed; 
drop ever_talc fu_time; /*whether she had ever taken talc (ever_talc) needs to be re-assessed*/     /*follow-up time (fu_time) needs to be re-assessed*/
RUN;

/*For each time period: set up the event status and the time-to-event*/
PROC SORT data = &output_file.; by id func_date; run;
DATA &output_file.;	set &output_file.;	by id func_date;
	/*set up time-to-event: fu_date, func_date, time (year)*/
	if not last.id then fu_date = drug_end_date; /*if the time period is not the last for that person, set the follow-up endpoint (fu_date) to the end date of that period (drug_end_date)*/
	if func_date = '.' then func_date = mdy(1,1,1997); /*For people without talc exposure, set up a non-exposure period from Jan/01/1997 to follow-up end date (fu_date)*/
	time = (fu_date - func_date)/365.25; /*The unit of time-to-event is "year" in the regression*/ 
	if sum_dose >0 then ever_talc = 1; else ever_talc = 0; /*ever_talc (whether she had ever taken talc) needs to be rechecked*/
	fu_time = intck('month', func_date, fu_date); /*fu_time (follow-up time) needs to be re-calculated*/
	if ca = '.' then ca = 0;
	if last.id & ca = 1 then ca = 1; else ca = 0; /*if the time period is not the last for that person, then the event has not happened (event = 0) */
	run;

/*defining "elder" as age >= 65*/
DATA &output_file.;	set &output_file.;	
if age >= 65 then elder = 1; else elder = 0; run;

%mend before_regression_process;
