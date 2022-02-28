*Create Figures 2a and 2b, Trend in Birth Rates by Population Subgroup
*By Race/Ethinicity and By Age Group

*Data in figures 2a, 2b, and 2e are gathered from CDC Births Reports
*Table 8, "Birth rates, by age and Hispanic origin of mother, and by race for mothers of non-Hispanic origin:"
  *1. 1980-2015: https://www.cdc.gov/nchs/data/nvsr/nvsr66/nvsr66_01.pdf
  *2. 2016-2018: https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-02-508.pdf
  *3. 2019-2020: https://www.cdc.gov/nchs/data/vsrr/vsrr012-508.pdf
*Table 16. "Birth rates for unmarried women, by age of mother, 15-44" (p. 47 in 1)

cap log close 
log using $ft_output_dir\logs\figs_2a_2b.log, replace

*Data Work, Merge All Sources Together:
import delimited $ft_data_dir\figs_2a_2b.csv, clear

destring *, replace

*Figure 2a - Mother's 5-yr age groups
twoway line brate_1519 brate_2024 brate_2529 brate_3034 brate_3539 brate_4044 year

graph export $ft_output_dir/fig_2a.png, replace

*Figure 2b - Mother's Race/Ethnicity
twoway line brate_whitenh brate_blacknh brate_hisp year if year>=1990

graph export $ft_output_dir/fig_2b.png, replace


log close
