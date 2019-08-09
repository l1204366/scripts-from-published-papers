/*grouping of the talc exposure into 3 levels*/
	/* Parameters:
		target_file: the target dataset for Cox regression 
		scalar: scalar variable to be categorized by the cut-off values
		cutoff01: cut-off point 01
		cutoff02: cut-off point 02
		level: categorical variable resulting from the cut-offs
		depend: dependent variable
	*/

%macro level_of_dose(target_file, scalar, cutoff01, cutoff02, level, depend);
PROC SORT data = &target_file.; by id func_date; run;  /*transforming the scalar into the levels*/
data &target_file.;	set &target_file.;	by id func_date;
if &scalar. <= &cutoff01. | &scalar. = '.' then &level. = 'low   '; /*low dose: <=cutoff01*/
if &scalar. > &cutoff01. & &scalar. <= &cutoff02. then &level. = 'medium'; /*medium dose: cutoff01~cutoff02*/
if &scalar. > &cutoff02. then &level. = 'high  '; 	run; /*high dose: >cutoff02*/

proc freq data = &target_file.; /*2*2 table: the dependent variable and the categorical variable */
tables &depend.*&level. / norow nopercent chisq;	run;

proc summary PRINT N MEAN STD MEDIAN Min Max MEDIAN Q1 Q3; /*check the summary of the scalar variable*/
var &scalar.;
run;

proc ttest; /*statistics of the scalar variable by the dependent variable, with t-test*/
class &depend.;
var &scalar.;
run;

%mend level_of_dose;
