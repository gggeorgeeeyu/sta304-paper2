#load in figure 2e data
data_fig2e <- read.csv("fig_2e.csv")

#apply ggplot to the data
figure2e <- ggplot(data_fig2e, aes(year)) + 
  #distinct the lines with different colours
  geom_line(aes(y = brate_unmarried, colour = "brate_unmarried")) + 
  geom_line(aes(y = brate_married, colour = "brate_married")) + 
  #add a vertical line where x = 2007
  geom_vline(xintercept = 2007, linetype = "dotted", size = 0.8) +
  #add label 2007
  geom_text(label="2007", x=2009, y=69, color = "black") +
  #add label "married" and "unmarried"
  geom_text(label = "Unmarried", x = 2000, y = 50, color = "black") +
  geom_text(label = "Married", x = 2000, y = 80, color = "black") +
  #remove the legand
  theme(legend.position = "none", axis.title.x = element_blank()) +
  #change the name of y-axis
  labs(y = "Births per 1,000 women in relevant population subgroup")
