---
title: C1 Data Dictionary
author: Will Beasley (OU) & John Delara (OSDH)
date: 2015-06-11
output:
  html_document:
    keep_md: yes
    toc: yes
---

These datasets are regularly downloaded from the Business Objects feature of ETO.  They live only in the temporary cache of the reporting server (and not available publically in the repository).

`c1-visit`
==========================
Each row represents a single scheduled visit by a C1 nurse to a client.  It's underlying source is `OK Participant Encounter Universe`, based on the "Participant" Subject Area ("This universe combine demographics, program enrollment, caseload and the encounter form information.").  

| Variable | Description | Type |
| :------- | :---------- | :--- |
|`Program Unique Identifier` | Program ID (this is effectively a County ID for C1) | Integer
|`Entity Site Identifier` | Nurse ID. | Integer
|`Case Number` | ID of the client in ETO. | Integer
|`PHOCIS ID` | ID of the client in the older PHOCIS database (in case the worlds need to be linked). | Integer
|`Staff Site Identifier` | ? | Integer
|`Case Worker` | Nurse Name. | String
|`Reason For Dismissal` | Indicates if dismissed or graduated | String
|`Program Name` | Program Name | String
|`OSIIS ID` | ? | String
