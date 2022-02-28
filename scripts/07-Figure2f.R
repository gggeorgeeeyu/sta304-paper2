library(haven)
#read in the first table
data_fig2f1 <- read_dta("nchs/nchs_births_pop_1990_2019.dta")

#read in the second table
data_fig2f2 <- read_dta("pop/age_race_comp_seer.dta")

#left join two tables by year and stname
data_fig2f3 <- left_join(data_fig2f1,data_fig2f2,by=c("year" = "year", "stname" = "stname"))

#select all the columns that we need
data_fig2f3 <- data_fig2f3 %>%
  select(year, numbirth_firstbirth, numbirth_secondbirth, numbirth_thirdbirth, numbirth_fourthbirth, pop1544) 

#calculate the aggregated data(mean) of each column, and then calculate the parity for each one
aggregated_data <- 
  aggregate(cbind(numbirth_firstbirth, numbirth_secondbirth, numbirth_thirdbirth, numbirth_fourthbirth, pop1544)~ year, data = data_fig2f3, FUN = mean) %>%
  mutate(parity_firstbirth = numbirth_firstbirth/pop1544*1000) %>%
  mutate(parity_secondbirth = numbirth_secondbirth/pop1544*1000) %>%
  mutate(parity_thirdirth = numbirth_thirdbirth/pop1544*1000) %>%
  mutate(parity_fourthbirth = numbirth_fourthbirth/pop1544*1000)

#apply ggplot to each column and distinguish them with different colors
figure2f <- ggplot(aggregated_data, aes(year)) + 
  geom_line(aes(y = parity_firstbirth, colour = "parity_firstbirth")) +
  geom_line(aes(y = parity_secondbirth, colour = "parity_secondbirth")) +
  geom_line(aes(y = parity_thirdirth, colour = "parity_thirdirth")) +
  geom_line(aes(y = parity_fourthbirth, colour = "parity_fourthbirth")) +
  #add a vertical line where x is 2007
  geom_vline(xintercept = 2007, linetype = "dotted", size = 0.8) +
  #add label 2007
  geom_text(label="2007", x=2009, y=15, color = "black") +
  #add label "married" and "unmarried"
  geom_text(label = "First birth", x = 2000, y = 26, color = "black") +
  geom_text(label = "Second birth", x = 2000, y = 20, color = "black") +
  geom_text(label = "Third birth", x = 2000, y = 12, color = "black") +
  geom_text(label = "Fourth birth", x = 2000, y = 9, color = "black") +
  #remove the legand
  theme(legend.position = "none", axis.title.x = element_blank(), axis.title.y = element_blank()) +
  #change the name of y-axis
  labs(y = "Births per 1,000 women in relevant population subgroup")