#figure2b
#Apply ggplot and distinct different lines with different colors
figure2b <- ggplot(data_fig2ab, aes(year)) + 
  geom_line(aes(y = brate_whitenh, colour = "brate_whitenh")) + 
  geom_line(aes(y = brate_blacknh, colour = "brate_blacknh")) + 
  geom_line(aes(y = brate_hisp, colour = "brate_hisp")) + 
  #add label on each line
  geom_text(label = "Hispanic", x = 2000, y = 100, color = "black") +
  geom_text(label = "Black, non-Hispanic", x = 2000, y = 70, color = "black") +
  geom_text(label = "White, non-Hispanic", x = 1995, y = 58, color = "black") +
  #remove the legend
  theme(legend.position = "none", axis.title.x = element_blank(), axis.title.y = element_blank()) +
  #change the y label
  labs(y = "Births per 1,000 women in relevant population subgroup") +
  #add the vertical line one 2007
  geom_vline(xintercept = 2007, linetype = "dotted", size = 0.8) +
  #add the 2007 label
  geom_text(label="2007", x=2010, y=100, color = "black") +
  #change the scale of x-axis
  coord_cartesian(xlim = c(1988, 2020))