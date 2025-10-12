/* 
This file produces the appendix tables (B.1-B.14) for "Seasonal liquidity, rural labor markets and agricultural production"

Version: 1.0 

Last Updated: 07/11/2020

*/

*** Setup ***
clear all
set maxvar 10000
set more off
set seed 5925169

*********************************************************************************************
******************** 1. Specify directories and macros **************************************
*********************************************************************************************

cap cd "" // Insert your directory here
global data = "Data/Analysis"
global clean = "Data/Clean Subject Panels"
global output = "Output/Appendix Tables"

global controls b_head_age b_imp_head_age_dum b_head_female b_members_* ///
	b_did_ganyu b_plan_ganyu ///
	b_acres_maize_total b_acres_cash_crops b_harvest_total_value b_crop_diversity ///
	b_asset_quintile b_livestock_value b_input_value b_hired_ganyu b_num_farm_workers b_num_iga_workers ///
	control_gift 
	
global baseline b_head_age b_head_female b_members_* ///
	b_did_ganyu b_plan_ganyu ///
	b_acres_maize_total b_acres_cash_crops b_harvest_total_value b_crop_diversity ///
	b_asset_quintile b_livestock_value b_input_value b_hired_ganyu b_num_farm_workers b_num_iga_workers // drops control_gift from list
	
global id female ageu20 age3039 age4049 age5059 age60_plus
	
global blocks block_dum_Chanje block_dum_Chiparamba block_dum_Eastern block_dum_Southern block_dum_Western 

**********************************************************************************************
**************************** 2. Appendix Tables **********************************************
**********************************************************************************************

********************** Appendix table A1: Loan values ****************************************

* Parameter values used in Model_simulation_figures.do

********************** Appendix table A2: Loan values ****************************************

* Table constructed based on summary statistics as follows:
// Column 1: 
use  "$data/household_panel_final", clear 
	sum daily_earnings95 if treated == 0
	sum l_harvest_value if treated == 0

// Columns 2-4: see Model_simulation_figures.do, calculations at:
* Column 2: line 154
* Column 3: begins line 371 
* Column 4: begins line 716


********************** Appendix table B1: Loan values ****************************************

	cap file close loan
	file open loan using "$output/B1.tex", write replace
	
	file write loan "\begin{tabular}{l ccc}" _n
	file write loan "\hline" _n
	file write loan " & Loan (January) & Repayment (July) & Implied interest \\ " _n
	file write loan "\\" _n
	file write loan "\multicolumn{4}{c}{A. Maize loan} \\ " _n
	file write loan "Offer & 3 bags (50 kg ea) & 4 bags (50 kg ea) & 30\% \\ " _n
	file write loan "Value (official) & K 195 & K 260 & 33\% \\ " _n
	file write loan "Value (reported) & K 261 & K 234 & -10\% \\ " _n
	file write loan "\\" _n
	file write loan "\multicolumn{4}{c}{B. Cash Loan} \\" _n
	file write loan "Offer& K 200 & K 260 & 30\% \\" _n
	file write loan "\hline" _n
	file write loan "\end{tabular}" _n
	file close loan
	
******************* Appendix table B2: Attrition by survey round *****************************

use "$data/admin_outcomes_final.dta", clear

***** Setup *****
	local surveys in_baseline in_harvest in_endline in_midline in_labor1 in_labor2 in_labor3 in_labor4
	
	cap file close attrition2
	file open attrition2 using "$output/B2.tex", write replace
	
	file write attrition2 "\begin{tabular}{l cc cc cc cc}" _n
	file write attrition2 "\hline" _n
	file write attrition2 " Year 1 treatments & & & & & & & & \\" _n	
	file write attrition2 " & Baseline & Y1 Harvest & Y2 Endline & Midline & Labor 1 & Labor 2 & Labor 3 & Labor 4 \\ " _n
	file write attrition2 "\hline" _n
	
***** Year 1, Row 1 *****	
	foreach svy of local surveys {
		
		sum `svy'
		local N_`svy'	 	  : display %-8.0f `r(N)'
		
		}
		
		file write attrition2 "Eligible & `N_in_baseline' & `N_in_harvest' & `N_in_endline' & `N_in_midline' & `N_in_labor1' & `N_in_labor2' & `N_in_labor3' & `N_in_labor4' \\ " _n
		file write attrition2 "& & & & & & & & \\ " _n
	
		
****** Year 1, Row 2 *****
	
	gen control1 = treat1 == 1
	sum control1 
	local c_share			: display %-8.2f `r(mean)'	
	
	foreach svy of local surveys {
		
			sum `svy' if treat1 == 1
			
			local c_`svy'	: display %-8.2f `r(mean)'	
		
			}
	
		file write attrition2 "Control group mean & `c_share' & `c_in_harvest' & `c_in_endline' & `c_in_midline' & `c_in_labor1' & `c_in_labor2' & `c_in_labor3' & `c_in_labor4' \\ " _n
		file write attrition2 "& & & & & & & & \\ " _n

***** Year 1, Rows 3 & 4 *****		
		
	foreach treat in cash1 maize1 {
	
		if "`treat'" == "cash1" {
			local label = "Cash loan treatment" 
			}
			else {
				local label = "Maize loan treatment"
				}
			
		sum `treat'
		local share			: display %-8.2f `r(mean)'
		
		foreach svy of local surveys {
		
			reg `svy' `treat' if treat1 == 1 | `treat' == 1, cl(vid)
			
			local b_`svy'	= _b[`treat']
			local b_`svy' 	: display %-4.3f `b_`svy''
			
			local se_`svy'	= _se[`treat']
			local se_`svy' 	: display %-4.3f `se_`svy''
			
		
			}
		
		
		file write attrition2 "`label' & `share' & `b_in_harvest' & `b_in_endline' & `b_in_midline' & `b_in_labor1' & `b_in_labor2' & `b_in_labor3' & `b_in_labor4' \\ " _n
		file write attrition2 " & & (`se_in_harvest') & (`se_in_endline') & (`se_in_midline') & (`se_in_labor1') & (`se_in_labor2') & (`se_in_labor3') & (`se_in_labor4') \\ " _n	
		
		}
	
	
	
****** Year 2, Row 1 ***** 
	
	file write attrition2 "\hline" _n
	file write attrition2 " Year 2 treatments & & & & & & & & \\" _n	
	file write attrition2 " & Baseline & Y1 Harvest & Y2 Endline & Midline & Labor 1 & Labor 2 & Labor 3 & Labor 4 \\ " _n
	file write attrition2 "\hline" _n
	
	gen control2 = treat2 == 1
	sum control2
	local c_share			: display %-8.2f `r(mean)'	
	
	foreach svy of local surveys {
		
			sum `svy' if treat2 == 1
			
			local c_`svy'	: display %-8.2f `r(mean)'	
		
			}
	
	file write attrition2 "Control group mean & `c_share' & `c_in_harvest' & `c_in_endline' & `c_in_midline' & `c_in_labor1' & `c_in_labor2' & `c_in_labor3' & `c_in_labor4' \\ " _n
	file write attrition2 "& & & & & & & & \\ " _n

***** Year 2, Rows 2-5 *****
	
	foreach treat in cash2 maize2 early cashonly {
	
		if "`treat'" == "cash2" {
			local label = "Cash loan treatment" 
			}
			else if "`treat'" == "maize2" {
				local label = "Maize loan treatment"
				}
				else if "`treat'" == "early" {
					local label = "Early notification sub-treatment"
					}
					else if "`treat'" == "cashonly" {
						local label = "Cash repayment sub-treatment"
						}
			
		sum `treat'
		local share			: display %-8.2f `r(mean)'
		
		foreach svy of local surveys {
		
			reg `svy' `treat' , cl(vid)
			
			local b_`svy'	= _b[`treat']
			local b_`svy' 	: display %-4.3f `b_`svy''
			
			local se_`svy'	= _se[`treat']
			local se_`svy' 	: display %-4.3f `se_`svy''

		
			}
			
		file write attrition2 "`label' & `share' & `b_in_harvest' & `b_in_endline' & `b_in_midline' & `b_in_labor1' & `b_in_labor2' & `b_in_labor3' & `b_in_labor4' \\ " _n
		file write attrition2 " & & (`se_in_harvest') & (`se_in_endline') & (`se_in_midline') & (`se_in_labor1') & (`se_in_labor2') & (`se_in_labor3') & (`se_in_labor4') \\ " _n	
		
		}	
	file write attrition2 "\hline" _n
	file write attrition2 "\end{tabular}" _n
	file close attrition2


	
****************** Appendix table B3: Attrition by participation stage ***********************

use "$data/admin_outcomes_final.dta", clear

***** Setup *****
	file open attrition using "$output/B3.tex", write replace
	
	file write attrition "\begin{tabular}{ll cc cc}" _n
	file write attrition "\hline" _n
	file write attrition "Year 1 & & & & & \\ " _n
	file write attrition " & & Invited & At meeting & Eligible & Take up \\ " _n
	file write attrition " \\ " _n

	
****** Year 1 ***** 
	
	forval x = 2/3 {
		
		if `x' == 2 {
			local treat = "Cash loan treatment" 
			}
			else {
				local treat = "Maize loan treatment"
				}
	
		sum invited1 	if invited1 == 1 & treat1 == `x'
		local N_inv		 	: display %-8.0f `r(N)'
		
		sum attend1 	if invited1 == 1 & treat1 == `x'
		local per_att 		: display %-8.2f `r(mean)'
		
		sum consent1 	if attend1 == 1 & treat1 == `x'
		local N_att 		: display %-8.0f `r(N)' 
		local per_cons		: display %-8.2f `r(mean)'
		
		sum takeup1 		if consent1 == 1 & treat1 == `x'
		local N_cons		: display %-8.0f `r(N)'
		local per_take		: display %-8.2f `r(mean)'
		
		sum takeup1 		if takeup1 == 1 & treat1 == `x'
		local N_take 		: display %-8.0f `r(N)'
		
		file write attrition "`treat' & N & `N_inv' & `N_att' & `N_cons' & `N_take' \\ " _n
		file write attrition " & Share & & `per_att' & `per_cons' & `per_take' \\" _n
		
		}
	
	
****** Year 2 ******
	file write attrition "Year 2 & & & & & \\ " _n
	file write attrition "& & Invited & At meeting & Eligible & Take up \\" _n
	
	forval x = 2/3 { 
		
		if `x' == 2 { 								//Treatments
			local treat = "Cash loan treatment" 
			}
			else {
				local treat = "Maize loan treatment"
				}
	
***** Pooled across subtreatments ****
		sum invited2 	if invited2 == 1 & treat2 == `x'
		local N_inv		 	: display %-8.0f `r(N)'
		
		sum attend2 	if invited2 == 1 & treat2 == `x'
		local per_att 		: display %-8.2f `r(mean)'
		
		sum consent2	if attend2 == 1 & treat2 == `x'
		local N_att 		: display %-8.0f `r(N)' 
		local per_cons		: display %-8.2f `r(mean)'
		
		sum takeup2 		if consent2 == 1 & treat2 == `x'
		local N_cons		: display %-8.0f `r(N)'
		local per_take		: display %-8.2f `r(mean)'
		
		sum takeup2 		if takeup2 == 1 & treat2 == `x'
		local N_take 		: display %-8.0f `r(N)'
		
		file write attrition "`treat' & & & & & \\ " _n  
		file write attrition " \hspace{1em} Pooled & N & `N_inv' & `N_att' & `N_cons' & `N_take' \\ " _n
		file write attrition " & Share & & `per_att' & `per_cons' & `per_take' \\" _n
			
		file write attrition "\hspace{1em} Notification timing sub-treatment & & & & & \\ " _n
		
***** Notification timing sub-treatments *****
		forval t = 0/1 {		
		
			if `t' == 0 {
			local early = "Standard notification" 
			}
			else {
				local early = "Early notification"
				}
			
		sum invited2 	if invited2 == 1 & treat2 == `x' & early == `t'
		local N_inv		 	: display %-8.0f `r(N)'
		
		sum attend2 	if invited2 == 1 & treat2 == `x' & early == `t'
		local per_att 		: display %-8.2f `r(mean)'
		
		sum consent2	if attend2 == 1 & treat2 == `x' & early == `t'
		local N_att 		: display %-8.0f `r(N)' 
		local per_cons		: display %-8.2f `r(mean)'
		
		sum takeup2 		if consent2 == 1 & treat2 == `x' & early == `t'
		local N_cons		: display %-8.0f `r(N)'
		local per_take		: display %-8.2f `r(mean)'
		
		sum takeup2 		if takeup2 == 1 & treat2 == `x' & early == `t'
		local N_take 		: display %-8.0f `r(N)'
		
		file write attrition "\hspace{2em} `early' & N & `N_inv' & `N_att' & `N_cons' & `N_take' \\ " _n
		file write attrition " & Share &  & `per_att' & `per_cons' & `per_take' \\ " _n
		
		}
		
		file write attrition "\hspace{1em} Cash repayment sub-treatment & & & & & \\ " _n	
		
***** Repayment sub-treatment *****
		forval c = 0/1 {		
		
		if `c' == 0 {
			local cashonly = "Standard repayment" 
			}
			else {
				local cashonly = "Cash only repayment"
				}
				
						
		sum invited2 	if invited2 == 1 & treat2 == `x' & cashonly == `c'
		local N_inv		 	: display %-8.0f `r(N)'
		
		sum attend2 	if invited2 == 1 & treat2 == `x' & cashonly == `c'
		local per_att 		: display %-8.2f `r(mean)'
		
		sum consent2	if attend2 == 1 & treat2 == `x' & cashonly == `c'
		local N_att 		: display %-8.0f `r(N)' 
		local per_cons		: display %-8.2f `r(mean)'
		
		sum takeup2 		if consent2 == 1 & treat2 == `x' & cashonly == `c'
		local N_cons		: display %-8.0f `r(N)'
		local per_take		: display %-8.2f `r(mean)'
		
		sum takeup2 		if takeup2 == 1 & treat2 == `x' & cashonly == `c'
		local N_take 		: display %-8.0f `r(N)'
		
		file write attrition "\hspace{2em} `cashonly' & N & `N_inv' & `N_att' & `N_cons' & `N_take' \\ " _n
		file write attrition " & Share &  & `per_att' & `per_cons' & `per_take' \\ " _n
		
		}
		} 
		
	file write attrition "\hline" _n
	file write attrition "\end{tabular}" _n		
	file close attrition	
	
	
***************** Appendix table B4: Summary stats by baseline reserves ***********************

use "$data/admin_outcomes_final.dta", clear
***** Setup *****
replace total_reserve = total_reserve*100
label var total_reserve "Baseline liquid reserves in Kwacha"
	
	cap file close sumstat
	file open sumstat using "$output/B4.tex", write replace
	
	file write sumstat "\begin{tabular}{l cc cc}" _n
	file write sumstat "\hline" _n
	file write sumstat  "& \multicolumn{4}{c}{Baseline grain and cash reserves} \\ " _n
	file write sumstat " & Q1 & Q2 & Q3 & Q4 \\ " _n
	file write sumstat  "\hline" _n
	
***** Table *****	
	foreach X of varlist total_reserve $baseline {
	
		local variable_label : variable label `X'
		
		forval i = 1/4 {
	
			sum `X' if reserves_q == `i'
			local tempmean`i' : display %-8.3f `r(mean)'
			local tempsd`i' : display %-4.3f `r(sd)'
			local temp`i' `r(N)'
			local tempvar`i' `r(Var)'
			
			}
			
			file write sumstat "`variable_label' & `tempmean1' & `tempmean2' & `tempmean3' & `tempmean4' \\ "  _n
			file write sumstat " & [`tempsd1'] & [`tempsd2'] & [`tempsd3'] & [`tempsd4'] \\ " _n
			
			}
	
	file write sumstat "\hline" _n
	file write sumstat "\end{tabular}" _n	
	 
	file close sumstat



******************* Appendix table B5: Randomization balance **********************************

use "$data/admin_outcomes_final.dta", clear
***** Setup ******
	cap file close balance
	file open balance using "$output/B5.tex", write replace

	file write balance "\begin{tabular}{l cc cc cc cc cc}" _n
	file write balance "\hline" _n
	file write balance " & \multicolumn{3}{c}{Year 1} & & & \multicolumn{3}{c}{Year 2} & & \\" _n
	file write balance " & Control & Cash & Maize & (1) vs (2) & (1) vs (3) & Control & Cash & Maize & (6) vs (7) & (6) vs (8) \\" _n
	file write balance " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\ " _n
	file write balance "\hline" _n
	
	foreach X of varlist $baseline {
	
		local variable_label : variable label `X'
		
		forval i = 1/2 {
***** Control Group (Columns 1 & 6) *****
			sum `X' if treat`i'==1
			local tempmean`i'_1 : display %-8.2f `r(mean)'
			local tempsd`i'_1 : display %-4.2f `r(sd)'
			local temp`i'_1 `r(N)'
			local tempvar`i'_1 `r(Var)'
***** Cash Treatment Group (Columns 2 & 7) *****
			sum `X' if treat`i'==2
			local tempmean`i'_2 : display %-8.2f `r(mean)'
			local tempsd`i'_2 : display %-4.2f `r(sd)'
			local temp`i'_2 `r(N)'
			local tempvar`i'_2 `r(Var)'
***** Maize Treatment Group (Columns 3 & 8) *****			
			sum `X' if treat`i'==3
			local tempmean`i'_3 : display %-8.2f `r(mean)'
			local tempsd`i'_3 : display %-4.2f `r(sd)'
			local temp`i'_3 `r(N)'
			local tempvar`i'_3 `r(Var)'
			
***** Means comparison: Control vs. Cash Treatment Group (Columns 4 & 9)  *****
			ttest `X' if treat`i' == 1 | treat`i' == 2, by(treat`i')
			local p`i'_2: display %-4.2f `r(p)'		
***** Means comparison: Control vs. Maize Treatment Group (Columns 5 & 10)  *****
			ttest `X' if treat`i' == 1 | treat`i' == 3, by(treat`i')
			local p`i'_3: display %-4.2f `r(p)'	
			
			}
		
		
			file write balance "`variable_label' & `tempmean1_1' & `tempmean1_2' & `tempmean1_3' & `p1_2' & `p1_3' & `tempmean2_1' & `tempmean2_2' & `tempmean2_3' & `p2_2' & `p2_3' \\ " _n
			file write balance " & [`tempsd1_1'] & [`tempsd1_2'] & [`tempsd1_3'] & & & [`tempsd2_1'] & [`tempsd2_2'] & [`tempsd2_3'] & & \\ " _n
			
			}
	
		file write balance "\hline" _n
		file write balance "\end{tabular}" _n
		file close balance
	

***************** Appendix table B6: Randomization balance, year 2 sub ************************

use "$data/admin_outcomes_final.dta", clear
***** Setup *****
	cap file close balance
	file open balance using "$output/B6.tex", write replace

	file write balance "\begin{tabular}{l cc cc cc cc cc}" _n
	file write balance "\hline" _n
	file write balance " & \multicolumn{4}{c}{Year 2 treatment status} & & & & & & \\" _n
	file write balance " & Never & Year 1 & Year 2 & Year 2 & (1) vs (2) & (1) vs (3) & (1) vs (4) & (2) vs (3) & (2) vs (4) & (3) vs (4)   \\" _n
	file write balance " & treated & only & new & repeat & & & & & & \\ " _n
	file write balance " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\ " _n
	file write balance "\hline" _n
	
	foreach X of varlist $baseline {

		local variable_label : variable label `X'
***** Stats by Year 2 Treatment Status (Columns 1-4 *****		
		forval i = 0/1 {
			forval j = 0/1 {
			
			sum `X' if any_treat2 ==`i' & treatedin1 == `j'
			local tempmean`i'_`j' : display %-8.2f `r(mean)'
			local tempsd`i'_`j' : display %-4.2f `r(sd)'
			local temp`i'_`j' `r(N)'
			local tempvar`i'_`j' `r(Var)'

			}
			}
			
***** Means comparisons by Treatment Status *****

***** Never Treated vs. Year 1 Only (Column 5) *****
			ttest `X' if (any_treat2 == 0  & treatedin1 == 0) | (any_treat2 == 0 & treatedin1 == 1), by(treatedin1)
			local p1: display %-4.2f `r(p)'	
			
***** Never Treated vs. Year 2 Only (Column 6) *****	
			ttest `X' if (any_treat2 == 0 | treatedin1 == 0) | (any_treat2 == 1 & treatedin1 == 0), by(any_treat2)
			local p2: display %-4.2f `r(p)'
			
***** Never Treated vs. Both (Column 7) *****
			ttest `X' if (any_treat2 == 0 | treatedin1 == 0) | (any_treat2 == 1 & treatedin1 == 1), by(any_treat2)
			local p3: display %-4.2f `r(p)'
			
***** Year 1 Only vs. Year 2 Only (Column 8) *****
			ttest `X' if (any_treat2 == 0 | treatedin1 == 1) | (any_treat2 == 1 & treatedin1 == 0), by(any_treat2)
			local p4: display %-4.2f `r(p)'
			
***** Year 1 Only vs. Both (Column 9) *****
			ttest `X' if (any_treat2 == 0 | treatedin1 == 1) | (any_treat2 == 1 & treatedin1 == 1), by(any_treat2)
			local p5: display %-4.2f `r(p)'
			
***** Year 2 Only vs. Both (Column 10) *****
			ttest `X' if (any_treat2 == 1 | treatedin1 == 0) | (any_treat2 == 1 & treatedin1 == 1), by(any_treat2)
			local p6: display %-4.2f `r(p)'
		
			file write balance "`variable_label' & `tempmean0_0' & `tempmean0_1' & `tempmean1_0' & `tempmean1_1' & `p1' & `p2' & `p3' & `p4' & `p5' & `p6' \\ " _n
			file write balance " & [`tempsd0_0'] & [`tempsd0_1'] & [`tempsd1_0'] & [`tempsd1_1'] & & & & & & \\ " _n
			
			}
	
		file write balance "\hline" _n
		file write balance "\end{tabular}" _n
		file close balance
	
************ Appendix table B7: Heterogeneous treatment effects *******************************
use "$data/household_panel_final", clear 
***** Setup *****
		cap file close het
		file open het using "$output/B7.tex", write replace
		
		file write het "\begin{tabular}{l ccccc}" _n
		file write het "\hline" _n
		file write het " & Hours sold & Hours hired & Family hours & Log & Adult meals \\" _n
		file write het " & & & on-farm & output & \\" _n
		file write het " & (1) & (2) & (3) & (4) & (5) \\" _n
		file write het "\hline" _n
		
	
		set level 90

		local quarts 0.87 3.03 6.33 24.6 
		gen meff = .
		gen hi = .
		gen lo = .
		gen b_reserves_q0 = b_reserves_q - 0.05 if treated == 0
		gen b_reserves_q1 = b_reserves_q + 0.05 if treated == 1
***** Columns 1-3 *****
	foreach var in work_hours hire_hours fam_hours {
	
		local variable_label : variable label `var'
				
			forval y = 1/2 {
	
			if `y' == 1 {
			reg `var' treated##c.b_total_reserve##c.b_total_reserve i.monthyear $blocks if year == `y' & calendar_month < 4, cl(vid) 
			}
				else {
					reg `var' treated##c.b_total_reserve##c.b_total_reserve##i.treatedin1 i.monthyear $blocks if year == `y' & calendar_month < 4, cl(vid)
					} 
					
			local i = 0
			foreach rhs in 1.treated b_total_reserve 1.treated#c.b_total_reserve c.b_total_reserve#c.b_total_reserve 1.treated#c.b_total_reserve#c.b_total_reserve {
				local i = `i'+1
				
				local b`i'_`var' : display %-4.3f _b[`rhs']
				local se`i'_`var' : display %-4.3f _se[`rhs']
				
				
				}
				
			sum `var' if treated == 0 & year == 1
			local mean_`var' : display %-4.2f `r(mean)'
			
			margins treated, at(c.b_total_reserve = (`quarts')) post

			replace meff = .
			replace hi = .
			replace lo = .
			
		forval i = 1/4 {
			replace meff = _b[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace meff = _b[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			}
		
		}
		
		}
***** Column 4 *****
	foreach var in l_harvest_value {
	
		*replace `var' = . if treatedin1 == 1 & year == 2
		local variable_label : variable label `var'
				
			forval y = 1/2 {
			
			if `y' == 1 {
				reg `var' treated##c.b_total_reserve##c.b_total_reserve $blocks if year == `y', cl(vid) 
			}
				else {
					reg `var' treated##c.b_total_reserve##c.b_total_reserve##i.treatedin1 $blocks if year == `y', cl(vid)
					}
					
			local i = 0
			foreach rhs in 1.treated b_total_reserve 1.treated#c.b_total_reserve c.b_total_reserve#c.b_total_reserve 1.treated#c.b_total_reserve#c.b_total_reserve {
				local i = `i'+1
				
				local b`i'_`var' : display %-4.3f _b[`rhs']
				local se`i'_`var' : display %-4.3f _se[`rhs']
				
				}
				
			sum `var' if treated == 0 & year == 1
			local mean_`var' : display %-4.2f `r(mean)'
			
			margins treated, at(c.b_total_reserve = (`quarts')) post
			
			replace meff = .
			replace hi = .
			replace lo = .
			
		forval i = 1/4 {
			sum b_total_reserve if b_reserves_q == `i'
			replace meff = _b[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace meff = _b[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			}
				}
		
		}
***** Column 5 *****
	ren adult_nshima_1w nshima
	foreach var in nshima food_short { 
	
		local variable_label : variable label `var'
				
			forval y = 1/2 {
	
			if `y' == 1 {
			reg `var' treated##c.b_total_reserve##c.b_total_reserve i.monthyear $blocks if year == `y' & calendar_month < 4, cl(vid) 
			}
				else {
					reg `var' treated##c.b_total_reserve##c.b_total_reserve##i.treatedin1 i.monthyear $blocks if year == `y' & calendar_month < 4, cl(vid) 
					}

			local i = 0
			foreach rhs in 1.treated b_total_reserve 1.treated#c.b_total_reserve c.b_total_reserve#c.b_total_reserve 1.treated#c.b_total_reserve#c.b_total_reserve {
				local i = `i'+1
				
				local b`i'_`var' : display %-4.3f _b[`rhs']
				local se`i'_`var' : display %-4.3f _se[`rhs']
				
				}
				
			sum `var' if treated == 0 & year == 1
			local mean_`var' : display %-4.2f `r(mean)'
			
			margins treated, at(c.b_total_reserve = (`quarts')) post
			
			replace meff = .
			replace hi = .
			replace lo = .
			
		forval i = 1/4 {
			sum b_total_reserve if b_reserves_q == `i'
			replace meff = _b[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace meff = _b[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#0.treated] if b_reserves_q == `i' & treated == 0 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#1.treated] if b_reserves_q == `i' & treated == 1 & e(sample)
			}
				}
		
		}
				file write het "Any loan treatment & `b1_work_hours' & `b1_hire_hours' & `b1_fam_hours' & `b1_l_harvest_value' & `b1_nshima' \\" _n
		file write het " & (`se1_work_hours') & (`se1_hire_hours') & (`se1_fam_hours') & (`se1_l_harvest_value') & (`se1_nshima') \\" _n
		file write het "Baseline reserves & `b2_work_hours' & `b2_hire_hours' & `b2_fam_hours' & `b2_l_harvest_value' & `b2_nshima' \\" _n
		file write het " & (`se2_work_hours') & (`se2_hire_hours') & (`se2_fam_hours') & (`se2_l_harvest_value') & (`se2_nshima') \\" _n
		file write het "Loan x Reserves & `b3_work_hours' & `b3_hire_hours' & `b3_fam_hours' & `b3_l_harvest_value' & `b3_nshima' \\" _n
		file write het " & (`se3_work_hours') & (`se3_hire_hours') & (`se3_fam_hours') & (`se3_l_harvest_value') & (`se3_nshima') \\" _n
		file write het "Reserves$^2$ & `b4_work_hours' & `b4_hire_hours' & `b4_fam_hours' & `b4_l_harvest_value' & `b4_nshima' \\" _n
		file write het " & (`se4_work_hours') & (`se4_hire_hours') & (`se4_fam_hours') & (`se4_l_harvest_value') & (`se4_nshima') \\" _n
		file write het "Loan x Reserves$^2$ & `b5_work_hours' & `b5_hire_hours' & `b5_fam_hours' & `b5_l_harvest_value' & `b5_nshima' \\" _n
		file write het " & (`se5_work_hours') & (`se5_hire_hours') & (`se5_fam_hours') & (`se5_l_harvest_value') & (`se5_nshima') \\" _n
		file write het "Year 1 control mean & `mean_work_hours' & `mean_hire_hours' & `mean_fam_hours' & `mean_l_harvest_value' & `mean_nshima' \\" _n

		file write het "\hline" _n
		file write het "\end{tabular}" _n
		file close het
		
************** Appendix table 8: Consumption smoothing alternatives **************************

use "$data/household_panel_final", clear 
***** Setup *****			
		local Y1coef "Any loan treatment"
		local Y1std ""
		local Y2coef "Any loan treatment"
		local Y2std ""
		local Y2_1coef "Treated in Y1"
		local Y2_1std ""
		local Y2_intcoef "Loan x Treated in Y1"
		local Y2_intstd ""
		local cashcoef "Cash"
		local cashstd ""
		local maizecoef "Maize"
		local maizestd ""
		
		local meanline1 "Year 1 control mean"
		local meanline2 "Year 2 control mean"
		local Y2_totcoef "Loan + Y1 + Loan x Y1"
		local Y2_totstd ""
		local pval1 "Year 1 = Year 2 new"
		local pval2 "Year 1 = Year 2 repeat"
		local pval3 "Cash = Maize"
		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/B8.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc cc}" _n
	file write table "\hline" _n
	file write table " & Input loan & Low interest & High interest & Sold asset & Sold livestock & Green maize \\ " _n
	file write table " & & informal loan & informal loan & & &  \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5) & (6)  \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n

***** Panel A *****		
file write table "\multicolumn{7}{c}{A. Year 1 - Pooled treatment arms} \\ " _n

	local outcomes loan_taken_clean nkhon_clean kaloba_clean sell_asset sell_animal
** Columns 1-5 **	
	foreach var in `outcomes' {
			
		reg `var' i.treated i.year `var'_bl $controls $blocks if year == 1, cl(vid) 
				
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
** Column 6 **
	local outcomes green_maize_1w 
	
	foreach var in `outcomes' {
	
		reg `var' i.treated i.monthyear $controls $blocks if year == 1 & survey_round > 3, cl(vid) 
				
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
					file write table "`Y1coef' \\" _n
					file write table "`Y1std' \\" _n
					file write table " \\ " _n
			
***** Panel B *****	
file write table "\multicolumn{7}{c}{B. Year 2 - Pooled treatment arms} \\ " _n
		 
	local outcomes loan_taken_clean nkhon_clean kaloba_clean sell_asset sell_animal
** Columns 1-5 **
	foreach var in `outcomes' {
	
			reg `var' i.treated##i.treatedin1 i.year $controls $blocks if year == 2, cl(vid) 
						
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					local b2 : display %-4.3f _b[1.treatedin1]
					local se2 : display %-4.3f _se[1.treatedin1]
					local b3 : display %-4.3f _b[1.treated#1.treatedin1]
					local se3 : display %-4.3f _se[1.treated#1.treatedin1]
					
					lincom 1.treated+1.treatedin1+1.treated#1.treatedin1
					
					local b4 : display %-4.3f `r(estimate)'
					local se4 : display %-4.3f `r(se)'


					local Y2_totcoef "`Y2_totcoef' & `b4'"
					local Y2_totstd "`Y2_totstd' & (`se4')"
					
					local Y2coef "`Y2coef' & `b1'"
					local Y2std "`Y2std' & (`se1')"
					local Y2_1coef "`Y2_1coef' & `b2'"
					local Y2_1std "`Y2_1std' & (`se2')"
					local Y2_intcoef "`Y2_intcoef' & `b3'"
					local Y2_intstd "`Y2_intstd' & (`se3')"

					}

** Column 6 **	
	local outcomes green_maize_1w 
	
	foreach var in `outcomes' {
	
			reg `var' i.treated##i.treatedin1 i.monthyear $controls $blocks if year == 2 & survey_round > 3, cl(vid) 
						
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					local b2 : display %-4.3f _b[1.treatedin1]
					local se2 : display %-4.3f _se[1.treatedin1]
					local b3 : display %-4.3f _b[1.treated#1.treatedin1]
					local se3 : display %-4.3f _se[1.treated#1.treatedin1]
					
					lincom 1.treated+1.treatedin1+1.treated#1.treatedin1
			
					local b4 : display %-4.3f `r(estimate)'
					local se4 : display %-4.3f `r(se)'


					local Y2_totcoef "`Y2_totcoef' & `b4'"
					local Y2_totstd "`Y2_totstd' & (`se4')"
					
					local Y2coef "`Y2coef' & `b1'"
					local Y2std "`Y2std' & (`se1')"
					local Y2_1coef "`Y2_1coef' & `b2'"
					local Y2_1std "`Y2_1std' & (`se2')"
					local Y2_intcoef "`Y2_intcoef' & `b3'"
					local Y2_intstd "`Y2_intstd' & (`se3')"

					}
					
					file write table "`Y2coef' \\" _n
					file write table "`Y2std' \\" _n
					file write table "`Y2_1coef' \\" _n
					file write table "`Y2_1std' \\" _n
					file write table "`Y2_intcoef' \\" _n
					file write table "`Y2_intstd' \\" _n
					file write table " \\ " _n
					file write table "`Y2_totcoef' \\" _n
					file write table "`Y2_totstd' \\" _n
					file write table " \\ " _n			

***** Panel C *****					
file write table "\multicolumn{7}{c}{C. By treatment arm - Pooled years} \\ " _n

	local outcomes loan_taken_clean nkhon_clean kaloba_clean sell_asset sell_animal 	
** Columns 1-5 **	
		foreach var in `outcomes' {
	
			reg `var' i.treatment##i.treatedin1 i.year $controls $blocks if year > 0, cl(vid) 
			margins, dydx(treatment) post
			test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"

			local b1 : display %-4.3f _b[2.treatment]
			local se1 : display %-4.3f _se[2.treatment]

			local b2 : display %-4.3f _b[3.treatment]
			local se2 : display %-4.3f _se[3.treatment]
					
					local cashcoef "`cashcoef' & `b1'"
					local cashstd "`cashstd' & (`se1')"
					local maizecoef "`maizecoef' & `b2'"
					local maizestd "`maizestd' & (`se2')"
					
					sum `var' if treated == 0 & year == 1
					local mean : display %-4.2f `r(mean)'
					local meanline1 "`meanline1' & `mean'"
					
					sum `var' if treated == 0 & treatedin1 == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					local N : display %9.0gc `e(N)'
					local Nline "`Nline' & `N'"
					
					qui reg `var' i.treated##i.treatedin1##i.year $controls $blocks  if year > 0, cl(vid) 
					
					test 1.treated = 1.treated#2.year
					local pv1 : display %-4.2f `r(p)'
					local pval1 "`pval1' & `pv1'"
					
					test 1.treated = (1.treated#2.year + 1.treated#1.treatedin1 + 1.treatedin1)
					local pv2 : display %-4.2f `r(p)'
					local pval2 "`pval2' & `pv2'"
					
					}
** Column 6 **	
	local outcomes green_maize_1w 
	
	foreach var in `outcomes' {
	
			reg `var' i.treatment##i.treatedin1 i.year $controls $blocks if year > 0 & survey_round > 3, cl(vid) 
			margins, dydx(treatment) post
			test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"

			local b1 : display %-4.3f _b[2.treatment]
			local se1 : display %-4.3f _se[2.treatment]

			local b2 : display %-4.3f _b[3.treatment]
			local se2 : display %-4.3f _se[3.treatment]
					
					local cashcoef "`cashcoef' & `b1'"
					local cashstd "`cashstd' & (`se1')"
					local maizecoef "`maizecoef' & `b2'"
					local maizestd "`maizestd' & (`se2')"
					
					sum `var' if treated == 0 & year == 1
					local mean : display %-4.2f `r(mean)'
					local meanline1 "`meanline1' & `mean'"
					
					sum `var' if treated == 0 & treatedin1 == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					local N : display %9.0gc `e(N)'
					local Nline "`Nline' & `N'"
					
					qui reg `var' i.treated##i.treatedin1##i.year $controls $blocks  if year > 0, cl(vid) 
					
					test 1.treated = 1.treated#2.year
					local pv1 : display %-4.2f `r(p)'
					local pval1 "`pval1' & `pv1'"
					
					test 1.treated = (1.treated#2.year + 1.treated#1.treatedin1 + 1.treatedin1)
					local pv2 : display %-4.2f `r(p)'
					local pval2 "`pval2' & `pv2'"
					
					}
					
					file write table "`cashcoef' \\" _n
					file write table "`cashstd' \\" _n
					file write table "`maizecoef' \\" _n
					file write table "`maizestd' \\" _n
					file write table " \\ " _n	
					file write table "\hline" _n	
					
					file write table "`meanline1' \\" _n
					file write table "`meanline2' \\" _n
					
					file write table "`pval1' \\" _n
					file write table "`pval2' \\" _n
					file write table "`pval3' \\" _n
					file write table "`Nline' \\" _n
					file write table "\hline" _n
			
		
		file write table "\end{tabular}" _n	
		file close table	

 
*********************** Appendix table 9: Health channel *************************************

use "$data/household_panel_final", clear 
***** Setup *****	
	est clear
	
	keep if calendar_month < 4
	
	local outcomes hlth_ill_filter   

	local outcomes2 SR_health_PCA weeds_acre_hour hlth_biceps_clean hlth_waist_clean hlth_grip_num hlth_grip_sec  
		
		local Y1coef "Any loan treatment &  "
		local Y1std " & "
		local Y2coef "Any loan treatment"
		local Y2std ""
		local Y2_1coef "Treated in Y1"
		local Y2_1std ""
		local Y2_intcoef "Loan x Treated in Y1"
		local Y2_intstd ""
		local cashcoef "Cash"
		local cashstd ""
		local maizecoef "Maize"
		local maizestd ""
		
		local meanline1 "Year 1 control mean"
		local meanline2 "Year 2 control mean"
		local Y2_totcoef "Loan + Y1 + Loan x Y1"
		local Y2_totstd ""
		local pval1 "Year 1 = Year 2 new & "
		local pval2 "Year 1 = Year 2 repeat & "
		local pval3 "Cash = Maize"
		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/B9.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc ccccc}" _n
	file write table "\hline" _n
	file write table " & Any illness & Self-reported & Acres weeded & Bicep & Waist & Grip strength & Grip strength \\ " _n
	file write table " & & health PCA & per hour & circumfrence & circumfrence & repetitions & duration \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5) & (6) & (7) \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n

***** Panel A *****		
	file write table "\multicolumn{8}{c}{A. Year 1 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes2' {
	
			reg `var' i.treated i.monthyear $controls $blocks $id if year == 1, cl(vid) 
	
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
					file write table "`Y1coef' \\" _n
					file write table "`Y1std' \\" _n
					file write table " \\ " _n
			
***** Panel B *****
	file write table "\multicolumn{8}{c}{B. Year 2 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' `outcomes2' {
	
			reg `var' i.treated##i.treatedin1 i.monthyear $controls $blocks $id if year == 2, cl(vid) 
				
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					local b2 : display %-4.3f _b[1.treatedin1]
					local se2 : display %-4.3f _se[1.treatedin1]
					local b3 : display %-4.3f _b[1.treated#1.treatedin1]
					local se3 : display %-4.3f _se[1.treated#1.treatedin1]
					
					lincom 1.treated+1.treatedin1+1.treated#1.treatedin1
					
					local b4 : display %-4.3f `r(estimate)'
					local se4 : display %-4.3f `r(se)'


					local Y2_totcoef "`Y2_totcoef' & `b4'"
					local Y2_totstd "`Y2_totstd' & (`se4')"
					local Y2coef "`Y2coef' & `b1'"
					local Y2std "`Y2std' & (`se1')"
					local Y2_1coef "`Y2_1coef' & `b2'"
					local Y2_1std "`Y2_1std' & (`se2')"
					local Y2_intcoef "`Y2_intcoef' & `b3'"
					local Y2_intstd "`Y2_intstd' & (`se3')"

					}
					
					file write table "`Y2coef' \\" _n
					file write table "`Y2std' \\" _n
					file write table "`Y2_1coef' \\" _n
					file write table "`Y2_1std' \\" _n
					file write table "`Y2_intcoef' \\" _n
					file write table "`Y2_intstd' \\" _n
					file write table " \\ " _n
					file write table "`Y2_totcoef' \\" _n
					file write table "`Y2_totstd' \\" _n
					file write table " \\ " _n			
***** Panel C *****
					
	file write table "\multicolumn{8}{c}{C. By treatment arm - Pooled years} \\ " _n
		
		foreach var in `outcomes' `outcomes2' {
	
			reg `var' i.treatment##i.treatedin1 i.monthyear $controls $blocks $id, cl(vid) 
			margins, dydx(treatment) post
			test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"

			local b1 : display %-4.3f _b[2.treatment]
			local se1 : display %-4.3f _se[2.treatment]
					
			
			local b2 : display %-4.3f _b[3.treatment]
			local se2 : display %-4.3f _se[3.treatment]
			
					local cashcoef "`cashcoef' & `b1'"
					local cashstd "`cashstd' & (`se1')"
					local maizecoef "`maizecoef' & `b2'"
					local maizestd "`maizestd' & (`se2')"
					
					sum `var' if treated == 0 & year == 1
					local mean : display %-4.2f `r(mean)'
					local meanline1 "`meanline1' & `mean'"
					
					sum `var' if treated == 0 & treatedin1 == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					local N : display %9.0gc `e(N)'
					local Nline "`Nline' & `N'"
					
					}
					
			foreach var in `outcomes2' {		
			
				qui reg `var' i.treated##i.treatedin1##i.year i.monthyear $controls $blocks $id, cl(vid) 
					
					test 1.treated = 1.treated#2.year
					local pv1 : display %-4.2f `r(p)'
					local pval1 "`pval1' & `pv1'"
					
					test 1.treated = (1.treated#2.year + 1.treated#1.treatedin1 + 1.treatedin1)
					local pv2 : display %-4.2f `r(p)'
					local pval2 "`pval2' & `pv2'"
					
					}
					
					file write table "`cashcoef' \\" _n
					file write table "`cashstd' \\" _n
					file write table "`maizecoef' \\" _n
					file write table "`maizestd' \\" _n
					file write table " \\ " _n	
					file write table "\hline" _n	
					
					file write table "`meanline1' \\" _n
					file write table "`meanline2' \\" _n
					
					file write table "`pval1' \\" _n
					file write table "`pval2' \\" _n
					file write table "`pval3' \\" _n
					file write table "`Nline' \\" _n
					file write table "\hline" _n
			
		
		file write table "\end{tabular}" _n	
		file close table

		
	

**************** Appendix table 10: Cognition and decision-making ****************************

use "$data/household_panel_final", clear 
***** Setup *****
	keep if calendar_month < 4
	
	local outcomes2 expend_clothes expend_beer expend_tobacco expend_sweets expend_tea 
	local outcomes raven_Z stroop_automated_Z2 stroop_automated_Z3 

		local Y1coef "Any loan treatment "
		local Y1std " "
	
		local Y2coef "Any loan treatment & & & & & "
		local Y2std "  & & & & & "
		local Y2_1coef "Treated in Y1 & & & & & "
		local Y2_1std " & & & & & "
		local Y2_intcoef "Loan x Treated in Y1 & & & & & "
		local Y2_intstd " & & & & & "
		
		local cashcoef "Cash"
		local cashstd ""
		local maizecoef "Maize"
		local maizestd ""
		
		local meanline1 "Year 1 control mean"
		local meanline2 "Year 2 control mean"
		local Y2_totcoef "Loan + Y1 + Loan x Y1 & & & & &"
		local Y2_totstd " & & & & & "
		local pval3 "Cash = Maize"
		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/B10.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc c ccc}" _n
	file write table "\hline" _n
	file write table " & \multicolumn{5}{c}{Expenditure on} & \multicolumn{3}{c}{Performance on} \\ "
	file write table " & Clothing & Beer & Tobacco & Sweets & Tea & Ravens & Stroops 2 & Stroops 3  \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n
***** Panel A *****
	file write table "\multicolumn{9}{c}{A. Year 1 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes2' {
	
			reg `var' i.treated i.monthyear $controls $blocks if year == 1, cl(vid) 
				
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
					file write table "`Y1coef' & & &  \\" _n
					file write table "`Y1std' & & &  \\" _n
					file write table " \\ " _n
			
***** Panel B *****	
	file write table "\multicolumn{9}{c}{B. Year 2 - Pooled treatment arms} \\ " _n

		foreach var in `outcomes' {
	
			reg `var' i.treated##i.treatedin1 i.monthyear $controls $blocks $id if year == 2, cl(vid) 
				
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					local b2 : display %-4.3f _b[1.treatedin1]
					local se2 : display %-4.3f _se[1.treatedin1]
					local b3 : display %-4.3f _b[1.treated#1.treatedin1]
					local se3 : display %-4.3f _se[1.treated#1.treatedin1]
					
					lincom 1.treated+1.treatedin1+1.treated#1.treatedin1
						
					local b4 : display %-4.3f `r(estimate)'
					local se4 : display %-4.3f `r(se)'


					local Y2_totcoef "`Y2_totcoef' & `b4'"
					local Y2_totstd "`Y2_totstd' & (`se4')"
					local Y2coef "`Y2coef' & `b1'"
					local Y2std "`Y2std' & (`se1')"
					local Y2_1coef "`Y2_1coef' & `b2'"
					local Y2_1std "`Y2_1std' & (`se2')"
					local Y2_intcoef "`Y2_intcoef' & `b3'"
					local Y2_intstd "`Y2_intstd' & (`se3')"

					}
					
					file write table "`Y2coef' \\" _n
					file write table "`Y2std' \\" _n
					file write table "`Y2_1coef' \\" _n
					file write table "`Y2_1std' \\" _n
					file write table "`Y2_intcoef' \\" _n
					file write table "`Y2_intstd' \\" _n
					file write table " \\ " _n
					file write table "`Y2_totcoef' \\" _n
					file write table "`Y2_totstd' \\" _n
					file write table " \\ " _n	
		
***** Panel C *****	
	file write table "\multicolumn{9}{c}{B. By treatment arm} \\ " _n

	foreach var in `outcomes2' `outcomes' {

			reg `var' i.treatment i.monthyear $controls $blocks, cl(vid) 
					
					local b1 : display %-4.3f _b[2.treatment]
					local se1 : display %-4.3f _se[2.treatment]
					local b2 : display %-4.3f _b[3.treatment]
					local se2 : display %-4.3f _se[3.treatment]
					
					local cashcoef "`cashcoef' & `b1'"
					local cashstd "`cashstd' & (`se1')"
					local maizecoef "`maizecoef' & `b2'"
					local maizestd "`maizestd' & (`se2')"
					
					test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"
					
					sum `var' if treated == 0 & year == 1
					local mean : display %-4.2f `r(mean)'
					local meanline1 "`meanline1' & `mean'"
					
					sum `var' if treated == 0 & treatedin1 == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					local N : display %9.0gc `e(N)'
					local Nline "`Nline' & `N'"
					
					}

					
					file write table "`cashcoef' \\" _n
					file write table "`cashstd' \\" _n
					file write table "`maizecoef' \\" _n
					file write table "`maizestd' \\" _n
					file write table " \\ " _n	
					file write table "\hline" _n	
					
					file write table "`meanline1' \\" _n
					file write table "`meanline2' \\" _n
					
					file write table "`pval3' \\" _n
					file write table "`Nline' \\" _n
					file write table "\hline" _n
			
		
		file write table "\end{tabular}" _n	
		file close table
	

		
****************** Appendix Table 11: Affect and motivation **********************************

use "$data/household_panel_final", clear 
***** Setup *****	
	est clear
	
	keep if calendar_month < 4
	
	local outcomes mental_health mental_nervous mental_sleep mental_dailywork mental_easilytired

	local outcomes2 fi_worry_filter  
		
		local Y1coef "Any loan treatment & & & & & "
		local Y1std " & & & & & "
		local Y2coef "Any loan treatment"
		local Y2std ""
		local Y2_1coef "Treated in Y1"
		local Y2_1std ""
		local Y2_intcoef "Loan x Treated in Y1"
		local Y2_intstd ""
		local cashcoef "Cash"
		local cashstd ""
		local maizecoef "Maize"
		local maizestd ""
		
		local meanline1 "Year 1 control mean"
		local meanline2 "Year 2 control mean"
		local Y2_totcoef "Loan + Y1 + Loan x Y1"
		local Y2_totstd ""
		local pval1 "Year 1 = Year 2 new  & & & & &"
		local pval2 "Year 1 = Year 2 repeat & & & & &"
		local pval3 "Cash = Maize"
		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/B11.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc cc}" _n
	file write table "\hline" _n
	file write table " & Mental health & Feel & Trouble  & Affect & Easily & Worried \\ " _n
	file write table " & problem index & anxious & sleeping & daily work & tired & about food \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5) & (6)  \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n

***** Panel A *****	
	file write table "\multicolumn{7}{c}{A. Year 1 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes2' {
	
			reg `var' i.treated i.monthyear $controls $blocks $id if year == 1, cl(vid) 
				
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
					file write table "`Y1coef' \\" _n
					file write table "`Y1std' \\" _n
					file write table " \\ " _n
			
***** Panel B *****	
	file write table "\multicolumn{7}{c}{B. Year 2 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' `outcomes2' {
	
			reg `var' i.treated##i.treatedin1 i.monthyear $controls $blocks $id if year == 2, cl(vid) 
					
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					local b2 : display %-4.3f _b[1.treatedin1]
					local se2 : display %-4.3f _se[1.treatedin1]
					local b3 : display %-4.3f _b[1.treated#1.treatedin1]
					local se3 : display %-4.3f _se[1.treated#1.treatedin1]
					
					lincom 1.treated+1.treatedin1+1.treated#1.treatedin1
				
					local b4 : display %-4.3f `r(estimate)'
					local se4 : display %-4.3f `r(se)'


					local Y2_totcoef "`Y2_totcoef' & `b4'"
					local Y2_totstd "`Y2_totstd' & (`se4')"
					
					local Y2coef "`Y2coef' & `b1'"
					local Y2std "`Y2std' & (`se1')"
					local Y2_1coef "`Y2_1coef' & `b2'"
					local Y2_1std "`Y2_1std' & (`se2')"
					local Y2_intcoef "`Y2_intcoef' & `b3'"
					local Y2_intstd "`Y2_intstd' & (`se3')"

					}
					
					file write table "`Y2coef' \\" _n
					file write table "`Y2std' \\" _n
					file write table "`Y2_1coef' \\" _n
					file write table "`Y2_1std' \\" _n
					file write table "`Y2_intcoef' \\" _n
					file write table "`Y2_intstd' \\" _n
					file write table " \\ " _n
					file write table "`Y2_totcoef' \\" _n
					file write table "`Y2_totstd' \\" _n
					file write table " \\ " _n			

***** Panel C *****					
	file write table "\multicolumn{7}{c}{C. By treatment arm - Pooled years} \\ " _n
		
		foreach var in `outcomes' `outcomes2' {
	
			reg `var' i.treatment##i.treatedin1 i.monthyear $controls $blocks $id, cl(vid) 
			margins, dydx(treatment) post
			test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"

			local b1 : display %-4.3f _b[2.treatment]
			local se1 : display %-4.3f _se[2.treatment]
					
				
			local b2 : display %-4.3f _b[3.treatment]
			local se2 : display %-4.3f _se[3.treatment]
					
				
					local cashcoef "`cashcoef' & `b1'"
					local cashstd "`cashstd' & (`se1')"
					local maizecoef "`maizecoef' & `b2'"
					local maizestd "`maizestd' & (`se2')"
					
					sum `var' if treated == 0 & year == 1
					local mean : display %-4.2f `r(mean)'
					local meanline1 "`meanline1' & `mean'"
					
					sum `var' if treated == 0 & treatedin1 == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					local N : display %9.0gc `e(N)'
					local Nline "`Nline' & `N'"
					
					}
					
			foreach var in `outcomes2' {		
			
				qui reg `var' i.treated##i.treatedin1##i.year i.monthyear $controls $blocks $id, cl(vid) 
					
					test 1.treated = 1.treated#2.year
					local pv1 : display %-4.2f `r(p)'
					local pval1 "`pval1' & `pv1'"
					
					test 1.treated = (1.treated#2.year + 1.treated#1.treatedin1 + 1.treatedin1)
					local pv2 : display %-4.2f `r(p)'
					local pval2 "`pval2' & `pv2'"
					
					}
					
					file write table "`cashcoef' \\" _n
					file write table "`cashstd' \\" _n
					file write table "`maizecoef' \\" _n
					file write table "`maizestd' \\" _n
					file write table " \\ " _n	
					file write table "\hline" _n	
					
					file write table "`meanline1' \\" _n
					file write table "`meanline2' \\" _n
					
					file write table "`pval1' \\" _n
					file write table "`pval2' \\" _n
					file write table "`pval3' \\" _n
					file write table "`Nline' \\" _n
					file write table "\hline" _n
			
		
		file write table "\end{tabular}" _n	
		file close table

	
******************** Appendix table 12: Notification timing **********************************
		
use "$data/household_panel_final", clear 
***** Setup *****
		local Y2coef "Any loan treatment"
		local Y2std ""
		local Y2_intcoef "Loan x Early"
		local Y2_intstd " "
		
		local meanline2 "Year 2 control mean"

		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/B12.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc cc c}" _n
	file write table "\hline" _n
	file write table " & Hours sold & Hours hired & Hours on- & Log output & Adult meals & Acres cash & Input value \\ " _n
	file write table " & & & farm (family) & & & crops &  \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5) & (6) & (7)  \\ " _n
	file write table "\hline" _n

***** Columns 1-3 *****
	local outcomes work_hours hire_hours fam_hours
	
	foreach var in `outcomes' {
	
		reg `var' i.treated##i.treatedin1 notification##i.treatedin1 i.monthyear $controls $blocks if year == 2 & calendar_month < 4, cl(vid) 
			

					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
					local b_int : display %-4.3f _b[1.notification]
					local se_int : display %-4.3f _se[1.notification]
					
					local Y2coef "`Y2coef' & `b'"
					local Y2std "`Y2std' & (`se')"
					local Y2_intcoef "`Y2_intcoef' & `b_int' "
					local Y2_intstd "`Y2_intstd' & (`se_int')"
		
					sum `var' if treated == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					}

***** Column 4 *****
	local outcomes l_harvest_value 
	
	foreach var in `outcomes' {
	
		reg `var' i.treated##i.treatedin1 notification##i.treatedin1 $controls $blocks if year == 2, cl(vid) 

					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
					local b_int : display %-4.3f _b[1.notification]
					local se_int : display %-4.3f _se[1.notification]
					
					local Y2coef "`Y2coef' & `b'"
					local Y2std "`Y2std' & (`se')"
					local Y2_intcoef "`Y2_intcoef' & `b_int' "
					local Y2_intstd "`Y2_intstd' & (`se_int')"

					sum `var' if treated == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					}
***** Column 5 *****
					
	local outcomes adult_nshima_1w
	
	foreach var in `outcomes' {
	
		reg `var' i.treated##i.treatedin1 notification##i.treatedin1 $controls $blocks if year == 2 & calendar_month < 4, cl(vid) 

					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
					local b_int : display %-4.3f _b[1.notification]
					local se_int : display %-4.3f _se[1.notification]
					
					local Y2coef "`Y2coef' & `b'"
					local Y2std "`Y2std' & (`se')"
					local Y2_intcoef "`Y2_intcoef' & `b_int'"
					local Y2_intstd "`Y2_intstd' & (`se_int')"

					sum `var' if treated == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"
					
					}

	drop l_harvest_value_bl
***** Columnns 6 & 7 *****
	local outcomes inputs_kw_value acres_cash_crops 
	
	foreach var in `outcomes' {
	
		reg `var' i.treated##i.treatedin1 notification##i.treatedin1 $controls $blocks if year == 2, cl(vid) 
							
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
					local b_int : display %-4.3f _b[1.notification]
					local se_int : display %-4.3f _se[1.notification]
					
					local Y2coef "`Y2coef' & `b'"
					local Y2std "`Y2std' & (`se')"
					local Y2_intcoef "`Y2_intcoef' & `b_int'"
					local Y2_intstd "`Y2_intstd' & (`se_int')"
					
					sum `var' if treated == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline2 "`meanline2' & `mean'"

					}
					
					
					file write table "`Y2coef' \\" _n
					file write table "`Y2std' \\" _n
					file write table "`Y2_intcoef' \\" _n
					file write table "`Y2_intstd' \\" _n
					file write table "\hline" _n
					
					file write table "`meanline2' \\" _n

					file write table " \hline " _n
					file write table "\end{tabular} \\" _n
					file close table
					
	
********************** Appendix table 13: Income effect control ******************************
		
use "$data/household_panel_final", clear 
***** Setup *****
		local coef "Control gift"
		local std ""
	
		local meanline "Pure control mean"

		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/B13.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc c}" _n
	file write table "\hline" _n
	file write table " & Hours sold & Hours hired & Hours on- & Log output & Adult meals \\ " _n
	file write table " & & & farm (family) & &  \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5)   \\ " _n
	file write table "\hline" _n
***** Columns 1-3 *****
	local outcomes work_hours hire_hours fam_hours

	foreach var in `outcomes' {
	
		reg `var' control_gift##i.treatedin1 i.monthyear $controls $blocks if treated == 0 & calendar_month < 4, cl(vid) 
				
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
					
					local coef "`coef' & `b'"
					local std "`std' & (`se')"

					
					sum `var' if treated == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline "`meanline' & `mean'"		
					}
***** Column 4 *****
	local outcomes l_harvest_value 
	
	foreach var in `outcomes' {
	
		reg `var' control_gift##i.treatedin1 i.year $controls $blocks if treated == 0, cl(vid) 

					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
					
					local coef "`coef' & `b'"
					local std "`std' & (`se')"
					
					sum `var' if treated == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline "`meanline' & `mean'"
					}
***** Column 5 *****
	local outcomes adult_nshima_1w
	
	foreach var in `outcomes' {
	
				reg `var' control_gift##i.treatedin1 i.monthyear $controls $blocks if treated == 0 & calendar_month < 4, cl(vid) 
				
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
					
					local coef "`coef' & `b'"
					local std "`std' & (`se')"
					
					sum `var' if treated == 0 & year == 2
					local mean : display %-4.2f `r(mean)'
					local meanline "`meanline' & `mean'"

					}
		
					
					file write table "`coef' \\" _n
					file write table "`std' \\" _n
					file write table "\hline " _n
					
					file write table "`meanline' \\" _n
					
					file write table " \hline " _n
					file write table "\end{tabular} \\" _n
					file close table

	
********************** Appendix table 14: Reporting bias *************************************

use "$data/reporting_bias_final.dta", clear
***** Setup ******
		local coef "Any loan treatment"
		local std ""
		local cashcoef "Cash"
		local cashstd " "
		local maizecoef "Maize"
		local maizestd " "
		local meanline "Control mean"
		local meanline2 "Control mean"

		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/B14.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc}" _n
	file write table "\hline" _n
	file write table " & \multicolumn{4}{c}{A. Social desirability bias} \\ " _n
	file write table " & \multicolumn{2}{c}{Labor survey} & \multicolumn{2}{c}{Endline survey} \\ " _n
	file write table " & (1) & (2) & (3) & (4) \\ " _n
	file write table "\hline" _n
***** Panel A *****
	foreach	var in ls3_bias_score e_bias_score {
	
		reg `var' treated treatedin1, cl(vid)

			local b : display %-4.3f _b[treated]
			local se : display %-4.3f _se[treated]
					
			local coef "`coef' & `b'"
			local std "`std' & (`se')"
			local maizecoef "`maizecoef' & "
			local maizestd "`maizestd' & "
			local cashcoef "`cashcoef' & "
			local cashstd "`cashstd' & "
			
			sum `var' if treated == 0 & treatedin1 == 0
			local mean : display %-4.2f `r(mean)'
			local meanline "`meanline' & `mean'"
		
		reg `var' i.treatment treatedin1, cl(vid)

			local b_c : display %-4.3f _b[2.treatment]
			local se_c : display %-4.3f _se[2.treatment]

			local b_m : display %-4.3f _b[3.treatment]
			local se_m : display %-4.3f _se[3.treatment]
			
			local coef "`coef' & "
			local std "`std' & "
			local maizecoef "`maizecoef' & `b_m'"
			local maizestd "`maizestd' & (`se_m')"
			local cashcoef "`cashcoef' & `b_c'"
			local cashstd "`cashstd' & (`se_c')"
			
			sum `var' if treated == 0 & treatedin1 == 0
			local mean : display %-4.2f `r(mean)'
			local meanline "`meanline' & `mean'"
	
		}
	
	file write table "`coef' \\ " _n
	file write table "`std' \\ " _n
	file write table "`cashcoef' \\ " _n
	file write table "`cashstd' \\ " _n
	file write table "`maizecoef' \\ " _n
	file write table "`maizestd' \\ " _n
	file write table "`meanline' \\ " _n
	
	file write table "\hline" _n
	file write table " & \multicolumn{4}{c}{B. Self-reported maize yields} \\ " _n
	file write table " & \multicolumn{2}{c}{Year 1} & \multicolumn{2}{c}{Year 2} \\ " _n
	file write table " & (1) & (2) & (3) & (4) \\ " _n
	file write table "\hline" _n

***** Panel B *****	
use "$data/yield_checks_final.dta", clear

		local obj "Objective measure"
		local objstd " "
		local coef "Any loan treatment"
		local std " "
		local int_coef "Objective measure x Loan"
		local int_std " "
		
		local meanline2 "Control mean"

		local Nline "Observations"

	foreach year in 1 2 {
	
		reg sr_yields_acre objective sr_share_hybrid if analysis==1 & year == `year', cl(vid)

			local b_obj : display %-4.3f _b[objective]
			local se_obj : display %-4.3f _se[objective]
					
			local obj "`obj' & `b_obj'"
			local objstd "`objstd' & (`se_obj')"
			local coef "`coef' & "
			local std "`std' & "
			local int_coef "`int_coef' & "
			local int_std "`int_std' & "
			
			sum sr_yields_acre if treated == 0 & treatedin1 == 0
			local mean : display %-4.2f `r(mean)'
			local meanline2 "`meanline2' & `mean'"
	
		reg sr_yields_acre c.objective##treated##treatedin1 sr_share_hybrid if analysis==1 & year == `year', cl(vid)	

			local b_obj : display %-4.3f _b[objective]
			local se_obj : display %-4.3f _se[objective]

			local b_obj : display %-4.3f _b[1.treated]
			local se_obj : display %-4.3f _se[1.treated]
	
			local b_int : display %-4.3f _b[1.treated#c.objective]
			local se_int : display %-4.3f _se[1.treated#c.objective]
			
			local obj "`obj' & `b_obj'"
			local objstd "`objstd' & (`se_obj')"
			local coef "`coef' & `b'"
			local std "`std' & (`se')"
			local int_coef "`int_coef' & `b_int'"
			local int_std "`int_std' & (`se_int')"
			
			sum sr_yields_acre if treated == 0 & treatedin1 == 0
			local mean : display %-4.2f `r(mean)'
			local meanline2 "`meanline2' & `mean'"
	
	}
						
	file write table "`obj' \\ " _n
	file write table "`objstd' \\ " _n
	file write table "`coef' \\ " _n
	file write table "`std' \\ " _n
	file write table "`int_coef' \\ " _n
	file write table "`int_std' \\ " _n
	file write table "`meanline2' \\ " _n
	
			file write table " \hline " _n
			file write table "\end{tabular} \\" _n
			file close table
