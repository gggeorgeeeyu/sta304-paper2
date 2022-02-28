*Create Figure 2d, birth rates by Mother's Level of Education
*Births Data is aggregated from NCHS Microdata, aggregated here to the state-year level

cap log close 
log using $ft_output_dir\logs\fig_2d.log, replace

tempfile temp1
tempfile temp2
tempfile temp3
tempfile temp4

******* (1/3) Numerator: Births, 20-44 by Educ Level ********
*From NCHS Natality Microdata
use $ft_data_dir\nchs\nchs_births_pop_1990_2019, clear
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")

gen numbirthalleduc = numbirth_lesshs + numbirth_hsgrad + numbirth_somecoll + numbirth_colgrad + numbirth_educ_miss
gen numbirth_witheduc = numbirth_lesshs + numbirth_hsgrad + numbirth_somecoll + numbirth_colgrad 

collapse (sum) numbirth_lesshs numbirth_hsgrad numbirth_somecoll ///
 numbirth_colgrad numbirthalleduc numbirth_witheduc, by(year)

save `temp1'


******* (2/3) Denominator: Pop 20-44 By Educ Level ********

*USE CPS 1990-2019 (Hispanic Origin Only Recorded 1994-)
use $ft_data_dir\educ\cps_19902019, clear

*drop health insurance supplement in 2014
drop if hflag==1

*keep only females
drop if sex==1

*keep 20-44
drop if age<20 | age>44

*education codes
gen edgrp = ""
replace edgrp = "lesshs" if educ<=71 // includes 12 grades 1992 recode
replace edgrp = "hsgrad" if educ>=72 & educ<=73
replace edgrp = "somecoll" if educ>=80 & educ<=100
replace edgrp = "colgrad" if educ>100
assert edgrp!= ""

*education codes
gen agegrp = ""
replace agegrp = "1519" if age<=19 
replace agegrp = "2024" if age>19 & age<=24
replace agegrp = "2534" if age>24 & age<=34
replace agegrp = "3544" if age>34
assert agegrp!= ""

*education codes 6 grps  
gen agegrp6 = ""
replace agegrp6 = "1519" if age<=19 
replace agegrp6 = "2024" if age>19 & age<=24
replace agegrp6 = "2529" if age>24 & age<=29
replace agegrp6 = "3034" if age>29 & age<=34
replace agegrp6 = "3539" if age>34 & age<=39
replace agegrp6 = "4044" if age>39
assert agegrp6!= ""

*collapse to number by state-year 
collapse (sum) pop=asecwt, by(state year edgrp)

*get state abbreviation to merge
statastates, fips(statefip)
drop _merge state_name statefip
rename state_abbrev stname

*reshape wide 
reshape wide pop, i(year stname) j(edgrp) string

gen total = poplesshs + pophsgrad + popsomecoll + popcolgrad
foreach var in lesshs hsgrad somecoll colgrad{
gen pct_`var'  = pop`var'/total
}
rename pop* pop*_cps 

merge 1:1 stname year using $ft_data_dir\pop\age_race_comp_seer.dta , keepusing(pop1519 pop2034 pop3544)
keep if _merge==3
drop _merge 

gen pop2044 = pop2034 + pop3544
keep stname year pct* *_cps pop2044

foreach var in lesshs hsgrad somecoll colgrad{
gen pop_`var'_seer  = pct_`var'*pop2044
}

keep stname year pop* 

drop if year<1992 | year>2019
*save $data_dir\decomp\state_year_educ_pop, replace

*cap drop _merge
*use $data_dir\decomp\state_year_educ_pop
*assert _merge==3
*drop _merge 

*use cps vars for population count
rename poplesshs_cps poplesshs
rename pophsgrad_cps pophsgrad
rename popsomecoll_cps popsomecoll
rename popcolgrad_cps popcolgrad
sum poplesshs pophsgrad popsomecoll popcolgrad 


*gen popalleduc = pop2044
gen popalleduc = poplesshs + pophsgrad + popsomecoll + popcolgrad

********* EDUCATION IMPUTATION *********

*Collapse by population
collapse (sum) poplesshs pophsgrad popsomecol popcolgrad popalleduc, by(year)

*merge in births data
merge 1:1 year using `temp1'
keep if _merge==3
drop _merge
	 
	*Reallocate births with missing educ according to nonmissing national distribution
	foreach var in lesshs hsgrad somecoll colgrad {
	gen pct_`var' = (numbirth_`var'/numbirthalleduc)
	gen pct_nonmissing_`var' = (numbirth_`var'/numbirth_witheduc)
	gen numbirth`var' = numbirthalleduc*pct_nonmissing_`var' 
	}
	*rename popsomecol popsomecoll
	drop numbirth_* numbirthalleduc pct* popalleduc
	
	foreach var in lesshs hsgrad somecoll colgrad {
	gen brate_`var' = numbirth`var'/pop`var'*1000
	}
	
	keep year brate_*

twoway line brate_lesshs brate_hsgrad brate_somecoll brate_colgrad year

graph export $ft_output_dir/fig_2d.png, replace

export delimited $ft_output_dir/fig_2d.csv, replace 
	
cap log close
