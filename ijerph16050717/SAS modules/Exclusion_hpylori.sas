/*Excluding patients with H.pylori / Peptic ulcer disease / Duodenal ulcer / Gastric ulcer / Gastritis / Duodenitis*/
	/*Prerequisite: 
		D102 or the CD files (datasets of ambulatory care expenditures by visit)
	*/
	     /* input parameter:
				outfile: the target file containing the ID list
			ouput: modified &outfile by excluding targeted diagnoses
		*/

%MACRO dx2times(outfile);
	/*For m.cd1997 (ambulatory care expenditures by visit): 
	determine the comorbidities based on the ICD codes
	output: work.dx1time
	*/
	DATA dx1time; 
		set 
		m.cd1997
		;
		array dxcode{3} icd9_1 icd9_2 icd9_3;
		do i= 1 to dim(dxcode);
			if dxcode(i) in :('531') then GU= 1;
			if dxcode(i) in :('532') then DU= 1;
			if dxcode(i) in :('533') then PUD= 1;
			if dxcode(i) in :('535') then Gastritis= 1;
			if dxcode(i) in :('04186') then Hpylori= 1;
		end;
		drop i; run;

	/*calculate the frequency of diagnoses: looking for >= 2 OPD visits*/
	proc means data=dx1time nway noprint;
	class id;
	var GU--Hpylori;
	output out=dx2times  sum = ;
	run;


	*** Select target patients ;
	DATA TARGET; SET dx2times;
	array comorb{*} GU--Hpylori;
	do i = 1 to dim(comorb);
		if comorb(i) >= 2 then comorb(i) = 1;  /*diagnosis criteria:  >= 2 OPD visits*/
		else comorb(i) = 0;
	end;
	drop i; 
	if (GU = 1) OR (DU = 1) OR (PUD = 1) OR (Gastritis = 1) OR (Hpylori = 1) then output;
	RUN;

	/*Back to the outfile (the ID list)*/
	PROC SQL; CREATE TABLE &outfile. AS 
		select *
		from &outfile. 
		where id NOT in (select id from TARGET); 
	QUIT;

%mend dx2times;
