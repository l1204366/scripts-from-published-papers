/* Assessing the amount of talc exposure and dealing with the missing value*/
/*Parameter:
drug_data: dataset with drug prescription data
*/
%macro chinese_herb_process(drug_data);
data  &drug_data.;
set &drug_data.;
if drug_day=0 then drug_day =1;                                                    /*if the length of prescription is 0  (drug_day = 0), then change it into drug_day = 1 because it is a STAT use. */
if total_qty/drug_day>20 then total_qty=total_qty/100;     /*If daily dose > 20g, then it makes little clinical sense so we divide the total quantity of prescription (total_qty) by 100, because in the reimbursement process it is a common typing error to mistaken 1.00 as 100 */
proc sort;
by id;
run;
/*mean imputation*/
PROC SQL; CREATE TABLE &drug_data.(drop = x) as
select *, case
	when x = 0 then sum(x) / sum(drug_day) * drug_day /*imputation for total_qty = 0 with average quantity per day multiplied by drug_day*/
	else x
	end as total_qty
FROM talc.exposure_data(rename=(total_qty=x)); /*rename total_qty to x, and then we modify x to a new total_qty; reference: https://communities.sas.com/t5/SAS-Procedures/SQL-how-to-exclude-a-variable-when-doing-select-in-SQL/td-p/91060*/
QUIT;

%mend chinese_herb_process;
