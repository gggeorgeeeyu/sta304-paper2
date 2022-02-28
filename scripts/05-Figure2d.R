names(figs_1_2_3)[13] <- "No_high_school_degree"
names(figs_1_2_3)[14] <- "high_school_degree"
names(figs_1_2_3)[15] <- "Some_college"
names(figs_1_2_3)[16] <- "College_graduate"
data_2d <-figs_1_2_3 %>% 
  select(year,
         No_high_school_degree,	
         high_school_degree,	
         Some_college,	
         College_graduate,)%>%
  gather(key = " e", value = "Births_per_1000_women", -year)
data_figd <- na.omit(data_2d)
colnames(data_figd)<- c("year","education","Births_per_1000_women")

figure2d <- data_figd %>%
  ggplot(aes(x=year, y = Births_per_1000_women)) + 
  geom_line(aes(color = education)) + 
  scale_color_manual(values = c("yellow", "orange", "blue", "grey")) + 
  # change the y label
  labs(y = "Births per 1,000 women in relevant population subgroup") +
  #add label on each line
  geom_text(label = "No high school degree", x = 1995, y = 100, color = "black") +
  geom_text(label = "high school degree", x = 1995, y = 60, color = "black") +
  geom_text(label = "Some college", x = 1995, y = 50, color = "black") +
  geom_text(label = "College graduate", x = 1995, y = 80, color = "black") +
  #add the vertical line one 2007
  geom_vline(xintercept = 2007, linetype = "dotted", size = 0.8) +
  #add the 2007 label
  geom_text(label="2007", x=2007, y=20, color = "black")+
  theme(legend.position = "none", axis.title.x = element_blank(), axis.title.y = element_blank())