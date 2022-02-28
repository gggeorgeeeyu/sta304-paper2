*Create Figures 1, 2, and 3

*Data in figures 1 is gathered from CDC Births Reports
*Table 8, "Birth rates, by age and Hispanic origin of mother, and by race for mothers of non-Hispanic origin:"
*"Fertility Rate, All Origins" Column
*1980-2015: https://www.cdc.gov/nchs/data/nvsr/nvsr66/nvsr66_01.pdf
*2016-2018: https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-02-508.pdf
*2019-2020: https://www.cdc.gov/nchs/data/vsrr/vsrr012-508.pdf

cap log close 
log using $ft_output_dir\logs\fig_1.log, replace

import delimited $ft_data_dir\fig_1.csv, clear

destring *, replace

*Figure 1
twoway line brate_all year

graph export $ft_output_dir/fig_1.png, replace

log close
