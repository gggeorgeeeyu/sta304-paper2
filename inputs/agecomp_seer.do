*Calculate age distribution of female population, 1960-2019
*Used for birth cohort analysis

*Source: NIH SEER Population Data,
*https://seer.cancer.gov/popdata/download.html, accessed 8/31/2021
 
cap log close
log using $ft_output_dir\logs\agecomp-seer.log, replace

*Population data for 1969 - 2019
infix int year 1-4 str stname 5-6 int stfips 7-8 ///
int countyfips 9-11 int registry 12-13 int race 14 int origin 15 ///
int sex 16 int age 17-18 population 19-26 using $ft_data_dir\pop\us.1969_2019.singleages.txt, clear
drop if sex == 1  // keep only females
drop if stname == "KR" // Special Cells for Hurricane Katrina Evacuees
drop if age<15 | age>44
drop if year<1980 
save "temp1", replace

forvalues i = 15(1)44{
gen fem`i' = population if age == `i'
}

gen fem1519 = population if age>=15 & age<=19
gen fem2034 = population if age>=20 & age<=34
gen fem3544 = population if age>=35 & age<=44

sort stname year
collapse (sum) fem*, by(stname year)

forvalues i = 15(1)19{
gen pctpop`i' = (fem`i'/fem1519)
}
forvalues i = 20(1)34{
gen pctpop`i' = (fem`i'/fem2034)
}
forvalues i = 35(1)44{
gen pctpop`i' = (fem`i'/fem3544)
}

gen pctpop1819 = pctpop18 + pctpop19

save $ft_data_dir\pop\agecomp-seer.dta, replace

cap log close
