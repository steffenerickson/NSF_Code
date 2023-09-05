*------------------------------------------------------------------------------*
* Title: NSF data cleaning master do file
* Author: Steffen Erickson
* Date: 8/18/23
*------------------------------------------------------------------------------*
clear all 
frame reset
/*
folder structure  
	  nsf_v2----|
				|---- code 
				|---- demographics_data
				|---- outcome_data
				|---- randomization_files
				|---- rater_assignment_files
				|---- trackers_data		
*/

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Baseline 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
* Pulls from demographics_data folder

* Baseline survey -------------------------------------------------------------*
do code/02_nsf_demographics.do

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Randomizations 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

* Pulls from trackers_data and randomization_files folders 

* Fall Randomizations ---------------------------------------------------------*
do code/03_f22_uva_randomization.do
do code/04_f22_ud_randomization.do
do code/05_f22_append_ud_uva_jmu.do

* Spring Randomizations -------------------------------------------------------*
do code/06_s23_uva_randomization.do
do code/07_s23_ud_randomization.do
do code/08_s23_append_ud_uva_jmu.do

* Append Fall and Spring  -----------------------------------------------------*
frame nsf_fall_baseline_data: frame put _all , into(nsf_baseline_data) 
frame change nsf_fall_baseline_data
frame nsf_baseline_data {
	frame nsf_spring_baseline_data {
		tempfile data 
		save `data'
	}
	append using `data', gen(semester)
	label define sems 0 "F22" 1 "S23"
	label values semester sems 
}

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Rater Assignments and Outcome Data
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
* Pulls from outcome_data folders

* SIM Rubric ------------------------------------------------------------------*

* Sim Rubric data cleaning 
do code/11_simrubric_cleaning.do

* Data Verification 
frame simse_performance_tasks {
gen id_check = _n
bysort participantid site semester rater task time: replace id_check = id_check[1]
egen dupes = tag(id_check)
	* !!!!!!73 duplicates in the collected data !!!!!
drop if dupes == 0
drop id_check dupes 
}
* now checking for duplicates by dc variable instead of rater 
frame simse_performance_tasks {
gen id_check = _n
bysort participantid site semester dc task time: replace id_check = id_check[1]
egen dupes = tag(id_check)
	* !!!!!!7 more  duplicates in the collected data !!!!!
drop if dupes == 0
drop id_check dupes 
}

*merge on double code 
frame nsf_baseline_data: frame put _all, into(performancetask_and_baseline)
frame performancetask_and_baseline {
	frame simse_performance_tasks {
		tempfile data 
		save `data'
	}
	merge 1:m participantid semester site  using `data'
	drop _merge 
}


* MQI -------------------------------------------------------------------------*

* Collected data 
do code/14_mqi_cleaning.do

* Merge MQI with baseline 
frame nsf_baseline_data : frame put _all , into(mqi_and_baseline)
frame mqi{
	preserve
	rename m11_2 site 
	rename m11_3 semester
	rename m11_5 participantid
	drop m11_6 m11_4
	tempfile data 
	save `data'
	restore 
}
frame mqi_and_baseline {
	merge 1:m participantid semester site using `data'
	drop if _merge == 1
	drop _merge 
}

* COSTI -----------------------------------------------------------------------*

* Collected data 
do code/15_costi_cleaning.do

* Merge COSTI with baseline 
frame nsf_baseline_data : frame put _all , into(costi_and_baseline)
frame costi {
	preserve
	rename c11_2 site 
	rename c11_3 semester
	rename c11_5 participantid
	drop c11_6 c11_4
	tempfile data 
	save `data'
	restore 
}
frame costi_and_baseline {
	merge 1:m participantid semester site using `data'
	drop if _merge == 1
	drop _merge 
}

* Self-Efficacy ---------------------------------------------------------------*

* Collected data 
do code/16_final_survey_cleaning.do

* Merge COSTI with baseline 
frame nsf_baseline_data : frame put _all , into(finalsurvey_and_baseline)
frame finalsurvey {
	tempfile data 
	save `data'
}
frame finalsurvey_and_baseline {
	merge m:1 d11_3 using `data'
	drop if _merge == 1
	drop _merge 
}

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Final Frame Management 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

frame change default 

* Drop unneeded frames --------------------------------------------------------*
frame drop nsf_fall_baseline_data ///
		   nsf_spring_baseline_data ///
		   s23_simrubric_raters  ///
		   f22_simrubric_raters  ///
		   baseline_demographics ///
		   costi ///
		   mqi ///
		   mqi ///
		   simrubric_raters_assignments ///
		   simse_performance_tasks ///
		   finalsurvey 
		   
* Link all of the Frames ------------------------------------------------------*		

frame dir    
		   
frame performancetask_and_baseline : frlink m:1 participantid semester site, frame(nsf_baseline_data)  generate(link1)

frame mqi_and_baseline : frlink m:1 participantid semester site, frame(nsf_baseline_data)  generate(link2)
frame costi_and_baseline : frlink m:1 participantid semester site, frame(nsf_baseline_data)  generate(link3)
frame finalsurvey_and_baseline  : drop if participantid == ""
frame finalsurvey_and_baseline  : frlink 1:1 participantid semester site, frame(nsf_baseline_data)  generate(link4)



/*

/*
* Simulation rater assignments 
do code/09_f22_rater_assign.do
do code/10_s23_rater_assign.do
* Append files 
frame f22_simrubric_raters: frame put _all , into(simrubric_raters_assignments)
frame simrubric_raters_assignments {
	frame s23_simrubric_raters {
		tempfile data 
		save `data'
	}
	append using `data', gen(semester)
	label define sems 0 "F22" 1 "S23"
	label values semester semsester 
}

* Classroom Placement rater assignments 
*do code/

* Sim Rubric data cleaning 
do code/11_simrubric_cleaning.do

* Data Verification 

* Check assignments vs collected data 
frame simse_performance_tasks {
gen id_check = _n
bysort participantid site semester rater task time: replace id_check = id_check[1]
egen dupes = tag(id_check)
	* !!!!!!73 duplicates in the collected data !!!!!
drop if dupes == 0
drop id_check dupes 
}
* now checking for dupilcates by dc variable instead of rater 
frame simse_performance_tasks {
gen id_check = _n
bysort participantid site semester dc task time: replace id_check = id_check[1]
egen dupes = tag(id_check)
	* !!!!!!7 more  duplicates in the collected data !!!!!
drop if dupes == 0
drop id_check dupes 
}

* rename and recode for matching
frame simrubric_raters_assignments: rename coder rater
frame simrubric_raters_assignments: rename double_code dc
frame simrubric_raters_assignments: recode task (1 = 4) (2 = 5) (3 = 6) if time == 1

*rename rater variable to compare assign vs. observed raters 
frame simse_performance_tasks: rename rater rater_obs
frame simrubric_raters_assignments: rename rater rater_assign

*merge on double code 
frame simrubric_raters_assignments: frame put _all, into(performancetask_and_baseline)
frame performancetask_and_baseline {
	frame simse_performance_tasks {
		tempfile data 
		save `data'
	}
	merge 1:m participantid semester site dc task using `data'
	keep if _merge != 1 // Keeping placement videos that are not matched currently 
}

*/





