/* 
This file creates the final datasets used for analysis for "Seasonal liquidity, rural labor markets and agricultural production."

Inputs: The clean subject panels created from the base surveys by cleaning and separating based on subject matter (e.g., labor, health, etc..)

Outputs: The datasets used in the analysis: 
1. admin_outcomes_final.dta (used for outcomes and treatment assignment) 
2. household_panel_final.dta (the main panel used in analysis -- a combination of the indvidiual subject panels) 
3. price_survey_final.dta (a final version of the crop price surveys)
4. reporting_bias_final.dta (a final version of the social desirability index measures)
5. yield_checks_final.dta (a final version of the objective maize yield measures)

Version: Revision 3, using final datasets for publication
*/

*********************************************************************************************
******************** 1. Specify directories and macros **************************************
*********************************************************************************************
clear all
*set maxvar 2000
set more off
	
	cap cd "/Users/zhushangkai/Desktop/Evan Munro/119649-V1" // add your directory here
	global clean = "Data/Clean Subject Panels"
	global analys = "Data/Analysis"
	global output = "Output"
	
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

	
	global adminvars hhid vid year monthyear calendar_month survey_round ///
		treated treatment treatedin1 notification control_gift
		
**********************************************************************************************
************************** 2. Admin dataset **************************************************
**********************************************************************************************

*Keeps vars from the admin dataset that will be used in the analysis	
	use "$clean/admin_outcomes_clean.dta", clear
	
	keep hhid vid takeup* repay_all* repay_pct* repay_cash* cash* maize* any_treat* ///
		treat* early cashonly treatedin1 any_nopay1  ///
		in_baseline in_harvest in_endline in_midline in_labor1 in_labor2 in_labor3 in_labor4 /// 
		invited* attend* consent* takeup* total_reserve reserves_q $baseline
		
	label var hhid "Household ID"
	label var vid "Village ID"
	label var treatedin1 "Assigned to either treatment in year 1"
	label var repay_pct1 "Percent of loan repaid"
	label var repay_pct2 "Percent of loan repaid"
	label var repay_all1 "Repaid loan in full"
	label var repay_all2 "Repaid loan in full"
	
	save "$analys/admin_outcomes_final.dta", replace
	
**********************************************************************************************
************************** 3. Household panel ************************************************
**********************************************************************************************
*Creates the final hh panel by combining and pruning the individual subject panels
	
*** labor and wages ***
	
	use "$clean/Labor_panel_short_recall_clean", clear
	
	****** added column for winsorization from 0% to 10% ******
	****** for hours sold Table 3 first		   
	// new added percentiles 
	forvalues p = 90/99 {

		foreach v in hired_ganyu_hours did_ganyu_hours farm_hours {
			quietly _pctile `v', p(`p')
			local thr = r(r1)
			gen `v'_p`p' = cond(missing(`v'), ., min(`v', `thr'))
			label var `v'_p`p' "`v' capped at `p'th percentile"
		}

		egen w_on_farm_hours_p`p' = rowtotal(hired_ganyu_hours_p`p' farm_hours_p`p'), missing
		egen w_family_hours_p`p'  = rowtotal(farm_hours_p`p' did_ganyu_hours_p`p'),  missing
		
		label var w_on_farm_hours_p`p' "Total hours labor demand `p' percentile"
		label var w_family_hours_p`p' "Total hours labor supply `p' percentile"
	
		gen hire_hours_p`p' = hired_ganyu_hours_p`p'
		gen work_hours_p`p' = did_ganyu_hours_p`p'
		gen fam_hours_p`p'  = farm_hours_p`p'
		
		label var work_hours_p`p' "Hours of ganyu sold `p' percentile"
		label var hire_hours_p`p' "Hours of ganyu hired `p' percentile"
		label var fam_hours_p`p' "Hours of family labor on-farm `p' percentile"

		egen h_i_p`p' = rowtotal(work_hours_p`p' fam_hours_p`p'), mi
		egen d_i_p`p' = rowtotal(hire_hours_p`p' fam_hours_p`p'), mi
		label var d_i_p`p' "Total labor demand `p' percentile"
		label var h_i_p`p' "Total family labor supply `p' percentile"
	}
	
	*********** For daily_earnings in Table 4
	forvalues p = 90/99{
		quietly _pctile daily_earnings, p(`p')
		local thr = r(r1)
		gen daily_earnings_p`p' = cond(missing(daily_earnings), ., min(daily_earnings, `thr'))
		label var daily_earnings_p`p' "daily_earnings capped at `p'th percentile"
	}
	**** handle case 100
	egen w_on_farm_hours_p100 = rowtotal(hired_ganyu_hours farm_hours), missing
	egen w_family_hours_p100 = rowtotal(farm_hours did_ganyu_hours)
	
	label var w_on_farm_hours_p100 "Total hours labor demand 100 percentile"
	label var w_family_hours_p100 "Total hours labor supply 100 percentile"
	
	ren hired_ganyu_hours hire_hours_p100
	ren did_ganyu_hours work_hours_p100
	ren farm_hours fam_hours_p100
	
	label var work_hours_p100 "Hours of ganyu sold 100 percentile"
	label var hire_hours_p100 "Hours of ganyu hired 100 percentile"
	label var fam_hours_p100 "Hours of family labor on-farm 100 percentile"
	
	egen h_i_p100 = rowtotal(work_hours_p100 fam_hours_p100)
	egen d_i_p100 = rowtotal(hire_hours_p100 fam_hours_p100)
	
	label var d_i_p100 "Total labor demand 100 percentile"
	label var h_i_p100 "Total family labor supply 100 percentile"
	
	// Original Code
	egen w_on_farm_hours = rowtotal(hired_ganyu_hours99 farm_hours99), missing
	egen w_family_hours = rowtotal(farm_hours99 did_ganyu_hours99)
	
	ren hired_ganyu_hours99 hire_hours
	ren did_ganyu_hours99 work_hours
	ren farm_hours99 fam_hours
	
	egen h_i = rowtotal(work_hours fam_hours), mi
	egen d_i = rowtotal(hire_hours fam_hours), mi
	
	keep $adminvars $controls $blocks reserves_q total_reserve reserves_q10 b_interest_q b_interest ///
		any_ganyu hire_ganyu any_farm_work w_on_farm_hours w_family_hours hire_hours 		did_ganyu_hours work_hours fam_hours ///
		daily_earnings99 daily_earnings95 vmean_wage cen_num_hh hours_day vtag pop dist_road_gps ///
		farm_days did_ganyu_days num_farm_workers did_ganyu_mem d_i h_i ///
		*_p?   // <- brings in all the 90–100 variants you created
		/// brings 100 percentile
		
		
		
	save "$analys/household_panel_final", replace 
		
	
*** ag production ***
	
	use "$clean/Productivity_panel_clean.dta", clear 	
	
	keep $adminvars $controls $blocks reserves_q total_reserve reserves_q10 b_interest_q b_interest *harvest_value* inputs_kw_value* acres_cash_crops* ///
		seed_kw fert_kw_value chem_kw_value 
		
	tempfile temp
	save `temp', replace
	
	use "$analys/household_panel_final", clear 
	merge 1:1 hhid survey_round monthyear using `temp'
	drop _merge
	
	save "$analys/household_panel_final", replace 

*** consumption ***
	
	use "$clean/Consumption_full_panel_clean", clear 
	
	gen harvest_meals = adult_nshima_1w if (calendar_month > 4 & calendar_month < 8)
	gen hungry_meals = adult_nshima_1w if calendar_month < 4
	
	foreach var in expend_clothes expend_beer expend_tobacco expend_sweets expend_tea {
		replace `var' = `var'_noone == 0
		replace `var' = . if `var'_noone == .
		}
		
	keep hhid survey_round monthyear adult_nshima_1w food_short food_sec_z hungry_meals harvest_meals ///
		sv_total total_liquidity grain_savings /// * these are not currently in analysis
		expend_clothes expend_beer expend_tobacco expend_sweets expend_tea food_short* ///
		green_maize_1w
	
	tempfile temp
	save `temp', replace
	
	use "$analys/household_panel_final", clear 
	merge 1:1 hhid survey_round monthyear using `temp'
	drop _merge
	
	save "$analys/household_panel_final", replace 
	
*** transactions ***
	
	use "$clean/Cashflow_panel_short_recall_clean.dta", clear

	gen any_purchase = (maize_purchases_price != . | mealie_purchases_price != .)
	replace any_purchase = . if monthyear < tm(2014m8)
	gen any_sale = (maize_sales_price != . | mealie_sales_price != .)
	replace any_sale = . if monthyear < tm(2014m8)
	egen price = rowmean(maize_sales_price maize_purchases_price)
	
	keep hhid survey_round monthyear any_purchase any_sale price 
	
	tempfile temp
	save `temp', replace
	
	use "$analys/household_panel_final", clear 
	merge 1:1 hhid survey_round monthyear using `temp'
	drop _merge
	
	save "$analys/household_panel_final", replace 
	
	use "$clean/Cashflow_panel_long_recall_clean", clear 
	
	keep hhid survey_round monthyear sell_asset* sell_animal* 
	
	tempfile temp
	save `temp', replace
	
	use "$analys/household_panel_final", clear 
	merge 1:1 hhid survey_round monthyear using `temp'
	drop _merge
	
	save "$analys/household_panel_final", replace 
	
*** health ***
	
	use "$clean/Health_panel_clean", clear 
	
	ren mental_health_problem mental_health

	keep hhid survey_round monthyear $id hlth_ill_filter SR_health_PCA weeds_acre_hour hlth_biceps_clean hlth_waist_clean hlth_grip_num hlth_grip_sec ///
		raven_Z stroop_automated_Z2 stroop_automated_Z3 ///
		mental_health mental_nervous mental_sleep mental_dailywork mental_easilytired ///
		fi_*
	
	tempfile temp
	save `temp', replace
	
	use "$analys/household_panel_final", clear 
	merge 1:1 hhid survey_round monthyear using `temp'
	drop _merge
	
	save "$analys/household_panel_final", replace 

*** borrowing ***
	
	use "$clean/SavingBorrowing_long_recall_clean", clear 
	
	keep hhid survey_round monthyear loan_taken_clean* nkhon_clean* kaloba_clean* ///
		loan_bank_clean loan_union_clean loan_govt_clean loan_ngo_clean ///
		save_rosca_cashrounds_clean save_village_bank_vsla_clean loan_inputprov_clean loan_agricom_clean
	
	tempfile temp
	save `temp', replace
	
	use "$analys/household_panel_final", clear 
	merge 1:1 hhid survey_round monthyear using `temp'
	drop _merge
	
	save "$analys/household_panel_final", replace 
	
	use "$clean/SavingBorrowing_short_recall_clean", clear 
	
	keep hhid survey_round monthyear loan_interest_clean 
	
	tempfile temp
	save `temp', replace
	
	use "$analys/household_panel_final", clear 
	merge 1:1 hhid survey_round monthyear using `temp'
	drop _merge
	
*** tidy up dataset ***
	
	order $adminvars $id $controls $blocks total_reserve reserves_q reserves_q10 b_interest b_interest_q 
	
*** label and rename vars ***
	
	ren total_reserve b_total_reserve
	ren reserves_q b_reserves_q	
	ren reserves_q10 b_reserves_q10
	
	label var monthyear "Month of survey"
	label var calendar_month "Calendar month of survey"
	
	label var work_hours "Hours of ganyu sold 99 percentile"
	label var hire_hours "Hours of ganyu hired 99 percentile"
	label var b_total_reserve "Baseline cash and grain reserves" 
	label var b_interest_q "Quartile of baseline interest rate"
	label var b_interest "Baseline interest rate"
	label var pop "Quartile of share of village pop treated" 

	label var fam_hours "Hours of family labor on-farm 99 percentile"
	label var w_on_farm_hours "Total hours labor demand 99 percentile"
	label var w_family_hours "Total hours labor supply 99 percentile"
	label var any_farm_work "Any hh member worked on-farm"
	label var any_ganyu "Any hh member did ganyu"
	label var hire_ganyu "Any ganyu hired"
	label var d_i "Total labor demand 99 percentile"
	label var h_i "Total family labor supply 99 percentile"
	
	label var harvest_value "Agricultural output value"
	label var l_harvest_value "Log agricultural output value"
	label var harvest_value_CP "Agricultural output value (constant prices)"
	label var l_harvest_value_CP "Log agricultural output value (constant prices)"
	
	label var harvest_value_bl "Baseline output value"
	label var l_harvest_value_bl "Log baseline output value"
	label var harvest_value_CP_bl "Baseline output value (constant prices)"
	label var l_harvest_value_CP_bl "Log baseline output value (constant prices)"

	label var adult_nshima_1w "Adult meals per day"
	label var harvest_meals "Adult meals per day, harvest season"
	label var hungry_meals "Adult meals per day, hungry season"
	
	label var any_purchase "Any maize purchase in past two weeks"
	label var any_sale "Any maize sale in past two weeks"
	label var price "Average trasaction price for maize in past two weeks"
	
	label var mental_health "Index of mental health problems"
	label var female "Respondent female"
	label var ageu20 "Respondent age"
	label var age3039 "Respondent age" 
	label var age4049 "Respondent age" 
	label var age5059 "Respondent age" 
	label var age60_plus "Respondent age"
	
	label var sell_animal "Sold animal in past year"
	label var sell_asset "Sold asset in past year"
	label var sell_asset_bl "Sold asset in baseline year"
	label var sell_animal_bl "Sold animal in baseline year"
	
save "$analys/household_panel_final", replace 

**********************************************************************************************
*************************** 4. Price survey **************************************************
**********************************************************************************************
*Cleans the price survey data	
use "$clean/price_survey.dta", clear

	gen monthyear = mofd(date)
	gen calendar_month = month(date)
	gen year = year(date)
	
	format monthyear %tm
	tab monthyear transaction_type, row
	tab monthyear maize_form, row
	
	label var surveyor "Surveyor"
	label var date "Date"
	label var monthyear "Month"
	label var calendar_month "Calendar month"
	label var year "Year"

save "$analys/price_survey_final.dta", replace

**********************************************************************************************
*************************** 5. Reporting bias ************************************************
**********************************************************************************************
*Cleans the social desirability bias data	
use "$clean/Reporting_bias_clean.dta", clear

	keep hhid vid treated treatment treatedin1 ls3_bias_score e_bias_score
	order hhid vid treated treatment treatedin1 ls3_bias_score e_bias_score

save "$analys/reporting_bias_final.dta", replace

**********************************************************************************************
*************************** 6. Yield checks **************************************************
**********************************************************************************************
*Cleans the yield verification data	
use "$clean/Yield_checks_clean.dta", clear

	keep hhid vid treated treatment treatedin1 year analysis objective sr_yields_acre objective sr_share_hybrid 
	order hhid vid treated treatment treatedin1 year analysis objective sr_yields_acre objective sr_share_hybrid

save "$analys/yield_checks_final.dta", replace


	
