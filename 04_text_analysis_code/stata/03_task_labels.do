//----------------------------------------------------------------------------//
// Data Cleaning For Measurment Analysis 

//----------------------------------------------------------------------------//
clear all
* Pull Study Data  
do /Users/steffenerickson/Desktop/repos/collab_rep_lab/nsf_v2/_pull_data.do 
frame dir 

global root "/Users/steffenerickson/Desktop/spring2024/qpp/text"
global output "data"
cd ${root}

//-----------------------------------------------------------------------------//
// Sim Rubric performance task scores
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric1 , replace
frame change simrubric1

* Data set up 
keep x1-x6 site semester participantid task time coaching
drop if task == . 
collapse x* , by(site semester participantid task time coaching)
label define t 1 "P1" 2 "P2" 3 "P3" 4 "P4" 5 "P5" 6 "P6" 7 "Placement" , modify
label values task t 

foreach v in site semester task {
	decode `v', gen(`v'2)
	drop `v'
	rename `v'2 `v'
}

rename participantid person 
rename semester course 
gen personid = site + "_" + course + "_" + person

rename (x1 x2 x3 x4 x5 x6) (objective unpacking selfinstruction selfregulation ending accuracy)

save ${output}/task_labels.dta , replace

