//----------------------------------------------------------------------------//
// Data Cleaning For Measurement Analysis 

//----------------------------------------------------------------------------//
clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement"
global datapull "/Users/steffenerickson/Documents/GitHub/NSF_Code/01_project_managment/_pull_data.do"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/02_measurement/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "data"
global output   "output"
global nlp      "nlp_scoring_data"
do ${datapull}

//-----------------------------------------------------------------------------//
// Sim Rubric performance task scores
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric1 , replace
frame change simrubric1

* Data set up 
keep x1-x6 site semester participantid task dc time coaching
recode task (4 = 1) (5 = 2) (6 = 3)
drop if task == .
drop if time == 2
egen dupes = tag(participantid site semester time dc task)
tab dupes
drop if dupes == 0

* reshape to a wide format 
reshape wide x1-x6 , i(participantid site semester time dc) j(task)
reshape wide x?? , i(participantid site semester dc) j(time)
reshape wide x???   , i(participantid site semester) j(dc)

merge 1:1 participantid site semester using "${root}/${data}/aidata.dta"
drop _merge

rename x???c x???3

*rater 
local varlist
foreach v of var x* {
	local temp = substr("`v'",1,4)
	local varlist: list varlist | temp 
}
reshape long `varlist', i(participantid site semester) j(rater)

*time 
local varlist
foreach v of var x* {
	local temp = substr("`v'",1,3)
	local varlist: list varlist | temp 
}
reshape long `varlist', i(participantid site semester rater) j(time)

*task 
local varlist
foreach v of var x* {
	local temp = substr("`v'",1,2)
	local varlist: list varlist | temp 
}
reshape long `varlist', i(participantid site semester rater time) j(task)


label values rater none

save "${root}/${data}/manova_data.dta" , replace

