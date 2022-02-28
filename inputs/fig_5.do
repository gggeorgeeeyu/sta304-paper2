*Figure 5: Children Ever Born by Mother’s Age, by Mother’s Birth Cohort

cap log close
log using $ft_output_dir\logs\fig_5.log, replace 

*Format SEER data for this use
use $ft_data_dir\pop\agecomp-seer.dta, clear
keep stname year fem1* fem2* fem3* fem4*
drop fem1519 fem2034 fem3544
collapse (sum) fem*, by (year)
reshape long fem, i(year) j(mage)
rename fem pop

gen cohort = year-mage
gen cohort2 = .

replace cohort2 = 1 if cohort >= 1968 & cohort <=1972
replace cohort2 = 2 if cohort >= 1973 & cohort <=1977
replace cohort2 = 3 if cohort >= 1978 & cohort <=1982
replace cohort2 = 4 if cohort >= 1983 & cohort <=1987
replace cohort2 = 5 if cohort >= 1988 & cohort <=1992
replace cohort2 = 6 if cohort >= 1993 & cohort <=1997
drop if cohort2==.

collapse (sum) pop, by (cohort2 mage)

save $ft_data_dir\pop\age_cohort_long_seer, replace


*Start with NCHS Cohort Data, merge in SEER population data
use $ft_data_dir\nchs\nchs_cohort_analysis, clear
merge 1:1 cohort2 mage using $ft_data_dir\pop\age_cohort_long_seer.dta
drop _merge 

gen brate = numbirth/pop*1000

sort cohort2 mage
by cohort2: gen cum_brate = sum(brate)/1000
label var brate "Births per Female"
label var cum_brate "Cumulative Births per Female"
label var mage "Mother's Age"

keep mage cohort2 brate cum_brate

gen years_born = ""
replace years_born = "1968-72" if cohort==1
replace years_born = "1973-77" if cohort==2
replace years_born = "1978-82" if cohort==3
replace years_born = "1983-87" if cohort==4
replace years_born = "1988-92" if cohort==5
replace years_born = "1993-97" if cohort==6

gen years_2025 = ""
replace years_2025 = "1988-92" if cohort==1
replace years_2025 = "1993-97" if cohort==2
replace years_2025 = "1998-02" if cohort==3
replace years_2025 = "2003-07" if cohort==4
replace years_2025 = "2008-12" if cohort==5
replace years_2025 = "2013-17" if cohort==6

keep mage cohort2 brate cum_brate
reshape wide brate cum_brate, i(mage) j(cohort2)

*CDF - cumulative births
twoway line cum_brate1 cum_brate2 cum_brate3 cum_brate4 cum_brate5 mage, ///
ylabel(,angle(0)) ytitle("Births per Woman") title("Lifetime Fertility, by Mother's Birth Cohort: US") ///
legend(subtitle("Birth Cohort") region(lstyle(none)) label(1 "1968-72") label(2 "1973-77") label(3 "1978-82") ///
 label(4 "1983-87") label(5 "1988-92") label(6 "1993-97")) name(cdf2, replace) 
graph export $ft_data_dir\fig_5.png, replace

export delimited $ft_output_dir\fig_5.csv, replace

log close
