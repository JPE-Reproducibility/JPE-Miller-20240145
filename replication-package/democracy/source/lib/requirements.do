* =============================================================================
* Stata Package Installation
* =============================================================================
* NOTE: All packages below are vendored in source/utils/analysis/ at the
* exact versions used for published results. Running this script is OPTIONAL
* and will install the latest versions from SSC/GitHub, which may differ.
*
* Vendored versions (in source/utils/analysis/):
*   esplot       0.10.2   (2jun2021)     - SSC
*   estout       3.24     (30apr2021)     - SSC (includes esttab, estadd, eststo)
*   ftools       2.49.1   (08aug2023)    - GitHub sergiocorreia/ftools
*   reghdfe      5.9.0    (03jun2020)    - GitHub sergiocorreia/reghdfe
*   ivreg2       4.1.12   (14aug2024)    - SSC (includes ranktest, waldtest)
*   ivreghdfe    1.0.0    (07jul2018)    - GitHub sergiocorreia/ivreghdfe
*   winsor2      1.1      (2014.12.16)   - SSC
*   asreg        4.8      (02jul2023)    - SSC
*   rangestat    1.1.1    (09may2017)    - SSC
*   gtools       1.5.1    (24mar2019)    - SSC (includes gcollapse, greshape)
* =============================================================================

* Install preliminaries (gslab utility)
net from https://raw.githubusercontent.com/gslab-econ/gslab_stata/master/gslab_misc/ado
net install preliminaries, replace

* Install esplot for event study plots (vendored: v0.10.2)
ssc install esplot, replace

* Install ftools (vendored: v2.49.1)
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install estout (vendored: v3.24)
ssc install estout, replace

* Install winsor2 (vendored: v1.1)
ssc install winsor2, replace

* Install reghdfe (vendored: v5.9.0)
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

* Install ivreg2 (vendored: v4.1.12)
cap ado uninstall ivreg2
ssc install ivreg2

* Install ivreghdfe (vendored: v1.0.0)
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)

* Install asreg (vendored: v4.8)
ssc install asreg, replace

* Install rangestat (vendored: v1.1.1)
ssc install rangestat, replace

* Install gtools (vendored: v1.5.1)
ssc install gtools, replace