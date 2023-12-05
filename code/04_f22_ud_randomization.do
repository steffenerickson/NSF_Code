 *------------------------------------------------------------------------------*  
/*
Title: NSF UD SITE Randomization and merge with baseline data 
Authors: Steffen Erikson 
Date: 8/18/23
*/ 

mkf ud_tracker
mkf ud_tracker2
mkf ud_randomize_temp
mkf ud_add_missing_participant

*------------------------------------------------------------------------------*
* Merge Files 
*------------------------------------------------------------------------------*

frame ud_tracker {
	import excel "trackers_data/F22 UD Data Tracker.xlsx", sheet("UD Data Tracker") firstrow case(lower) clear
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
	drop if consent == "No" & participantid != "024" 
	tab participantid  // check frequency matches above
}


*------------------------------------------------------------------------------*
* Randomization
*------------------------------------------------------------------------------*

// Rewrote function so this code will not produce the same results 
// randomize coaching, id(participantid) arms(2) seed(0982) by(section) //genfile(firstname lastname site recipientemail)  
//


frame ud_randomize_temp {
	import delimited "randomization_files/f22_ud_randomization_20221010.csv", clear
	gen coaching2 = 1 if coaching =="Treatment"
	replace coaching2 = 0 if coaching == "Control"
	drop coaching 
	rename coaching2 coaching
	gen str3 z = string(participantid,"%03.0f")
	drop participantid
	rename z participantid
	gen date = date(randomization_dt, "DMY")
	drop randomization_dt
	rename date randomization_dt
	format randomization_dt %td 
	label define treat_condition 0 "Control" 1 "Treatment"
	label values coaching treat_condition
	drop if participantid == ""
	keep coaching participantid randomization_dt strata	
	frame ud_tracker {
		tempfile data
		save `data'
	}
	merge 1:1 participantid using `data'
	drop _merge
	cap drop if participantid == "030"
}

* Cut participant 030 out - appending back on and assigning to the treatment
frame ud_tracker2 {
	import excel "trackers_data/F22 UD Data Tracker.xlsx", sheet("UD Data Tracker") firstrow case(lower) clear
	rename emailaddress d11_3
	frame baseline_demographics  {
		tempfile data
		save `data'
	}
	merge 1:1 d11_3 using `data'
	keep if participantid == "030"
	tempfile data_missing_person
	save `data_missing_person'
}

frame ud_randomize_temp {
	append using `data_missing_person'
	recode coaching (. = 0) if participantid == "030"
	recode strata (. = 2) if participantid == "030"
	egen dupes = tag(participantid)
	drop if dupes != 1
	drop dupes 
	frame put _all , into(ud_randomize_final)
}

frame ud_randomize_final: keep coaching participantid d* site section
frame drop ud_add_missing_participant ud_randomize_temp ud_tracker ud_tracker2   






