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
	import excel "trackers_data/S23 JMU Data Tracker.xlsx", sheet("S23_ JMU Data Tracker") firstrow case(lower) clear
	drop if participantid == ""
	loc list1 boyerkg@dukes.jmu.edu ///
		 lumsdega@dukes.jmu.edu ///
		 devinerm@dukes.jmu.edu ///
		 odonneac@dukes.jmu.edu ///
		 antonuje@dukes.jmu.edu ///
		 bezanshd@dukes.jmu.edu ///
		 rawsonlk@dukes.jmu.edu ///
		   yorket@dukes.jmu.edu ///
		 dubilibp@dukes.jmu.edu 

	foreach x of loc list1 {
		drop if emailaddress == "`x'"
	}

	rename emailaddress d11_3
	frame baseline_demographics  {
		tempfile data
		save `data'
	}	
	merge 1:1 d11_3 using `data'
	drop if _merge == 2
	drop _merge 
	
	
	tab consent 
	list participantid d11_3 consent if consent == "No" 
	drop if consent == "No" |  consent == "" | s23task1 == ""

	replace section = subinstr(section, "_", "",.) 
	rename  section section_num
	rename g section
	drop  audioconsent-s23task3

	replace site = "JMU" if site == ""
	
}

*------------------------------------------------------------------------------*
* Append all sites together
*------------------------------------------------------------------------------*
frame change ud_randomize_final_2 
frame uva_randomize_final_2 {
	tempfile data 
	save `data'
}
append using `data'
frame jmu_tracker {
	tempfile data 
	save `data'
}
append using `data'
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
frame put _all , into(nsf_spring_baseline_data)
frame change nsf_spring_baseline_data
frame drop jmu_tracker ud_randomize_final_2 uva_randomize_final_2





