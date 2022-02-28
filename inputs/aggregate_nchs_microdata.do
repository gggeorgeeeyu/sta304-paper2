*get all births 1980-2019, all 15-44 and by subgroup

*---------------------------------------------------------
* Program Setup
*---------------------------------------------------------
version 13
set more off
*clear all
set linesize 80
*macro drop _all
set scheme s1color
*Data Sources:
* Vital Statistics Birth Data, 1980-1989: NBER NCHS' Vital Statistics Natality Birth Data
* http://data.nber.org/data/vital-statistics-natality-data.html, accessed 7/27/20

cd "D:\fertility-data\nber"

capture log close
log using "D:\fertility-data\FT-LHSdataprep.log", replace


****************************************************************
*****************  NATALITY DATA  ******************************
****************************************************************
*1980-1989 come from NBER 
cd "D:\fertility-data\nber"

tempfile temp1			//creates temporary file for append later

*INPUT DATA FOR 1980
use natl1980.dta, clear		//reads 1980 vital stats data into stata

rename datayear year		//to create same naming convention
rename stateres stateenchs	//to create same naming convention
destring stateenchs, replace	//to create numeric variable

replace year = 1980 + year		//year coded as 0 instead of 1980
gen white = crace == 1			//create dummy var with white == 1
drop if stateenchs > 51			//keeps only 50 states and DC

gen nonmarital = dmar == 2		//creates dummy var with nonmarried == 1
replace nonmarital = . if dmar > 2	//codes . as missing variables

gen educ = 0
replace educ = 1 if dmeduc <= 11
replace educ = 2 if dmeduc == 12
replace educ = 3 if dmeduc >=13 & dmeduc<=15
replace educ = 4 if dmeduc == 16
replace educ = 5 if dmeduc == 17
replace educ = 99 if dmeduc == 99

keep year stateenchs dmage white dmage nonmarital educ //keeps only the variables for project

save `temp1', replace		//saves changes in temporary variable


*INPUT DATA FOR 1981 - 1988		//year 1981-88 follow same structure as 1980

forvalues year = 81/88 {
	use natl19`year'.dta, clear

	rename datayear year
	rename stateres stateenchs
	destring stateenchs, replace

	replace year = 1980 + year
	gen white = crace == 1
	drop if stateenchs > 51

	gen nonmarital = dmar == 2
	replace nonmarital = . if dmar > 2
 
    gen educ = 0
	replace educ = 1 if dmeduc <= 11
	replace educ = 2 if dmeduc == 12
	replace educ = 3 if dmeduc >=13 & dmeduc<=15
	replace educ = 4 if dmeduc == 16
	replace educ = 5 if dmeduc == 17
	replace educ = 99 if dmeduc == 99

	keep year stateenchs white dmage nonmarital educ
	append using `temp1'	//appending all years into one datafile
	save `temp1', replace
}

//for remaining years, I comment only those lines that vary from those above 
*INPUT DATA FOR 1989	
use natl1989.dta, clear

rename datayear year
rename stateres stateenchs
destring stateenchs, replace

gen white = crace == 1
drop if stateenchs > 51

gen nonmarital = dmar == 2
replace nonmarital = . if dmar > 2

    gen educ = 0
	replace educ = 1 if dmeduc <= 11
	replace educ = 2 if dmeduc == 12
	replace educ = 3 if dmeduc >=13 & dmeduc<=15
	replace educ = 4 if dmeduc == 16
	replace educ = 5 if dmeduc == 17
	replace educ = 99 if dmeduc == 99
	
keep year stateenchs white dmage nonmarital educ
append using `temp1'

save `temp1', replace

*INPUT DATA FOR 1990
*use natl1990.dta, clear
	use "D:\fertility-data\nchs\NatAC1990\natl1990", clear

rename datayear year
cap rename mplbirr mbstate_rec
rename stateres stateenchs
destring stateenchs, replace

drop if stateenchs > 51
gen hisp = orracem <= 5			//create dummy var with hispanic == 1
gen whitenh = orracem == 6		//create dummy var with white_nonhispanic == 1
gen blacknh = orracem == 7		//create dummy var with black_nonhispanic == 1
gen white = mrace == 1			//create dummy var with white == 1

gen mexican = orracem == 1			//create dummy var with mexican == 1

gen nonmarital = dmar == 2
replace nonmarital = . if dmar > 2

    gen educ = 0
	replace educ = 1 if dmeduc <= 11
	replace educ = 2 if dmeduc == 12
	replace educ = 3 if dmeduc >=13 & dmeduc<=15
	replace educ = 4 if dmeduc == 16
	replace educ = 5 if dmeduc == 17
	replace educ = 99 if dmeduc == 99

gen native = 0
replace native = mbstate_rec == 1
replace native = . if mbstate_rec == 3

gen mexicob = mplbir == 57
	
keep year stateenchs white whitenh blacknh hisp mexican dmage nonmarital educ native mexicob livord9 
include $programs_dir/staterename
append using `temp1'  //// uncommented to add 1980-1989 data back in

save `temp1', replace

*INPUT DATA FOR 1991 - 2002	//year 1991-2002 follow same structure as 1990
forvalues year = 1991/2002 {

di `year'
    
	*use natl`year'.dta, clear
	use "D:\fertility-data\nchs\NatAC`year'\natl`year'", clear

	rename datayear year
	rename stateres stateenchs
	destring stateenchs, replace

	drop if stateenchs > 51
	gen hisp = orracem <= 5
	gen whitenh = orracem == 6
	gen blacknh = orracem == 7
	gen white = mrace == 1

	gen mexican = orracem == 1			//create dummy var with mexican == 1

	gen nonmarital = dmar == 2
	replace nonmarital = . if dmar > 2
	
	gen educ = 0
	replace educ = 1 if dmeduc <= 11
	replace educ = 2 if dmeduc == 12
	replace educ = 3 if dmeduc >=13 & dmeduc<=15
	replace educ = 4 if dmeduc == 16
	replace educ = 5 if dmeduc == 17
	replace educ = 99 if dmeduc == 99
	
	cap rename mplbirr mbstate_rec
	gen native = 0
	replace native = mbstate_rec == 1
	replace native = . if mbstate_rec == 3
	
	gen mexicob = mplbir == 57

	keep year stateenchs white whitenh blacknh hisp mexican dmage nonmarital educ native mexicob livord9
    include $programs_dir/staterename
	
	append using `temp1'
	save `temp1', replace
}

*tempfile temp1
*save `temp1', replace

*INPUT DATA FOR 2003
*use "D:\fertility-data\nber\natl2003.dta", clear
use "D:\fertility-data\nchs\NatAC2003\natl2003", clear
rename dob_yy year
rename mrstate stname
rename mager dmage	//no normal mother's age variable mager == mage - 13 in 2013
rename lbo_rec livord9
replace dmage = dmage + 13 //creates standard mother's age var

drop if stname == "GU" | stname == "MP" | stname == "PR" | stname == "VI" | 	   stname == "CC" | stname == "CU" | stname == "MX" | stname == "YY" | 		  stname == "ZZ" | stname == "AS"	//states coded asabbreviations instead of numbers starting in 2003

gen hisp = mracehisp <= 5
gen whitenh = mracehisp == 6
gen blacknh = mracehisp == 7
gen white = mrace == 1

gen mexican = mracehisp == 1			//create dummy var with mexican == 1

gen nonmarital = mar == 2
replace nonmarital = . if mar>2

	gen educ = 0
	replace educ = 1 if meduc <= 2
	replace educ = 2 if meduc == 3
	replace educ = 3 if meduc >=4 & meduc<=5
	replace educ = 4 if meduc == 6
	replace educ = 5 if meduc >=7 & meduc<=8
	replace educ = 99 if meduc == 9 | meduc==. 
	*many missing meduc values, use dmeduc as second source of educ
	replace educ = 1 if dmeduc <= 11 & meduc==.
	replace educ = 2 if dmeduc == 12 & meduc==.
	replace educ = 3 if dmeduc >=13 & dmeduc<=15 & meduc==.
	replace educ = 4 if dmeduc == 16 & meduc==.
	replace educ = 5 if dmeduc == 17 & meduc==.
	replace educ = 99 if dmeduc == 99 & meduc==.

	cap rename mplbirr mbstate_rec
	gen native = 0
	replace native = mbstate_rec == 1
	replace native = . if mbstate_rec == 3
	
	gen mexicob = umbstate == "MX"

keep year stname white whitenh blacknh hisp mexican dmage nonmarital educ native mexicob livord9

append using `temp1'
save `temp1', replace

*INPUT DATA FOR 2004
*use "D:\fertility-data\nber\natl2004.dta", clear
use "D:\fertility-data\nchs\NatAC2004\natl2004", clear
rename dob_yy year
rename mager dmage
rename mrstate stname
rename lbo_rec livord9

drop if stname == "GU" | stname == "MP" | stname == "PR" | stname == "VI" | 	   stname == "CC" | stname == "CU" | stname == "MX" | stname == "YY" | 		  stname == "ZZ" | stname == "AS"

gen hisp = mracehisp <= 5
gen whitenh = mracehisp == 6
gen blacknh = mracehisp == 7
gen white = mrace == 1

gen mexican = mracehisp == 1			//create dummy var with mexican == 1

gen nonmarital = mar == 2
replace nonmarital = . if mar>2

	gen educ = 0
	replace educ = 1 if meduc <= 2
	replace educ = 2 if meduc == 3
	replace educ = 3 if meduc >=4 & meduc<=5
	replace educ = 4 if meduc == 6
	replace educ = 5 if meduc >=7 & meduc<=8
	replace educ = 99 if meduc == 9  | meduc==.
	*many missing meduc values, use dmeduc as second source of educ
	replace educ = 1 if dmeduc <= 11 & meduc==.
	replace educ = 2 if dmeduc == 12 & meduc==.
	replace educ = 3 if dmeduc >=13 & dmeduc<=15 & meduc==.
	replace educ = 4 if dmeduc == 16 & meduc==.
	replace educ = 5 if dmeduc == 17 & meduc==.
	replace educ = 99 if dmeduc == 99 & meduc==.
	
	cap rename mplbirr mbstate_rec
	gen native = 0
	replace native = mbstate_rec == 1
	replace native = . if mbstate_rec == 3

	gen mexicob = umbstate == "MX"
	
keep year stname white whitenh blacknh hisp mexican dmage nonmarital educ native mexicob livord9

append using `temp1'
save `temp1', replace 

forvalues year = 2005/2013 {
use "D:\fertility-data\nchs\NatAC`year'\natl`year'", clear
rename dob_yy year
rename mager dmage
rename mrstate stname
cap rename mrace6 mrace
cap rename dmar mar 
rename lbo_rec livord9

cap gen dmeduc=. // create dmeduc if year>2013

drop if stname == "GU" | stname == "MP" | stname == "PR" | stname == "VI" | stname == "CC" | stname == "CU" | stname == "MX" | stname == "YY" | stname == "ZZ" | stname == "AS"

gen hisp = mracehisp <= 5
gen whitenh = mracehisp == 6
gen blacknh = mracehisp == 7
gen white = mrace == 1

gen mexican = mracehisp == 1		//create dummy var with mexican == 1


gen nonmarital = mar == 2
replace nonmarital = . if mar>2

	gen educ = 0
	replace educ = 1 if meduc <= 2
	replace educ = 2 if meduc == 3
	replace educ = 3 if meduc >=4 & meduc<=5
	replace educ = 4 if meduc == 6
	replace educ = 5 if meduc >=7 & meduc<=8
	replace educ = 99 if meduc == 9 | meduc==.  
	*many missing meduc values, use dmeduc as second source of educ
	replace educ = 1 if dmeduc <= 11 & meduc==.
	replace educ = 2 if dmeduc == 12 & meduc==.
	replace educ = 3 if dmeduc >=13 & dmeduc<=15 & meduc==.
	replace educ = 4 if dmeduc == 16 & meduc==.
	replace educ = 5 if dmeduc == 17 & meduc==.
	replace educ = 99 if dmeduc == 99 & meduc==.
	
	cap rename mplbirr mbstate_rec
	gen native = 0
	replace native = mbstate_rec == 1
	replace native = . if mbstate_rec == 3
	
	cap rename mbstate umbstate
	gen mexicob = umbstate == "MX"
	replace mexicob = 1 if mbcntry == "MX"
	
keep year stname white whitenh blacknh hisp mexican dmage nonmarital educ native mexicob livord9

	append using `temp1'
	save `temp1', replace
}

*separate 2014-2019 b/c they recode race/ethnicity question
forvalues year = 2014/2019 {
use "D:\fertility-data\nchs\NatAC`year'\natl`year'", clear
rename dob_yy year
rename mager dmage
rename mrstate stname
cap rename mrace6 mrace
cap rename dmar mar 
rename lbo_rec livord9

cap gen dmeduc=. // create dmeduc if year>2013

drop if stname == "GU" | stname == "MP" | stname == "PR" | stname == "VI" | stname == "CC" | stname == "CU" | stname == "MX" | stname == "YY" | stname == "ZZ" | stname == "AS"

gen hisp = mracehisp == 7
gen whitenh = mracehisp == 1
gen blacknh = mracehisp == 2
gen white = mrace == 1

gen mexican = mhisp_r == 1	//create dummy var with mexican == 1

gen nonmarital = mar == 2
replace nonmarital = . if mar>2

	gen educ = 0
	replace educ = 1 if meduc <= 2
	replace educ = 2 if meduc == 3
	replace educ = 3 if meduc >=4 & meduc<=5
	replace educ = 4 if meduc == 6
	replace educ = 5 if meduc >=7 & meduc<=8
	replace educ = 99 if meduc == 9 | meduc==.  
	*many missing meduc values, use dmeduc as second source of educ
	replace educ = 1 if dmeduc <= 11 & meduc==.
	replace educ = 2 if dmeduc == 12 & meduc==.
	replace educ = 3 if dmeduc >=13 & dmeduc<=15 & meduc==.
	replace educ = 4 if dmeduc == 16 & meduc==.
	replace educ = 5 if dmeduc == 17 & meduc==.
	replace educ = 99 if dmeduc == 99 & meduc==.

	cap rename mplbirr mbstate_rec
	gen native = 0
	replace native = mbstate_rec == 1
	replace native = . if mbstate_rec == 3

	gen mexicob = mbstate == "MX"
	replace mexicob = 1 if mbcntry == "MX"
	
keep year stname white whitenh blacknh hisp mexican dmage nonmarital educ native mexicob livord9

	append using `temp1'
	save `temp1', replace
}

*CREATE BIRTHS DATA FILE
use `temp1', clear

*save "D:\fertility-data\nber\FT-styr-births1990-2019.dta", replace //saves data in temp1 to a .dta file

drop if dmage < 15 // | dmage > 44		//initially looking at mothers aged 15-44

save "D:\fertility-data\nber\FT-styr-births1980-2019.dta", replace 

preserve 
*** Create births by cohort
rename dmage mage 
gen cohort = year-mage
drop if mage < 15 | mage > 44		//drops data for irrelevant ages

gen cohort2 = .
replace cohort2 = 1 if cohort >= 1968 & cohort <=1972
replace cohort2 = 2 if cohort >= 1973 & cohort <=1977
replace cohort2 = 3 if cohort >= 1978 & cohort <=1982
replace cohort2 = 4 if cohort >= 1983 & cohort <=1987
replace cohort2 = 5 if cohort >= 1988 & cohort <=1992
replace cohort2 = 6 if cohort >= 1993 & cohort <=1997
drop if cohort2==.

collapse (count) numbirth = year, by (cohort2 mage)

sort cohort2 mage
by cohort2: gen cum_birth = sum(numbirth)

save "D:\fertility-data\nber\nchs_cohort_analysis", replace
restore

drop if year<1990

save "D:\fertility-data\nber\FT-styr-births1990-2019.dta", replace 

// each subsection aggregates individual data to count the number of births by state of the specified ages. I only comment on new code.
*---------------------------------------------------------
* WOMEN AGED 15-19, 20-34,35-44
*---------------------------------------------------------
*CREATE NUMBER OF BIRTHS FOR ALL TEENS 15-19
tempfile temp2  //resets temp2 file

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 19		//drops data for irrelevant ages
collapse (count) numbirth1519 = dmage, by (stname year)	//counts number of births in specified age group by state and year
save `temp2', replace // beginning new datafile 

*CREATE NUMBER OF BIRTHS FOR ALL WOMEN 20-24
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear
drop if dmage < 20 | dmage > 24
collapse (count) numbirth2024 = dmage, by (stname year)
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS FOR ALL WOMEN 25-29
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear
drop if dmage < 25 | dmage > 29
collapse (count) numbirth2529 = dmage, by (stname year)
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS FOR ALL WOMEN 20-34
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear
drop if dmage < 30 | dmage > 34
collapse (count) numbirth3034 = dmage, by (stname year)
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS FOR ALL WOMEN 35-39
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear
drop if dmage < 35 | dmage > 39
collapse (count) numbirth3539 = dmage, by (stname year)
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS FOR ALL WOMEN 40-44
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear
drop if dmage < 40 | dmage > 44
collapse (count) numbirth4044 = dmage, by (stname year)
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS FOR ALL WOMEN 45+
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear
drop if dmage < 45 | dmage==.
collapse (count) numbirth45plus = dmage, by (stname year)
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* WOMEN IN 5 EDUC GROUPS
*---------------------------------------------------------

*CREATE NUMBER OF BIRTHS FOR ALL EDUC=1-5
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 20 | dmage > 44
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i' = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}

*CREATE NUMBER OF BIRTHS FOR MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 20 | dmage > 44
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 15-19
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage > 19
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_1519 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}

*CREATE NUMBER OF BIRTHS FOR 15-19, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage > 19
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_1519 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS FOR ALL EDUC=1-5
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 45
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_45plus = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 45
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_45plus = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* WOMEN IN 3 RACE/ETH GROUPS
*---------------------------------------------------------

*whitenh blacknh hisp
foreach i in whitenh blacknh hisp {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if `i'!=1		//drops data for irrelevant race/eths
collapse (count) numbirth_`i' = `i', by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}

*---------------------------------------------------------
* HISPANIC - MEXICO NATIVEBORN
*---------------------------------------------------------
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if mexican!=1		//drops data for irrelevant race/eths
drop if native!=1
collapse (count) numbirth_hisp_mexican_nativeb = mexican, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* HISPANIC - NON-MEXICO NATIVEBORN
*---------------------------------------------------------
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if mexican!=0		//drops data for irrelevant race/eths
drop if native!=1
collapse (count) numbirth_hisp_nonmexican_nativeb = mexican, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* WOMEN MARRIED/UNMARRIED
*---------------------------------------------------------

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if nonmarital!=1		//drops data for irrelevant race/eths
collapse (count) numbirth_unmarried = nonmarital, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if nonmarital==1 | nonmarital==.		//drops data for irrelevant race/eths
collapse (count) numbirth_married = nonmarital, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* AGE & EDUC VERSION 1
*---------------------------------------------------------
*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 20-24
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 20 | dmage > 24
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_2024 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 20-24, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 20 | dmage > 24
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_2024 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 25-34
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 25 | dmage > 34
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_2534 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 25-34, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 25 | dmage > 34
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_2534 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 35-44
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 35 | dmage > 44
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_3544 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 35-44, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 35 | dmage > 44
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_3544 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* AGE & EDUC VERSION 2 (all 5 year age groups)
*---------------------------------------------------------
*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 25-29
foreach j in whitenh blacknh hisp {
forvalues i = 1(1)5 {
use if (dmage >= 25 & dmage <= 29) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1990-2004
drop if `j'!=1 | (dmage < 25 | dmage > 29)
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_2529 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace
}

*CREATE NUMBER OF BIRTHS FOR 25-29, MISSING EDUC
use if (dmage >= 25 & dmage <= 29) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1990-2004
drop if `j'!=1 | (dmage < 25 | dmage > 29)
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_2529 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 30-34
forvalues i = 1(1)5 {
use if (dmage >= 30 & dmage <= 34) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1990-2004
drop if `j'!=1 | (dmage < 30 | dmage > 34)
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_3034 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 30-34, MISSING EDUC
use if (dmage >= 30 & dmage <= 34) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1990-2004
drop if `j'!=1 | (dmage < 30 | dmage > 34)
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_3034 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 35-39
forvalues i = 1(1)5 {
use if (dmage >= 35 & dmage <= 39) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | (dmage < 35 | dmage > 39)
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_3539 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 35-39, MISSING EDUC
use if (dmage >= 35 & dmage <= 39) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1990-2004
drop if `j'!=1 | (dmage < 35 | dmage > 39)
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_3539 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace


*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 40-44
forvalues i = 1(1)5 {
use if (dmage >= 40 & dmage <= 44) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1990-2004
drop if `j'!=1 | (dmage < 40 | dmage > 44)
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_4044 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace
}

*CREATE NUMBER OF BIRTHS FOR 40-44, MISSING EDUC
use if (dmage >= 40 & dmage <= 44) using "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1990-2004
drop if `j'!=1 | (dmage < 40 | dmage > 44)
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_4044 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
*tab _merge
drop _merge
save `temp2', replace
}


*---------------------------------------------------------
* RACE & AGE & EDUC
*---------------------------------------------------------

foreach j in whitenh blacknh hisp {
*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 15-19
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 |  dmage > 19
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_1519 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 1519, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | dmage > 19 
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_1519 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace


*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 20-24
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | (dmage < 20 | dmage > 24)
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_2024 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 20-24, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | (dmage < 20 | dmage > 24)
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_2024 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 25-34
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | (dmage < 25 | dmage > 34)
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_2534 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 25-34, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | (dmage < 25 | dmage > 34)
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_2534 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace


*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 35-44
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | (dmage < 35 | dmage > 44)
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_`j'_3544 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}
*CREATE NUMBER OF BIRTHS FOR 35-44, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if `j'!=1 | (dmage < 35 | dmage > 44)
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_`j'_3544 = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}


*---------------------------------------------------------
* Hispanic by Nativity
*---------------------------------------------------------

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if hisp!=1
drop if native!=1		//drops data for irrelevant race/eths
collapse (count) numbirth_hisp_nativeb = hisp, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if hisp!=1
drop if native!=0		//drops data for irrelevant race/eths
collapse (count) numbirth_hisp_nonnativeb = hisp, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 44
drop if hisp!=1
drop if native!=.		//drops data for irrelevant race/eths
collapse (count) numbirth_hisp_missnativeb = hisp, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* Hispanic by Nativity, by Age
*---------------------------------------------------------
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 15 | dmage > 19
drop if hisp!=1
drop if native!=0		
collapse (count) numbirth_hisp_nonnativeb1519 = hisp, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 20 | dmage > 24
drop if hisp!=1
drop if native!=0		
collapse (count) numbirth_hisp_nonnativeb2024 = hisp, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 25 | dmage > 34
drop if hisp!=1
drop if native!=0		
collapse (count) numbirth_hisp_nonnativeb2534 = hisp, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if dmage < 35 | dmage > 44
drop if hisp!=1
drop if native!=0		
collapse (count) numbirth_hisp_nonnativeb3544 = hisp, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*---------------------------------------------------------
* Hispanic by Nativity, by Educ
*---------------------------------------------------------
*CREATE NUMBER OF BIRTHS BY EDUC=1-5 for all 15-19
forvalues i = 1(1)5 {
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if hisp!=1
drop if native!=0	
drop if educ!=`i'		//drops data for irrelevant ages
collapse (count) numbirth_educ`i'_hispforb = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace
}

*CREATE NUMBER OF BIRTHS FOR 15-19, MISSING EDUC
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if hisp!=1
drop if native!=0	
drop if educ!=99		//drops data for irrelevant ages
collapse (count) numbirth_educ_miss_hispforb = educ, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace


*---------------------------------------------------------
* Hispanic Foreign Born, by Mexico-Born or Other
*---------------------------------------------------------
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if hisp!=1
drop if native!=0	
drop if mexicob!=1		
collapse (count) numbirth_hispforb_mex = mexicob, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if hisp!=1
drop if native!=0	
drop if mexicob!=0		
collapse (count) numbirth_hispforb_other = mexicob, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
tab _merge
drop _merge
save `temp2', replace

*Hispanic, Mexican, Native Born
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
drop if hisp!=1
drop if native!=1	
drop if mexican!=1		
collapse (count) numbirth_hispnativeb_mex = mexican, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
save `temp2', replace

*Hispanic, Non-Mexican, Native Born
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
drop if hisp!=1
drop if native!=1	
drop if mexican!=0		
collapse (count) numbirth_hispnativeb_nonmex = mexican, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
save `temp2', replace

*---------------------------------------------------------
* Birth Order
*---------------------------------------------------------
*First Birth
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
drop if livord9!=1		
collapse (count) numbirth_firstbirth = livord9, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
save `temp2', replace

*2nd Birth
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
drop if livord9!=2		
collapse (count) numbirth_secondbirth = livord9, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
save `temp2', replace

*3rd Birth
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
drop if livord9!=3		
collapse (count) numbirth_thirdbirth = livord9, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
save `temp2', replace

*4th+ Birth
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
drop if livord9!=1		
collapse (count) numbirth_fourthbirth = livord9, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
save `temp2', replace

*Missing Birth Order
use "D:\fertility-data\nber\FT-styr-births1990-2019.dta", clear //start with all 1980-2004
drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
drop if livord9!=1		
collapse (count) numbirth_noorderbirth = livord9, by (stname year)	//counts number of births in specified age group by state and year
merge 1:1 stname year using `temp2'
save `temp2', replace


*---------------------------------------------------------
* CLEAN UP STATS
*---------------------------------------------------------
sort stname year

statastates, a(stname)
rename state_fips state
keep year stname state numbirth* 

save "D:\fertility-data\lhs_births_1990_2018", replace

drop if year<1990
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
merge 1:1 stname year using "D:\fertility-data\seer\age_race_comp_seer.dta"

******* FINAL LHS DATASET *****************
*rename educ groups
rename numbirth_educ1* numbirth_lesshs*
rename numbirth_educ2* numbirth_hsgrad*
rename numbirth_educ3* numbirth_somecoll*
rename numbirth_educ4* numbirth_ba*
rename numbirth_educ5* numbirth_gtc*

cap drop numbirth2034 numbirth3544 brate1519 brate2034 brate3544 numbirth1545plus ///
numbirth1544 numbirth_colgrad numbirth_alleduc numbirth_whitenhblacknhhisp numbirth_marriedunmarried

gen numbirth2034 = numbirth2024 + numbirth2529 + numbirth3034 
gen numbirth3544 = numbirth3539 + numbirth4044
gen numbirth1544 = numbirth1519 + numbirth2024 + numbirth2529 + numbirth3034 + numbirth3539 + numbirth4044
gen numbirth1545plus = numbirth1519 + numbirth2024 + numbirth2529 + numbirth3034 + numbirth3539 + numbirth4044 + numbirth45plus

gen pop1544 = pop1519 + pop2034 + pop3544

gen brate1519=ln(numbirth1519/pop1519)
gen brate2034=ln(numbirth2034/pop2034)
gen brate3544=ln(numbirth3544/pop3544)
gen brate1544=ln(numbirth1544/pop1544)

foreach age in 1519 2024 2534 3544 {
	foreach var in lesshs hsgrad somecoll ba gtc educ_miss {
	replace numbirth_`var'_`age' =0 if numbirth_`var'_`age' ==.
	}
	}

foreach raceeth in whitenh blacknh hisp {
foreach age in 2529 3034 3539 4044 {
	foreach var in lesshs hsgrad somecoll ba gtc educ_miss {
	replace numbirth_`var'_`raceeth'_`age' =0 if numbirth_`var'_`raceeth'_`age' ==.
	}
	}
}

foreach raceeth in whitenh blacknh hisp {
foreach age in 1519 2024 2534 3544 {
	foreach var in lesshs hsgrad somecoll ba gtc educ_miss {
	replace numbirth_`var'_`raceeth'_`age' =0 if numbirth_`var'_`raceeth'_`age' ==.
	}
	}
}

gen numbirth_colgrad_1519 = numbirth_ba_1519 + numbirth_gtc_1519
gen numbirth_colgrad_2024 = numbirth_ba_2024 + numbirth_gtc_2024
gen numbirth_colgrad_2534 = numbirth_ba_2534 + numbirth_gtc_2534
gen numbirth_colgrad_3544 = numbirth_ba_3544 + numbirth_gtc_3544

gen numbirth_colgrad = numbirth_ba + numbirth_gtc
gen numbirth_alleduc = numbirth_lesshs + numbirth_hsgrad + numbirth_somecoll + numbirth_colgrad
gen numbirth_whitenhblacknhhisp = numbirth_whitenh + numbirth_blacknh + numbirth_hisp
gen numbirth_marriedunmarried = numbirth_married + numbirth_unmarried

cap drop _merge
save "D:\fertility-data\LHS_births_pop_1990_2019", replace


log close 
