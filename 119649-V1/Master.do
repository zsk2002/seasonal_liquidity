/* 

Replication Code for "Seasonal liquidity, rural labor markets and agricultural production"

Version: 1.0 
Last Updated: 7/11/2020
*/

clear all
cap log close
set maxvar 10000
set more off
set varabbrev on

/*
Installing Necessary Ado Files:

ssc install inecdec0 //For estimation of inequality outcomes in Model_simulation_figures.do
search leebounds // For estimation of Lee Treatment Effect Bounds in Main_tables.do
*/

cap cd "" //Insert your directory here
*log using "" //Insert your log path here
global input "Do Files" //Path to do-files


*********************** Creates the final analysis datasets **********************************
do "$input/Final_datasets.do"

*********************** Main Paper Tables and Figures ****************************************
do "$input/Main_tables.do"
do "$input/Main_figures.do"
do "$input/Model_simulation_figures.do"

************************ Appendix Figures and Tables *****************************************
do "$input/Appendix_tables.do"
do "$input/Appendix_figures.do"
**********************************************************************************************
cap log close
