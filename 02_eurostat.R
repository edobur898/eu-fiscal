library(readxl)
library(tidyverse)
library(janitor)
library(eurostat)
excel_sheets("data/eu_budget_spending_and_revenue_2000-2025.xlsx")

# Read the EU Spending & Expenditure data, skip the empty rows common to each sheet

eu_row <- read_excel("data/eu_budget_spending_and_revenue_2000-2025.xlsx",
                     sheet = "2020",
                     skip = 2)

# Change the names into formattable ones

eu_row <- janitor::clean_names(eu_row)            

names(eu_row)
head(eu_row)

tail(eu_row, 15) |> select(1:3)

#Find where the total expenditure is from an arbitrarily chosen year

eu_row |>
  filter(str_detect(x2020_eur_million, regex("total", ignore_case = TRUE))) |>
  select(1:3)

#There is some text under bg, find out what it is

eu_row |> 
  filter(!is.na(bg), is.na(as.numeric(bg))) |> #Apparently they were only footnotes
  select(x2, bg)


#Here is:

#A tibble: 2 × 2
#x2    bg                         
#<chr> <chr>                      
#1 NA    p.m. amount of the 2019    
#2 NA    UK correction (2nd update):

  
#Define a character series with the country codes, that will be needed for joining sheets. 

eu_codes <- tolower(eu_countries$code)

#Define a function that unitarily reads all sheets, creating tables with data and columns matching with the Eurostat data

read_year <- function(sheet) {
  read_excel("data/eu_budget_spending_and_revenue_2000-2025.xlsx",
  sheet = sheet, skip = 2) |>
janitor::clean_names() |> 
rename(code = 1, heading = 2) |>
filter(code == "TOTAL EXPENDITURE") |>
select(any_of(eu_codes)) |>
mutate(across(everything(), as.numeric)) |>
pivot_longer(everything(), names_to = "geo", values_to = "eu_exp_meur") |>
mutate(year = as.integer(sheet))
  }

eu_exp <- map(as.character(2014:2024), read_year) |> list_rbind()



eu_exp |> count(year)
nat_exp_dropped |> count(year)
eu_exp|> filter(geo == "bg") #check if any data is missing because I had text appearing in the excel under there. See #31

eu_exp |> filter(is.na(eu_exp_meur))


#Join two tables eu_exp & nat_exp_dropped

eu_exp <- eu_exp |> mutate(geo = toupper(geo)) #Turn country labels to lowerdown so that it matches with the Eurostat data. 

#Check for mismatching structure
anti_join(eu_exp, nat_exp_dropped, by = c("geo", "year"))
anti_join(nat_exp_dropped, eu_exp, by = c("geo", "year"))

#Join the two tables

df <- inner_join(nat_exp_dropped, eu_exp, by = c("geo", "year"))

df |> count(year) # data is clean and matching

#Calculate and add a column to show EU expenditure for the country as % of public national spending. 

df <- df |> mutate(eu_share_pct = eu_exp_meur / nat_exp_meur * 100)

#See the share in descending order, and take note

df |> group_by(geo) |>
  summarise(mean_share = mean(eu_share_pct)) |> 
  arrange(desc(mean_share)) |>
  print(, n=Inf)

#Plot the output of #92
df |> group_by(geo) |>
  summarise(mean_share = mean(eu_share_pct)) |>
  ggplot(aes(x = reorder(geo, mean_share), y = mean_share)) +
  geom_col() +
  coord_flip() + 
  labs(x=NULL, y = "EU spending as % of national government expenditure", 
       title = "EU Spending relative to national public spending, 2014-2024 average") 

#Plot change in the share between years for some key countries

df |> 
  filter(geo %in% c("DE", "PL", "HU", "EL", "IT")) |>
  ggplot(aes(x = year, y = eu_share_pct, colour = geo)) +
  geom_line() +
  scale_color_discrete(labels = setNames(eu_countries$name, eu_countries$code)) +
  labs(x = NULL, y = "EU spending as % of national government expenditure", colour = NULL)


#Save the plots as images to the project folder. 
