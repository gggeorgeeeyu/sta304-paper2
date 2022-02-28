*Calculate age distribution of female population, by race/ethnicity
*Source: NIH SEER Population Data
*https://www.nber.org/research/data/survey-epidemiology-and-end-results-seer-us-state-and-county-population-data-age-race-sex-hispanic, accessed 2/22/2021

cap log close
log using $ft_output_dir\logs\agecomp-seer.log, replace

*Population data for 1990 - 2019
infix int year 1-4 str stname 5-6 int stfips 7-8 ///
int countyfips 9-11 int registry 12-13 int race 14 int hispanic 15 ///
int sex 16 int age 17-18 pop 19-26 using $ft_data_dir\pop\us.1990_2019.singleages.txt, clear

drop if sex == 1  // keep only females
drop if stname == "KR" // Special Cells for Hurricane Katrina Evacuees
drop if age<15 | age>44
drop if year<1980

forvalues i = 15(1)44{
gen pop`i' = pop if age == `i'
}

gen pop1519 = pop if age>=15 & age<=19
gen pop2024 = pop if age>=20 & age<=24 
gen pop2534 = pop if age>=25 & age<=34
gen pop2034 = pop if age>=20 & age<=34 
gen pop3544 = pop if age>=35 & age<=44
gen pop45plus = pop if age>44

gen popwhitenh1519 = pop if age>=15 & age<=19 & race==1 & hispanic==0
gen popwhitenh2024 = pop if age>=20 & age<=24 & race==1 & hispanic==0
gen popwhitenh2534 = pop if age>=25 & age<=34 & race==1 & hispanic==0
gen popwhitenh2034 = pop if age>=20 & age<=34 & race==1 & hispanic==0 
gen popwhitenh3544 = pop if age>=35 & age<=44 & race==1 & hispanic==0
gen popwhitenh45plus = pop if age>=35 & age<=44 & race==1 & hispanic==0

gen popblacknh1519 = pop if age>=15 & age<=19 & race==2 & hispanic==0
gen popblacknh2024 = pop if age>=20 & age<=24 & race==2 & hispanic==0
gen popblacknh2534 = pop if age>=25 & age<=34 & race==2 & hispanic==0
gen popblacknh2034 = pop if age>=20 & age<=34 & race==2 & hispanic==0
gen popblacknh3544 = pop if age>=35 & age<=44 & race==2 & hispanic==0
gen popblacknh45plus = pop if age>44 & race==1 & hispanic==0

gen pophispanic1519 = pop if age>=15 & age<=19 & hispanic==1
gen pophispanic2024 = pop if age>=20 & age<=24 & hispanic==1
gen pophispanic2534 = pop if age>=25 & age<=34 & hispanic==1
gen pophispanic2034 = pop if age>=20 & age<=34 & hispanic==1
gen pophispanic3544 = pop if age>=35 & age<=44 & hispanic==1
gen pophispanic45plus = pop if age>44 & race==1 & hispanic==0

gen popotherrace1519 = pop if age>=15 & age<=19 & race>2 & hispanic==0
gen popotherrace2024 = pop if age>=20 & age<=24 & race>2 & hispanic==0
gen popotherrace2534 = pop if age>=25 & age<=34 & race>2 & hispanic==0
gen popotherrace2034 = pop if age>=20 & age<=34 & race>2 & hispanic==0
gen popotherrace3544 = pop if age>=35 & age<=44 & race>2 & hispanic==0
gen popotherrace45plus = pop if age>44 & race==1 & hispanic==0

sort stname year
collapse (sum) pop*, by(stname year)

forvalues i = 15(1)19{
gen pctpop`i' = (pop`i'/pop1519)
}
forvalues i = 20(1)34{
gen pctpop`i' = (pop`i'/pop2034)
}
forvalues i = 35(1)44{
gen pctpop`i' = (pop`i'/pop3544)
}

*save `temp1', replace 

gen pctpop1819 = pctpop18 + pctpop19

gen pop2045plus = pop2034 + pop3544 + pop45plus

*race agg data
gen popwhite1544 = popwhitenh1519 + popwhitenh2034 ///
					+ popwhitenh3544
gen popblack1544 = popblacknh1519 + popblacknh2034 ///
					+ popblacknh3544
gen pophispanic1544 = pophispanic1519 + pophispanic2034 ///
					+ pophispanic3544
					
save $ft_data_dir\pop\age_race_comp_seer.dta, replace

cap log close
