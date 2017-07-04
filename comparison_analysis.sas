/*Ishan Sharma
March 9, 2017
for Dr. Noukhovitch

comparison_analysis.sas
Compiling raw data into a readable sheet

Input: Earth Day .sas7bdat spreadsheet file
Output: PDF sheet of formatted data*/

/*Creating an excel file, with preferred style and sheet name*/
ods excel file="/home/ishansharma30/summative/comparison.xlsx" 
 style=pearl
 options(
  sheet_name="comparison"
 );

/*Converting the RAIS file into a readable dataset*/
data rais;
	infile "/home/ishansharma30/summative/RAIS_dataset_suppressed.csv" dsd delimiter=",";
	input repyr reg_status $ appr_trade_code $ appr_trade_name $ comp_vol $ gender $ total_reg mean_age sd_age total_NA total_cont total_disc mean_reg_dur mean_date_reg;
	if total_cont=. then total_cont=0;
	if total_disc=. then total_disc=0;
	run;

/*Converting the OCTAA file into a readable dataset*/
data octaa;
	length appr_trade_name $ 200.;
	infile "/home/ishansharma30/summative/OCTAA_chart.csv" dsd delimiter=",";
	input appr_trade_name $ appr_trade_code $ noc_code appr_sector $ appr_ratio $ tax_train_cred $ fact_sheets $ red_seal $ cofq $ otj_hours in_class_hours train_std_year curr_std_year trade_board $ acad_entry_req;
	if in_class_hours=. then in_class_hours=0;
	if otj_hours=. then otj_hours=0;
	run;

/*Sorting the datasets in order to create easily-mergeable sets*/
proc sort data=rais;
	by appr_trade_code;
	run;
	
proc sort data=octaa;
	by appr_trade_code;
	run;

/*Merge the datasets, strip the unnecessary variables from the final data set, remove the records with unknown hours and/or students*/
data comparison (keep=perc_cont perc_disc appr_trade_code in_class_hours otj_hours);
	merge rais octaa;
	by appr_trade_code;
	retain last_cont 0;
 	last_cont + total_cont; 
	retain last_disc 0;
	last_disc + total_disc;
	first_code = first.appr_trade_code;
	last_code = last.appr_trade_code;
	if first_code=1 then last_cont=total_cont;
	if first_code=1 then last_disc=total_disc;
	if last_code=1;
	if in_class_hours=. then in_class_hours=0;
	if otj_hours=. then otj_hours=0;
	if last_cont=. then last_cont=0;
	if last_disc=. then last_disc=0;
	perc_cont=100*last_cont/(last_cont + last_disc);
	perc_disc=100*last_disc/(last_cont + last_disc);
	if last_cont > 0 or last_disc > 0;
	run;

/*Print the dataset*/
proc print data=comparison label split=" " noobs;
	var appr_trade_code in_class_hours otj_hours perc_cont perc_disc;
	title "Tabular data of apprenticeship course";
	footnote "By Ishan Sharma";
	options nodate pageno=2;
	label appr_trade_code="Program code" in_class_hours="In-class hours" otj_hours="On-job hours" perc_cont="Percentage continued" perc_disc="Percentage discontinued";
	run;

title "The in-class hours of an apprenticeship in relation to the percent of students who continue the course";

/*Print the graphs of the data*/
proc sgplot data=comparison;
  	scatter y=perc_cont x=in_class_hours;
	run;
title;

title "The in-job hours of an apprenticeship in relation to the percent of students who continue the course";
proc sgplot data=comparison;
  	scatter y=perc_cont x=otj_hours;
	run;
title;

title "The in-class hours of an apprenticeship in relation to the percent of students who discontinue the course";
proc sgplot data=comparison;
  	scatter y=perc_disc x=in_class_hours;
	run;
title;

title "The in-job hours of an apprenticeship in relation to the percent of students who discontinue the course";
proc sgplot data=comparison;
	scatter y=perc_disc x=otj_hours;
	run;
title;
 
ods excel close;
