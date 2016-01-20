---
title: "County-Level Data"

---

***
***
# Purpose

These datasets are made available to assist other researchers investigating the factors affecting Oklahoma families.  If you have questions, please post a comment at the bottom of this page.

***
***
# Datasets
The following datasets have one row for each Oklahoma County.

***
## County Characteristics
[Download compressed dataset](./data-phi-free/CountyCharacteristics.zip).

The dataset indicates a county's characteristics, with the following fields:

| Variable Name | Type | Variable Description |
| :------------ | :--- | :------------------- |
| CountyID | integer | Alphabetically-ordered ID of a county.  Notice that `Mc` precedes `M`. |
| CountyName | string | The name of the county. |
| GeoID | integer | The county's FIPS code, which is useful for merging with Census data, or cartographic polygons. |
| FundingC1 | bit | Indicates if the county receives funding for C1. |
| FundingOcap | bit | Indicates if the county receives funding for OCAP. |
| C1LeadNurseRegion | integer | Oklahoma's 77 counties are categorized into roughly 20 regions, each with it's own "lead nurse". |
| Urban | bit | Indicates if the county is either Oklahoma or Tulsa (because they operate differently for HV services). |
| LabelLongitude | float | The longitude of a good place to label the county with on a map. |
| LabelLatitude | float | The latitude of a good place to label the county with on a map. |
| MiechvEvaluation | bit | Indicates if the county participates in the 2011 MIECHV "Evaluation Grant". |
| MiechvFormula | bit | Indicates if the county participates in the 2011 MIECHV "Formula Grant". |
| WicNeedPopInfant | integer | The number of "infants in need", as estimated by WIC. |
| WicNeedPopTotal | integer | The number of "people in need", as estimated by WIC. |
| WicYear | integer | The of the WIC estimates of need. |

***
## WIC Estimates of Need
[Download compressed dataset](./data-phi-free/WicNeed.zip).

The dataset countains the WIC Estimates of Need for counties for different years.  [WIC Estimates of Need](http://www.fns.usda.gov/national-and-state-level-estimates-special-supplemental-nutrition-program-women-infants-and-childr-2) are available periodically (*i.e.*, 1998, 2000, 2004, 2005, 2006, 2010, and 2014).  [Loess regression](https://en.wikipedia.org/wiki/Local_regression) (with a [span of 2](https://stat.ethz.ch/R-manual/R-patched/library/stats/html/loess.html)) was used to provide smooth and continuous county estimates for the years through 2016 for many of our longitudinal models.  Furthermore, loess provides stable extrapolations, which is necessary for the years following the last official estimate (*i.e.*, 2014).  Some spatial and longitudinal graphs are available in the [Map Appendix](http://ouhscbbmc.github.io/MReportingPublic/reports/osdh-maps.html).

| Variable Name | Type | Variable Description |
| :------------ | :--- | :------------------- |
| CountyID | integer | Alphabetically-ordered ID of a county.  Notice that `Mc` precedes `M`. |
| Year | integer | The year for the estimates |
| CountyName | string | The name of the county. |
| WomanCount | integer | The number of "women in need", as estimated by WIC. |
| InfantCount | integer | The number of "infants in need", as estimated by WIC. |
| ChildCount | integer | The number of "children in need", as estimated by WIC. |
| TotalCount | integer | The sum of the previous three columns. |
| OfficialSurvey | boolean | Indicates if the survey is available for the specified years. |
| WomanCountLoess | integer | A smoothed (and possibly extrapolated) version of women in need.  See the description of loess above. |
| InfantCountLoess | integer | A smoothed (and possibly extrapolated) version of infants in need.  See the description of loess above. |
| ChildCountLoess | integer | A smoothed (and possibly extrapolated) version of children in need.  See the description of loess above. |
| TotalCountLoess | integer | The sum of the previous three columns.  (Slight rounding errors may be present.) |
