/* 
This file produces the main paper tables (1-7) for "Seasonal liquidity, rural labor markets and agricultural production"

Version: 1.0 

Last Updated: 07/11/2020

*/

clear all
set maxvar 10000
set more off
*********************************************************************************************
******************** 1. Specify directories and macros **************************************
*********************************************************************************************

cap cd "" //Insert your directory here
global data = "Data/Analysis"
global output = "Output/Main Tables"

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
************************** 2. Main text tables ********************************************** 
**********************************************************************************************


********************** Table 1: survey sample sizes *****************************************

	cap file close surveys
	file open surveys using ///
		"$output/T1.tex", ///
		write text replace
					
	file write surveys "\begin{tabular}{l cc cc }" _n
	file write surveys "\hline" _n
	file write surveys "Survey round & Dates & Observations & Hungry season  \\ " _n
	file write surveys " & & & observations  \\ " _n
	file write surveys "Baseline & Nov 2013-Dec 2013 & 3139 & 0 \\ " _n
	file write surveys "Harvest	& July 2014-Sept 2014 & 3028 & 	0 \\ " _n
	file write surveys "Endline & July 2015-Sept 2015 & 3005 & 0 \\ " _n
	file write surveys "Midline & Feb 2014-Apr 2014 & 1193 & 1190 \\ " _n
	file write surveys "Labor R1 & Jan 2014-July 2014 & 1276 & 778 \\ " _n
	file write surveys "Labor R2 & July 2014-Jan 2015 & 1333 & 376 \\ " _n
	file write surveys "Labor R3 & Jan 2015-Mar 2015 & 1388 & 1388 \\ " _n
	file write surveys "Labor R4 & April 2015-June 2015 & 680 & 0 \\ " _n
	file write surveys "Total & & 15042 & 4412 \\ " _n
	file write surveys "\hline" _n
	file write surveys "\end{tabular}" _n
	file close surveys
	
*********************** Table 2: Take up and repayment ***************************************
	
use "$data/admin_outcomes_final.dta", clear
	
	local outcomes takeup repay_all repay_pct repay_cash
	
	cap file close takeup_repay
	file open takeup_repay using ///
		"$output/T2.tex", ///
		write text replace
					
	file write takeup_repay "\begin{tabular}{l cc cc}" _n
	file write takeup_repay "\hline" _n
		
	file write takeup_repay "& Take up & Full & Percent & Repaid \\ " _n
	file write takeup_repay "&  & repayment & repaid & any cash \\ " _n
	file write takeup_repay " & (1) & (2) & (3) & (4) \\ " _n
	file write takeup_repay "\hline" _n
	file write takeup_repay "\\" _n
	file write takeup_repay "\multicolumn{5}{c}{Panel A: Year 1} \\" _n
	
	
	foreach out of local outcomes {
****Panel A Row 1****
		sum `out'1 if cash1 == 1
		local `out'_sum : display %-4.2f `r(mean)'
****Panel A Row 2****
		reg `out'1 maize1 , cl(vid)
		local b_`out' = _b[maize1]
		local b_`out' : display %-4.3f `b_`out''
		local se_`out' = _se[maize1]
		local se_`out' : display %-4.3f `se_`out''
		
		}
		
		file write takeup_repay "Cash loan mean & `takeup_sum' & `repay_all_sum' & `repay_pct_sum' & `repay_cash_sum' \\ " _n
		file write takeup_repay "\\" _tab "" _n
		file write takeup_repay "Maize loan & `b_takeup' & `b_repay_all' & `b_repay_pct' & `b_repay_cash' \\ " _n
		file write takeup_repay " & (`se_takeup') & (`se_repay_all') & (`se_repay_pct') & (`se_repay_cash') \\ " _n
	
		
	file write takeup_repay "\\" _n
	file write takeup_repay "\multicolumn{5}{c}{Panel B: Year 2} \\" _n
	
	foreach out of local outcomes {
****Panel B row 1****
		sum `out'2 if cash2 == 1
		local `out'_sum : display %-4.2f `r(mean)'
****Panel B row 2****
		reg `out'2 maize2 , cl(vid)
		local b_`out' = _b[maize2]
		local b_`out' : display %-4.3f `b_`out''
		local se_`out' = _se[maize2]
		local se_`out' : display %-4.3f `se_`out''
		
		}
		
		file write takeup_repay "Cash loan mean & `takeup_sum' & `repay_all_sum' & `repay_pct_sum' & `repay_cash_sum' \\ " _n
		file write takeup_repay "\\" _n
		file write takeup_repay "Maize loan & `b_takeup' & `b_repay_all' & `b_repay_pct' & `b_repay_cash' \\ " _n
		file write takeup_repay " & (`se_takeup') & (`se_repay_all') & (`se_repay_pct') & (`se_repay_cash') \\ " _n
		
****Panel B rows 3-5****
	foreach y1 in any_treat1 early cashonly  {
	
		foreach out of local outcomes {
		
			if "`y1'" == "any_treat1" {
			local label = "Treated in year 1" 
			local i = 1
			}
			else if "`y1'" == "any_nopay1" {
				local label = "Any default in village in year 1"
				local i = 2
				}
				else if "`y1'" == "early" {
					local label = "Early notification sub-treatment"
					local i = 3
					}
					else if "`y1'" == "cashonly" {
						local label = "Cash repayment sub-treatment"
						local i = 4
						}
		
			reg `out'2 `y1', cl(vid)
			local b_`out'`i' = _b[`y1']
			local b_`out'`i' : display %-4.3f `b_`out'`i''
			local se_`out'`i' = _se[`y1']
			local se_`out'`i' : display %-4.3f `se_`out'`i''
		
			}
	
		file write takeup_repay "`label' & `b_takeup`i'' & `b_repay_all`i'' & `b_repay_pct`i'' & `b_repay_cash`i'' \\ " _n
		file write takeup_repay " & (`se_takeup`i'') & (`se_repay_all`i'') & (`se_repay_pct`i'') & (`se_repay_cash`i'') \\ " _n
		
		}
		
	file write takeup_repay "\\" _n
	file write takeup_repay "\multicolumn{5}{c}{Panel C: Year 2, repeat treatment} \\" _n
****Panel C****
	foreach y1 in any_nopay1 {
	
		foreach out of local outcomes {
		
			keep if treatedin1 == 1
			local label = "Any default in village in year 1" 
			local i = 1
		
		
			reg `out'2 `y1', cl(vid)
			local b_`out'`i' = _b[`y1']
			local b_`out'`i' : display %-4.3f `b_`out'`i''
			local se_`out'`i' = _se[`y1']
			local se_`out'`i' : display %-4.3f `se_`out'`i''

		
			}
	
		file write takeup_repay "`label' & `b_takeup`i'' & `b_repay_all`i'' & `b_repay_pct`i'' & `b_repay_cash`i'' \\ " _n
		file write takeup_repay " & (`se_takeup`i'') & (`se_repay_all`i'') & (`se_repay_pct`i'') & (`se_repay_cash`i'') \\ " _n
		
		}
		
		file write takeup_repay "\hline" _n
			
		file write takeup_repay "\end{tabular}" _n	
		file close takeup_repay
		
		

****************** Table 3: Labor average treatment effects *********************************

use "$data/household_panel_final", clear 
****Setup****
	keep if calendar_month < 4 // hungry season only	
		
	local outcomes any_ganyu work_hours hire_ganyu hire_hours fam_hours 

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
		"$output/T3.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc c}" _n
	file write table "\hline" _n
	file write table " & Any ganyu  & Hours sold & Any ganyu  & Hours hired & Family hours \\ " _n
	file write table " & sold & & hired & & on-farm \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5)  \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n
	
****Panel A*****
	file write table "\multicolumn{6}{c}{A. Year 1 - Pooled treatment arms} \\ " _n
	
		foreach var in `outcomes' {
	
			reg `var' i.treated i.monthyear $controls $blocks if year == 1, cl(vid) 

					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
					file write table "`Y1coef' \\" _n
					file write table "`Y1std' \\" _n
					file write table " \\ " _n
			
****Panel B*****
	file write table "\multicolumn{6}{c}{B. Year 2 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' {
	
			reg `var' i.treated##i.treatedin1 i.monthyear $controls $blocks if year == 2, cl(vid) 
					
					local p1 = (2 * ttail(e(df_r), abs(_b[1.treated]/_se[1.treated])))
					
					local p2 = (2 * ttail(e(df_r), abs(_b[1.treatedin1]/_se[1.treatedin1])))
						
					local p3 = (2 * ttail(e(df_r), abs(_b[1.treated#1.treatedin1]/_se[1.treated#1.treatedin1])))
						
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					local b2 : display %-4.3f _b[1.treatedin1]
					local se2 : display %-4.3f _se[1.treatedin1]
					local b3 : display %-4.3f _b[1.treated#1.treatedin1]
					local se3 : display %-4.3f _se[1.treated#1.treatedin1]
					
					lincom 1.treated+1.treatedin1+1.treated#1.treatedin1
					local p4 = (2 * ttail(`r(df)', abs(`r(estimate)'/`r(se)')))
					
					local b4 : display %-4.3f `r(estimate)'
					local se4 : display %-4.3f `r(se)'
					
					local Y2coef "`Y2coef' & `b1'"
					local Y2std "`Y2std' & (`se1')"
					local Y2_1coef "`Y2_1coef' & `b2'"
					local Y2_1std "`Y2_1std' & (`se2')"
					local Y2_intcoef "`Y2_intcoef' & `b3'"
					local Y2_intstd "`Y2_intstd' & (`se3')"
					local Y2_totcoef "`Y2_totcoef' & `b4'"
					local Y2_totstd "`Y2_totstd' & (`se4')"
					
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

****Panel C*****			
	file write table "\multicolumn{6}{c}{C. By treatment arm - Pooled years} \\ " _n
		
		foreach var in `outcomes' {
	
			reg `var' i.treatment##i.treatedin1 i.monthyear $controls $blocks, cl(vid) 
			margins, dydx(treatment) post
			test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"

			local b1 : display %-4.3f _b[2.treatment]
			local se1 : display %-4.3f _se[2.treatment]
					
					local p1 = (2 * ttail(e(df_r), abs(_b[2.treatment]/_se[2.treatment])))
						
			local b2 : display %-4.3f _b[3.treatment]
			local se2 : display %-4.3f _se[3.treatment]
					
					local p2 = (2 * ttail(e(df_r), abs(_b[3.treatment]/_se[3.treatment])))
						
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
					
					qui reg `var' i.treated##i.treatedin1##i.year i.monthyear $controls $blocks , cl(vid) 
					
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
	
************************* Table 4: Daily earnings ********************************************

use "$data/household_panel_final", clear 
set seed 5925169

**** Setup ****
	est clear
	keep if calendar_month < 4
	
	local outcomes1 daily_earnings99 daily_earnings95  // winsorized at 99th and 95th pctl
	
	local outcomes2 vmean_wage // trimmed at 95th pctl

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
		"$output/T4.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l ccc cc}" _n
	file write table "\hline" _n
	file write table " & \multicolumn{2}{c}{Individual-level} & Village mean & \multicolumn{2}{c}{Treatment bounds} \\ " _n
	file write table " & \multicolumn{2}{c}{daily earnings} & daily earnings & Lower & Upper  \\ " _n
	file write table " & (winsorize 1pct) & (winsorize 5pct) & & & \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5) \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n

**** Panel A, Columns 1&2 ****		
	file write table "\multicolumn{4}{c}{A. Year 1 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes1' {
	
			reg `var' i.treated i.monthyear cen_num_hh hours_day $controls $blocks if year == 1, cl(vid) 
					
					local p = (2 * ttail(e(df_r), abs(_b[1.treated]/_se[1.treated])))
					
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
		
**** Panel A, Column 3 ****
			
		foreach var in `outcomes2' {
	
			reg `var' i.treated i.monthyear cen_num_hh $blocks if year == 1 & vtag == 1, cl(vid) 
					
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
**** Panel A, Columns 4 & 5 ****				
					// Lee bounds on 99th pctl effect
					reg daily_earnings95 i.treated if year == 1, cl(vid)
					local df `e(df_r)'
		
					bootstrap, cluster(vid) idcluster(newvid) group(hhid): leebounds daily_earnings95 treated if year == 1, select(any_ganyu)
		
					local trim : display %-4.2f e(trim)
					local b_lower : display %-4.3f _b[lower]
					local b_upper : display %-4.3f _b[upper]
					local se_lower : display %-4.3f _se[lower]
					local se_upper : display %-4.3f _se[upper]
						
					file write table "`Y1coef' & `b_lower' & `b_upper' \\" _n
					file write table "`Y1std' & (`se_lower') & (`se_upper') \\" _n
					file write table " \\ " _n
			
**** Panel B ****	
	file write table "\multicolumn{4}{c}{B. Year 2 - Pooled treatment arms} \\ " _n
**** Panel B, Columns 1 & 2 ****		
		foreach var in `outcomes1' {
	
			reg `var' i.treated##i.treatedin1 hours_day cen_num_hh i.monthyear $controls $blocks if year == 2, cl(vid) 
				
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
**** Panel B, Column 3 ****
		foreach var in `outcomes2' {
	
			reg `var' i.treated##i.treatedin1 i.monthyear cen_num_hh $blocks if year == 2 & vtag == 1, cl(vid) 
					
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
**** Panel B, Columns 4 & 5 ****					
					// Lee bounds 
					reg daily_earnings95 i.treated if year == 2 & treatedin1 == 0, cl(vid)
					local df `e(df_r)'
					
					bootstrap, cluster(vid) idcluster(newvid) group(hhid): leebounds daily_earnings95 treated if year == 2 & treatedin1 == 0, select(any_ganyu)
		
					local trim : display %-4.2f e(trim)
					local b_lower : display %-4.3f _b[lower]
					local b_upper : display %-4.3f _b[upper]
					local se_lower : display %-4.3f _se[lower]
					local se_upper : display %-4.3f _se[upper]
					

					file write table "`Y2coef' & `b_lower' & `b_upper' \\" _n
					file write table "`Y2std' & (`se_lower') & (`se_upper') \\" _n
					file write table "`Y2_1coef' & &  \\" _n
					file write table "`Y2_1std' & &  \\" _n
					file write table "`Y2_intcoef' & & \\" _n
					file write table "`Y2_intstd' & & \\" _n
					file write table " \\ " _n	
					
					reg daily_earnings99 i.treated if year == 2 & treatedin1 == 1, cl(vid)
					local df `e(df_r)'
					
					bootstrap, cluster(vid) idcluster(newvid) group(hhid): leebounds daily_earnings95 treated if year == 2 & treatedin1 == 1, select(any_ganyu)
		
					local trim : display %-4.2f e(trim)
					local b_lower : display %-4.3f _b[lower]
					local b_upper : display %-4.3f _b[upper]
					local se_lower : display %-4.3f _se[lower]
					local se_upper : display %-4.3f _se[upper]
								
					file write table "`Y2_totcoef' & `b_lower' & `b_upper' \\" _n
					file write table "`Y2_totstd' & (`se_lower') & (`se_upper') \\" _n
					file write table " \\ " _n
**** Panel C ****					
	file write table "\multicolumn{4}{c}{C. By treatment arm - Pooled years} \\ " _n
**** Panel C, Columns 1 & 2 ****
		foreach var in `outcomes1' {
	
			reg `var' i.treatment##i.treatedin1 cen_num_hh i.monthyear hours_day $controls $blocks, cl(vid) 
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
					
					qui reg `var' i.treated##i.treatedin1##i.year cen_num_hh hours_day i.monthyear $controls $blocks , cl(vid) 
					
					test 1.treated = 1.treated#2.year
					local pv1 : display %-4.2f `r(p)'
					local pval1 "`pval1' & `pv1'"
					
					test 1.treated = (1.treated#2.year + 1.treated#1.treatedin1 + 1.treatedin1)
					local pv2 : display %-4.2f `r(p)'
					local pval2 "`pval2' & `pv2'"
					
					}

**** Panel C, Column 3 ****		
		foreach var in `outcomes2' {
	
			reg `var' i.treatment##i.treatedin1 i.monthyear cen_num_hh $blocks if vtag == 1, cl(vid) 
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
					
					qui reg `var' i.treated##i.treatedin1##i.year i.monthyear cen_num_hh $blocks if vtag == 1, cl(vid) 
					
					test 1.treated = 1.treated#2.year
					local pv1 : display %-4.2f `r(p)'
					local pval1 "`pval1' & `pv1'"
					
					test 1.treated = (1.treated#2.year + 1.treated#1.treatedin1 + 1.treatedin1)
					local pv2 : display %-4.2f `r(p)'
					local pval2 "`pval2' & `pv2'"
					
					}
					
					file write table "`cashcoef' & & \\" _n
					file write table "`cashstd'  & & \\" _n
					file write table "`maizecoef'  & & \\" _n
					file write table "`maizestd' & &  \\" _n
					file write table " \\ " _n	
					file write table "\hline" _n	
					
					file write table "`meanline1' & &  \\" _n
					file write table "`meanline2' & &  \\" _n
					
					file write table "`pval1' & &  \\" _n
					file write table "`pval2' & &  \\" _n
					file write table "`pval3' & &  \\" _n
					file write table "`Nline' & &  \\" _n
					file write table "\hline" _n
			
		
		file write table "\end{tabular}" _n	
		file close table	
		
		
**************************** Table 5: Ag production *****************************************

use "$data/household_panel_final", clear 
**** Setup ****	
	local outcomes harvest_value harvest_value_CP inputs_kw_value acres_cash_crops
	gen l_inputs_kw_value = inputs_kw_value
	gen l_acres_cash_crops = acres_cash_crops // rename only to show means in levels
	
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
		"$output/T5.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc}" _n
	file write table "\hline" _n
	file write table " & Log harvest value & Log harvest value & Total input value & Acres cash crops \\ " _n
	file write table " & & constant prices & &  \\ " _n
	file write table " & (1) & (2) & (3) & (4) \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n

**** Panel A ****		
	file write table "\multicolumn{5}{c}{A. Year 1 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' {
	
			reg l_`var' i.treated i.year $controls $blocks if year == 1, cl(vid) 
						
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
					file write table "`Y1coef' \\" _n
					file write table "`Y1std' \\" _n
					file write table " \\ " _n
			
**** Panel B ****	
	file write table "\multicolumn{5}{c}{B. Year 2 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' {
	
			reg l_`var' i.treated##i.treatedin1 i.year $controls $blocks if year == 2, cl(vid) 
				
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					local b2 : display %-4.3f _b[1.treatedin1]
					local se2 : display %-4.3f _se[1.treatedin1]
					local b3 : display %-4.3f _b[1.treated#1.treatedin1]
					local se3 : display %-4.3f _se[1.treated#1.treatedin1]
					
					lincom 1.treated+1.treatedin1+1.treated#1.treatedin1
					local p4 = (2 * ttail(`r(df)', abs(`r(estimate)'/`r(se)')))
				
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

**** Panel C ****					
	file write table "\multicolumn{5}{c}{C. By treatment arm - Pooled years} \\ " _n
		
		foreach var in `outcomes' {
	
			reg l_`var' i.treatment##i.treatedin1 i.year $controls $blocks if year > 0, cl(vid) 
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
					
					qui reg l_`var' i.treated##i.treatedin1##i.year $controls $blocks , cl(vid) 
					
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
	

*************************** Table 6: Consumption *****************************************

use "$data/household_panel_final", clear 
**** Setup ****	
	replace food_short = . if survey_round > 3
	replace food_sec_z = . if calendar_month > 3
	
	keep if survey_round > 1
	
	local outcomes food_short food_sec_z hungry_meals harvest_meals  
	
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
		"$output/T6.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc cc}" _n
	file write table "\hline" _n
	file write table " & Months with & Food security & Meals per day & Meals per day \\ " _n
	file write table " & enough food & (z-score) & hungry season & harvest season \\ " _n
	file write table " & (1) & (2) & (3) & (4) \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n

**** Panel A ****		
	file write table "\multicolumn{5}{c}{A. Year 1 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' {
	
			reg `var' i.treated i.monthyear $controls $blocks if year == 1, cl(vid) 
			
					local b : display %-4.3f _b[1.treated]
					local se : display %-4.3f _se[1.treated]
	
					local Y1coef "`Y1coef' & `b'"
					local Y1std "`Y1std' & (`se')"

					}
					
					file write table "`Y1coef' \\" _n
					file write table "`Y1std' \\" _n
					file write table " \\ " _n
			
**** Panel B ****
	file write table "\multicolumn{5}{c}{B. Year 2 - Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' {
	
			reg `var' i.treated##i.treatedin1 i.monthyear $controls $blocks if year == 2, cl(vid) 
			
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

**** Panel C ****					
	file write table "\multicolumn{5}{c}{C. By treatment arm - Pooled years} \\ " _n
		
		foreach var in `outcomes' {
	
			reg `var' i.treatment##i.treatedin1 i.monthyear $controls $blocks, cl(vid) 
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
					
					qui reg `var' i.treated##i.treatedin1##i.year i.monthyear $controls $blocks , cl(vid) 
					
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
		
**************************** Table 7: Maize prices ******************************************

use "$data/household_panel_final.dta", clear

***** Setup ****
*only asked in year 2
	
	foreach var in any_purchase any_sale price {
		gen hun_`var' = `var' == 1
		replace hun_`var' = . if calendar_month > 3
		replace hun_`var' = . if `var' == .
		
		gen har_`var' = `var' == 1
		replace har_`var' = . if calendar_month < 7 | calendar_month > 11
		replace har_`var' = . if `var' == . 
		
		}
		
	local outcomes har_any_purchase har_any_sale har_price ///
		hun_any_purchase hun_any_sale hun_price 
	
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
		local meanline2 "Control mean"
		local Y2_totcoef "Loan + Y1 + Loan x Y1"
		local Y2_totstd ""
		local pval1 "Year 1 = Year 2 new"
		local pval2 "Year 1 = Year 2 repeat"
		local pval3 "Cash = Maize"
		local Nline "Observations"
	
	cap file close table
	
	file open table using ///
		"$output/T7.tex", ///
		write text replace
					
	file write table "\begin{tabular}{l cc c cc c}" _n
	file write table "\hline" _n
	file write table " & \multicolumn{3}{c}{Year 1 post-harvest season} & \multicolumn{3}{c}{Year 2 hungry season} \\ " _n
	file write table " & Any purchase & Any sale & Price & Any purchase & Any sale & Price \\ " _n
	file write table " & (1) & (2) & (3) & (4) & (5) & (6) \\ " _n
	file write table "\hline" _n
	file write table " \\ " _n

***** Panel A *****	
		file write table "\multicolumn{7}{c}{A. Pooled treatment arms} \\ " _n
		
		foreach var in `outcomes' {
	
			if "`var'" == "har_any_purchase" | "`var'" == "har_any_sale" | "`var'" == "har_price" | "`var'" == "hun_price" {
				reg `var' i.treated i.monthyear $controls $blocks, cl(vid) 
			
						
					local b1 : display %-4.3f _b[1.treated]
					local se1 : display %-4.3f _se[1.treated]
					
					
					local Y2coef "`Y2coef' & `b1'"
					local Y2std "`Y2std' & (`se1')"
					local Y2_1coef "`Y2_1coef' & "
					local Y2_1std "`Y2_1std' & "
					local Y2_intcoef "`Y2_intcoef' & "
					local Y2_intstd "`Y2_intstd' & "
					local Y2_totcoef "`Y2_totcoef' & "
					local Y2_totstd "`Y2_totstd' & "
				}
				
				else {
					reg `var' i.treated##i.treatedin1 i.monthyear $controls $blocks, cl(vid) 

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
			

***** Panel B *****					
	file write table "\multicolumn{7}{c}{B. By treatment arm} \\ " _n
		
		foreach var in `outcomes' {
			
			if "`var'" == "har_any_purchase" | "`var'" == "har_any_sale" | "`var'" == "har_price" | "`var'" == "hun_price" {
				reg `var' i.treatment i.monthyear $controls $blocks, cl(vid) 
				
			test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"

			local b1 : display %-4.3f _b[2.treatment]
			local se1 : display %-4.3f _se[2.treatment]
				
			local b2 : display %-4.3f _b[3.treatment]
			local se2 : display %-4.3f _se[3.treatment]
				
				}
				
				
				else {
					reg `var' i.treatment##i.treatedin1 i.monthyear $controls $blocks, cl(vid) 
					
					margins, dydx(treatment) post
					test 2.treatment = 3.treatment
					local pv3 : display %-4.2f `r(p)'
					local pval3 "`pval3' & `pv3'"

			local b1 : display %-4.3f _b[2.treatment]
			local se1 : display %-4.3f _se[2.treatment]
				
			local b2 : display %-4.3f _b[3.treatment]
			local se2 : display %-4.3f _se[3.treatment]
				
					}
			
			
					
					local cashcoef "`cashcoef' & `b1'"
					local cashstd "`cashstd' & (`se1')"
					local maizecoef "`maizecoef' & `b2'"
					local maizestd "`maizestd' & (`se2')"
					
					sum `var' if treated == 0 & treatedin1 == 0
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
					
					file write table "`meanline2' \\" _n
					
					file write table "`pval3' \\" _n
					file write table "`Nline' \\" _n
					file write table "\hline" _n
			
		
		file write table "\end{tabular}" _n	
		file close table
