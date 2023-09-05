 *------------------------------------------------------------------------------*  
/*
Title: Spring 2023 UVA SITE Randomization and merge with baseline data 
Authors: Steffen Erikson 
Date: 8/18/23
*/ 
 *------------------------------------------------------------------------------*
 
 
* Dependencies 
do code/00_randomize_program.do


*frames 
mkf ud_tracker

*------------------------------------------------------------------------------*
* Merge Files 
*------------------------------------------------------------------------------*

frame ud_tracker {
	import excel "trackers_data/S23 UD Data Tracker.xlsx", sheet("S23_ UD Data Tracker") firstrow case(lower) clear
	drop if participantid == ""
	rename emailaddress d11_3
	frame baseline_demographics  {
		tempfile data
		save `data'
	}	
	merge 1:1 d11_3 using `data'
	drop if _merge != 3
	drop _merge 
	
	*Removing non-consenters for randomization 
	tab consent 
	list participantid d11_3 consent if consent == "No"
	drop if consent == "No" 
}


*------------------------------------------------------------------------------*
* Randomization
*------------------------------------------------------------------------------*

frame ud_tracker: randomize coaching, id(participantid) arms(2) by(section) seed(671286)  /*genfile(firstname lastname recipientemail)*/
frame ud_tracker: keep coaching participantid d* site section
frame ud_tracker: frame put _all, into(ud_randomize_final_2)
frame drop ud_tracker  






