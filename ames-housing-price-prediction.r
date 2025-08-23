# Ames Housing Price Prediction
# Purpose: Predict house prices in Ames, Iowa using multiple linear regression
# Author: Shipu Debnath
# Date: August 2025

# Load required packages
library(AmesHousing)    # Ames Housing Dataset
library(tidyverse)      # Data manipulation and visualization
library(jtools)         # Model summaries
library(GGally)         # Pairwise correlation plots
library(performance)    # Model diagnostics
library(easystats)      # Additional model tools

# Load and preprocess Ames Housing Dataset
ames_raw <- make_ames()  # Load raw dataset

# Select relevant variables and filter for density-related zoning
ames_filtered <- ames_raw %>%
  dplyr::select(Sale_Price, Gr_Liv_Area, Total_Bsmt_SF, Neighborhood, 
                MS_Zoning, Full_Bath, Half_Bath, Bedroom_AbvGr, 
                Garage_Cars, Year_Built) %>%
  filter(str_detect(MS_Zoning, "Density")) %>%  # Focus on residential density zones
  na.omit()  # Remove rows with missing values

# Create derived variables: HomeAge and collapse MS_Zoning categories
ames_processed <- ames_filtered %>%
  mutate(HomeAge = 2010 - Year_Built,  # Calculate home age as of 2010
         MS_Zoning = factor(MS_Zoning),
         MS_Zoning = fct_collapse(MS_Zoning,
                                  LowDensityNeighborhood = "Residential_Low_Density",
                                  HigherDensityNeighborhood = c("Residential_High_Density", 
                                                               "Residential_Medium_Density")),
         BathRooms = Full_Bath + (Half_Bath * 0.5)) %>%  # Combine full and half bathrooms
  dplyr::select(-Year_Built, -Full_Bath, -Half_Bath)  # Remove original variables

# Summary of processed dataset
summary(ames_processed)

# Visualize pairwise correlations among numeric variables
ggpairs(ames_processed[, c("Sale_Price", "Gr_Liv_Area", "Total_Bsmt_SF", 
                           "Garage_Cars", "BathRooms", "HomeAge")],
        title = "Correlation Matrix of Ames Housing Variables") +
  theme_minimal()

# Fit initial multiple linear regression model
model_linear <- lm(Sale_Price ~ Gr_Liv_Area + Total_Bsmt_SF + 
                   Garage_Cars + BathRooms, data = ames_processed)
summ(model_linear, confint = TRUE, digits = 3)  # Summarize model with confidence intervals

# Check model assumptions (e.g., linearity, normality, outliers)
check_model(model_linear)

# Identify and remove outliers based on boxplot
sale_price_boxplot <- boxplot(ames_processed$Sale_Price, plot = FALSE)
outliers <- which(ames_processed$Sale_Price %in% sale_price_boxplot$out)
ames_cleaned <- ames_processed[-outliers, ]  # Remove outliers

# Additional cleaning: Remove extreme sale prices (> $700,000)
ames_cleaned <- ames_cleaned %>% filter(Sale_Price < 700000)

# Visualize cleaned sale price distribution
hist_sale_price <- ggplot(ames_cleaned, aes(x = Sale_Price)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.5) +
  theme_bw() +
  labs(title = "Distribution of House Sale Prices in Ames, Iowa",
       x = "Sale Price ($)", y = "Count")
hist_sale_price
ggsave("plots/sale_price_histogram.png", hist_sale_price, width = 8, height = 6)

# Visualize sale price by neighborhood
boxplot_neighborhood <- ggplot(ames_cleaned, aes(x = Neighborhood, y = Sale_Price, fill = Neighborhood)) +
  stat_boxplot(geom = "errorbar") +
  geom_boxplot(alpha = 0.5) +
  geom_jitter(size = 0.5, width = 0.2) +
  theme_light() +
  theme(legend.position = "none") +
  coord_flip() +
  labs(title = "Sale Prices by Neighborhood in Ames, Iowa",
       x = "Neighborhood", y = "Sale Price ($)")
boxplot_neighborhood
ggsave("plots/neighborhood_boxplot.png", boxplot_neighborhood, width = 10, height = 6)

# Visualize log-transformed sale price distribution
hist_log_sale_price <- ggplot(ames_cleaned, aes(x = log(Sale_Price))) +
  geom_histogram(bins = 30, fill = "green", alpha = 0.5) +
  theme_bw() +
  labs(title = "Distribution of Log-Transformed Sale Prices",
       x = "Log(Sale Price)", y = "Count")
hist_log_sale_price
ggsave("plots/log_sale_price_histogram.png", hist_log_sale_price, width = 8, height = 6)

# Fit log-transformed regression model
model_log <- lm(log(Sale_Price) ~ Gr_Liv_Area + Total_Bsmt_SF + 
                Garage_Cars + BathRooms, data = ames_cleaned)
summ(model_log, confint = TRUE, digits = 4)  # Summarize log model
exp(model_log$coefficients)  # Exponentiate coefficients for interpretation

# Check assumptions for log-transformed model
check_model(model_log)

# Save results for reference
sink("results/model_summary.txt")
print("Linear Model Summary:")
summ(model_linear, confint = TRUE, digits = 3)
print("Log-Transformed Model Summary:")
summ(model_log, confint = TRUE, digits = 4)
sink()
