*Calculate miscelaneous stats in section 2A
* Share of hispanic women of childbearing age 
* Share of women of childbearing age unmarried 

capture log close
clear

log using $ft_output_dir\logs\sec_2_a_stats.log, replace

*ACS Data on Hispanic Population, by Nativity
use $ft_data_dir\sec_2a\hisp_nativity.dta, clear

keep if age >= 15 & age <= 44
keep if sex == 2
gen native = bpl <= 56
gen married = marst <= 2

gen educcat = 1 if educd <= 61
replace educcat = 2 if educd == 63 | educd == 64
replace educcat = 3 if educd >= 65 & educd <= 100
replace educcat = 4 if educd > 100 & educd <= 116

label define educlbl 1 "hs drop" 2 "hs grad" 3 "some college" 4 "college grad"
label values educcat educlbl

gen hispanic = hispan > 0
gen mexican = hispan == 1



*2007 stats
preserve
keep if year == 2007

*tab hispanic native [weight=perwt]
tab hispanic native [weight=perwt], row nofr

*tab mexican native [weight=perwt]
tab mexican native [weight=perwt], row nofr

tab married [weight=perwt]

tab educcat if age >= 20 [weight=perwt]



*2018 stats
restore
keep if year == 2018
 
*tab hispanic native [weight=perwt]
tab hispanic native [weight=perwt], row nofr

*tab mexican native [weight=perwt]
tab mexican native [weight=perwt], row nofr

tab married [weight=perwt]

tab educcat if age >= 20 [weight=perwt]

log close
