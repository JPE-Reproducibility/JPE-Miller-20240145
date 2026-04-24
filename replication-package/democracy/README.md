---
title: Who values democracy?
contributors:
  - Max Miller
---

## Overview

The code in this replication package constructs the analysis file from the multiple data sources using Stata and Python. Running `uv run scons` runs all of the code to generate the data for the 8 main figures, 12 main tables, 13 appendix figures, and 17 appendix tables in the paper, as well as the figures and tables themselves. The replicator should expect the code to run for about 30 minutes.

## Quick Replication Guide

### Prerequisites
- Stata 19 (MP, SE, or BE)
- Python >=3.11, <3.13
- pdflatex (e.g., via TeX Live: `brew install --cask mactex` on macOS, `apt install texlive-full` on Linux)
- [uv](https://docs.astral.sh/uv/) (Python package manager)

### Setup
1. Clone this repository
2. Copy `.env.example` to `.env` and update paths:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` to set `ROOT_PATH` to the absolute path of this repository on your machine.

3. If your Stata executable is not called `StataMP`, set the override:
   ```bash
   # In .env or shell:
   export JMSLAB_EXE_STATA=stata-mp  # Linux
   export JMSLAB_EXE_STATA=StataSE   # if using Stata/SE
   ```

4. Stata dependencies are vendored in `source/utils/analysis/` — no install needed (gtools must be reinstalled for windows).
   To install fresh copies instead (optional):
   ```bash
   # Open Stata and run:
   do source/lib/requirements.do
   ```

5. Build everything:
   ```bash
   uv sync                    # Install Python dependencies
   uv run python -m SCons -c  # Clean any pre-built outputs
   uv run python -m SCons     # Full build (10-60 minutes depending on machine)
   ```

### Repository structure

- `source/` contains source scripts and outputs for the paper
- `datastore/` houses all raw and derived data.

### Raw Data Sources

All raw data files are stored in `datastore/raw/` organized by source. Within each source directory, original data files are placed in an `orig/` subdirectory (e.g., `datastore/raw/jst/orig/JSTdatasetR5.dta`). File paths below are listed relative to each source's directory. The following sections describe each data source and how to access it.

#### 1. Correlates of War (CoW)

**Location:** `datastore/raw/cow/`

**Data Description:** Data from the Correlates of War project, including records of interstate wars, extra-state wars, intra-state wars, and militarized interstate disputes (MIDs). Provides information on the participants, dates, outcomes, and fatalities of conflicts in the international system.

**Access Instructions:**
- **URL:** https://correlatesofwar.org/
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed July 2020

**Citation:**
- Palmer, G., McManus, R. W., D’Orazio, V., Kenwick, M. R., Karstens, M., Bloch, C., Dietrich, N., Kahn, K., Ritter, K., & Soules, M. J. (2021). The MID5 Dataset, 2011–2014: Procedures, coding rules, and description. Conflict Management and Peace Science, 39(4), 470-482. https://doi.org/10.1177/0738894221995743 (Original work published 2022)
- Sarkees, Meredith Reid and Frank Wayman (2010). Resort to War: 1816 - 2007. Washington DC: CQ Press.

**Files:**
- `militarized_interstate_disputes/MIDB_4.2.csv`
- `militarized_interstate_disputes/MIDLOCI_2.0.csv`
- `wars/Inter-StateWarData_v4.0.dta`
- `wars/Extra-StateWarData_v4.0.dta`
- `wars/Intra-StateWarData_v4.1.dta`

#### 2. Fraser Institute's Economic Freedom Index (EFI)

**Location:** `datastore/raw/economic_freedom/`

**Data Description:** Measures the degree to which the policies and institutions of countries are supportive of economic freedom. The cornerstones of economic freedom are personal choice, voluntary exchange, freedom to enter markets and compete, and security of the person and privately owned property.

**Access Instructions:**
- **URL:** https://www.fraserinstitute.org/categories/economic-freedom
- **Direct Download:** https://www.fraserinstitute.org/economic-freedom/dataset
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed July 2020

**Citation:** James Gwartney, Robert Lawson, Joshua Hall, and Ryan Murphy (2022). Economic Freedom Dataset, published in Economic Freedom of the World: 2022 Annual Report. Fraser Institute. <www.fraserinstitute.org/economic-freedom/dataset>

**Files:**
- `efi_data.dta`

#### 3. Global Financial Data (GFD/Finaeon)

**Location:** `datastore/raw/gfd/`

**Data Description:** Historical financial data for the UK and US markets including:
- Dividend Yields
- Total Returns and Price Index Series
- Capital Gains Series
- Number of Publicly Traded Firms
- Price-Earnings Ratios
- Corporate and Government Bond Yields
- Inflation
- Government Spending-GDP Ratios
- OECD CLI

**Access Instructions:**
- **URL:** https://finaeon.com/ (formerly Global Financial Data)
- **Cost:** Subscription required
- **Registration:** Institutional subscription required
- **Restrictions:** Data cannot be redistributed; academic licenses available
- **Access Date:** Data accessed August 2019
- **Documentation:** https://finaeon.com/products/

**Note:** This data requires a paid subscription. Independent researchers should contact Finaeon at the URL above for institutional or academic access.

**Citation:** Global Financial Data, Inc. (2019). Global Financial Data [dataset]. Finaeon. https://finaeon.com/

**Files:**
- `country_series/` (subdirectories by ISO country code, each containing CSV files for individual data series)
- `gfd_data_series_list.xlsx` (this file maps data codes we used from Finaeon)
- `gfd_recessions.csv`
- `govt_rev_gdp.dta`
- `supplements/extraTotalReturnsClean.xlsx`
- `supplements/price_earnings_clean.csv`

#### 4. International Crisis Behavior (ICB)

**Location:** `datastore/raw/icb/`

**Data Description:** Comprehensive dataset regarding interstate conflicts and protracted conflicted, the effects of crisis-induced stress on coping and choice, patterns in crisis dimensions, and outcome.

**Access Instructions:**
- **URL:** https://sites.duke.edu/icbdata/
- **Cost:** Free for academic use
- **Registration:** Not required
- **Access Date:** Data accessed February 2019

**Citation:**
- Book: Brecher, Michael and Jonathan Wilkenfeld (1997). A Study of Crisis. Ann Arbor: University of Michigan Press.
- Data: Brecher, Michael, Jonathan Wilkenfeld, Kyle Beardsley, Patrick James, and David Quinn, "International Crisis Behavior Data Codebook," 2017. Version 12.

**Files:**
- `icb2v12.csv`

#### 5. Jordà-Schularick-Taylor (JST) Macrohistory Database

**Location:** `datastore/raw/jst/`

**Data Description:** Comprehensive macrofinancial dataset covering 18 advanced economies since 1870, including real economy variables, international accounts, government finances, money and prices, credit data, house prices, crisis dates, rates of return, and bank balance sheet ratios.

**Access Instructions:**
- **URL:** https://www.macrohistory.net/database/
- **Cost:** Free for academic use
- **License:** Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
- **Registration:** Not required
- **Access Date:** Data accessed June 2021 (Release 5)

**Citation:**
- Main database: Òscar Jordà, Moritz Schularick, and Alan M. Taylor. 2017. "Macrofinancial History and the New Business Cycle Facts." NBER Macroeconomics Annual 2016.
- Returns data: Òscar Jordà, Katharina Knoll, Dmitry Kuvshinov, Moritz Schularick, and Alan M. Taylor. 2019. "The Rate of Return on Everything, 1870–2015." Quarterly Journal of Economics, 134(3), 1225-1298.
- Bank ratios: Òscar Jordà, Björn Richter, Moritz Schularick, and Alan M. Taylor. 2021. "Bank capital redux: solvency, liquidity, and crisis." The Review of Economic Studies, 88(1), 260-286.

**Files:**
- `JSTdatasetR5.dta`

#### 6. Maddison Historical Statistics

**Location:** `datastore/raw/ggdc/`

**Data Description:** Comparative economic growth and income levels over the very long run. The 2020 version of this database covers 169 countries and the period up to 2018.

**Access Instructions:**
- **URL:** https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2020
- **Direct Download:** https://www.rug.nl/ggdc/historicaldevelopment/maddison/data/mpd2020.dta
- **Cost:** Free, publicly available
- **License:** Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
- **Registration:** Not required
- **Access Date:** Data accessed December 2020
- **Documentation:** https://www.rug.nl/ggdc/historicaldevelopment/maddison/publications/wp15.pdf

**Citation:** Maddison Project Database, version 2020. Bolt, Jutta and Jan Luiten van Zanden (2020), “Maddison style estimates of the evolution of the world economy. A new 2020 update ”

**Files:**
- `mpd2020.dta`

#### 7. Penn World Table

**Location:** `datastore/raw/pwt/`

**Data Description:** Relative levels of income, output, input and productivity, covering 183 countries between 1950 and 2019.

**Access Instructions:**
- **URL:** https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt100
- **Direct Download:** https://www.rug.nl/ggdc/docs/pwt100.dta (main dataset, additional files on website)
- **Cost:** Free, publicly available
- **License:** Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
- **Registration:** Not required
- **Access Date:** Data accessed May 2021
- **Documentation:** https://www.rug.nl/ggdc/docs/the_next_generation_of_the_penn_world_table.pdf

**Citation:** Feenstra, Robert C., Robert Inklaar and Marcel P. Timmer (2015), "The Next Generation of the Penn World Table" American Economic Review, 105(10), 3150-3182

**Files:**
- `pwt100.dta`
- `pwt100-capital-detail.dta`
- `pwt100-labor-detail.dta`

#### 8. Relative Political Capacity Dataset (RPC)

**Location:** `datastore/raw/arpc/`

**Data Description:** The Relative Political Capacity (RPC) dataset measures governments' ability to extract economic resources from that population, reach and mobilize their population, and allocate those resources to pursue desired policies.

**Access Instructions:**
- **URL:** https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NRR7MB
- **Direct Download:** https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/NRR7MB/6DC2YR 
- **Cost:** Free, publicly available
- **License:** Creative Commons Attribution-CC0 1.0 Universal Public Domain Dedication
- **Registration:** Not required
- **Access Date:** Data accessed December 2021

**Citation:** Ali Fisunoglu; Kyungkook Kang; Marina Arbetman-Rabinowitz; Jacek Kugler, 2011, "Relative Political Capacity Dataset (Version 2.4) August 2020", https://doi.org/10.7910/DVN/NRR7MB, Harvard Dataverse, V7

**Files:**
- `arpc_2020_comp.dta`

#### 9. Standardized World Income Inequality Database (SWIID)

**Location:** `datastore/raw/swiid/`

**Data Description:** Comparable Gini indices of disposable and market income inequality for 199 countries for as many years as possible from 1960 to the present; it also includes information on absolute and relative redistribution.

**Access Instructions:**
- **URL:** https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/LM4OWF
- **Direct Download:** https://dataverse.harvard.edu/api/access/datafile/4149926 
- **Cost:** Free, publicly available
- **License:** Creative Commons Attribution-CC0 1.0 Universal Public Domain Dedication
- **Registration:** Not required
- **Access Date:** Data accessed October 2020

**Citation:** Solt, Frederick, 2019, "The Standardized World Income Inequality Database, Versions 8-9", https://doi.org/10.7910/DVN/LM4OWF, Harvard Dataverse, V14 

**Files:**
- `swiid9_0_summary.csv`

#### 10. Varieties of Democracy (V-Dem)

**Location:** `datastore/raw/vdem/`

**Data Description:** Comprehensive and detailed democracy ratings including:
- Electoral Democracy Index
- Regimes of the World & Regime Information
- Physical Violence & Political Violence Index
- Mass Mobilizations & Mass Mobilizations for Democracy
- Civil Society Organization Anti-System Movements & Character
- Equal Distribution of Resources Index
- Public Sector Corruption Index
- Executive Bribery & Corrupt Exchanges

**Access Instructions:**
- **URL:** https://v-dem.net/
- **Direct Download:** https://dataverse.harvard.edu/api/access/datafile/4149926 
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed March 2020

**Citation:**
- Coppedge, Michael, John Gerring, Carl Henrik Knutsen, Staffan I. Lindberg, Svend-Erik Skaaning, Jan Teorell, David Altman, Michael Bernhard, M. Steven Fish, Agnes Cornell, Sirianne Dahlum, Haakon Gjerløw, Adam Glynn, Allen Hicken, Joshua Krusell, Anna L¨uhrmann, Kyle L. Marquardt, Kelly McMann, Valeriya Mechkova, Juraj Medzihorsky, Moa Olin, Pamela Paxton, Daniel Pemstein, Josefine Pernes, Johannes von R¨omer, Brigitte Seim, Rachel Sigman, Jeffrey Staton, Natalia Stepanova, Aksel Sundstr¨om, Eitan Tzelgov, Yi-ting Wang, Tore Wig, Steven Wilson, and Daniel Ziblatt. 2018. "V-Dem Dataset v8" Varieties of Democracy (V-Dem) Project.
- Pemstein, Daniel, Kyle L. Marquardt, Eitan Tzelgov, Yi-ting Wang, Joshua Krusell and Farhad Miri. 2018. "The V-Dem Measurement Model: Latent Variable Analysis for Cross-National and Cross-Temporal Expert-Coded Data". University of Gothenburg, Varieties of Democracy Institute: Working Paper No. 21, 3d edition

**Files:**
- `V-Dem-CY+Others-v8.dta`
- `V-Dem-CY-Full+Others-v10.dta`

##### 10.1 Episodes of Regime Transformation (ERT)

**Location:** `datastore/raw/regime_change/`

**Data Description:** Identifies episodes of democratization (liberalizing autocracy, democratic deepening) and autocratization (democratic regression, autocratic regression) in the V-Dem datasets.

**Access Instructions:**
- **URL:** https://www.v-dem.net/data/ert-dataset/
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed January 2021

**Citation:** Edgell, Amanda B., Seraphine F. Maerz, Laura Maxwell, Richard Morgan, Juraj Medzihorsky, Matthew C. Wilson, Vanessa Boese, Sebastian Hellmeier, Jean Lachapelle, Patrik Lindenfors, Anna L¨uhrmann, and Sta↵an I. Lindberg. (2020). Episodes ofRegime Transformation Dataset (v2.0) Codebook.

**Files:**
- `ERT.csv`

##### 10.2 Successful Democratizations

**Location:** `datastore/raw/regime_change/`

**Data Description:** Identifies countries that successfully or failed to transition to democracy from the V-Dem datasets.

**Access Instructions:**
- **URL:** https://www.v-dem.net/data/ert-dataset/
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed January 2021

**Citation:** Lindberg, Staffan I., Patrik Lindenfors, Anna L ¨uhrmann, Laura Maxwell, Juraj Medzihorsky, Richard Morgan, and Matthew Charles Wilson, “Successful and Failed Episodes of Democratization: Conceptualization, Identification, and Description,” 2018. V-Dem Working Paper 2018:79.

**Files:**
- `vod_democratizations.csv`

#### 11. World Income Inequality Database (WIID)

**Location:** `datastore/raw/wiid/`

**Data Description:** Country-level income inequality data.

**Access Instructions:**
- **URL:** https://www.wider.unu.edu/database/world-income-inequality-database-wiid
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed May 2021

**Citation:**
UNU-WIDER, World Income Inequality Database (WIID) Companion dataset (wiidcountry and/or wiidglobal). Version 31 May 2021. https://doi.org/10.35188/UNU-WIDER/WIIDcomp-310521

**Files:**
- `wiidcountry.dta`

#### 12. Wharton Research Data Services (WRDS)

**Location:** `datastore/raw/wrds/`

**Data Description:** Financial markets data including:
- Factset  Annual Fiscal
- IBES Global Actuals

**Access Instructions:**
- **URL:** https://wrds-www.wharton.upenn.edu/
- **Cost:** Institutional subscription required
- **Registration:** Requires WRDS account at subscribing institution
- **Restrictions:** Data access restricted to authorized users; cannot be shared publicly
- **Access Date:** Data accessed May 2022
- **Documentation:** https://wrds-www.wharton.upenn.edu/pages/support/

**Note:** WRDS requires an institutional subscription. Independent researchers should contact their institution's library or WRDS directly (wrds@wharton.upenn.edu) to inquire about access. Academic trial accounts are available for faculty at qualifying institutions.

**Citation:**
- FactSet Research Systems, Inc. (2022). "Factset - Annual Fiscal v3 (International - NON US and Canada)".  Accessed via Wharton Research Data Services (WRDS). Available at: https://wrds-www.wharton.upenn.edu/pages/get-data/factset/fundamentals-international-v3/annual-fiscal/

![ibes wrds](ibes_wrds.png "WRDS IBES Query")

- LSEG Institutional Brokers' Estimate System (I/B/E/S) (2022). "IBES Global Aggregates Actuals". Accessed via Wharton Research Data Services (WRDS). Available at: https://wrds-www.wharton.upenn.edu/pages/get-data/lseg-ibes/ibes-global-aggregates/global-aggregates/actuals

![factset wrds](factset_wrds.png "WRDS Factset Query")

**Files:**
- `factset_annual_fiscal.dta`
- `ibes_global_actual.dta`

#### 13. World Bank's World Development Indicators (WDI)

**Location:** `datastore/raw/fdi/`

**Data Description:** Data on foreign direct investment from World Bank's World Development Indicators (WDI) reported by the International Monetary Fund (IMF).

**Access Instructions:**
- **URL:** https://www.worldbank.org/ext/en/home
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed December 2022

**Citation:**
- World Bank. "Foreign Direct Investment, Net Inflows (% of GDP)." World Development Indicators. Last modified September 16, 2022. https://data.worldbank.org/indicator/BX.KLT.DINV.WD.GD.ZS.
- World Bank. "Foreign Direct Investment, Net Outflows (% of GDP)." World Development Indicators. Last modified September 16, 2022. https://data.worldbank.org/indicator/BM.KLT.DINV.WD.GD.ZS.

**Files:**
- `fdi_inflows_raw.csv`
- `fdi_outflows_raw.csv`

#### 14. World Religion Dataset (WRD)

**Location:** `datastore/raw/cow/religion/`

**Data Description:** Detailed information about religious adherence worldwide since 1945. It contains data about the number of adherents by religion in each of the states in the international system. 

**Access Instructions:**
- **URL:** https://correlatesofwar.org/data-sets/world-religion-data/
- **Cost:** Free, publicly available
- **Registration:** Not required
- **Access Date:** Data accessed February 2019
- **Documentation:** https://correlatesofwar.org/wp-content/uploads/wrp-codebook-bibliography.pdf

**Citation:** Zeev Maoz and Errol A. Henderson. 2013. “The World Religion Dataset, 1945-2010: Logic, Estimates, and Trends.” International Interactions, 39: 265-291.

**Files:**
- `WRP_national.csv`

#### 15. Data from Published Papers and Other Events

**Location:** `datastore/raw/other_events/`

**Data Description:** Data extracted from replication files of published academic papers, including financial crisis dates, sovereign default events, assassinations of heads of government, and country name crosswalks.

##### 15.1 Acemoglu et al. (2019) - Democratic Transitions

**Citation:** Acemoglu, Daron, Suresh Naidu, Pascual Restrepo, and James A. Robinson. “Democracy Does Cause Growth.” Journal of Political Economy 127, no. 1 (2019): 47–100. https://doi.org/10.1086/700936.

**Access Instructions:**
- **URL:** https://knowledge.uchicago.edu/record/13708?ln=en&v=pdf
- **Cost:** Free, publicly available
- **Access Date:** 
- **Direct Download:** https://knowledge.uchicago.edu/record/13708/files/2014340data.zip?ln=en

**Files:**
- `DDCGdata_final.dta`

##### 15.2 Reinhart and Rogoff (2009) - Financial Crises & Sovereign Defaults

**Citation:** Reinhart, Carmen & Rogoff, Kenneth. (2009). This Time Is Different: Eight Centuries of Financial Folly. 10.2307/j.ctvcm4gqx.

**Access Instructions:**
- **URL:** https://carmenreinhart.com/
- **Cost:** Free, publicly available
- **Access Date:** Data accessed June and August 2019
- **Data File:** https://carmenreinhart.com/data/

**Files:**
- `reinhart_rogoff_defaults.dta`
- `reinhart_rogoff_financial_crisis.csv`

##### 15.3 Jones and Olken (2009) - Assassinations

**Citation:** Jones, Benjamin F., and Benjamin A. Olken. 2009. "Hit or Miss? The Effect of Assassinations on Institutions and War." American Economic Journal: Macroeconomics, 1(2): 55–87.

**Access Instructions:**
- **URL:** https://www.openicpsr.org/openicpsr/project/114047/version/V1/view
- **Direct Download:** https://www.openicpsr.org/openicpsr/project/114047/version/V1/download/terms;jsessionid=C23376E9D5051B826CE5FA3202A7DCB7?path=/openicpsr/114047/fcr:versions/V1&type=project
- **Cost:** Free, publicly available
- **Access Date:** Data accessed August 2019

**Files:**
- `assassinations_data.dta`

##### 15.4 Other Files

###### 15.4.1 Wikipedia

**Citation:** Wikipedia. "List of heads of state and government who died in office." Wikimedia. https://en.wikipedia.org/wiki/List_of_heads_of_state_and_government_who_died_in_office 

**Access Instructions:**
- **URL:** https://en.wikipedia.org/wiki/List_of_heads_of_state_and_government_who_died_in_office
- **Cost:** Free, publicly available
- **Access Date:** Data accessed Jan 2020

**Files:**
- `HOG_death.csv`

#### 16. Country Code Crosswalks

**Location:** `datastore/raw/crosswalks/`

**Data Description:** Mapping files for converting between different country code systems (ISO3, ISO2, CoW codes, IBES codes) and regional classifications used to harmonize data across sources. Compiled by author.

**Files:**
- `country_name_to_iso3.csv`
- `cow_country_codes_to_iso3.csv`
- `ibes_country_to_iso3_codes.csv`
- `icb_country_code_to_iso3.csv`
- `iso2_codes_to_iso3_codes.csv`
- `region_map.dta`
- `valid_iso3_codes.dta`

#### 17. Regime Change Data

**Location:** `datastore/raw/regime_change/`

**Data Description:** Datasets on episodes of democratization and regime transformation, including historical event dates and classifications. Compiled by author with data source listed in dataset.

**Files:**
- `historical_events_for_democratization.csv`


### Analysis Data (Derived Datasets)

All analysis datasets are stored in `datastore/derived/` and are generated from the raw data sources described above through automated processing scripts located in `source/derived/`. These derived datasets are **included in the replication package** and can be regenerated by running `scons` from the project root directory.

**Availability:** All derived analysis datasets are included in the replication package.

#### Model-Generated Data

**Location:** `datastore/derived/model/`

**Description:** Theoretical predictions and calibration outputs from four structural models presented in the paper. Each model subdirectory contains model-specific parameters, equilibrium solutions, and comparative statics results formatted for tables and figures.

**Generation:** Created by model solution scripts in `source/derived/model/`. Models are solved numerically using specified parameter values and economic primitives.

### Data Processing Pipeline

All derived datasets in `datastore/derived/` are generated from raw data sources through an automated build process:

1. **Data Cleaning:** Scripts in `source/derived/01_events/`, `source/derived/02_macro_political`, `source/derived/03_assets`, `source/derived/04_merging` process raw data files
2. **Model Creation:** Scripts in `source/derived/model/` create models  
3. **Tables and Figures:** Final outputs generated in `source/tables/` and `source/figures/`

The complete data processing pipeline can be reproduced by running `uv run scons` from the project root directory. All intermediate processing steps are documented in the respective `SConscript` files located in the source directories.

### Non-Public Data Statement

Two data sources (GFD/Finaeon and WRDS) require paid institutional subscriptions and cannot be shared publicly due to licensing restrictions:

1. **Global Financial Data (GFD/Finaeon):** All GFD data require a subscription. Academic researchers can contact Finaeon for institutional licensing: https://finaeon.com/

2. **WRDS:** Factset and IBES data require a WRDS subscription. Academic researchers should contact their institution's library or WRDS directly: wrds@wharton.upenn.edu. Faculty at qualifying academic institutions can request trial access.

All other data sources are publicly available at no cost.

### Data Citation

When using data from this replication package, please cite both this paper and the original data sources as listed above, following each source's specific citation requirements.

## Computational requirements

### Software Requirements

- [x] The replication package contains one or more programs to install all dependencies and set up the necessary directory structure.

- pdflatex (e.g., via [TeX Live](https://www.tug.org/texlive/): `brew install --cask mactex` on macOS, `apt install texlive-full` on Linux)
- [uv](https://docs.astral.sh/uv/) (for Python dependency management and running SCons)
- Stata (code was last run with version 19)
  - `estout` (v3.24), `esplot` (v0.10.2), `ftools` (v2.49.1), `reghdfe` (v5.9.0), `ivreg2` (v4.1.12), `ivreghdfe` (v1.0.0), `winsor2` (v1.1), `asreg` (v4.8), `rangestat` (v1.1.1), `gtools` (v1.5.1)
  - All Stata dependencies are vendored in `source/utils/analysis/` at the exact versions listed above. No network install is needed.
  - To install fresh copies instead, run `do source/lib/requirements.do` in Stata (optional).
- Python >=3.11, <3.13
  - `scipy` == 1.16.0
  - `matplotlib` == 3.10.5
  - `numpy` == 1.26.4
  - `pandas` == 2.2.2
  - `pyyaml` == 6.0.1
  - `scons` == 4.8.1
  - Dependencies are managed via `pyproject.toml` at the project root. Run `uv sync` to install all necessary dependencies.

### Memory, Runtime, Storage Requirements

#### Summary time to reproduce

Approximate time needed to reproduce the analyses on a standard (2025) desktop machine:

- [ ] <10 minutes
- [x] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] > 14 days

#### Summary of required storage space

Approximate storage space needed:

- [ ] < 25 MBytes
- [ ] 25 MB - 250 MB
- [ ] 250 MB - 2 GB
- [x] 2 GB - 25 GB
- [ ] 25 GB - 250 GB
- [ ] > 250 GB

#### Computational Details

The code was last run on a **10-core Intel-based laptop with WindowsOS version 11 Enterprise with 50GB of free space**. Computation took **21 minutes**

### License for Code

The code is licensed under a MIT license. See [LICENSE](LICENSE) for details.

## List of tables and programs

The provided code reproduces:

- [x] All numbers provided in text in the paper
- [x] All tables and figures in the paper
- [x] Selected tables and figures in the paper, as explained and justified below.


| Figure/Table #    | Program                                                      | Output file                                      | Note                            |
|-------------------|--------------------------------------------------------------|--------------------------------------------------|----------------------------------|
| **Main Tables** | Programs in: `source/analysis/main/tables/` | Output in `source/tables/raw` | |
| Table 1           | 01_table_1_change_in_log_dividend_yield.do                                 | table_1_change_in_log_dividend_yields.tex      |                                  |
| Table 2           | 02_table_2_cashflow_growth.do                                             | table_2_cashflow_growth.tex                  |                                  |
| Table 3           | 03_table_3_democratization_vs_other_political_risk.do                                         | table_3_democratization_vs_other_political_risk.tex              |                                  |
| Table 4           | 04_table_4_revolution_risk.do                                | table_4_revolution_risk.tex     |                                  |
| Table 5           | 05_table_5_regional_waves_instrument.do                              | table_5_regional_waves_instrument.tex   |                                  |
| Table 6           | 06_table_6_balance_tests.do                                          | table_6_balance_tests.tex               |                                  |
| Table 7           | 07_table_7_did_results.do                                            | table_7_did_results.tex                |                                  |
| Table 8           | 08_table_8_explicit_redistribution.do                                | table_8_explicit_redistribution.tex    |                                  |
| Table 9           | 09_table_9_implicit_redistribution.do                                | table_9_implicit_redistribution.tex    |                                  |
| Table 10          | 10_table_10_high_vs_low_redistribution_risk.do                                            | table_10_high_vs_low_redistribution_risk.tex                 |                                  |
| Table 11          | 11_table_11_model_calibration.py                                | table_11_model_calibration.tex          | Python script                    |
| Table 12          | 12_table_12_model_results.py                              | table_12_model_results.tex                  | Python script                    |
| **Main Figures** | Programs in: `source/analysis/main/figures/` | Output in `source/figures/raw` | |
| Figure 1          | 01_figure_1_dividend_yield_event_study.do                             | figure_1_dividend_yield_event_study.pdf |                                  |
| Figure 2          | 02_figure_2_physical_human_capital.do                                 | figure_2_physical_human_capital.pdf      |                                  |
| Figure 3          | 03_figure_3_gdp_consumption_distributions.do                          | figure_3a_gdp_growth_distribution.pdf, figure_3b_consumption_growth_distribution.pdf |                                  |
| Figure 4          | 04_figure_4_regional_waves.do                                         | figure_4_regional_waves.pdf             |                                  |
| Figure 5          | 05_figure_5_anti_regime_event_study.do                                    | figure_5a_event_study_anti_system_cso.pdf, figure_5b_event_study_democratic_protests.pdf |                                  |
| Figure 6          | 06_figure_6_returns_event_study.do                                | figure_6_did_event_study_returns.pdf    |                                  |
| Figure 7          | 07_figure_7_dividend_yield_coefficients_over_time.do                                 | figure_7_coefficients_over_time.pdf     |                                  |
| Figure 8          | 08_figure_8_autocratization_figure.py                           | figure_8_autocratization_model.pdf                    | Python script                    |
| **Appendix Tables** | Programs in: `source/analysis/appendix/tables/` | Output in `source/tables/raw` | |
| Table A1          | 01_table_A1_summary_statistics.do                              | table_A1_summary_statistics.tex |                                  |
| Table B2          | 02_table_B2_adverse_dividend_growth.do                         | table_B2_adverse_dividend_growth.tex |                                  |
| Table B3          | 03_table_B3_risk_premium.do                                    | table_B3_risk_premium.tex |                                  |
| Table B4          | 04_table_B4_macro_political_risk_measures.do                   | table_B4_macro_political_risk_measures.tex |                                  |
| Table B5          | 05_table_B5_adverse_probability.do                             | table_B5a_adverse_probability_all.tex, table_B5b_adverse_probability_div_yld.tex |                                  |
| Table B6          | 06_table_B6_democratize_risk_measures.do                       | table_B6_democratize_risk_measures.tex |                                  |
| Table C7          | 07_table_C7_probability_democratize_post_vatican_ii.do         | table_C7_probability_democratize_post_vatican_ii.tex |                                  |
| Table C8          | 08_table_C8_vatican_i.do                                       | table_C8_did_first_vatican.tex |                                  |
| Table C9          | 09_table_C9_catholic_democracies.do                            | table_C9_did_democracies.tex |                                  |
| Table C10         | 10_table_C10_removing_outliers.do                              | table_C10a_removing_outliers_short_sample.tex, table_C10b_removing_outliers_long_sample.tex |                                  |
| Table C11         | 11_table_C11_outlier_robust_weights.do                         | table_C11_did_robust_weights.tex |                                  |
| Table C12         | 12_table_C12_global_capm.do                                    | table_C12_did_global_capm.tex |                                  |
| Table C13         | 13_table_C13_no_rolling_beta.do                                | table_C13_did_no_rolling_beta.tex |                                  |
| Table C14         | 14_table_C14_home_country_bonds.do                             | table_C14_did_results_country_bonds.tex |                                  |
| Table C15         | 15_table_C15_capital_gains_control.do                          | table_C15_did_capital_gains.tex |                                  |
| Table D16         | 16_table_D16_inequality_price_decline.do                       | table_D16_inequality_price_decline.tex |                                  |
| Table G17         | 17_table_G17_ert_democracy.py                                  | table_G17_democratizations_and_history.tex | Python script                    |
| **Appendix Figures** | Programs in: `source/analysis/appendix/figures/` | Output in `source/figures/raw` | |
| Figure B1         | 01_figure_B1_democracy_log_price.do                            | figure_B1a_log_price_event_study.pdf, figure_B1b_log_dividend_growth_event_study.pdf, figure_B1c_log_gdp_per_capita_event_study.pdf |                                  |
| Figure B2         | 02_figure_B2_democracy_dividend_yield_specs.do                 | figure_B2_dividend_yield_event_study_1.pdf through figure_B2_dividend_yield_event_study_4.pdf |                                  |
| Figure C3         | 03_figure_C3_cso_activity_vs_mobilizations.do                  | figure_C3_democracy_activity_mobil.pdf |                                  |
| Figure C4         | 04_figure_C4_sample_period_move.do                             | figure_C4a_country_pair_falsification.pdf, figure_C4b_country_pair_falsification_aut.pdf |                                  |
| Figure C5         | 05_figure_C5_window_end_date.do                                | figure_C5a_window_end_date_all.pdf, figure_C5b_window_end_date_aut.pdf |                                  |
| Figure C6         | 06_figure_C6_country_pair_1946_1976.do                         | figure_C6a_country_pair_PE_short.pdf, figure_C6a_country_pair_T_short.pdf, figure_C6b_country_pair_PE_short_aut.pdf, figure_C6b_country_pair_T_short_aut.pdf |                                  |
| Figure C7         | 07_figure_C7_country_pair_1939_1983.do                         | figure_C7a_country_pair_PE_long.pdf, figure_C7a_country_pair_T_long.pdf, figure_C7b_country_pair_PE_long_aut.pdf, figure_C7b_country_pair_T_long_aut.pdf |                                  |
| Figure C8         | 08_figure_C8_dividend_yield_event_study.do                     | figure_C8_dividend_yield_event_study.pdf |                                  |
| Figure D9         | 09_figure_D9_explicit_redistribute_event_study.do              | figure_D9a_explicit_redistribute_event_study_govt_rev_gdp.pdf, figure_D9b_explicit_redistribute_event_study_swiid.pdf |                                  |
| Figure D10        | 10_figure_D10_democratization_end_price_response.do            | figure_D10a_democratize_price_response_succ.pdf, figure_D10b_democratize_price_response_ld.pdf |                                  |
| Figure F12        | 11_figure_F12_sweden_case_study.do                             | figure_F12_sweden_case_study.pdf |                                  |
| Figure F13        | 12_figure_F13_france_case_study.do                             | figure_F13_france_case_study.pdf |                                  |

---

## Acknowledgements

Some content on this page was copied from [Hindawi](https://www.hindawi.com/research.data/#statement.templates). Other content was adapted  from [Fort (2016)](https://doi.org/10.1093/restud/rdw057).