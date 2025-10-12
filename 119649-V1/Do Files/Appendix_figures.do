/* 
This file produces the appendix figures (B.1-B.11) for "Seasonal liquidity, rural labor markets and agricultural production"

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
global output = "Output/Appendix Figures"

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
******************************* APPENDIX FIGURES  ********************************************
**********************************************************************************************

************************* Appendix figure B.1: child weight ***********************************

/* This figure is created using external data on child weight for age from the Zambia DHS (2001-2, 2007 and 2013-14)
   See the ReadMe for more details on how to access this data.
   The code to generate the figure is provided in Appendix_figure_B1.do */
   
******************* Appendix figure B.2: Maize prices by month ********************************

use "$data/price_survey_final.dta", clear

gen disp_mon = calendar_month - 6
replace disp_mon = disp_mon + 12 if disp_mon < 1

	reg price i.disp_mon i.year i.transaction_type i.maize_form, cl(monthyear)
	margins disp_mon
	marginsplot, recastci(rline) ciopts(lpattern(tight_dot)) ///
		plotopts(msymbol(none)) graphregion(fcolor(white) lcolor(white)) ///
		title(" ") xtitle("") xlabel(1 "Jul" 2 "Aug" 3 "Sept" 4 "Oct" 5 "Nov" 6 "Dec" 7 "Jan" 8 "Feb" 9 "Mar" 10 "Apr" 11 "May" 12 "Jun") ///
		ytitle(Maize price)	
		graph export "$output/FB2.pdf", replace


****************** Appendix figure B.3: interest rates by baseline reserves ********************

use "$data/household_panel_final", clear 

	replace treated = . if treatedin1 == 1 & year == 2

	twoway (lpolyci loan_interest_clean b_reserves_q10 if survey_round == 1, ciplot(rline) ), ///
	legend(off) ytitle(Repayment amount) xtitle(Baseline reserves decile) ///
	graphregion(fcolor(white) lcolor(white)) xscale(range(0 11))
	
	graph export "$output/FB3.pdf", replace
	
	
***************************** Appendix Figure B.4: rainfall ************************************

/* This figure is created using external data on rainfall from the Msekera Research Stataion
   see the ReadMe for more details on how to access this data.
   The code to generate the figure is provided in Appendix_figure_B4.do */

************* Appendix figure B.5: Daily earnings by share of population treated ***************


use "$data/household_panel_final", clear 

	est clear
	keep if calendar_month < 4

	set level 90
	gen b = .
	gen se = .
	gen hi = .
	gen lo = .
	
	* replace year = . if (year == 2 & treatedin1 == 1) // drop villages treated in both years from year 2 analysis
	
	reg vmean_wage i.treated##c.pop##i.treatedin1 i.monthyear cen_num_hh  $blocks if vtag == 1, cl(vid)
	margins , dydx(treated) at(pop=(1(1)5)) post
	forval i = 1/5 {
		replace b = _b[1.treated:`i'._at] if pop == `i'
		replace se = _se[1.treated:`i'._at] if pop == `i'
		}
		replace hi = b + invnormal(0.95) * se
		replace lo = b - invnormal(0.95) * se
		
		twoway (line b pop if vtag == 1, sort) ///
			(line hi pop if vtag == 1, sort lpattern(tight_dot) lcolor(navy)) ///
			(line lo pop if vtag == 1, sort lpattern(tight_dot) lcolor(navy)), ///
			xtitle(Share of population treated (quintiles)) ///
			ytitle("Treatment effect on daily earnings") legend(off) ///
			graphregion(fcolor(white) lcolor(white)) /// 
			saving("$output/B.5/FB5", replace)
			graph export "$output/B.5/FB5.pdf", replace
			
		
************************* Appendix figures B.6-B.8 *********************************************
use "$data/household_panel_final", clear 
	
		set level 90

		local quarts 0.87 3.03 6.33 24.6 
		gen meff = .
		gen hi = .
		gen lo = .
		gen b_reserves_q0 = b_reserves_q - 0.05 if treated == 0
		gen b_reserves_q1 = b_reserves_q + 0.05 if treated == 1
		
***** Figure B6: Ganyu sold, ganyu hired, and family hours worked on farm by baseline reserves, year 2 *****
	foreach var in work_hours hire_hours fam_hours {
	
		local variable_label : variable label `var'
	
					reg `var' treated##c.b_total_reserve##c.b_total_reserve##i.treatedin1 i.monthyear $blocks if year == 2 & calendar_month < 4, cl(vid)
					
				
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
			saving("$output/B.6/FB6_`var'_y2.gph", replace)
				graph export "$output/B.6/FB6_`var'_y2.pdf", replace
		}
		
***** Figure B7: Log agricultural output value by baseline reserves, year 2 *****

	foreach var in l_harvest_value {
	
		*replace `var' = . if treatedin1 == 1 & year == 2
		local variable_label : variable label `var'
				
					reg `var' treated##c.b_total_reserve##c.b_total_reserve##i.treatedin1 $blocks if year == 2, cl(vid)
				
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
			saving("$output/B.7/FB7_`var'_y2.gph", replace)
				graph export "$output/B.7/FB7_`var'_y2.pdf", replace
		}
		
***** Figure B8: Number of months w/ enough fod and adult meals per day by baseline reserves, year 2 *****

	ren adult_nshima_1w nshima
	foreach var in nshima food_short { 
	
		*replace `var' = . if treatedin1 == 1 & year == 2
		local variable_label : variable label `var'
	
					reg `var' treated##c.b_total_reserve##c.b_total_reserve##i.treatedin1 i.monthyear $blocks if year == 2 & calendar_month < 4, cl(vid) 
				
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
			saving("$output/B.8/FB8_`var'_y2.gph", replace)
				graph export "$output/B.8/FB8_`var'_y2.pdf", replace
		}
	
		
	

******************* Appendix figures B.9-B.11: Alt heterogeneity analysis **********************

use "$data/household_panel_final", clear 
	set level 90
	
	local quarts 48 63 75 100
	gen meff = .
	gen hi = .
	gen lo = .
	gen b_interest_q0 = b_interest_q - 0.05 if treated == 0
	gen b_interest_q1 = b_interest_q + 0.05 if treated == 1
	
***** Figure B9: Ganyu sold, ganyu hired, and family hours worked on farm by baseline interest rate, year 1 *****
foreach var in work_hours hire_hours fam_hours{

	local variable_label : variable label `var'

		reg `var' treated##c.b_interest##c.b_interest i.calendar_month $blocks if year == 1 & calendar_month < 4, cl(vid) 
		margins treated, at(c.b_interest = (`quarts')) post
		
		replace meff = .
		replace hi = .
		replace lo = .
		
	forval i = 1/4 {
		replace meff = _b[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
		replace meff = _b[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
		replace hi = meff + 1.96*_se[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
		replace hi = meff + 1.96*_se[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
		replace lo = meff - 1.96*_se[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
		replace lo = meff - 1.96*_se[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
		}
	
	twoway (connected meff b_interest_q0 if treated == 0, sort mcolor(navy)) (connected meff b_interest_q1 if treated == 1, sort mcolor(maroon) msymbol(T)) ///
		(rcap hi lo b_interest_q0 if treated == 0, lcolor(navy)) (rcap hi lo b_interest_q1 if treated == 1, lcolor(maroon)), ///
		xtitle(Baseline reported interest rate (quartiles)) xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", noticks) xscale(range(0.5 4.5)) ///
		legend(order(1 "Control" 2 "Loan treatment")) ytitle(`variable_label') ///
		graphregion(fcolor(white) lcolor(white)) ///
		saving("$output/B.9/FB9_`var'_interest.gph", replace)
			graph export "$output/B.9/FB9_`var'_interest.pdf", replace
	}
	

		label var l_harvest_value "Log agricultural output value"
		label var harvest_value "Agricultural output value"
		* local quarts 787 1673 2995 6798 // for baseline harvest alt
		
***** Figure B10: Log agricultural output value by baseline interest rate, year 1 *****
	foreach var in l_harvest_value{
	
		*replace `var' = . if treatedin1 == 1 & year == 2
		local variable_label : variable label `var'
	
			reg `var' treated##c.b_interest##c.b_interest $blocks if year == 1, cl(vid) 
			margins treated, at(c.b_interest = (`quarts')) post
			
			replace meff = .
			replace hi = .
			replace lo = .
			
		forval i = 1/4 {
			sum b_interest if b_interest_q == `i'
			replace meff = _b[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
			replace meff = _b[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
			}
		
		twoway (connected meff b_interest_q0 if treated == 0, sort mcolor(navy)) (connected meff b_interest_q1 if treated == 1, sort mcolor(maroon) msymbol(T)) ///
			(rcap hi lo b_interest_q0 if treated == 0, lcolor(navy)) (rcap hi lo b_interest_q1 if treated == 1, lcolor(maroon)), ///
			xtitle(Baseline interest rate (quartiles)) xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", noticks) xscale(range(0.5 4.5)) ///
			legend(order(1 "Control" 2 "Loan treatment")) ytitle(`variable_label') ///
			graphregion(fcolor(white) lcolor(white)) ///
			saving("$output/B.10/FB10_`var'_interest.gph", replace)
				graph export "$output/B.10/FB10_`var'_interest.pdf", replace
		}
		
		replace adult_nshima_1w = . if calendar_month > 3
		replace food_short = . if survey_round > 3
		label var adult_nshima_1w "Adult meals per day"
		label var food_short "Months with enough food"
		*local quarts 787 1673 2995 6798  // baseline harvest version

***** Figure B11: Number of months w/ enough fod and adult meals per day by baseline interest rate, year 1 *****

	ren adult_nshima_1w nshima
	
	foreach var in nshima food_short  {
	
		*replace `var' = . if treatedin1 == 1 & year == 2
		local variable_label : variable label `var'
	
			reg `var' treated##c.b_interest##c.b_interest i.calendar_month $blocks if year == 1, cl(vid) 
			margins treated, at(c.b_interest = (`quarts')) post
			
			replace meff = .
			replace hi = .
			replace lo = .
			
		forval i = 1/4 {
			*sum b_harvest_total_value if b_reserves_q == `i'
			replace meff = _b[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
			replace meff = _b[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
			replace hi = meff + 1.96*_se[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#0.treated] if b_interest_q == `i' & treated == 0 & e(sample)
			replace lo = meff - 1.96*_se[`i'._at#1.treated] if b_interest_q == `i' & treated == 1 & e(sample)
			}
		
		twoway (connected meff b_interest_q0 if treated == 0, sort mcolor(navy)) (connected meff b_interest_q1 if treated == 1, sort mcolor(maroon) msymbol(T)) ///
			(rcap hi lo b_interest_q0 if treated == 0, lcolor(navy)) (rcap hi lo b_interest_q1 if treated == 1, lcolor(maroon)), ///
			xtitle(Baseline reported interest rate (quartiles)) xlabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", noticks) xscale(range(0.5 4.5)) ///
			legend(order(1 "Control" 2 "Loan treatment")) ytitle(`variable_label') ///
			graphregion(fcolor(white) lcolor(white)) ///
			saving("$output/B.11/FB11_`var'_interest.gph", replace)
				graph export "$output/B.11/FB11_`var'_interest.pdf", replace
		}
		

