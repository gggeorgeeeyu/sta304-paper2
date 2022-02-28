figs_1_2_3 <- read_csv("figs_1_2_3.csv")
options(readr.show_col_types = FALSE)
# rename variables
names(figs_1_2_3)[20] <- "Native_born_Mexican"
names(figs_1_2_3)[21] <- "Foreign_born_Mexican"
names(figs_1_2_3)[22] <- "Native_born_non_Mexican"
names(figs_1_2_3)[23] <- "Foreign_born_non_Mexican"

data_2c <-figs_1_2_3 %>% 
  select(year, 
         Native_born_Mexican, 
         Foreign_born_Mexican, 
         Native_born_non_Mexican, 
         Foreign_born_non_Mexican)%>%
  gather(key = " h", value = "Births_per_1000_women", -year)
data_figc <- na.omit(data_2c)
colnames(data_figc)<- c("year","Hispanic","Births_per_1000_women")

figure2c<- data_figc %>% 
  ggplot(aes(x = year, y = Births_per_1000_women)) + 
  geom_line(aes(color =  Hispanic)) + 
  scale_color_manual(values = c("grey", "blue", "yellow", "orange")) +
  #change the y label
  labs(y = "Births per 1,000 women in relevant population subgroup") +
  #add label on each line
  geom_text(label = "Foreign born Mexican", x = 2015, y = 100, color = "black") +
  geom_text(label = "Native born Mexican", x = 2015, y = 50, color = "black") +
  geom_text(label = "Native born non Mexican", x = 2000, y = 100, color = "black") +
  geom_text(label = "Foreign born non Mexican", x = 2000, y = 50, color = "black") +
  #add the vertical line one 2007
  geom_vline(xintercept = 2007, linetype = "dotted", size = 0.8) +
  #add the 2007 label
  geom_text(label="2007", x=2007, y=140, color = "black")+
  theme(legend.position = "none", axis.title.x = element_blank())