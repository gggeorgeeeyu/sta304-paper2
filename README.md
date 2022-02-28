This repo is for paper 2 of STA 304, Winter 2022

It is organised as follows.
- Overview: The code in this replication package constructs the analysis for Kearney, Levine, Pardue (2021) using Stata. One master file run all of the code to generate the data for the 4 figures in the paper, in addition to several statistics cited in the text.
- LICENSE: Federal Reserve Bank of New York
- inputs: data
  * Birth data
  * Population data
  * Long-term changes data
  * State level economic and policy factors used in annual regressions, 2000-2019
  * Demographic variables
- outputs: paper
  * paper.pdf: the pdf version of paper
  * paper.rmd: the r markdown file for the paper
  * reference.bib: the bib tex for the reference
- paper2.Rproj: the R project file for this paper
- README.md
- scripts: eight files in total
  * 01_figure1.r: plotting functions for the figure with label fig1
  * 02_Figure2a.r: plotting functions for the figure with label fig2a
  * 03_Figure2b.r: plotting functions for the figure with label fig2b
  * 04_Figure2c.r: plotting functions for the figure with label fig2c
  * 05_Figure2d.r: plotting functions for the figure with label fig2d
  * 06_Figure2e.r: plotting functions for the figure with label fig2e
  * 07_Figure2f.r: plotting functions for the figure with label fig2f
  * 08_figure3.r: plotting functions for the figure with label fig3
- programs: nine programs in total for replication
  * 0_setup.do – installs necessary STATA packages; only needs to be run once.
  * main_prog.do – runs the full analysis to create figures, tables, and numbers cited in the text
  * programs/fig_1.do - reads in birth rates from CDC Final Births Reports to produce figure 1 - birth rates overall.
  * programs/figs_2a_2b.do - reads in birth rates from CDC Final Births Reports to produce figures 2a and 2b - birth rates by mother's age group and birth rates by mother's race/ethnicity.
  * programs/fig_2c.do - reads in births data from CDC WONDER and population data from the CPS to create figure 2c, births among Hispanic women by nativity and Mexican origin.
  * programs/fig_2d.do - reads in aggregated births data and population data from the CPS to create figure 2d, births by mother's educational level.
  * programs/fig_2e.do - reads in birth rate data from the CDC Final Births Reports to produce figures 2e - birth rates by marital status.
  * programs/fig_2f.do - reads in aggregated births data and population from CDC SEER to create figure 2f, birth rates by parity.
  * programs/fig_3.do - reads in aggregated births data and population from CDC SEER to create figure 3, a map displaying percent change in average birth rates from 2004- 2008 to 2015-2018.


