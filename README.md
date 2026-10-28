---
title: "notes"
output: html_document
---

[!EU spending relative to national public spending](Rplot_EU_SPENDING_AS_PERC_OF_NAT_SPENDING.png)

# EU spending relative to national public spending, 2014–2024

## Question
How large is EU expenditure in each member state relative to that
state's own general government expenditure?

## Sources
1. **Eurostat, `gov_10a_exp`** — general government expenditure by function.
   Retrieved via the `eurostat` R package.
   Filter: unit = MIO_EUR, sector = S13, na_item = TE, cofog99 = TOTAL.
2. **European Commission, "EU spending and revenue – Data 2000–2025"**
   (Excel, one sheet per year). Downloaded from the Commission's
   "EU spending and revenue 2021–2027" page.
   Used: "Total expenditure" row of each yearly sheet, EUR million.

## Pipeline
- `01_eurostat.R` — download, filter, restrict to EU27, years ≥ 2014
- `02_eu_budget.R` — read yearly sheets with one function, reshape wide → long
- `03_join.R` — harmonise keys, check with anti_join, inner join, compute ratio
  

Final dataset: 27 countries × 11 years = 297 rows, no missing values.

## Decisions
- Dropped aggregates (EU27_2020, EA19/20/21) and non-EU countries (CH, IS, NO)
  using the package's `eu_countries` reference list, not a hand-typed list.
- Kept only years with data for all 27 member states (balanced panel). The data 
  from Eurostat, LU national public expenditures had one extra entry of years (2025). 
  To match all data, that value was removed from the dataset. 
  - Commission sheets: the total-expenditure label sits in the first column,
  not the heading column.
- Bulgaria column contained a footnote ("p.m. amount of the 2019 UK
  correction") spilling across cells, which forced it to text; converted to
  numeric after confirming no real values were lost.
- Country codes: Eurostat uppercase, Commission lowercase; both use EL for
  Greece. Harmonised with toupper().
- Units: both sources in EUR million. Checked by 
  Germany 2020: national = 1763784.0, EU = 12565.5806, ratio = 0.7124217].

## Results
- Highest ratios: Lithuania, Bulgaria, Latvia, Hungary, Romania (8–10%).
- Lowest: Netherlands, Germany, Sweden, Austria, Denmark (under 1%).


## Disclaim

I shared the files 01_eurostat.R and 02_eu_merge.R and results with Claude and prompted 
the preparation of this README document for my own future retrospective purposes. The rest of this
markdown file above, is by and large, but not all, AI created. The rest of the work belongs to me.
