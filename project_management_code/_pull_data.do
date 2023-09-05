*------------------------------------------------------------------------------*
* Title: NSF data pull do file 
* Author: Steffen Erickson
* Date: 08/25/23
*------------------------------------------------------------------------------*



						***** Run Cleaning Code ******

* ssc install egenmore //uncomment if you do not have egenmore installed 
global root_drive "/Users/steffenerickson/Desktop/repos/collab_rep_lab/nsf_v2"  // Change file path to master folder 
global data_drive "/Users/steffenerickson/Desktop"

cd $root_drive
do ${root_drive}/code/01_master.do

frame dir 

* unique ID for all datasets are participantid site semester 
* all outcome data files are linked to the baseline data with participantid site semester 
* baseline data contains treatment assignments, randomization blocks, and baseline survey info




						******* Access Frames *******




* run [ frame change .... ] to access data 

//----------------------------------------------------------------------------//
*baseline data 
frame change nsf_baseline_data  
*save ${data_drive}/nsf_baseline_data.dta, replace  // uncomment to save 
*export excel ${data_drive}/nsf_baseline_data.xlsx, replace firstrow(variables) // uncomment to save 
//----------------------------------------------------------------------------//
*performance tasks and baseline data 
frame change performancetask_and_baseline 
frlink describe link1
*save ${data_drive}/performancetask_and_baseline.dta, replace // uncomment to save 
*export excel ${data_drive}/performancetask_and_baseline.xlsx, replace firstrow(variables) // uncomment to save 
//----------------------------------------------------------------------------//
*mqi and baseline data 
frame change mqi_and_baseline  
frlink describe link2
*save ${data_drive}/mqi_and_baseline.dta, replace // uncomment to save 
*export excel ${data_drive}/mqi_and_baseline.xlsx, replace firstrow(variables) // uncomment to save 
//----------------------------------------------------------------------------//
*costi and baseline data
frame change costi_and_baseline
frlink describe link3
*save ${data_drive}/costi_and_baseline.dta, replace // uncomment to save 
*export excel ${data_drive}/costi_and_baseline.xlsx, replace firstrow(variables) // uncomment to save   
//----------------------------------------------------------------------------//
*final survey and baseline data 
frame change finalsurvey_and_baseline
frlink describe link4
*save ${data_drive}/finalsurvey_and_baseline.dta, replace // uncomment to save 
*export excel ${data_drive}/finalsurvey_and_baseline.xlsx, replace firstrow(variables) // uncomment to save  
//----------------------------------------------------------------------------//



						****** Example Data Pull *******



//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Full outcome and baseline data with one observation per participant 
// for experimental arms only
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
* Create Copies of frames 
frame copy nsf_baseline_data full_outcome, replace 
frame copy performancetask_and_baseline performancetask , replace 
frame copy mqi_and_baseline mqi, replace 
frame copy finalsurvey_and_baseline finalsurvey, replace 

* Baseline variables to keep 
frame full_outcome : keep coaching-d167 d921 d107 d132 d142 d156_* d161-d1610 site section semester

* collapse performancetask data 
frame performancetask  {
	drop if x1-x6 == .
	foreach v in x1 x2 x3 x4 x5 x6 {	//copy variable labels 
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
	}
	collapse x1 x2 x3 x4 x5 x6, by(participantid coaching semester section site time)
	reshape wide x1 x2 x3 x4 x5 x6 , i(coaching participantid semester  site section) j(time)
	foreach v in x1 x2 x3 x4 x5 x6 {	//attach variable labels to collapsed vars 
        label var `v'0 "`l`v''"
		label var `v'1 "`l`v''"
		label var `v'2 "`l`v''"
	}

}
* collapse mqi data 
frame mqi  {
	foreach v of var * {				//copy variable labels 
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
	}
	collapse m15_8 m16_4 m17_5 m18_7, by(participantid coaching semester site  section)
	foreach v of var * {				//attach variable labels to collapsed vars 
        label var `v' "`l`v''"
	}
}
* keep final self efficacy measure 
frame finalsurvey: keep coaching participantid site section semester d126_1_2-d126_6_2
* Merge files 
frame full_outcome {
	local dataframes performancetask mqi finalsurvey
	foreach df of local dataframes {
		frame `df' {
			tempfile data
			save `data'
		}
		merge 1:1 participantid site semester using `data'
		drop _merge 
	}
}
frame full_outcome {
	drop if site == 3
	drop if coaching == . 
}
frame drop performancetask mqi finalsurvey
frame dir 
frame change full_outcome
*save ${data_drive}/full_outcome.dta, replace // uncomment to save 
*export excel ${data_drive}/full_outcome.xlsx, replace firstrow(variables) // uncomment to save  




			****** Access variables from linked frames *******
						
frame copy nsf_baseline_data baseline, replace 
frame copy performancetask_and_baseline performancetask , replace 
frame copy mqi_and_baseline mqi, replace 
frame copy finalsurvey_and_baseline finalsurvey, replace 						

frame mqi: frlink describe link2

// make a copy of content score variable and add it to the mqi data frame 
frame mqi : frget d921, from(link2) suffix(a)
frame mqi : sum d921a

// make an alias of the content score variable and add it to the mqi data frame 
frame mqi : fralias add  d921, from(link2)  suffix(b)
frame mqi : fralias describe  
frame mqi : sum d921b


// function to access variables in other frames 
frame mqi : generate d921c = frval(link2, d921)  
frame mqi : sum d921c




