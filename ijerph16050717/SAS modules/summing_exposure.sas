/*calculating the cumulative exposure of talc (SUM_dose)*/
	/*Parameters
		ID_list: target file containing the ID list
		drug_data: dataset with drug prescription data
		output_file: the name of the resulting output file
	*/
%macro summing_exposure(ID_list, drug_data, output_file);
data exposure_data;	set &drug_data.; /*summing up the exposure by id, multiplied by the weight percentage of talc (talc_frc)*/
by id;    
if first.id then do;		SUM_dose = 0;	end; 
SUM_dose+total_qty * talc_frc;		RUN; 

/*outputing the cumulative exposure (sum_dose) and cumulative length of prescription (sum_day) for each ID*/
data exposure_byid (keep=id SUM_dose func_date);   
set exposure_data;
by id;
if last.id then output;         
run;

/*mapping the exposure data to the target dataset by ID*/
PROC SQL;
create table &output_file. as
select a.*, b.sum_dose, b.func_date
from &ID_list. as a left join exposure_byid as b
on a.id = b.id;
QUIT;

%mend summing_exposure;
