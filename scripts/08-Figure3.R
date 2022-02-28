library(haven)
data_fig3 <- read_dta("nchs/nchs_births_pop_1990_2019.dta")

#Birth Data: NCHS Microdata
temp0 <- data_fig3 %>% 
  filter((data_fig3$year >= 2004 & data_fig3$year <= 2008) | (data_fig3$year >= 2015 & data_fig3$year <= 2019)) %>%
  group_by(year, stname) %>%
  select(year, stname, numbirth1544)

#Pop Data: CDC SEER
age_race_comp_seer <- read_dta("pop/age_race_comp_seer.dta")
age_race_comp_seer <- age_race_comp_seer %>%
  mutate(pop1544 = pop1519 + pop2034 + pop3544) %>%
  filter( year >= 2004 & year <= 2008 | year >= 2015 & year <= 2019) %>%
  group_by(stname) %>%
  select(year, stname, pop1544)

#left join
temp0 <- left_join(temp0,age_race_comp_seer,by=c("year" = "year", "stname" = "stname"))

#generate new column
data_fig3 <- temp0 %>% mutate(year = case_when(year >= 2004 & year <= 2008 ~ "2004",
                                               year >= 2015 & year <= 2019 ~ "2019")) %>%
  group_by(stname,year) 

aggregated_data <- 
  aggregate(cbind(numbirth1544, pop1544)~ year + stname, data = data_fig3, FUN = mean) %>%
  mutate(brate1544_thsnds = numbirth1544/pop1544 * 1000)

library(dplyr)
#table1
table0 <- aggregated_data
table1 = table0 %>% filter(table0$year == "2004") %>% 
  rename(brate2004 = brate1544_thsnds) %>%
  select(stname, brate2004)

#table2
table2 <- aggregated_data
table3 = table2 %>% filter(table2$year == "2019") %>%
  rename(brate2019 = brate1544_thsnds) %>%
  select(stname, brate2019)

#new table
table = merge(x = table1, y = table3, by = c("stname", "stname"))
table <- table %>% 
  mutate(brate_diff = brate2019 - brate2004) %>%
  
  rename(state = stname)

#map
library(usmap)
library(ggplot2)
plot_usmap(data = table, values = "brate_diff") +
  
  scale_fill_continuous(high = "#FFFFE0", low = "#8B0000", name = "Population (2015)", label = scales::comma) +
  theme(legend.position = "right")
