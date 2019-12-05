# Time series forecasting optimization with genetic algorithm
  
**Code will be gradually added to this project**
 
The project is about forecasting a coefficient that represents natural gas consumption of households which is published by distribution system operator on its website (https://www.psgaz.pl/gazowe-zapotrzebowanie-grzewcze). Several models are built and their parameters (eg. number of decision trees in random forests, number of hidden layers in neural network) are optimized with genetic algorithm in order to minimize forecasting error (RMSE or MAPE).

There are 4 .R files:
1. `01_get_data.R` - gets train and test data sets from csv files `data.csv` and `temperature.csv`
2. `02_models.R` - creates forecasting models (for now there is only random forests model; more will be added gradually)
3. `03_genetic_algorithm.R` - optimizes models' parameters in orderd to minimize forecasting error
4. `forecast.R` - final file with results

