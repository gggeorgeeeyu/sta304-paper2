*Figure 2f, Birth Rates by Parity

cap log close 
log using $ft_output_dir\logs\fig_2f.log, replace

*From NCHS Natality Microdata, Merge in SEER Composition Data
use $ft_data_dir\nchs\nchs_births_pop_1990_2019, clear
cap drop _merge
merge 1:1 stname year using $ft_data_dir\pop\age_race_comp_seer.dta

*aggregate to national/year
gen pop2044 = pop2024 + pop2534 + pop3544
collapse (sum) numbirth_first* numbirth_second* numbirth_third* numbirth_fourth* ///
pop1544 pop2044, by(year)

foreach var in firstbirth secondbirth thirdbirth fourthbirth {
gen brate_`var' = numbirth_`var'/pop1544*1000
}


rename brate_fourthbirth brate_fourthplusbirth

label var brate_firstbirth "Parity 1 Birth Rate"
label var brate_secondbirth "Parity 2 Birth Rate"
label var brate_thirdbirth "Parity 3 Birth Rate"
label var brate_fourthplusbirth "Parity 4+ Birth Rate"

twoway line brate_firstbirth brate_secondbirth brate_thirdbirth brate_fourthplusbirth year, ///
   title("Birth Rates by Parity, 15-44") ylabel(, angle(0))
   graph export $ft_output_dir/fig_2f.png, replace


export delimited year brate_firstbirth brate_secondbirth brate_thirdbirth ///
 brate_fourthplusbirth using $ft_output_dir/fig_2f.csv, replace

log close
