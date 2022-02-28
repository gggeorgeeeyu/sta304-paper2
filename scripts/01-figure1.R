#read in data for figure1
data_fig1_1 <- read.csv("fig_1.csv")
data_fig1 <- na.omit(data_fig1_1)
#plot figure1
figure1 <- data_fig1 %>% 
  #apply ggplot
  ggplot(aes(x = year, y = brate_all)) + 
  #change the y axis name
  ylab("Births per 1,000 women age 15–44") +
  #change the line color to blue
  geom_line(color = "blue")+
  #add a vertical dot line to the graph and change the size of the line
  geom_vline(xintercept = 2007, linetype = "dotted", size = 0.8) +
  #apply minimal theme
  theme_minimal() +
  #remove the label of x-axis
  theme(axis.title.x = element_blank()) +
  geom_text(label="2007", x=2009, y=69)
figure1