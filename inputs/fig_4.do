*GENERATE DATA FOR SCATTERPLOTS (FIGURE 4)
*AND CALCULATE LONG-TERM CHANGES in ECONOMIC/SOCIAL VARIABLES 
*Average changes cited in section III.C at the end of log file

cap log close _all
log using $ft_output_dir\logs\section3_c_regressions.log, replace 

tempfile temp1

*1. Birth Data: NCHS Microdata
use $ft_data_dir\nchs\nchs_births_pop_1990_2019, clear
keep if (year>=2004 & year<=2008) | (year>=2015 & year<=2019) & year!=.
drop if inlist(stname,"AB","BC","MB","NB","NS","ON","QC","SK","XX")
keep stname year numbirth1544
save `temp1', replace 

*2. Pop Data: CDC SEER
use $ft_data_dir\pop\age_race_comp_seer.dta
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
gen brate1544_thsnds = numbirth1544/pop1544*1000

save $ft_data_dir\long_term\long_birth_rates, replace

*3. MERGE IN ECONOMIC VARIABLES - from 2004-2008 & 2015-2019 ACS 
use $ft_data_dir\long_term\longdiff-RHS-1519, clear
append using $ft_data_dir\long_term\longdiff-RHS-0408
merge 1:1 statefip year using $ft_data_dir\long_term\longdiff-rentcost-0419
	drop _merge
	drop if statefip>56 // get rid of territories
	statastates, f(statefip) // NO HAWAII
	keep if _merge==3
	rename state_abbrev stname
	drop state_name _merge statefip 
	order year stname 
	sort stname year
merge 1:1 stname year using $ft_data_dir\long_term\long_birth_rates
drop _merge 

*4. MERGE IN BIRTH CONTROL USAGE - BRFSS
merge 1:1 stname year using $ft_data_dir\long_term\bcusage_st0417_wide
drop if _merge == 2 // drop Puerto Rico
drop _merge 

*5. MERGE IN MEAN CHILDCARE COSTS IN CEX
merge 1:1 stname year using $ft_data_dir\long_term\child_care_costs_under12_0408_1519
drop _merge

*6. MERGE IN CHILDCARE COSTS IN ASEC
merge 1:1 stname year using $ft_data_dir\long_term\childcare_asec_09_1519
drop _merge

*7. MERGE IN STUDENT LOAN DEBT - nyfed 
merge 1:1 stname year using $ft_data_dir\long_term\nyfed-student-debt-per-capita-0419
drop _merge 

*8. MERGE IN RELIGIOUSITY - pew 
merge 1:1 stname year using $ft_data_dir\long_term\long-diff-religion
drop _merge 


** Variable Cleaning **
replace urate_all = urate_all*100
replace epop_all = epop_all*100
replace larcall = larcall*100
replace avg_grossrent = avg_grossrent/1000
replace avg_grossrent_hisp = avg_grossrent_hisp/1000
replace coll_c3 = coll_c3/1000
replace child2 = child2/1000

 *Make Median & 75th-percentile Wage Ratio
 gen p50wage_all_ratio = p50wage_all/p50wage_male_all*100
 cap rename p75wage p75wage_all
 cap rename p75wage_male p75wage_male_all
 gen p75wage_all_ratio = p75wage_all/p75wage_male_all*100

label var larcall "LARC Usage (\%)"
label var epop_all "Female, Prime-Age EPOP (\%)"
label var avg_grossrent "Average Gross Rent, 2-3 BR (Thsnds)"
label var cost_burd "Share Housing Cost Burdened HH's"
label var coll_c3 "Mean Child Care Costs (Thsnds)"
label var child2 "Mean Child Care Costs, >0 (Thsnds)"
label var hwsei_all "Occupational Prestige Index, Women 25-44"
label var child_asec "Mean Child Care Costs, ASEC (Thsnds)"
label var very_somewhat_important "Religion is ``Somewhat or Very Important''"
label var p50wage_all_ratio "Female-Male Median Wage Ratio (\%)"
label var p75wage_all_ratio "Female-Male 75th-Percentile Wage Ratio (\%)"

*Make State Dummies
qui tab stname, gen(stdv)

*Create First-Differences for Scatterplots
sort stname year 
foreach var in brate1544 brate1544_thsnds larcall epop_all hwsei_all avg_grossrent /// 
 child2 child_asec stud_loan_cap very_somewhat_important p50wage_all_ratio p75wage_all_ratio {
bys stname: gen fd_`var' = `var'-`var'[_n-1]
}


********************* REGRESSIONS: LOGS *************************

*** INDIVIDUALLY
*unweighted 
foreach var in larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child2 child_asec p50wage_all_ratio p75wage_all_ratio {
areg brate1544 `var' i.year, r absorb(stname)
}

*weighted
foreach var in larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child2 child_asec p50wage_all_ratio p75wage_all_ratio ///
 med_child_asec child_asec {
areg brate1544 `var' i.year [pw=pop1544], r absorb(stname)
}

*** TOGETHER
*unweighted
local xvar larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child_asec p50wage_all_ratio p75wage_all_ratio 
areg brate1544 `xvar' i.year, r absorb(stname)

*weighted
local xvar larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child_asec p50wage_all_ratio p75wage_all_ratio 
areg brate1544 `xvar' i.year  [pw=pop1544], r absorb(stname)


********************* REGRESSIONS: LEVELS *************************

*** INDIVIDUALLY
*unweighted 
foreach var in larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child2 child_asec p50wage_all_ratio p75wage_all_ratio {
areg brate1544_thsnds `var' i.year, r absorb(stname)
}

*weighted with 2014 & 2019 weights
foreach var in larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child2 child_asec p50wage_all_ratio p75wage_all_ratio {
areg brate1544_thsnds `var' i.year [pw=pop1544], r absorb(stname)
}

	******** WEIGHTED REGS WILL MATCH SCATTER PLOT (First Diff) Regressions ******
	sort stname year
	bys stname: gen pop1544_2019 = pop1544[_N]
	*unweighted vs. weighted 2019 weights
	foreach var in larcall epop_all avg_grossrent very_somewhat_important ///
	hwsei_all stud_loan_cap child2 child_asec p50wage_all_ratio p75wage_all_ratio {
		areg brate1544_thsnds `var' i.year, r absorb(stname)
		areg brate1544_thsnds `var' i.year [pw=pop1544_2019], r absorb(stname)
		}
	

*** TOGETHER
*unweighted
local xvar larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child_asec p50wage_all_ratio p75wage_all_ratio 
areg brate1544_thsnds `xvar' i.year, r absorb(stname)

*weighted
local xvar larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child_asec p50wage_all_ratio p75wage_all_ratio 
areg brate1544_thsnds `xvar' i.year  [pw=pop1544], r absorb(stname)



********************* EXPORT SCATTERPLOT DATA *************************
preserve 

keep year stname fd_* pop1544 // pct*
keep if year==2019
drop fd_brate1544 fd_hwsei_all 

*(rename some variables to make them more self-explanatory)
rename fd_stud_loan_cap fd_stud_debt_cap
rename fd_child2 fd_avg_childcare_exp_cex
order stname fd_brate
drop year
export delimited $ft_output_dir/long_term_scatterplot_variables_2019.csv, replace 

*unweighted scatterplot
foreach var in larcall epop_all avg_grossrent child_asec stud_debt_cap ///
 very_somewhat_important p50wage_all_ratio {
scatter fd_brate1544_thsnds fd_`var', mlabel(stname) || || lfit  fd_brate1544_thsnds fd_`var'
graph export $ft_output_dir/fig_8_`var'.png, replace
}

*weighted regressions in first-difference specification (Identical to reg with state/year F.E above)
foreach var in fd_larcall fd_epop_all fd_avg_grossrent fd_avg_childcare_exp fd_child_asec fd_stud_debt_cap ///
 fd_very_somewhat_important fd_p50wage_all_ratio fd_p75wage_all_ratio {
reg fd_brate1544_thsnds `var' [pw=pop1544], r
}

*weighted correlations 
foreach var in fd_larcall fd_avg_grossrent fd_very_somewhat_important fd_stud_debt_cap fd_child_asec fd_avg_childcare_exp_cex ///
  fd_p50wage_all_ratio {
pwcorr fd_brate1544_thsnds `var' [aw=pop1544], star(0.05)
}

restore

*weighted regression toghether, only including variables in scatterplot
local xvar_scatter larcall avg_grossrent very_somewhat_important stud_loan_cap child_asec ///
  p50wage_all_ratio
areg brate1544_thsnds `xvar_scatter' i.year  [pw=pop1544], r absorb(stname)


****************** ESTIMATE PERCENT OF DECLINE EXPLAINED ********************* 
******************  GIVEN BETAS & CHANGE IN X-VARIABLE *********************

*CHANGES IN X-VARIABLES BETWEEN EARLY AND LATER PERIODS
local xvar larcall epop_all avg_grossrent very_somewhat_important ///
 hwsei_all stud_loan_cap child_asec p50wage_all_ratio p75wage_all_ratio 
foreach var in `xvar' {
sum `var' if year==2004 [aw=pop1544]
sum `var' if year==2019 [aw=pop1544]
} 

log close



