/*"time-dependent process": We treated the talc exposure as a time-dependent variable 
in order to eliminate the immortal time bias, which is a form of selection bias arising 
when the period between cohort entry and date of first exposure to a drug is either misclassified 
or simply excluded because the event of interest has not occurred*/
/*For patients ever received medical prescription of talc, we considered the time interval 
between the beginning of the study (January 1st 1997) and the date of first prescription of talc 
to be a non-exposure period, whereas the time interval from the date of first prescription of talc 
to the endpoint of follow-up was recognized as an exposure period. */
	/*Parameter
		drug_data: dataset with drug prescription data
	*/

%macro time_dependent_exposure(drug_data);

 /*calculating the end date of prescription (drug_end_date) */
data exposure_data;		set &drug_data.;
format drug_end_date date9.;
drug_end_date = func_date + drug_day;

/*Sorting the prescription data by id and the prescription date*/
proc sort; 
by id func_date;
run;

/*Summarizing multiple times of exposure into a single period of exposure: 
the time interval from the date of first prescription of talc to the endpoint of follow-up 
was recognized as an exposure period*/
	/*new variables:
	time_dependent_func_date: date of first exposure
	sum_day: cumulative length of prescription
	sum_dose: cumulative dose of prescription
	*/
data exposure_data_byid;
set exposure_data;
by id func_date;
format time_dependent_func_date date9.;
if first.id then do;
	sum_day = 0;
	sum_dose = 0; 
	time_dependent_func_date = func_date; /*time_dependent_func_date is the date of first prescription*/
end;
sum_day + drug_day; /*calculating the sum_day*/
sum_dose + total_qty * talc_frc; /*calculating the sum_dose*/
time_dependent_func_date + 0;
func_date = time_dependent_func_date; /*transferring the value of time_dependent_func_date back to func_date, so the func_date is the date of first prescription. Then we dropped time_dependent_func_date*/
drop time_dependent_func_date;
if last.id then output;
drop total_qty drug_day;
run;


/*Identifying the non-exposure period: the time interval between the beginning of the study 
(January 1st 1997) and the date of first prescription of talc is a "non-exposure period"*/
	/*new variables:
	no_drug_begin: the start date of the non-exposure period. It will be renamed into func_date.
	no_drug_end: the end date of the non-exposure period.  It will be renamed into drug_end_date.
	*/
data non_exposure_data;
set exposure_data_byid;
format no_drug_end no_drug_begin date9.;
no_drug_end = func_date; 	 /*the date of prescription is the end date of the non-exposure period*/
no_drug_begin = mdy(1,1,1997); /*the start date of the non-exposure period is the beginning of the study (January 1st 1997)*/
keep id no_drug_begin no_drug_end;
rename no_drug_end = drug_end_date; /*renaming the end date of the non-exposure period into drug_end_date, for subsequent merging of the data of exposure period and the data of non-exposure period*/
rename no_drug_begin = func_date; /*renaming the start date of the non-exposure period into func_date, for subsequent merging of the data of exposure period and the data of non-exposure period*/
run;

/*merging of the data of exposure period and the data of non-exposure period,
and sorting it by the ID and the start date (func_date)*/
data &drug_data.;
set exposure_data_byid non_exposure_data;
if sum_day = . then sum_day = 0;
if sum_dose = . then sum_dose = 0; /*if we see sum_dose = 0, then we know it is a non-exposure period, and vise versa.*/
proc sort;
by id func_date;
run;

%mend time_dependent_exposure;
