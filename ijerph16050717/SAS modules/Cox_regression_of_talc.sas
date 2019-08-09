/*2018.01 Cox regression of talc
dependent variable: diagnosis of stomach cancer (ca)
explanatory variables: ever exposure to talc (ever_talc), level of talc exposure (level_dose)
confounders: age, gender, CCI*/
	/* Parameter:
		ID_list: target file containing the time, the outcome, and the variables.
	*/
data Inrisks_ever_talc; /*this dataset would be used as the baseline statement of 
the PROC PHREG (Cox regression on ever exposure to talc) for estimating the survival function*/
  input ever_talc Id $;
  datalines;
0 unexposed
1 exposed
;
data Inrisks_level_dose; /*this dataset would be used in the baseline statement of 
the PROC PHREG (Cox regression on level of talc exposure) for estimating the survival function*/
  input level_dose $ Id $;
  datalines;
medium medium_e
high high_e
low low_e
;


%macro Cox_regression_of_talc(ID_list);
	/*Cox regression (on ever exposure to talc): crude HR*/
	proc phreg data = &ID_list. ;
	class ever_talc (ref = '0') / param = ref;
	model time*ca(0)= ever_talc;	
	baseline covariates=Inrisks_ever_talc out=Pred1 survival=_all_ / rowid=Id; /*calculate absolute risk by the estimated survival function*/
	run;
		/*print out the 10-y absolute risks*/
		proc print data=Pred1(where=(ever_talc = 1 and round(time,.01)=10)); /*10-y absolute risks for exposure group */
		proc print data=Pred1(where=(ever_talc = 0 and round(time,.01)=10)); /*10-y absolute risks for unexposed group */
  		run;
		/*Wilcoxin test for survival analysis*/
		PROC LIFETEST DATA= &ID_LIST. NOTABLE OUTSURV= surv1; 
		TIME time * ca(0); 
		STRATA ever_talc; 
		RUN;
		/*Survival plot*/
		proc sgplot data=surv1;
		  step x=time y=survival / group=ever_talc lineattrs=(pattern=solid) name='s';
		  keylegend 's';
		  yaxis min=0.99;
		run;


	/*Cox regression (on level of talc exposure): crude HR*/
	proc phreg data = &ID_list.;
	class level_dose (ref = 'low   ') / param = ref;
	model time*ca(0)= level_dose;	
	baseline covariates=Inrisks_level_dose out=Pred2 survival=_all_ / rowid=Id; /*calculate absolute risk by the estimated survival function*/
	run;
	/*print out the 10-y absolute risks*/
		proc print data=Pred2(where=(level_dose = 'low   ' and round(time,.01)=10)); /*10-y absolute risks for low exposure group (non-elder, female, low CCI)*/
		proc print data=Pred2(where=(level_dose = 'medium' and round(time,.01)=10)); /*10-y absolute risks for medium exposure group (non-elder, female, low CCI)*/
		proc print data=Pred2(where=(level_dose = 'high  ' and round(time,.01)=10)); /*10-y absolute risks for high exposure group (non-elder, female, low CCI)*/
		run;
		/*Wilcoxin test for survival analysis*/
		PROC LIFETEST DATA= &ID_LIST. NOTABLE OUTSURV= surv2;
		TIME time * ca(0); 
		STRATA level_dose; 
		RUN;
		/*Survival plot*/
		proc sgplot data=surv2;
		  step x=time y=survival / group=level_dose lineattrs=(pattern=solid) name='s';
		  keylegend 's';
		  yaxis min=0.99;
		run;

	/*Cox regression (on ever exposure to talc): adjusted HR*/
	proc phreg data = &ID_list.;
	class elder (ref = '0') / param = ref; /*confounders: age, gender, CCI*/
	class id_sex (ref = 'F') / param = ref;
	class CCI (ref = 'low ') / param = ref;
	class ever_talc (ref = '0') / param = ref;
	model time*ca(0)= elder id_sex CCI ever_talc;	
	run;

   /*Cox regression (on level of talc exposure): adjusted HR*/
	proc phreg data = &ID_list. ;
	class elder (ref = '0') / param = ref; /*confounders: age, gender, CCI*/
	class id_sex (ref = 'F') / param = ref;
	class CCI (ref = 'low ') / param = ref;
	class level_dose (ref = 'low   ') / param = ref;
	model time*ca(0)= elder id_sex CCI level_dose;	
	run;
%mend Cox_regression_of_talc;
