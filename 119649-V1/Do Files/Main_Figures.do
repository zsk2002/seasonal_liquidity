/* 
This file produces the Main paper figures (1-6) for "Seasonal liquidity, rural labor markets and agricultural production"

Version: 1.0 

Last Updated: 07/11/2020

*/

*** Setup ***
clear all
set maxvar 10000
set more off
*********************************************************************************************
******************** 1. Specify directories and macros **************************************
*********************************************************************************************

cap cd "" //Insert your directory here
global data = "Data/Analysis"
global output = "Output/Main Figures"

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
************************* 2. MAIN TEXT FIGURES ***********************************************
**********************************************************************************************

*********************************** Figures 1 and 2 ******************************************

/* Figures 1 and 2 describe the study timeline and design, respectively, and are not empirical */

************** Figure 3: Liquidity, consumption and labor by month ***************************

use "$data/household_panel_final", clear 

	gen restrict = (year == 2 & treatedin1 == 1)
	
		gen disp_mon = calendar_month - 6
		replace disp_mon = disp_mon + 12 if disp_mon < 1
***** Figure 3 Part a: Liquidity by Month *****
	reg total_liquidity i.disp_mon if treated == 0 & calendar_month != 10 & restrict == 0
	margins disp_mon
	marginsplot, recastci(rline) ciopts(lpattern(tight_dot)) ///
		plotopts(msymbol(none)) graphregion(fcolor(white) lcolor(white)) ///
		title(" ") xtitle("") xlabel(1 "Jul" 2 "Aug" 3 "Sept" 4 "Oct" 5 "Nov" 6 "Dec" 7 "Jan" 8 "Feb" 9 "Mar" 10 "Apr" 11 "May" 12 "Jun") ///
		legend(off) ytitle(Total liquidity (x100 Kwacha))	
	graph export "$output/Figure 3/F3a.pdf", replace 
	
***** Figure 3 Part b: Meals per day by month *****
	reg adult_nshima_1w i.disp_mon if treated == 0 & calendar_month != 10 & restrict == 0
		margins disp_mon
		marginsplot, recastci(rline) ciopts(lpattern(tight_dot)) ///
			plotopts(msymbol(none)) graphregion(fcolor(white) lcolor(white)) ///
			title(" ") xtitle("") xlabel(1 "Jul" 2 "Aug" 3 "Sept" 4 "Oct" 5 "Nov" 6 "Dec" 7 "Jan" 8 "Feb" 9 "Mar" 10 "Apr" 11 "May" 12 "Jun") ///
			ytitle(Number of meals per day)
		graph export "$output/Figure 3/F3b.pdf", replace
		
***** Figure 3 Part c: Labor Demand by Month ******
	reg d_i i.disp_mon if treated == 0 & calendar_month != 10 & restrict == 0
	margins disp_mon
	marginsplot, recastci(rline) ciopts(lpattern(tight_dot)) ///
		plotopts(msymbol(none)) graphregion(fcolor(white) lcolor(white)) ///
		title(" ") xtitle("") xlabel(1 "Jul" 2 "Aug" 3 "Sept" 4 "Oct" 5 "Nov" 6 "Dec" 7 "Jan" 8 "Feb" 9 "Mar" 10 "Apr" 11 "May" 12 "Jun") ///
		legend(off) ytitle(Total labor demand (hours/week))	
	graph export "$output/Figure 3/F3c.pdf", replace
	
***** Figure 3 Part d: Any Ganyu Sold (Percentage) by Month *****
	reg any_ganyu i.disp_mon if treated == 0 & calendar_month != 10 & restrict == 0
	margins disp_mon
	marginsplot, recastci(rline) ciopts(lpattern(tight_dot)) ///
		plotopts(msymbol(none)) graphregion(fcolor(white) lcolor(white)) ///
		title(" ") xtitle("") xlabel(1 "Jul" 2 "Aug" 3 "Sept" 4 "Oct" 5 "Nov" 6 "Dec" 7 "Jan" 8 "Feb" 9 "Mar" 10 "Apr" 11 "May" 12 "Jun") ///
		legend(off) ytitle(Any ganyu sold (past week))	
	graph export "$output/Figure 3/F3d.pdf", replace	
	
	
********************** Figure 4: Heterogeneity figures ***************************************


use "$data/household_panel_final", clear 
	
**** Setup for figures 4-6 ****
		set level 90

		local quarts 0.87 3.03 6.33 24.6 
		gen meff = .
		gen hi = .
		gen lo = .
		gen b_reserves_q0 = b_reserves_q - 0.05 if treated == 0
		gen b_reserves_q1 = b_reserves_q + 0.05 if treated == 1
		
***** Figure 4 Parts 1,2, and 3: heterogeneous treatment effects on hours of ganyu sold, hours of ganyu hired, and hours of family work on farm ***** 
	foreach var in work_hours hire_hours fam_hours{
	
		local variable_label : variable label `var'
			reg `var' treated##c.b_total_reserve##c.b_total_reserve i.monthyear $blocks if year == 1 & calendar_month < 4, cl(vid) 
				
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
		
		twoway (connected meff b_reserves_q0 if treated == 0, sort mcolor(navy)) (connected meff b_reserves_q1 if treated == 1, sort mcolor(maroon) msymbol(T)) ///
			(rcap hi lo b_reserves_q0 if treated == 0, lcolor(navy)) (rcap hi lo b_reserves_q1 if treated == 1, lcolor(maroon)), ///
			xtitle(Baseline grain and cash resources (quartiles)) xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", noticks) xscale(range(0.5 4.5)) ///
			legend(order(1 "Control" 2 "Loan treatment")) ytitle(`variable_label') ///
			graphregion(fcolor(white) lcolor(white)) ///
			saving("$output/Figure 4/F4_`var'_y1.gph", replace)
				graph export "$output/Figure 4/F4_`var'_y1.pdf", replace
		}
		
*********************************Figure 5*****************************************************
***** Figure 5: Heterogeneous treatment effets on log agricultural output value ****
	foreach var in l_harvest_value {
	
		local variable_label : variable label `var'
				
				reg `var' treated##c.b_total_reserve##c.b_total_reserve $blocks if year == 1, cl(vid) 
			
			local i = 0
			foreach rhs in 1.treated b_total_reserve 1.treated#c.b_total_reserve c.b_total_reserve#c.b_total_reserve 1.treated#c.b_total_reserve#c.b_total_reserve {
				local i = `i'+1
				
				local b`i'_`var' : display %-4.3f _b[`rhs']
				local se`i'_`var' : display %-4.3f _se[`rhs']
				local p = (2 * ttail(e(df_r), abs(_b[`rhs']/_se[`rhs']))) 
				if `p'>0.1 	local stars`i'_`var' =""
				if `p'<=0.1	local stars`i'_`var' = "*" 
				if `p'<=0.05	local stars`i'_`svy' = "**" 
				if `p'<=0.01  local stars`i'_`svy' = "***"
				
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
		
		twoway (connected meff b_reserves_q0 if treated == 0, sort mcolor(navy)) (connected meff b_reserves_q1 if treated == 1, sort mcolor(maroon) msymbol(T)) ///
			(rcap hi lo b_reserves_q0 if treated == 0, lcolor(navy)) (rcap hi lo b_reserves_q1 if treated == 1, lcolor(maroon)), ///
			xtitle(Baseline grain and cash resources (quartiles)) xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", noticks) xscale(range(0.5 4.5)) ///
			legend(order(1 "Control" 2 "Loan treatment")) ytitle(`variable_label') ///
			graphregion(fcolor(white) lcolor(white)) ///
			saving("$output/Figure 5/F5_`var'_y1.gph", replace)
				graph export "$output/Figure 5/F5_`var'_y1.pdf", replace
		}
		
********************************* Figure 6 ***************************************************
***** Figure 6 Parts 1 and 2: heterogeneous treatment effects on months with enough food and adult meals per day****
	ren adult_nshima_1w nshima
	foreach var in nshima food_short { 
		
		local variable_label : variable label `var'
	
			reg `var' treated##c.b_total_reserve##c.b_total_reserve i.monthyear $blocks if year == 1 & calendar_month < 4, cl(vid) 

			local i = 0
			foreach rhs in 1.treated b_total_reserve 1.treated#c.b_total_reserve c.b_total_reserve#c.b_total_reserve 1.treated#c.b_total_reserve#c.b_total_reserve {
				local i = `i'+1
				
				local b`i'_`var' : display %-4.3f _b[`rhs']
				local se`i'_`var' : display %-4.3f _se[`rhs']
				local p = (2 * ttail(e(df_r), abs(_b[`rhs']/_se[`rhs']))) 
				if `p'>0.1 	local stars`i'_`var' =""
				if `p'<=0.1	local stars`i'_`var' = "*" 
				if `p'<=0.05	local stars`i'_`svy' = "**" 
				if `p'<=0.01  local stars`i'_`svy' = "***"
				
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
		
		twoway (connected meff b_reserves_q0 if treated == 0, sort mcolor(navy)) (connected meff b_reserves_q1 if treated == 1, sort mcolor(maroon) msymbol(T)) ///
			(rcap hi lo b_reserves_q0 if treated == 0, lcolor(navy)) (rcap hi lo b_reserves_q1 if treated == 1, lcolor(maroon)), ///
			xtitle(Baseline reserves (quartiles)) xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", noticks) xscale(range(0.5 4.5)) ///
			legend(order(1 "Control" 2 "Loan treatment")) ytitle(`variable_label') ///
			graphregion(fcolor(white) lcolor(white)) ///
			saving("$output/Figure 6/F6_`var'_y1.gph", replace)
				graph export "$output/Figure 6/F6_`var'_y1.pdf", replace
		}	
