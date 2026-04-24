'''
Purpose: generate table of democratizations used in the asset pricing results
Primary author: Max Miller
Date: 12-05-2025
Details:
'''

# %% ==========================================================================
# Load in modules
# =============================================================================

import pandas as pd
from source.config import ROOT_PATH, DATASTORE_PATH

# ==============================================================================
# Define globals
# ==============================================================================

REGIME_CHANGE_ORIG = DATASTORE_PATH / 'raw/regime_change/orig'
CROSSWALKS = DATASTORE_PATH / 'raw/crosswalks'
ANALYSIS_DERIVED = DATASTORE_PATH / 'derived/analysis'
TABLES_OUTPUT = ROOT_PATH / 'source/tables/raw'

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():

    history = pd.read_csv(REGIME_CHANGE_ORIG / 'historical_events_for_democratization.csv')
    
    dems = (
        pd.read_stata(ANALYSIS_DERIVED / 'section_3_data.dta')
        .assign(
            temp = lambda x: x['year'].where(x['combo_dem_end'] == 1),
            end_year = lambda x: x.groupby('combo_dem_id')['temp'].transform('min'),
        )
        [lambda x: x['combo_dem_minus_start'] == 1]
        [lambda x: x['log_all_div_yld_5yr'].notna()]
        [['country', 'country_name', 'year', 'end_year']]
    )
        

    democratizations = (
        dems
        .merge(history, on=['country', 'year'], how='inner')
    )

    create_tex_file(democratizations)

# =============================================================================
# Create tex file
# =============================================================================

def create_tex_file(democratizations: pd.DataFrame):
    """
    Create a LaTeX table from the fast democratizations data.
    
    Args:
        fastDemocratizations (pd.DataFrame): Fast democratizations data
    """

    outpath = TABLES_OUTPUT / 'table_G17_democratizations_and_history.tex'

    text_file = open(outpath, "wt")
    for i in range(0,len(democratizations)):
        c  = democratizations.country_name[i].replace('United States of America', 'U.S.A.')
        sy = democratizations.year[i]
        ey = democratizations.end_year[i]
        re = democratizations.reason[i]
        footer = r"\ \hline" + "\n"
        parboxHead1 = r"\parbox[t][][t]{2cm}{\centering"
        parboxHead2 = r"\parbox[t][][t]{10cm}{ "
        parboxFooter = r"} \vspace*{.15cm} \\ \hline" + "\n"

        if sy == ey:
            line = c + '  &  ' + parboxHead1 + str(int(sy)) + "} & " + parboxHead2 + re + parboxFooter
        else:
            line = c + '  &  ' + parboxHead1 + str(int(sy)) + '--' + str(int(ey)) + "} & " + parboxHead2 + re + parboxFooter
        n = text_file.write(line)
        
    text_file.close()

# %% ===========================================================================
# Run main function
# ==============================================================================

if __name__ == "__main__":
    main()
# %%
