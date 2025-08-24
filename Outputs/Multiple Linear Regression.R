library(performance)
library(AmesHousing)
library(tidyverse)
library(easystats)
library(jtools)
library(GGally)
AmesIowa <- make_ames()
View(AmesIowa)
AmesIowa2 <- AmesIowa %>%
  dplyr::select(., "Sale_Price", "Gr_Liv_Area", "Total_Bsmt_SF",
                "Neighborhood", "MS_Zoning", "Full_Bath",
                "Half_Bath", "Bedroom_AbvGr", "Garage_Cars",
                "Year_Built")
AmesIowa3 <- AmesIowa2 %>% filter(., str_detect(MS_Zoning, 'Density'))  
AmesIowa3$HomeAge = 2010 - AmesIowa3$Year_Built
AmesIowa3$Year_Built <-NULL
AmesIowa3$MS_Zoning = factor(AmesIowa3$MS_Zoning)
table(AmesIowa3$MS_Zoning)
AmesIowa3$MS_Zoning <- fct_collapse(AmesIowa3$MS_Zoning,
                                    LowDensityNeighorhood = "Residential_Low_Density",
                                    HigherDensityNeighorhood =
                                    c("Residential_High_Density",
                                      "Residential_Medium_Density" ))
table(AmesIowa3$MS_Zoning)
AmesIowa3 %>% mutate(., BathRooms = Full_Bath + (Half_Bath * 0.5)) %>%
  dplyr::select(., -contains("_Bath")) -> AmesIowa4
summary(AmesIowa4)
ggpairs(AmesIowa4[, c(1:3, 6:8)])
MR = lm(Sale_Price ~ Gr_Liv_Area + Total_Bsmt_SF +
          Garage_Cars + BathRooms, data = AmesIowa4)
summ(MR, confint = TRUE)
check_model(MR)
AmesIowa5 = AmesIowa4[-c(1405, 2046), ]
ggplot(AmesIowa5, aes(Sale_Price)) +
  geom_histogram() + theme_lucid()
ggplot(AmesIowa5, aes(x = Neighborhood, y = Sale_Price, fill = Neighborhood)) +
  stat_boxplot(geom = 'errorbar') + geom_boxplot(alpha = 0.5) +
  geom_jitter(size = 0.5) + theme_light() + theme(legend.position = "none") +
  coord_flip() + labs(x = "Neighborhoods", y = "Sale Price")
bx = boxplot(AmesIowa5$Sale_Price)
bx
sort(bx$out)
AmesIowa6 = AmesIowa5 %>% filter(Sale_Price < 700000)
ggplot(AmesIowa6, aes(x = Sale_Price)) +
  geom_histogram() + theme_bw()
ggplot(AmesIowa6, aes(x = log(Sale_Price))) +
  geom_histogram() + theme_bw()
lgMR = lm(log(Sale_Price) ~ Gr_Liv_Area + Total_Bsmt_SF +
            Garage_Cars + BathRooms, data = AmesIowa6)
summ(lgMR, confint = TRUE, digits = 4)
exp(lgMR$coefficients)
check_model(lgMR)
