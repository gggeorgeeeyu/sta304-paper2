*6 age groups
*estimate number of women 15-44 within 36 age-educ-raceeth groups (3 for 15-19 by raceeth,
* + 60 for 20-44 by age-educ-raceeth), by state-year


use $ft_data_dir\decomp\cps_19902019, clear

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

drop if raceeth==""

*collapse to number by state-year 
replace edgrp = "all" if agegrp6=="1519"
collapse (sum) pop=asecwt, by(state year agegrp6 edgrp raceeth)

statastates, fips(statefip)
drop _merge state_name statefip
rename state_abbrev stname

*reshape wide 
gen age6_ed_raceeth_grp = edgrp+raceeth+agegrp6
drop agegrp6 edgrp raceeth 
reshape wide pop, i(year stname) j(age6_ed_raceeth_grp) string

recode pop* (. = 0)
egen total = rowtotal(pop*)

foreach raceeth in whitenh blacknh hisp{
foreach age in 2024 2529 3034 3539 4044{
foreach var in lesshs hsgrad somecoll colgrad{
gen pct_`var'`raceeth'`age'  = pop`var'`raceeth'`age'/total
}
}
}


foreach raceeth in whitenh blacknh hisp{
foreach age in 1519 {
gen pct_all`raceeth'`age'  = popall`raceeth'`age'/total
}
}

merge 1:1 stname year using $ft_data_dir\pop\age_race_comp_seer.dta, keepusing(*1544)
tab year if _merge!=3
keep if _merge==3 // all unmerged are in years 1990-1999 and 2020 (not needed)
drop _merge

gen pop1544 = popwhite1544 + popblack1544 + pophispanic1544
keep stname year pct* pop1544

foreach raceeth in whitenh blacknh hisp {
foreach age in 2024 2529 3034 3539 4044{
foreach var in lesshs hsgrad somecoll colgrad{
gen pop_`var'`raceeth'`age'  = pct_`var'`raceeth'`age'*pop1544
}
}
}

foreach raceeth in whitenh blacknh hisp {
foreach age in 1519 {
gen pop_all`raceeth'`age'  = pct_all`raceeth'`age'*pop1544
}
}

keep stname year pop* 
drop if year<=2000 | year>2019
save $ft_data_dir\decomp\state_year_age6grp_educ_raceeth_pop1544_aggteens, replace
