/* 
This file contains code for estimating the theoretical model found in for "Seasonal liquidity, rural labor markets and agricultural production" and producing graphs analogous to figures 7 & 8 in the paper. The exact contours of the figures will depend on choice of seed and parameters.

Version: 1.0 

Last Updated: 04/22/2020

*/
/*
**********************************************************************************************
**********************1. Partial Treatment Simulations****************************************
**********************************************************************************************
This section computes equilibrium outcomes with partial treatments

IMPORTANT: 
If parameters are changed, please make sure wage ranges are sufficiently wide
in lines 77 and 203 of this code to cover/find market clearing wages

This file was coded to allow for a range of different parametric settings, which can be changed as follows

* Basic model parameters: section 1.A (~line 40)
* Initial wealth distribution:  section 1.B (~line 46)
* Distribution of agricultural output: section 1.C (~line 55)
* Interest rates range: sections 1.D and 1.E (~lines 63 and 176, respectively)
* Treatment share: section 1.F (~line 189)
* Treatment interest rates: section 1.F (~line 189)

Version
20 April 2020: updated paramters and documentation

*/

* Working directories
 cap cd "/Users/kelsey/Dropbox/Zambia labor/FJM Replication Data and Code/" //Insert your directory here
 global out = "Output/Simulation Figures"

* Clear memory and set seed
 
clear
scalar drop _all
set obs 500000
set seed 100
 
 
***** Section 1.A: Key Model parameters *****

scalar rho = 0.95 // subjective discounting factor
scalar beta = 0.5 // relative productivity of labor/land -assumed equally important
scalar k = 1  // land endowment of farms in hectares - normalized to one
scalar h_min = 0.5  // baseline provision of labor
scalar phi = 0.0001 // needs to be smaller than 1/w as stated in paper - restricted to small level here

***** Section 1.B: Initial wealth distribution *****

gen lninc = rnormal(4,2) // mean of 400, median 50
gen S0 = exp(lninc)


****** Section 1.C: Productivity distribution (correlated with wealth) *****
// Load calibration output - see separate "Calibration of TFP A" DO file for grid search process to identify these parameters

scalar a_SD =  0.42
scalar  a_target = 15.16
scalar a_corr =  0.300
 
set seed 1001
gen a = (rnormal(a_target,a_SD) + a_corr*lninc)/2 // plugged in from calibration file
gen A =exp(a) 

****** Section 1.D: Interest rates: 50-150%, increasing in log income *****

sum lninc
gen IR = 1.5 + (r(max)-lninc)/20 // parameters set here to get desired range

****** Set up variables for equilibrium

gen wage = .
gen ELDS = .

// Main loop starts here - considering all wages in predefined range; need to check line 117 to make sure range is appropriate (internal solution)

local i=1
forvalues w =1200(10)2000 {  // make sure to adjust range here to include clearing wage // set up to be fast now
	di "Computing demand and supply without treatment for wage = `w'"
	replace wage = `w' in `i'
	cap drop d_i
	gen d_i = k*(beta*A/`w'/IR)^(1/(1-beta))
		//output
	cap drop y_i
	gen y_i = A*d_i^beta*k^(1-beta) 
		//profit
	cap drop profit_i
	qui gen profit_i = y_i/IR - d_i*`w'
	
		// consumption
	cap drop c1_i
	qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*`w'))
	
	cap drop c2_i
	qui gen c2_i = c1_i*IR*rho*(1-phi*`w')
		
		// supply
	cap drop h_i
	qui gen h_i = h_min + phi*c1_i // introducing fixed labor supply component here
	
	

		// balance

	qui sum d_i
	replace ELDS = r(mean) in `i'
	qui sum h_i
	replace ELDS = ELDS - r(mean) in  `i'
	local i= `i'+1
}

*** Plug in equilibrium wage again to get distribution of labor and output



gen balance = abs(ELDS)
sum balance
sum wage if balance == r(min) // check here wage is not a boundary solution
scalar eq_wage = r(mean)
replace wage = eq_wage
cap drop d_i
gen d_i = k*(beta*A/wage/IR)^(1/(1-beta))
cap drop y_i
gen y_i = A*d_i^beta*k^(1-beta) 
cap drop profit_i
qui gen profit_i = y_i/IR - d_i*wage

// consumption
cap drop c1_i
qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*wage))

cap drop c2_i
qui gen c2_i = c1_i*IR*rho*(1-phi*wage)
		
// supply
cap drop h_i
qui gen h_i = h_min + phi*c1_i // 
	
// household net labor supply

gen nls = h_i - d_i

// average initial levels (for Appendix Table)

gen lny = ln(y_i)
gen util0 = ln(c1)+rho*ln(c2)

// column 2, Table A2
sum wage lny c1 util

* Collapse by S= percentile  and store results 

xtile incpct =S0, nq(100)
collapse (p50) h_i d_i y_i nls c1_i c2_i wage, by(incpct) // note that wage is an eqm object, does not vary
keep inc nls y_i c1_i c2_i h_i wage
rename nls nls0 // rename to facilitate later comparison
rename y_i y0
rename c1_i c10
rename c2_i c20
rename h_i h0
rename wage wage0
save wf_temp.dta, replace



**********************************************************************************************
* Program impact: compute new equilibrium with everybody facing lower interest (and adjustment)
**********************************************************************************************

* relaunch the same model, but now add interest loan treatment
clear
set obs 500000
set seed 100

gen lninc = rnormal(4,2) // mean of 400, median 50
gen S0 = exp(lninc)

***** Section 1.E: Interest rates: 50-150, increasing in log income *****

sum lninc
gen IR = 1.5 + (r(max)-lninc)/20 

* Calibrate this to get average seasonal wage of 1600 (16 times 100 work days)

set seed 1001
gen a = (rnormal(a_target,a_SD) + a_corr*lninc)/2 // plugged in from above
gen A =exp(a) 


******* Section 1.F: Treatment Share and Interest Rate *****

gen treated = uniform()>0.5 // 50% treated to 1.3 IR  // partial treatment setting
replace IR = (IR+1.3)/2  if treated==1 & IR > 1.3  // switch to 30% for treated assuming half the borrowing happens at 30% on average
*replace IR = 1.3  if treated==1 & IR > 1.3  //  Alternative scenario: unlimited borrowing at 30% for treated

***** Set up variables for equilibrium

gen wage = .
gen ELDS = .

// Main loop starts here - considering all wages from 1000-3000

local i=1
forvalues w = 1200(10)2000 {  // make sure to adjust range here to include clearing wage
	di "Computing demand and supply without treatment for wage = `w'"
	replace wage = `w' in `i'
	cap drop d_i
	gen d_i = k*(beta*A/`w'/IR)^(1/(1-beta))
		//output
	cap drop y_i
	gen y_i = A*d_i^beta*k^(1-beta) 
		//profit
	cap drop profit_i
	qui gen profit_i = y_i/IR - d_i*`w'
	
		// consumption
	cap drop c1_i
	qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*`w'))
	
	cap drop c2_i
	qui gen c2_i = c1_i*IR*rho*(1-phi*`w')
		
		// supply
	cap drop h_i
	qui gen h_i = h_min + phi*c1_i // introducing fixed labor supply component here
	
	
	// balance

	qui sum d_i
	replace ELDS = r(mean) in `i'
	qui sum h_i
	replace ELDS = ELDS - r(mean) in  `i'
	local i= `i'+1
}

*** Plug in equilibrium wage again to get distribution of labor and output

gen balance = abs(ELDS)
sum balance
sum wage if balance == r(min)

scalar eq_wage1 = r(mean)
replace wage = eq_wage1
cap drop d_i
gen d_i = k*(beta*A/wage/IR)^(1/(1-beta))
cap drop y_i
gen y_i = A*d_i^beta*k^(1-beta) 
cap drop profit_i
qui gen profit_i = y_i/IR - d_i*wage

// consumption
cap drop c1_i
qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*wage))
	
cap drop c2_i
qui gen c2_i = c1_i*IR*rho*(1-phi*wage)
		
// supply
cap drop h_i
qui gen h_i = h_min + phi*c1_i // 
	

// household net labor supply

gen nls = h_i - d_i

// average levels at followup

gen lny = ln(y_i)
gen util1 = ln(c1)+rho*ln(c2)
sum wage lny c1 c2 util
sum lny
scalar ly_post = r(mean)

** collapse by S0 percentile

xtile incpct =S0, nq(100)
collapse (p50) h_i d_i nls y_i c1_i c2_i wage, by(incpct treated)

keep incpct nls treated y_i c1_i c2_i h_i wage

sort incpct
merge m:1 incpct using wf_temp.dta
erase wf_temp.dta


* Graph I: Output

gen ly0 = ln(y0)
gen lyi = ln(y_i)

sort incpct

twoway (line ly0 inc, lcolor(black) ) ///
(line lyi inc if treated==1, lcolor(maroon) lpattern(dash) lwidth(medthick)) ///
(line lyi inc if treated==0, lcolor(navy) lpattern(vshortdash) lwidth(medthick)), ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Ln(Output)", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)" 3 "Intervention (non-treated)"))
graph save "$out/7. Partial Treatment/F7a.gph", replace
graph export "$out/7. Partial Treatment/F7a.pdf", replace

* Changes relative to baseline 
sum y0 y_i 
sum y0 y_i if treated==0
sum y0 y_i if treated==1

* Income inequality assessments
ineqdec0 y_i 
ineqdec0 y_i if treated==1

* Graph II: Net labor supply

sort incpct
twoway (line nls0 inc, lcolor(black) ) ///
(line nls inc if treated==1, lcolor(maroon) lpattern(dash) lwidth(medthick)) ///
(line nls inc if treated==0, lcolor(navy) lpattern(vshortdash) lwidth(medthick)), ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Net labor supply", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)" 3 "Intervention (non-treated)"))
graph save "$out/7. Partial Treatment/F7b.gph", replace
graph export "$out/7. Partial Treatment/F7b.pdf", replace

bys treated: sum nls0 nls

* Graph III: Hungry season consumption

sort incpct
twoway (line c10 inc if c10 < 5001, lcolor(black) ) ///
(line c1_i inc if treated==1 & c1_i< 5001, lcolor(maroon) lpattern(dash) lwidth(medthick)) ///
(line c1_i inc if treated==0 & c1_i < 5001, lcolor(navy) lpattern(vshortdash) lwidth(medthick)), ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Hungry season consumption", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)" 3 "Intervention (non-treated)"))
graph save "$out/7. Partial Treatment/F7c.gph", replace
graph export "$out/7. Partial Treatment/F7c.pdf", replace

bys treated: sum c10 c1_i
ineqdec0 c10
ineqdec0 c1_i if treated==1
ineqdec0 c1_i 

sum c10 c1_i if incpct > 95

* Graph IV: total utility

gen util0 = ln(c10)+rho*ln(c20)
gen util_i = ln(c1_i)+rho*ln(c2_i)

sort inc
twoway (line util0 inc, lcolor(black) ) ///
(line util_i inc if treated==1 , lcolor(maroon) lpattern(dash) lwidth(medthick)) ///
(line util_i inc if treated==0, lcolor(navy) lpattern(vshortdash) lwidth(medthick)), ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Total utility", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)" 3 "Intervention (non-treated)"))
graph save "$out/7. Partial Treatment/F7d.gph", replace
graph export "$out/7. Partial Treatment/F7d.pdf", replace

bys treated: sum util*

ineqdec0 util0
ineqdec0 util_i

// for appendix table A2, column 3: treatment effects

scalar list eq_wage eq_wage1
di "Absolute change in wage = " eq_wage1 -eq_wage
di "Change in ln(wage) = " ln(eq_wage1) - ln(eq_wage)


sum c1*
sum c10
scalar c1base = r(mean)
sum c1_i if treated==1
di ln(r(mean)) - ln(c1base)


sum ly0 
scalar ly_base = r(mean)
scalar ly_base_sd = r(sd)
sum lyi if treated ==1
di "Change in ln(y), treated = " r(mean) -ly_base
di "Change in sd ln(y), treated = " r(sd) -ly_base_sd
sum lyi if treated==0
di "Change in ln(y), untreated = " r(mean) -ly_base

sum util0
scalar util_base = r(mean)
sum util_i if treated==1
di "Change in utility, treated = " r(mean) - util_base // note that utility is already in log space

sum util_i if treated==0
di "Change in utility, untreated = " r(mean) - util_base // note that utility is already in log space

/*
**********************************************************************************************
*********************** Section 2: Full Treatment Simulation *********************************
**********************************************************************************************
This section computes equilibrium outcomes with full treatment

IMPORTANT: 
If parameters are changed, please make sure wage ranges are sufficiently wide
in lines 466 and 584 of this code to cover/find market clearing wages

This file was coded to allow for a range of different parametric settings, which can be changed as follows

* Basic model parameters: Section 2.A 
* Initial wealth distribution: Section 2.B 
* Distribution of agricultural output: Section 2.C 
* Interest rates range: Sections 2.D and 2.E 
* Treatment share: Section 2.F 
* Treatment interest rates: Section 2.F 

*/

* Clear memory and set seed
 
clear
scalar drop _all
set obs 500000
set seed 100
 
***** Section 2.A: Key Model parameters *****

scalar rho = 0.95 // subjective discounting factor
scalar beta = 0.5 // relative productivity of labor/land -assumed equally important
scalar k = 1  // land endowment of farms in hectares - normalized to one
scalar phi = 0.0001 // needs to be smaller than 1/w as stated in paper - restricted to small level here to 
scalar h_min = 0.5  // baseline provision of labor

***** Section 2.B: Initial wealth distribution *****

gen lninc = rnormal(4,2) // mean of 400, median 50
gen S0 = exp(lninc)


***** Section 2.C: Productivity distribution (correlated with wealth) *****

scalar a_SD =  0.42
scalar  a_target = 15.16
scalar a_corr =  0.300  //note that this is not the final correlation, just the best-fitting parameter
 
gen a = (rnormal(a_target,a_SD) + a_corr*lninc)/2 // plugged in from calibration file
gen A =exp(a) 

****** Section 2.D: Interest rates: 50-150, increasing in log income *****

sum lninc
gen IR = 1.5 + (r(max)-lninc)/20 // parameters set here to get desired range

// Set up variables for equilibrium

gen wage = .
gen ELDS = .

// Main loop starts here - considering all wages in predefined range - narrow range right now
// to restrict running time; need to check line 117 to make sure range is appropriate (internal solution)

local i=1
forvalues w =1200(10)2500 {  // make sure to adjust range here to include clearing wage // set up to be fast now
	di "Computing demand and supply without treatment for wage = `w'"
	replace wage = `w' in `i'
	cap drop d_i
	gen d_i = k*(beta*A/`w'/IR)^(1/(1-beta))
		//output
	cap drop y_i
	gen y_i = A*d_i^beta*k^(1-beta) 
		//profit
	cap drop profit_i
	qui gen profit_i = y_i/IR - d_i*`w'
	
		// consumption
	cap drop c1_i
	qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*`w'))
	
	cap drop c2_i
	qui gen c2_i = c1_i*IR*rho*(1-phi*`w')
		
		// supply
	cap drop h_i
	qui gen h_i = h_min + phi*c1_i // introducing fixed labor supply component here
	
	

		// balance

	qui sum d_i
	replace ELDS = r(mean) in `i'
	qui sum h_i
	replace ELDS = ELDS - r(mean) in  `i'
	local i= `i'+1
}

*** Plug in equilibrium wage again to get distribution of labor and output



gen balance = abs(ELDS)
sum balance
sum wage if balance == r(min) // check here wage is not a boundary solution

scalar eq_wage = r(mean)
replace wage = eq_wage
cap drop d_i
gen d_i = k*(beta*A/wage/IR)^(1/(1-beta))
cap drop y_i
gen y_i = A*d_i^beta*k^(1-beta) 
cap drop profit_i
qui gen profit_i = y_i/IR - d_i*wage

// consumption
cap drop c1_i
qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*wage))
	
cap drop c2_i
qui gen c2_i = c1_i*IR*rho*(1-phi*wage)
		
		// supply
cap drop h_i
qui gen h_i = h_min + phi*c1_i // 
	

// household net labor supply

gen nls = h_i - d_i

xtile incpct =S0, nq(100)
collapse (p50) h_i d_i y_i nls c1_i c2_i, by(incpct)

* store initial results
keep inc nls y_i c1_i c2_i h_i
rename nls nls0
rename y_i y0
rename c1_i c10
rename c2_i c20
rename h_i h0
save wf_temp.dta, replace

**********************************************************************************************
* Program impact: compute new equilibrium with everybody facing lower interest (and adjustment)
**********************************************************************************************


*  Step 1 relaunch the same model
clear
set obs 500000

set seed 100
gen lninc = rnormal(4,2) // mean of 400, median 50
gen S0 = exp(lninc)


******* Section 1.E: Interest rates: 50-150, increasing in log income *****

sum lninc
gen IR = 1.5 + (r(max)-lninc)/20 // parameters set here to get desired range

* Calibrate this to get average seasonal wage of 1600 (16 times 100 work days)

set seed 1001
gen a = (rnormal(a_target,a_SD) + a_corr*lninc)/2 // plugged in from above
gen A =exp(a) 

* MAIN SWITCH TO BE SET HERE
******* Section 1.F: Treatment share and interest rate ********

gen treated = 1  // 100% treated to 1.3 IR  // partial treatment setting
replace IR = 1.3 if treated==1 & IR > 1.3  

// Set up variables for equilibrium

gen wage = .
gen ELDS = .

// Main loop starts here - considering all wages from 1000-3000

local i=1
forvalues w = 1200(10)3000 {  // make sure to adjust range here to include clearing wage
	di "Computing demand and supply without treatment for wage = `w'"
	replace wage = `w' in `i'
	cap drop d_i
	gen d_i = k*(beta*A/`w'/IR)^(1/(1-beta))
		//output
	cap drop y_i
	gen y_i = A*d_i^beta*k^(1-beta) 
		//profit
	cap drop profit_i
	qui gen profit_i = y_i/IR - d_i*`w'
	
		// consumption
	cap drop c1_i
	qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*`w'))
	
	cap drop c2_i
	qui gen c2_i = c1_i*IR*rho*(1-phi*`w')
		
		// supply
	cap drop h_i
	qui gen h_i = h_min + phi*c1_i // introducing fixed labor supply component here
	
	
	// balance

	qui sum d_i
	replace ELDS = r(mean) in `i'
	qui sum h_i
	replace ELDS = ELDS - r(mean) in  `i'
	local i= `i'+1
}

*** Plug in equilibrium wage again to get distribution of labor and output

gen balance = abs(ELDS)
sum balance
sum wage if balance == r(min)

scalar eq_wage1 = r(mean)
replace wage = eq_wage1
cap drop d_i
gen d_i = k*(beta*A/wage/IR)^(1/(1-beta))
cap drop y_i
gen y_i = A*d_i^beta*k^(1-beta) 
cap drop profit_i
qui gen profit_i = y_i/IR - d_i*wage

// consumption
cap drop c1_i
qui gen c1_i = (profit_i +S0)/((1+rho)*(1-phi*wage))
	
cap drop c2_i
qui gen c2_i = c1_i*IR*rho*(1-phi*wage)
		
// supply
cap drop h_i
qui gen h_i = h_min + phi*c1_i // 
	

// household net labor supply

gen nls = h_i - d_i

xtile incpct =S0, nq(100)


collapse (p50) h_i d_i nls y_i c1_i c2_i, by(incpct treated)

keep incpct nls treated y_i c1_i c2_i h_i

sort incpct
merge m:1 incpct using wf_temp.dta
erase wf_temp.dta

* Graph I: output

gen ly0 = ln(y0)
gen lyi = ln(y_i)

twoway (line ly0 inc, lcolor(black) lwidth(medthick)) ///
(line lyi inc if treated==1, lcolor(maroon) lpattern(dash) lwidth(medthick)),  ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Ln(Output)", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)"))
graph save "$out/8. Full Treatment/F8a.gph", replace
graph export "$out/8. Full Treatment/F8a.pdf", replace


* Graph II: Net labor supply

sort inc
twoway (line nls0 inc, lcolor(black) lwidth(medthick)) ///
(line nls inc if treated==1, lcolor(maroon) lpattern(dash) lwidth(medthick)),  ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Net labor supply", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)"))
graph save "$out/8. Full Treatment/F8b.gph", replace
graph export "$out/8. Full Treatment/F8b.pdf", replace



* Graph III: hungry season consumption (restricted to < 5000 to make graph nicer)

sort inc
twoway (line c10 inc if c10 < 5000, lcolor(black) lwidth(medthick)) ///
(line c1_i inc if treated==1 & c1_i < 5000 , lcolor(maroon) lpattern(dash) lwidth(medthick)),  ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Hungry season consumption", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)"))
graph save "$out/8. Full Treatment/F8c.gph", replace
graph export "$out/8. Full Treatment/F8c.pdf", replace


* Graph IV: total utility

gen util0 = ln(c10)+rho*ln(c20)
gen util_i = ln(c1_i)+rho*ln(c2_i)

sort inc
twoway (line util0 inc, lcolor(black) lwidth(medthick)) ///
(line util_i inc if treated==1, lcolor(maroon) lpattern(dash) lwidth(medthick)),  ///
xtitle("Baseline resource percentiles (S_i0)") ytitle("Total utility", size(medlarge)) ///
graphregion(color(white)) xlabel(0(10)100) ///
legend(order (1 "Control" 2 "Intervention (treated)"))
graph save "$out/8. Full Treatment/F8d.gph", replace
graph export "$out/8. Full Treatment/F8d.pdf", replace




// for appendix table A2, column 4: treatment effects

scalar list eq_wage eq_wage1
di "Absolute change in wage = " eq_wage1 -eq_wage
di "Change in ln(wage) = " ln(eq_wage1) - ln(eq_wage)


sum c1*
sum c10
scalar c1base = r(mean)
sum c1_i if treated==1
di ln(r(mean)) - ln(c1base)


sum ly0 
scalar ly_base = r(mean)
scalar ly_base_sd = r(sd)
sum lyi if treated ==1
di "Change in ln(y) = " r(mean) -ly_base
di "Change in sd ln(y) = " r(sd) -ly_base_sd

sum util0
scalar util_base = r(mean)
sum util_i if treated==1
di "Change in utility = " r(mean) - util_base // not that utility is already in log space

 
* Percentile changes and inequality (in text comments)
sum ly0 lyi y0 y_i if incpct <= 20
sum ly0 lyi  y0 y_i if incpct >=80
sum ly0 lyi  y0 y_i if incpct >95


* Inequality stats

* Output
ineqdec0 y0 
ineqdec0 y_i 

* hungry season consumpt

ineqdec0 c10
ineqdec0 c1_i

* total utility

sum util*
ineqdec0 util0
ineqdec0 util_i
// note that due to log utility spec, utility inequality is much lower than inequality on the other two domains
