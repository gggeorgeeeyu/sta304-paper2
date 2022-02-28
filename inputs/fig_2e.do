*Create Figure 2e, Birth Rates by Marital Status

*Data in figure 2e is gathered from CDC Births Reports
*Table 16. "Birth rates for unmarried women, by age of mother, 15-44" (p. 47 in 1)
  *1. 1980-2015: https://www.cdc.gov/nchs/data/nvsr/nvsr66/nvsr66_01.pdf
  *2. 2016-2018: https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-02-508.pdf
  *3. 2019-2020: https://www.cdc.gov/nchs/data/vsrr/vsrr012-508.pdf

cap log close 
log using $ft_output_dir\logs\fig_2e.log, replace

import delimited $ft_data_dir\fig_2e.csv, clear

destring *, replace

*Figure 6
twoway line brate_married brate_unmarried year

graph export $ft_output_dir/fig_2e.png, replace

export delimited $ft_output_dir/fig_2e.csv, replace 

log close
