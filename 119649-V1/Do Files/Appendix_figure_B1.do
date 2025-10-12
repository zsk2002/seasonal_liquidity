/* 

This file produces Appendix Figure B.1 for "Seasonal liquidity, rural labor markets and agricultural production"
The code uses all DHS surveys from Zambia since 2000
See README for information on data access

Version: 1.0 

Last Updated: 07/10/20

*/

clear all
set maxvar 10000
set more off

cap cd "/Users/kelsey/Dropbox/Zambia labor/" 

* Step 1: append all 3 survey rounds

use "Data/9. Other/DHS/ZMKR42FL.DTA", clear
append using "Data/9. Other/DHS/ZMKR51FL.DTA" 
append using "Data/9. Other/DHS/ZMKR61FL.DTA"  

* Step 2: outcome variables

gen haz = hw5/100 if hw5 < 8000
gen waz = hw8/100 if hw8 < 8000
gen underweight = waz < -2
replace underwe = . if waz > 6

gen weight_female = v437/10 if v437 < 9000 
gen height_female = v438/10 if v438 < 2000 
replace height_female = . if height_f < 130
gen bmi = weight_female/(height_female/100)^2
gen uw_female = bmi < 18.5
label var uw_female "Woman is underweight (BMI < 18.5)"
replace uw_female= . if bmi ==.

		
* Table

table v006, c(mean haz mean waz mean weight mean bmi)

* cluster ID

egen cid = group(v007 v001) // unique cluster id

** Time variable - rescaled to have hungry season in the middle

gen month = v006
tab month 
tab month if v213==0 
	
	gen disp_mon = month - 6
	replace disp_mon = disp_mon + 12 if disp_mon < 1

** Underweight


reg underw i.hw1 i.month i.v007 i.v013 v133, cluster(cid) // exclude July - relatively small sample
margins month

marginsplot , recastci(rline) ciopts(lpattern(tight_dot)) ///
		plotopts(msymbol(none)) graphregion(fcolor(white) lcolor(white)) ///
		title(" ") xtitle("") ///
		xlabel(1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sept" 10 "Oct" 11 "Nov" 12 "Dec") ///
		ytitle("Underweight (WAZ < -2), children under-5") ///
		graphregion(fcolor(white) lcolor(white)) 
		

graph export "FJM Replication Data and Code/Output/Appendix Figures/FB1.pdf", replace

	
** Women's height (placebo test)
	
reg height i.month i.v007 i.v013 v133 if v213==0, cluster(cid)
margins month

marginsplot, recastci(rline) ciopts(lpattern(tight_dot)) ///
		plotopts(msymbol(none)) graphregion(fcolor(white) lcolor(white)) ///
		title(" ") xtitle("") ///
		xlabel(1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sept" 10 "Oct" 11 "Nov" 12 "Dec") ///
		ytitle("Height of women 15-49 in cm") ///
		graphregion(fcolor(white) lcolor(white)) 
		
		
		
	
