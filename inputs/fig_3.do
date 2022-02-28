*Create Figure 3, Change in Birth Rates by State, 2004-2008-2015-2018

cap log close 
log using $ft_output_dir\logs\fig_3.log, replace

tempfile temp1
tempfile temp2
tempfile temp3
tempfile temp4


*Birth Data: NCHS Microdata
use $ft_data_dir\nchs\nchs_births_pop_1990_2019, clear
keep if (year>=2004 & year<=2008) | (year>=2015 & year<=2019) & year!=.
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
collapse (sum) numbirth1544, by(stname year)
export delimited $ft_data_dir\map\state_births_04_19, replace

save `temp1', replace 

*Pop Data: CDC SEER
use $ft_data_dir\pop\age_race_comp_seer.dta, clear
gen pop1544 = pop1519 + pop2034 + pop3544
keep if (year>=2004 & year<=2008) | (year>=2015 & year<=2019) & year!=.
collapse (sum) pop1544, by(stname year)

*Merge Births and Pop Data, Collapse by 2004-2008 & 2015-2019
merge 1:1 stname year using `temp1'

gen year2 = 2004 if (year>=2004 & year<=2008) 
replace year2 = 2019 if (year>=2015 & year<=2019) 

*collapse by state, year2
collapse (sum) numbirth1544 (sum) pop1544, by(stname year2)

rename year2 year
*rename numbirth_* numbirth*

***** MAP DELCINES BY STATE
gen brate1544_thsnds = numbirth1544/pop1544*1000
bys stname: gen brate1544_thsnds_2015_19 = brate1544_thsnds[_N]
gen brate1544_thsnds_ch = (brate1544_thsnds_2015_19 - brate1544_thsnds) if year==2004
gen brate1544_thsnds_ch_pct = 100*(brate1544_thsnds_2015_19 - brate1544_thsnds)/brate1544_thsnds if year==2004
gen state=stname

maptile brate1544_thsnds_ch if year==2004, geo(state) revcolor cutvalues(-10 -5 0)  ///
  twopt(title("Change in Average Birth Rates by State, 2004-2008 to 2015-2019") ///
 legend(title("Change in Birth Rate", size(small)) ///
 label(5 "0 - 8") label(4 "-5 - 0") label(3 "-10 - -5") ///
 label(2 "-22 - -10")) /// label(2 "-22 - -12")) ///
 note("Notes: Birth Rates are calculated among women aged 15-44." ///
 "Source: Birth data from NCHS Vital Statistics. Population Data from CDC SEER"))
graph export $ft_output_dir/fig_3.png, replace

export delimited stname brate1544_thsnds_ch_pct if year==2004 using $ft_output_dir/fig_3.csv, replace

cap log close

