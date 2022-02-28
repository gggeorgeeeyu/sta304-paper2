*OBTAIN COEFFICIENTS FOR ECONOMIC/POLICY REGRESSIONS 
*AND CALCULATE PERCENT OF DECLINE IN BIRTH RATE EXPLAINED BY EACH VARIABLE
*CITED IN SECTION III.B


cap log close _all
log using $ft_output_dir\logs\section3_b_regressions.log, replace 


*1. Birth Data: NCHS Microdata
use $ft_data_dir\nchs\nchs_births_pop_1990_2019, clear
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
keep stname year numbirth1544

sort stname year 
statastates, a(stname)
gen stfips = state_fips
order state_fips stname year numbirth1544
drop _merge

drop if state_fips==.
xtset state_fips year


cap drop _merge
merge 1:1 stname year using $ft_data_dir\annual_policy\policyvars01_19
assert _merge == 3 if year>=2001
keep if _merge==3
drop _merge 


******** MERGE ST-YEAR POPULATIONS, overall and by race & education ********
merge 1:1 stname year using $ft_data_dir\pop\age_race_comp_seer.dta , keepusing(pop1519 pop2034 pop3544)
drop _merge
gen pop1544 = pop1519 + pop2034 + pop3544
drop pop1519 pop2034 pop3544

*cap drop state
*egen state = max(stfips), by(stname)

tab year, gen(yrdv)
tab stname, gen(stdv)

format stname %2s

gen trend = year - 1979
gen trendsq = trend^2
gen trendqb = trend^3
	 
gen trend00 = year - 2000
gen trend00sq = trend^2
gen trend00qb = trend^3

*****ADD STATE SPECIFIC QUADRATIC TRENDS******;
local stnum 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51

foreach num in `stnum' {
     gen sttrend`num' = trend*stdv`num'
	 }
	 
foreach num in `stnum' {
     gen sttrendsq`num' = trendsq*stdv`num'
	 }
 
foreach num in `stnum' {
     gen sttrendqb`num' = trendqb*stdv`num'
	 }

foreach num in `stnum' {
     gen sttrend00`num' = trend00*stdv`num'
	 }

foreach num in `stnum' {
     gen sttrendsq00`num' = trend00sq*stdv`num'
	 }
 
foreach num in `stnum' {
     gen sttrendqb00`num' = trend00qb*stdv`num'
	 }

*clear;
*gen waivpov19 = waivnoteens2
*gen pctpop1819_old = pctpop18_old + pctpop19_old


*** LEVEL BIRTH RATE
gen brate1544_thsnds = numbirth1544/pop1544*1000
*** LOG BIRTH RATE
gen brate1544 = ln(numbirth1544/pop1544)

**** REGRESSIONS
sort state_fips year
	
*PREFERRED SPECIFICATION
*LEVELS: All + BY AGE, 2001-2019
local rhsvars unemp logben3 contmand ///
 parental delay pctmarried pctwhitenh pcthisp pcthsdrop pcthsgrad pctsomecol ///
 sexed sexedcont sexed1mis sexed2mis tadexpmil logrstateminwage aca_mcaid_exp

	 eststo reg1544_levels: qui areg brate1544_thsnds `rhsvars' yrdv* sttrend00* sttrendsq00* ///
     sttrendqb2-sttrendqb51 if year>=2001 [weight=pop1544], absorb(stname) robust cluster(stname)

local tablevars unemp logben3 contmand ///
 parental delay sexed sexedcont ///
 tadexpmil logrstateminwage aca_mcaid_exp  
 
local regs reg1544_levels

esttab `regs', label replace  ///
	keep(`tablevars') order(`tablevars') b(%9.5f) se(%9.3f) ar2(%9.2f) ///
	varwidth(25) wrap mtitles("All") ///
	star(* 0.10 ** 0.05 *** 0.01) title(Level of Birth Rates, Women 15-44, 2001-2019\label{tab2}) 

	
	
*******************************************
******* FOR BETAS*(Change in X) ***********
*******************************************

*sum x-variables in 2007 & 2019
local sumvars unemp logben3 contmand parental delay ///
sexed sexedcont tadexpmil logrstateminwage aca_mcaid_exp

sum `sumvars' if year==2007
sum `sumvars' if year==2019
 
keep if year == 2007 | year==2019
collapse (mean) meanunemp=unemp meanlogben3=logben3 meancontmand=contmand ///
 meanparental=parental	meandelay=delay meansexed=sexed ///
 meansexedcont=sexedcont meantadexpmil=tadexpmil meanlogrstateminwage=logrstateminwage ///
 meanaca_mcaid_exp=aca_mcaid_exp, by(year)
 

reshape long mean, i(year) j(var) string
reshape wide mean, i(var) j(year)

gen diff_07_19 = mean2019 - mean2007
gen coeff = .
foreach coeff in unemp logben3 contmand parental delay ///
sexed sexedcont tadexpmil logrstateminwage aca_mcaid_exp {
replace coeff = _b[`coeff'] if var == "`coeff'"
}

gen predicted_ch = diff_07_19*coeff

***** USING 2007 & 2019 BIRTH RATES FROM CDC (in Fig 1)
***** 2007 = 69.1
***** 2019 = 58.3
gen pct_of_decline = predicted_ch/(58.3-69.1)*100


*For Sec 3.B: What Percent of Total Decline is Explained by these Factors?
egen total_pct_decline_explained = total(pct_of_decline)
qui sum total_pct_decline
di r(mean)
 
cap log close
	

