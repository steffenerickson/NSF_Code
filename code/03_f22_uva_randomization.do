*------------------------------------------------------------------------------*  
/*
Title: NSF UVA SITE Randomization and merge with baseline data 
Authors: Steffen Erikson 
Date: 8/18/23
*/ 
mkf uva_tracker 
mkf uva_randomize_temp
*------------------------------------------------------------------------------*
* Merge Files 
*------------------------------------------------------------------------------*

frame uva_tracker {
	import excel "trackers_data/F22 UVA Data Tracker.xlsx", sheet("UVA Data Tracker") firstrow case(lower) clear
	drop if participantid == ""
	rename emailaddress d11_3

	frame baseline_demographics  {
		tempfile data
		save `data'
	}	
	merge 1:1 d11_3 using `data'
	drop if _merge != 3
	drop _merge 
}

tempfile data1
save `data1'


*------------------------------------------------------------------------------*
* Randomization
*------------------------------------------------------------------------------*
/*
cd ${root_drive}/${results}
// Rewrote function so this code will not produce the same results 
randomize coaching, arms(2) seed(2348) /*genfile(ParticipantID) */ // Joint F is not rejected - one that we went with!!! 
*/
*getting around not randomizing again - the function was updated so the result will not be the same if it's run again 
frame uva_randomize_temp {
	import delimited "randomization_files/f22_uva_randomization_20220928.csv", clear
	label define treat_condition 0 "Control" 1 "Treatment"
	label values coaching treat_condition
	gen str3 z = string(participantid,"%03.0f")
	drop participantid
	rename z participantid
	frame uva_tracker {
		tempfile data
		save `data'
	}
	merge 1:1 participantid using `data'
	gen date = date(randomization_dt, "DMY")
	drop randomization_dt
	rename date randomization_dt
	format randomization_dt %td 
	drop _merge
	frame put _all, into(uva_randomize_final)
}

frame uva_randomize_final: keep coaching participantid d* site section
frame drop uva_randomize_temp uva_tracker 
