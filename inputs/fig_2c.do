*Create Figure 4, birth rates by Hispanic Sub-Population

cap log close 
log using $ft_output_dir\logs\fig_2c.log, replace

tempfile temp1
tempfile temp2
tempfile temp3
tempfile temp4


******* (1/3) Numerator: Births, Hispanics 15-44 by Native/Foreign x Mexican/Other ********
*From NCHS Natality Microdata
use $ft_data_dir\nchs\nchs_births_pop_1990_2019, clear
keep if year>=1990 & year<=2019 & year!=.
drop if stname== "AB" | stname== "BC" | stname== "MB" | stname == "NB" | stname== "NS" | stname == "ON" | stname == "QC" | stname== "SK" | stname== "XX"	 
cap drop pop2044
drop pop*

collapse (sum) numbirth_hispforb_other numbirth_hispforb_mex numbirth_hispnativeb_nonmex ///
numbirth_hisp_mexican_nativeb , by(year)

save `temp1'

******* (2/3) Denominator: Hispanic Pop 15-44 by Native/Foreign x Mexican/Other ********

*USE CPS 1990-2019 (Hispanic Origin Only Recorded 1994-)
use $ft_data_dir\hisp\cps_19902019, clear

*drop health insurance supplement in 2014
drop if hflag==1

*keep only females
drop if sex==1

*keep 15-44
drop if age<15 | age>44

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

*married/unmarried 
gen married = ""
replace married = "married" if marst==1 | marst==2
replace married = "unmarried" if marst>2
assert married!=""

*raceeth 
gen raceeth = ""
replace raceeth = "whitenh" if race==100 & hisp==0
replace raceeth = "blacknh" if race==200 & hisp==0
replace raceeth = "hisp" if hisp>0
*drop if raceeth==""

*nativity 
gen native = "nativeborn" if nativity>=1 & nativity<=4
replace native = "foreignborn" if nativity==5
replace native = "" if nativity==0

*mexican (not BORN IN Mexico)
gen mexican = "mexican" if hisp>=100 & hisp<=108
replace mexican = "other" if hisp>0 & mexican!="mexican"

*from mexico 
gen mexicob = "mexico" if native == "foreignborn" & bpl==20000
replace mexicob = "other" if native == "foreignborn" & bpl!=20000
assert mexicob == "mexico" | mexicob == "other" if native=="foreignborn"
 
 
preserve 

drop if raceeth!="hisp" | native==""

*collapse to number by state-year 
collapse (sum) pop=asecwt, by(state year native)

statastates, fips(statefip)
drop _merge state_name statefip
rename state_abbrev stname

*reshape wide  
reshape wide pop, i(year stname) j(native) string

recode pop* (. = 0)
egen total = rowtotal(pop*)


foreach var in foreignborn nativeborn {
gen pct_`var'  = pop`var'/total
}


merge 1:1 stname year using $ft_data_dir\pop\age_race_comp_seer.dta , keepusing(pophispanic1544)
tab year if _merge!=3
keep if _merge==3 // all unmerged are in years 1990-1999 and 2020 (not needed)
drop _merge

keep stname year pct* pophispanic1544

foreach var in foreignborn nativeborn {
gen pop_`var'  = pct_`var'*pophispanic1544
}


keep stname year pop* 
drop if year<1990 | year>2019
tab year
save `temp2', replace 

restore
 

preserve

drop if raceeth!="hisp" | native!="foreignborn"

*collapse to number by state-year 
collapse (sum) pop=asecwt, by(state year mexicob) 

statastates, fips(statefip)
drop _merge state_name statefip
rename state_abbrev stname

*reshape wide  
reshape wide pop, i(year stname) j(mexicob) string
recode pop* (. = 0)
egen total = rowtotal(pop*) // this is pop foreignborn


recode pop* (. = 0) // in some years there are no foreign-born hispanics in certain states (VT, WV, MT)
foreach var in mexico other {
gen pct_`var'  = pop`var'/total // these are percents of foreign born, need number foreignborn hisp from previous calculation
}

*want pop non-native to get pop non-native within each group
drop if year<1990 | year>2019
merge 1:1 stname year using `temp2', keepusing(pop_foreignborn)
recode pct* (. = 0) // in some years there are no foreign-born hispanics in certain states (VT, WV, MT)

keep stname year pct* pop_foreignborn

foreach var in mexico other {
gen pop_`var'_hispforb  = pct_`var'*pop_foreignborn
}


keep stname year pop* 
drop if year<1990 | year>2019
save `temp3', replace

restore
 

drop if raceeth!="hisp" | native!="nativeborn"

*collapse to number by state-year 
collapse (sum) pop=asecwt, by(state year mexican)

statastates, fips(statefip)
drop _merge state_name statefip
rename state_abbrev stname

*reshape wide  
reshape wide pop, i(year stname) j(mexican) string

recode pop* (. = 0)
egen total = rowtotal(pop*)


foreach var in mexican other {
gen pct_`var'  = pop`var'/total
}


drop if year<1990 | year>2019
merge 1:1 stname year using `temp2', keepusing(pop_nativeborn)
recode pct* (. = 0) // in some years there are no foreign-born hispanics in certain states (VT, WV, MT)

keep stname year pct* pop_nativeborn

foreach var in mexican other {
gen pop_`var'  = pct_`var'*pop_nativeborn
}


keep stname year pop* 
drop if year<1990 | year>2019
save `temp4', replace

 
 
******* (3/3) MERGE BIRTHS AND POP TOGHETHER TO GET BIRTH RATES *******

*merge in hisp foreign by mexican, other (pop_other_hispforb pop_mexico_hispforb)
use `temp3'

*merge in hisp native by mexican, other (pop_mexican pop_other)
merge 1:1 stname year using `temp4'

collapse (sum) pop_other_hispforb pop_mexico_hispforb pop_mexican pop_other, by(year)

*merge in births data from nchs
merge 1:1 year using `temp1'

	gen brate_hispforb_other = numbirth_hispforb_other/pop_other_hispforb*1000
	gen brate_hispforb_mex = numbirth_hispforb_mex/pop_mexico_hispforb*1000
	gen brate_hispnativeb_nonmex =  numbirth_hispnativeb_nonmex/pop_other*1000
	gen brate_hispnativeb_mex =  numbirth_hisp_mexican_nativeb/pop_mexican*1000
	
	keep year brate*
	
twoway line brate_hispforb_other brate_hispforb_mex brate_hispnativeb_nonmex brate_hispnativeb_mex year

graph export $ft_output_dir\fig_2c.png, replace

export delimited $ft_output_dir/fig_2c.csv, replace 

log close
