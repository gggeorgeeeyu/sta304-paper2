
* Decomposition Presented in Table 1 
* Decompose change in birth rate across 63 age-educ-raceeth groups 
*(3 for 15-19 by raceeth, + 60 for 20-44 by age-educ-raceeth)

cap log close
log using $ft_output_dir\logs\table1.log, replace 

tempfile temp1
tempfile temp2
tempfile temp3
tempfile temp4

import delimited $ft_data_dir\decomp\births_educ_race_age6.csv, clear
save `temp1', replace

******** Population: CPS ********

*creates file used below: age x educ x race/eth population
qui do $ft_programs_dir\table_1_population

use $ft_data_dir\decomp\state_year_age6grp_educ_raceeth_pop1544_aggteens
egen popalleduc = rowtotal(pop_*)
	collapse (sum) pop_all*1519 pop_lesshs* pop_hsgrad* pop_somecol* ///
	pop_colgrad* popalleduc, by(year) 
merge 1:1 year using `temp1'
assert _merge==3
drop _merge	 

*Get the overall Birth Rate (EP) change - 
	*need this for calculating D s_i x (E/P)_i
	preserve 
	collapse (sum) numbirthalleduc popalleduc, by(year)
 
	reshape long numbirth pop, i(year) j(edgrp) string
	
	gen brate = numbirth/pop
	keep year edgrp brate
	
	reshape wide brate, i(edgrp) j(year)
	local brate_all = brate2001[1]
	
	local brate_all_01 = brate2001[1]
	local brate_all_07 = brate2007[1]
	local brate_all_19 = brate2019[1]
	
	di brate2001*1000
	di brate2007*1000
	di brate2019*1000
	
	restore
 
	*1. Reallocate missing educ #'s FOR 20-44 Y.O's according to nonmissing distribution
	foreach raceeth in blacknh whitenh hisp {	
	foreach age in 2024 2529 3034 3539 4044 {
	foreach var in lesshs hsgrad somecoll colgrad {
	gen pct_`var'_`raceeth'_`age' = (numbirth_`var'_`raceeth'_`age'/numbirthalleduc_2044)
	gen pct_nm_`var'_`raceeth'_`age' = (numbirth_`var'_`raceeth'_`age'/numbirth_witheduc_2044)
	gen numbirth_`var'`raceeth'`age' = numbirthalleduc_2044*pct_nm_`var'_`raceeth'_`age' 
	}
	}
	}
	
	*so we have numbirth_all_1519_whitenh pop_allwhitenh1519
	rename numbirth_all_1519_whitenh numbirth_alleducwhitenh1519
	rename numbirth_all_1519_blacknh numbirth_alleducblacknh1519
	rename numbirth_all_1519_hisp numbirth_alleduchisp1519
	rename pop_allwhitenh1519 pop_alleducwhitenh1519
	rename pop_allblacknh1519 pop_alleducblacknh1519
	rename pop_allhisp1519 pop_alleduchisp1519
	
	drop numbirth_lesshs_* numbirth_hsgrad_* numbirth_somecoll_* numbirth_colgrad_* numbirth_witheduc
	 
	rename pop_* pop*
	rename numbirth_* numbirth*
	
	drop numbirthalleduc numbirthalleduc_2044 pct* popalleduc
	
	reshape long numbirth pop, i(year) j(age_raceeth_edgrp) string

	
*Now, calculate each of the three decomposed terms for each detailed age bin
	*Generate share s_i
	bysort year: egen totalpop = sum(pop)
	gen si = pop/totalpop
	
	*Generate brate
	gen brate = numbirth/pop
	
	replace brate = 0 if numbirth==0 | pop==0
	assert brate!=.
	
	*Reshape to facilitate calculation for each year
	keep year age_raceeth_edgrp brate si
	reshape wide brate si, i(age_raceeth_edgrp) j(year)
	
	*Calculate input variables
	gen bratediff_0107 = brate2007-brate2001
	gen sidiff_0107 = si2007-si2001
	gen brateall_01 = `brate_all_01'
	gen term1_0107 = si2001*bratediff_0107
	gen term2_0107 = sidiff_0107*(brate2001-`brate_all_01')
	gen term3_0107 = sidiff_0107*bratediff_0107

	*Calculate input variables: 07-19
	gen bratediff_0719 = brate2019-brate2007
	gen sidiff_0719 = si2019-si2007
	gen brateall_07 = `brate_all_19'
	gen term1_0719 = si2007*bratediff_0719
	gen term2_0719 = sidiff_0719*(brate2007-`brate_all_07')
	gen term3_0719 = sidiff_0719*bratediff_0719
	
	*Calculate input variables: 01-18
	gen bratediff_0119 = brate2019-brate2001
	gen sidiff_0119 = si2019-si2001
	  *gen brateall_01 = `brate_all_01'
	gen term1_0119 = si2001*bratediff_0119
	gen term2_0119 = sidiff_0119*(brate2001-`brate_all_01')
	gen term3_0119 = sidiff_0119*bratediff_0119
	
	label define order  1 alleducwhitenh1519  ///
	2 lesshswhitenh2024 3 lesshswhitenh2529 4 lesshswhitenh3034 5 lesshswhitenh3539 6 lesshswhitenh4044 ///
	7 hsgradwhitenh2024 8 hsgradwhitenh2529 9 hsgradwhitenh3034 10 hsgradwhitenh3539 11 hsgradwhitenh4044 ///
	12 somecollwhitenh2024 13 somecollwhitenh2529 14 somecollwhitenh3034 15 somecollwhitenh3539 16 somecollwhitenh4044 ///
	17 colgradwhitenh2024 8 colgradwhitenh2529 19 colgradwhitenh3034 20 colgradwhitenh3539 21 colgradwhitenh4044 ///
	22 alleducblacknh1519  ///
	23 lesshsblacknh2024 24 lesshsblacknh2529 25 lesshsblacknh3034 26 lesshsblacknh3539 27 lesshsblacknh4044 ///
	28 hsgradblacknh2024 29 hsgradblacknh2529 30 hsgradblacknh3034 31 hsgradblacknh3539 32 hsgradblacknh4044 ///
	33 somecollblacknh2024 34 somecollblacknh2529 35 somecollblacknh3034 36 somecollblacknh3539 37 somecollblacknh4044 ///
	38 colgradblacknh2024 39 colgradblacknh2529 40 colgradblacknh3034 41 colgradblacknh3539 42 colgradblacknh4044 ///
	43 alleduchisp1519  ///
	44 lesshshisp2024 45 lesshshisp2529 46 lesshshisp3034 47 lesshshisp3539 48 lesshshisp4044 ///
	49 hsgradhisp2024 50 hsgradhisp2529 51 hsgradhisp3034 52 hsgradhisp3539 53 hsgradhisp4044 ///
	54 somecollhisp2024 55 somecollhisp2529 56 somecollhisp3034 57 somecollhisp3539 58 somecollhisp4044 ///
	59 colgradhisp2024 60 colgradhisp2529 61 colgradhisp3034 62 colgradhisp3539 63 colgradhisp4044 
	encode age_raceeth_edgrp, gen(age_raceeth_edgrp2) label(order)
	sort age_raceeth_edgrp2
	
	replace brate2001=brate2001*1000
	replace brate2007=brate2007*1000
	replace brate2019=brate2019*1000
	
	order age_raceeth_edgrp brate2001 brate2007 brate2019 si2001 si2007 si2019
	save `temp2', replace
	
	*Collapse again by decomposition age bins
	collapse (sum) term1* (sum) term2* (sum) term3*, by(age_raceeth_edgrp)
	
	replace term1_0107 = term1_0107*1000
	replace term2_0107 = term2_0107*1000
	replace term3_0107 = term3_0107*1000

	replace term1_0719 = term1_0719*1000
	replace term2_0719 = term2_0719*1000
	replace term3_0719 = term3_0719*1000
	
	replace term1_0119 = term1_0119*1000
	replace term2_0119 = term2_0119*1000
	replace term3_0119= term3_0119*1000
	
	label define order2  1 alleducwhitenh1519  ///
	2 lesshswhitenh2024 3 lesshswhitenh2529 4 lesshswhitenh3034 5 lesshswhitenh3539 6 lesshswhitenh4044 ///
	7 hsgradwhitenh2024 8 hsgradwhitenh2529 9 hsgradwhitenh3034 10 hsgradwhitenh3539 11 hsgradwhitenh4044 ///
	12 somecollwhitenh2024 13 somecollwhitenh2529 14 somecollwhitenh3034 15 somecollwhitenh3539 16 somecollwhitenh4044 ///
	17 colgradwhitenh2024 8 colgradwhitenh2529 19 colgradwhitenh3034 20 colgradwhitenh3539 21 colgradwhitenh4044 ///
	22 alleducblacknh1519  ///
	23 lesshsblacknh2024 24 lesshsblacknh2529 25 lesshsblacknh3034 26 lesshsblacknh3539 27 lesshsblacknh4044 ///
	28 hsgradblacknh2024 29 hsgradblacknh2529 30 hsgradblacknh3034 31 hsgradblacknh3539 32 hsgradblacknh4044 ///
	33 somecollblacknh2024 34 somecollblacknh2529 35 somecollblacknh3034 36 somecollblacknh3539 37 somecollblacknh4044 ///
	38 colgradblacknh2024 39 colgradblacknh2529 40 colgradblacknh3034 41 colgradblacknh3539 42 colgradblacknh4044 ///
	43 alleduchisp1519  ///
	44 lesshshisp2024 45 lesshshisp2529 46 lesshshisp3034 47 lesshshisp3539 48 lesshshisp4044 ///
	49 hsgradhisp2024 50 hsgradhisp2529 51 hsgradhisp3034 52 hsgradhisp3539 53 hsgradhisp4044 ///
	54 somecollhisp2024 55 somecollhisp2529 56 somecollhisp3034 57 somecollhisp3539 58 somecollhisp4044 ///
	59 colgradhisp2024 60 colgradhisp2529 61 colgradhisp3034 62 colgradhisp3539 63 colgradhisp4044 
	encode age_raceeth_edgrp, gen(age_raceeth_edgrp2) label(order2)
	sort age_raceeth_edgrp2
	

	keep age_raceeth_edgrp term1_0719 
	
	merge 1:1 age_raceeth_edgrp using `temp2', keepusing(brate2001 brate2007 brate2019 si2001 si2007 si2019)
	drop _merge 
	
	egen total_term1=total(term1_0719)
	gen share_term1 = term1_0719/total_term1*100
		gen share_neg_term1 = -term1_0719/total_term1*100
		sort share_neg_term1
		drop share_neg_term1
		
	*Keep top 8 groups (in percent of total constant-share change) for Table 1
	keep if [_n]<=8

	set obs 9
	replace age_raceeth_edgrp = "total" if age_raceeth_edgrp==""
	
	foreach var in share_term1 si2007{
	egen total_`var'_top8 = total(`var')
	replace `var' = total_`var'_top8 if age_raceeth_edgrp=="total"
	}
	
	*avg birth rates among top 8 groups
	sum brate2007 [aw= si2007]
	local mean07 = r(mean)
	replace brate2007 = `mean07' if age_raceeth_edgrp=="total"

	sum brate2019 [aw= si2019]
	local mean19 = r(mean)
	replace brate2019 = `mean19' if age_raceeth_edgrp=="total"

	gen brate_diff_0719 = brate2019 - brate2007

	keep age_raceeth_edgrp share_term1 si2007 brate2007 brate2019 brate_diff_0719
	order age_raceeth_edgrp share_term1 si2007 brate2007 brate2019 brate_diff_0719

	export delimited $ft_output_dir\table_1.csv, replace
