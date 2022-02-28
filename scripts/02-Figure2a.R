#read in data for figure2a and 2b
data_fig2ab <- read.csv("figs_2a_2b.csv")

#figure 2a
#Apply ggplot and distinct different lines with different colors
figure2a <- ggplot(data_fig2ab, aes(year)) + 
  geom_line(aes(y = brate_1519, colour = "brate_1519")) + 
  geom_line(aes(y = brate_2024, colour = "brate_2024")) +
  geom_line(aes(y = brate_2529, colour = "brate_2529")) + 
  geom_line(aes(y = brate_3034, colour = "brate_3034")) +
  geom_line(aes(y = brate_3539, colour = "brate_3539")) + 
  geom_line(aes(y = brate_4044, colour = "brate_4044")) +
  
  #add label on each line
  geom_text(label = "Age 40-44", x = 1990, y = 10, color = "black") +
  geom_text(label = "Age 35-39", x = 1990, y = 30, color = "black") +
  geom_text(label = "Age 15-19", x = 1990, y = 58, color = "black") +
  geom_text(label = "Age 30-34", x = 2000, y = 80, color = "black") +
  geom_text(label = "Age 20-24", x = 1990, y = 110, color = "black") +
  geom_text(label = "Age 25-29", x = 2006, y = 115, color = "black") +
  #remove the legend
  theme(legend.position = "none", axis.title.x = element_blank()) +
  #change the y label
  labs(y = "Births per 1,000 women in relevant population subgroup") +
  #add the vertical line one 2007
  geom_vline(xintercept = 2007, linetype = "dotted", size = 0.8) +
  #add the 2007 label
  geom_text(label="2007", x=2009, y=69, color = "black")