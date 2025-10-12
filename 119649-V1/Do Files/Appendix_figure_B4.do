/* 

This file produces Appendix Figure B.4 for "Seasonal liquidity, rural labor markets and agricultural production"
The code uses monthly rainfall data obtained from the Ministry of Agriculture's research station in Chipata District
See README for information on data access

Version: 1.0 

Last Updated: 07/10/20

*/

clear all
set maxvar 10000
set more off


cap cd "/Users/kelsey/Dropbox/Zambia labor/"

use "Data/9. Other/Rainfall/Msekera_Rainfall.dta", clear

gen year = substr(seasons,1,4)
destring year, replace
order year
drop if year == .
drop if year == 1970 // incomplete
drop if year == 1977 | year == 1978 | year == 1979 // also incomplete

foreach m in july aug sep oct april may june {
	replace `m' = "" if `m' == "NIL"
	replace `m' = "" if `m' == "TR"
	destring `m', replace
	replace `m' = 0 if `m' == .
	}
	
egen total = rowtotal(july aug sep oct nov dec jan feb mar april may june) // growing season

kdensity total, title("") xtitle("") ///
	xline(906.6 1084.2 1418.5, lp(-)) xlabel(906.6 "2014/15" 1084.2 "2013/14" 1418.5 "2012/13") ///
	graphregion(fcolor(white) lcolor(white)) note("") 
	graph export "FJM Replication Data and Code/Output/Appendix Figures/FB4.pdf", replace
