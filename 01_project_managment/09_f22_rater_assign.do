*------------------------------------------------------------------------------*  
/*
Title: Assign Coders 
*Authors: Steffen Erikson 
*Date: 08/20/23
*Purpose: Assign coders to rate participant videos for f22 sim videos 
*/ 
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
* Assigning Coders to Participant Videos
*------------------------------------------------------------------------------*

do ${code}/00_permin_program.do
mkf f22_simrubric_raters_temp
*-----------------------*
* Rater Assignment 
* 1) Generate all permutations of raters 
*-----------------------*

frame change f22_simrubric_raters_temp
matrix Coders = (1,2,3,4,5,6,7)'
matrix colnames Coders = "video"
svmat Coders, names(col)
permin video, k(6)


*-----------------------*
* Create two samples of rater permutations for pre and post
*-----------------------*

local n_s  = 149   // n of sample 
gen coder_comb = _n
sort coder_comb
set seed 3408
generate rannum = runiform()  
sort rannum
generate insample1 = _n <= `n_s' // first n_s
generate insample2 = (_N - _n) < `n_s' //last n_s

forvalues x = 1/2 {
	frame put _all ,into(sample`x')
	frame sample`x' : keep if insample`x' == 1 
	frame sample`x' : gen index = _n 
}

forvalues x = 1/2 {
	frame nsf_fall_baseline_data: frame put _all , into(f22_simrubric_raters_`x')
	frame f22_simrubric_raters_`x' {
		
		//---- Ensures observations are sorted to match original file
		sort site participantid 
		replace participantid = "060" if participantid == "024" & site == 2
		replace participantid = "061" if participantid == "030" & site == 2
		recode site (3 = 2) (1 = 3) (2 = 1)
		label define sites2 1 "UD" 2 "UVA" 3 "JMU"
		label values site sites2
		sort site participantid 
		sort site d11_3 in 71/149
		replace participantid = "024" if participantid == "060" & site == 1
		replace participantid = "030" if participantid == "061" & site == 1
		//-------
		gen index = _n 
		
		frame sample`x' {
			tempfile data
			save `data'
		}
		merge 1:1 index using `data'
		drop _merge /*coder_comb*/ index 
		#delimit ; 
		label define coder 	1 "Coder 1" 
							2 "Coder 2" 
							3 "Coder 3" 
							4 "Coder 4" 
							5 "Coder 5"
							6 "Coder 6"
							7 "Coder 7";
		#delimit cr
		label values video* coder 		
	
		recode site (2 = 3) (3 = 1) (1 = 2)
		label define sites3 1 "JMU" 2 "UD" 3 "UVA"
		label values site sites3
	}
}

frame f22_simrubric_raters_1: frame put _all , into(f22_simrubric_raters)
frame f22_simrubric_raters {
	frame f22_simrubric_raters_2 {
		tempfile data 
		save `data'
	}
	append using `data' , gen(time)
	drop rannum insample1 insample2
	label define session 0 "pre" 1 "post"
	label values time session 
}


frame change f22_simrubric_raters
frame drop f22_simrubric_raters_1 f22_simrubric_raters_2 f22_simrubric_raters_temp sample1 sample2   

*---------------------------------------------------*
* Resape to long data LONG DATA 
*---------------------------------------------------*

rename video_1 video_1_sc 
rename video_2 video_2_sc 
rename video_3 video_3_sc 
rename video_4 video_1_dc 
rename video_5 video_2_dc 
rename video_6 video_3_dc 
reshape long video_1_ video_2_ video_3_ , i(participantid site time) j(double_code) string
reshape long video, i(participantid site double_code time) j(task) string
encode task, gen(task_2)
drop task 
rename task_2 task
label define task_num 1 "Task 1" 2 "Task 2" 3 "Task 3"
label values task task_num 
encode double_code, gen(double_code_2)
drop double_code
rename double_code_2 double_code
label define double_code_num 1 "One" 2 "Two" 
label values double_code double_code_num 
rename video coder
gen video = 1 if time == 0 & task == 1
replace video = 2 if time == 0 & task == 2 
replace video = 3 if time == 0 & task == 3 
replace video = 4 if time == 1 & task == 1
replace video = 5 if time == 1 & task == 2 
replace video = 6 if time == 1 & task == 3 



recode site (1 = 3) (3 = 1) 
label define sites4 1 "UVA" 2 "UD" 3 "JMU"
label values site sites4
