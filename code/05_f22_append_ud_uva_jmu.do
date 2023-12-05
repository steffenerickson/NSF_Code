*------------------------------------------------------------------------------*  
/*
Title: Append JMU, UVA, UD baseline and randomization data 
Authors: Steffen Erikson 
Date: 8/18/23

*/ 

mkf jmu_tracker
*------------------------------------------------------------------------------*
* Merge JMU File with baseline data 
*------------------------------------------------------------------------------*

frame jmu_tracker {
	import excel "trackers_data/F22 JMU Data Tracker.xlsx", sheet("JMU Data Tracker") firstrow case(lower) clear
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
* Append all sites together
*------------------------------------------------------------------------------*
frame change ud_randomize_final 
frame uva_randomize_final {
	tempfile data 
	save `data'
}
append using `data'
frame jmu_tracker {
	tempfile data 
	save `data'
}
append using `data'
replace consent = "yes" if consent == ""
replace section = "Thomas" if section == ""
encode site, gen(site2) 
drop site
rename site2 site 
recode site (1=3) (3=1)
label define sites 1 "UVA" 2 "UD" 3 "JMU"
label values site sites 
replace coaching = 2 if coaching == .
label define treat_condition 2 "Non-Experimental" , modify
encode section, gen(section2) 
drop section
rename section2 section

keep d* coaching participantid d* site section
frame put _all , into(nsf_fall_baseline_data)
frame change nsf_fall_baseline_data
frame drop jmu_tracker ud_randomize_final uva_randomize_final





