# Ames Housing Price Prediction

## Overview
This project analyzes house prices in Ames, Iowa, focusing on the relationship between sale prices, living area, and zoning density. It uses linear regression to predict prices and logistic regression to assess the likelihood of higher-density zoning, leveraging the Ames Housing Dataset.

## Dependencies
- R (>= 4.0)
- Packages: `AmesHousing`, `tidyverse`, `DescTools`, `jtools`
- Install: `install.packages(c("AmesHousing", "tidyverse", "DescTools", "jtools"))`

## Data
- Source: Ames Housing Dataset (`make_ames()` from `AmesHousing` package)
- Processed data: `/data/ames_processed.csv`

## Usage
1. Clone the repository: `git clone https://github.com/ShipuDebnath/ames-housing-price-prediction.git
2. Open R and set the working directory to the repo folder.
3. Run the script: `source("ames-housing-price-prediction.r")`
4. Outputs:
   - Model summaries in `results/model_summaries.txt`
   - Processed data in `data/ames_processed.csv`

## Key Findings
- Linear regression shows a significant positive relationship between `Gr_Liv_Area` and `Sale_Price`.
- Logistic regression indicates how `Sale_Price` influences the odds of higher-density zoning.

## Author
Shipu Debnath  
MS Student in Geography, Texas Tech University  
[LinkedIn](https://linkedin.com/in/shipudebnath/) | [Google Scholar](https://scholar.google.com/citations?user=WyP6KUUAAAAJ&hl=en)

## License
MIT License
