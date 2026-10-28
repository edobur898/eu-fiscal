install.packages(c("tidyverse", "eurostat", "countrycode", "readxl", "janitor"))
library(tidyverse)
library(eurostat)

#DATA CHECK,
# 1. Find out which sector, expenditure item, and label matches with what I am looking for
# 2. 

raw <- get_eurostat("gov_10a_exp")

glimpse(raw)
count(raw)
nrow(raw)
raw |> count(unit)
raw |> count(sector)
raw |> count(cofog99)
print(raw |> count(cofog99), n=100)
print(count(raw, cofog99), )

raw |> distinct(unit) |> mutate( label = label_eurostat(unit, dic = "unit"))
raw |> distinct(sector) |> mutate(label = label_eurostat(sector, dic ="sector"))
raw |> distinct(na_item) |> mutate (label = label_eurostat(na_item, dic="na_item")) |> print(n= Inf)
raw |> distinct(cofog99) |> mutate(label= label_eurostat(cofog99, dic="cofog99")) |> print(n=Inf)
raw |> distinct(cofog99)|> mutate(label = label_eurostat(cofog99, dic = "cofog99")) |> filter(str_detect(label, "health"))

#After the inquiry above, limit data to only include data of interest.

exp <- raw |> 
  filter(unit == "MIO_EUR",
         sector =="S13",
         na_item == "TE",
         cofog99 == "TOTAL")

exp |> count(geo,TIME_PERIOD) |> filter(n>1) |> View()

eu_countries
nrow(eu_countries)

# Drop aggregates, only include data for individual EU countries. 

exp <- exp |> filter(geo %in% eu_countries$code)

# Check if the code for Greek is "GR" or "EL"

exp |> filter(str_detect(geo, "EL")) |> View()  

# Limit the data to only include years of interest. 

exp <- exp |> mutate(year = as.integer(format(TIME_PERIOD, "%Y"))) |> filter(year >= 2014)

# Arrange column names to indicate country names, year, and that expenditures are in millions

nat_exp <- exp |> select(geo, year, nat_exp_meur = values) |>
  arrange(geo, year)

nat_exp |> group_by(year) 

#Clean the extra entry of year 2025 for LU, to match the number of observations for all countries

nrow(nat_exp)
nat_exp |> filter(year == 2025)

nat_exp |> count(year)
nat_exp |> group_by(year) |> filter(n() < 27) 

nat_exp_dropped <- nat_exp |> 
  filter(!is.na(nat_exp_meur)) |>
  group_by(year) |> 
  filter(n() == 27) |>
  ungroup()
print(count(nat_exp_dropped, geo), n= Inf)

#Check if the final set is solid

nrow(nat_exp_dropped)
nat_exp_dropped |> distinct(year)
nat_exp_dropped |> filter(is.na(nat_exp_meur))

n_distinct(nat_exp_dropped$geo)
