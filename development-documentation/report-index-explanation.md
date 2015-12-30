# Explanation of the Site's Report Index

There are ~18 subaims in our 2011 project, and at least another dozen in our upcoming project.  Some subaims will have multiple reports (eg, 3A), and some reports apply to multiple aims.  This creates a many-to-many relationship.  Even worse, some reports will be used by multiple projects.  All this suggests the info needs to be in a relational database (in this case, SQLite, located in [.\reports\report_index.sqlite3](.\reports\report_index.sqlite3).  

These two pages below comes from Rmd files that read the database, and display the reports in two different ways.  In the first page, you look up the Aim to find the associated report(s).  In the second page, the reports are indexed (and I may later list the Aim(s) associated with them).  The `tblReport` entries in the database determine the paths underneath each hyperlink.

  * http://ouhscbbmc.github.io/MReportingPublic/research_2011a.html
  * http://ouhscbbmc.github.io/MReportingPublic/report_index.html

To create the database, run the file https://github.com/OuhscBbmc/MReportingPublic/tree/gh-pages/reports/create_index/create_report_index.R.  It reads the values in the different CSVs in that directory (one CSV per database table), and writes to SQLite.  Although it's somewhat redundant to have the data in two places (ie, the CSVs and the database), I thought each merited inclusion.  The CSVs make it easier to track progress over time (because their text content is easily diffed by Git).  The database makes it easier to enforce the referential integrity, so some report can't be associated with an aim that doesn't exist.  After you add a new row to one of the CSVs, run `create_report_index.R`.  This file will:

  1. delete the the whole database
  2. recreate its objects and relationships, and
  3. transfer data from the CSVs into the database.

The two Rmd files currently used the same 'codebehind' R file (although this will probably change).  The [first Rmd](./research_2011a.html) uses a nested structure and embeds the reports in markdown language.  A report is nested within a Subaim, which is nested in an Aim.  I'm not thrilled with the current aesthetics, but I'm waiting until its more complete before I tweak the style.  The [second Rmd](./report_index.html) is much simpler; it calls a simpler database view/query and dumps it into a table created by knitr::kable.  https://github.com/OuhscBbmc/MReportingPublic/blob/gh-pages/research_2011a.R
