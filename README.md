# CA-Homeownership
This repository contains instructions, raw data, and Stata scripts for replicating the results from the analysis of California homeownership data contained in the [accompanying issue brief](https://youngamericans.berkeley.edu/2024/08/young-adults-and-the-decline-of-homeownership-in-california/). This repository also includes all output and accompanying estimates.

## Repository Structure

### [Scripts](https://github.com/jamesohawkins/California-Homeownership/tree/main/Scripts)
The Stata scripts for this repository can be found in the scripts folder. All scripts for this repository can be run from 00_script-control.do. To run these scripts, users will need to set their directory in 00_script-control.do. Furthermore, users will need to set up Python on their system and define their IPUMS API key in 00_script-control.do if they intend to access IPUMS-CPS data via the API (see [Raw-data](#raw-data)).

### [Raw-data](https://github.com/jamesohawkins/SCF-Comparison/tree/main/Raw-Data)

#### Homeownership analysis
Any analysis based on homeownership in California or outside of the state is based on microdata available from [IPUMS-USA](https://usa.ipums.org/usa/index.shtml). Access to IPUMS-USA requires creating an account and agreeing to their user agreement. They also place restrictions on publicly disseminating their data; therefore, replication of this analysis requires accessing data either through the [IPUMS API](https://developer.ipums.org/docs/v2/apiprogram/) (the method implemented in my scripts) or directly through the IPUMS-USA extract system. If the API is used, the user will need to obtain an IPUMS API key. See instructions in 01_script-control.do on how to define your API key in the scripts. If the extract system is used, the user can ignore certain sections in 01_wrangling.do and edit the script to directly access their own IPUMS-USA extract.

#### Commuting zone analysis
I take inspiration from [Hoxie, Shoag, & Veuger (2023)](https://www.sciencedirect.com/science/article/pii/S0047272723000889#fn6). I delineate California commuting zones based on publicly available data from [David Dorn](https://www.ddorn.net/data.htm#Local%20Labor%20Market%20Geography). Specifically, I use the E2, E3, E4, E5, and E6 crosswalk files from Dorn's site, which download as a zip file containing cw_ctygrp1970_czone_corr.dta, cw_ctygrp1980_czone_corr.dta, cw_puma1990_czone, cw_puma2000_czone.dta, and cw_puma2010_czone.dta, respectively. I use density data (1970) from David Autor's [replication data](https://www.openicpsr.org/openicpsr/project/116495/version/V1/view) for [Autor (2019)](https://www.aeaweb.org/articles?id=10.1257/pandp.20191110). Specifically, I use the workfile5015.dta file from this replication data.

#### Permits for every thousand residents analysis
I use resident population data for the United States from [USAFacts](https://usafacts.org/data/topics/people-society/population-and-demographics/population-data/population/) and for California from [FRED](https://fred.stlouisfed.org/series/CAPOP) (originally sourced from the U.S. Census Bureau). Permits data come from the [U.S. Census Bureau](https://www.census.gov/construction/bps/visualizations/datatool/index.html).

### [Derived-data](https://github.com/jamesohawkins/SCF-Comparison/tree/main/Derived-Data)
Empty folder where wrangled data is stored.

### [Output](https://github.com/jamesohawkins/SCF-Comparison/tree/main/Output)
Contains all output (visualizations and csv files) from the analysis.
