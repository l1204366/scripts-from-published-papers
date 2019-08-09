/* 
Constructing the "ID List" of target population
*/
data talc.ID_List;
set m.id2000 m.id2002-m.id2013; /*aggregate data from the Registry for beneficiaries (ID) */
keep ID INS_AMT ID_BIRTHDAY ID_SEX AREA_NO_I REG_ZIP_CODE ID_OUT_DATE;
	/* variables:
	ID: Beneficiary identification
	ID_BIRTHDAY: date of birth
	ID_SEX: gender
	AREA_NO_I: place of residence (old post code)
	REG_ZIP_CODE: place of residence (new post code)
	ID_OUT_DATE: date of cancellation of insurance
	*/
run;
proc sort data = talc.ID_List;	by id; /*sort by id*/
run;
data ID_LastID;	set talc.ID_List;	by id; /*get the latest ID_OUT_DATE by extracting from the last entry by ID*/
if last.id then output;
run; 
data talc.ID_List;	set talc.ID_List;	by id; /*remove duplicates by extracting from the first entry by ID*/
if first.id then output;
run; 
PROC SQL; CREATE TABLE talc.ID_List(drop = x) AS /*update the "ID_list" with the latest ID_OUT_DATE*/
SELECT a.*, b.ID_OUT_DATE
FROM talc.ID_List(rename=(ID_OUT_DATE=x)) as a, ID_LASTID as b
WHERE a.ID = b.ID; QUIT;
