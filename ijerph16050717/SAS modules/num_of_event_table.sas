/*Reporting numbers of outcome events or summary measures over time.*/
	/*Parameters
		ID_list: target file containing the ID list to calculate the of outcome events
		event: the name of variable of interest (the event)
		fu_time_year: the variable name containing the follow-up time (year)
	*/
%macro num_of_event_table(ID_list);
DATA ID_list; SET &ID_list.;
if age >= 65 then elder = 1; else elder = 0;
fu_time_year = fu_time / 12;

/*grouping variables: age, gender, levels of urbanization, 
co-morbidities, ever exposed to talc, levels of talc exposure*/
PROC tabulate  data = ID_LIST; 
class elder id_sex urban CCI ever_talc level_dose/missing;
var ca fu_time_year;
table elder * ca , sum;
table elder * fu_time_year , sum;
table id_sex * ca , sum;
table id_sex * fu_time_year , sum;
table urban * ca , sum;
table urban * fu_time_year , sum;
table CCI * ca , sum;
table CCI * fu_time_year , sum;
table ever_talc * ca , sum;
table ever_talc * fu_time_year , sum;
table level_dose * ca , sum;
table level_dose * fu_time_year , sum;
RUN;
%mend num_of_event_table;
