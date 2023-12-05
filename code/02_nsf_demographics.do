*------------------------------------------------------------------------------*
/*
Title:   NSF Baseline Survey 
Author:  Steffen Erickson 
Date:    9/18/22 
Revised by Kaijie Liu (4/19/2013)
Revised by Steffen Erickson (8/17/2013)

Purpose: Data Cleaning - NSF Baseline Survey 

*/
*------------------------------------------------------------------------------*
clear 
frames reset 
*------------------------------------------------------------------------------*
* Set Up 
*------------------------------------------------------------------------------*
* Import Data Frames 

* Make empty frames
mkf main
mkf main_numeric 
mkf uva_tepp
mkf ud_re_offer 
mkf ud_re_offer_numeric

* Import Data Frames 
frame main: import excel "demographics_data/F22: SimSE Background & Demographics Survey_August 17, 2023_15.28.xlsx", sheet("Sheet0") firstrow case(lower) clear
frame main_numeric: import excel "demographics_data/F22: SimSE Background & Demographics Numeric Survey_August 17, 2023_15.30.xlsx", sheet("Sheet0") firstrow case(lower) clear
frame ud_re_offer : import excel "demographics_data/S23: SimSE Background & Demographics Survey - UD Re-Offer_August 17, 2023_16.46.xlsx", sheet("Sheet0") firstrow case(lower) clear
frame ud_re_offer_numeric : import excel "demographics_data/S23: SimSE Background & Demographics Numeric Survey - UD Re-Offer_August 17, 2023_16.45.xlsx", sheet("Sheet0") firstrow case(lower) clear
frame uva_tepp: import excel "demographics_data/NEO Data Cohen.xlsx", sheet("Sheet1") firstrow case(lower) clear

* Rename variable names in the main and numeric versions of the surveys
foreach f in main main_numeric ud_re_offer ud_re_offer_numeric {
frame `f' {
drop in 1
*------------------------------------------------------------------------------*
*Remove Unfinished and duplicate surveys 
*------------------------------------------------------------------------------*

destring progress , replace
keep if progress > 70
gen index = _n 
egen nobs = nvals(index) ,by(q98_4)
tab nobs
drop nobs index 

*------------------------------------------------------------------------------*
* Rename Variables  
*------------------------------------------------------------------------------*

rename q98_1  d11_1                                              
rename q98_2  d11_2                                               
rename q98_4  d11_3        
replace d11_3 =strlower(d11_3 )                                            
rename q17_1		    d91_1  
rename q17_2            d91_2 	
rename q17_3            d91_3
rename q18              d92
rename q19              d93
rename q20              d94
rename q21              d95
rename q22_1            d96_1
rename q22_2            d96_2
rename q22_3            d96_3
rename q22_4            d96_4
rename q23              d97
rename q24_1            d98_1
rename q24_2            d98_2
rename q24_3            d98_3
rename q24_4            d98_4
rename q25              d99
rename q26       		d910
rename q27       		d911
rename q28       		d912
rename q29_1     		d913_1
rename q29_2            d913_2
rename q29_3            d913_3
rename q29_4            d913_4
rename q30       		d914
rename q31       		d915
rename q32_1     		d916_1
rename q32_2            d916_2
rename q32_3            d916_3
rename q32_4            d916_4
rename q33  			d917
rename q34  			d918
rename q35  			d919
rename q36_1			d920_1
rename q36_2            d920_2
rename q36_3            d920_3
rename q36_4            d920_4
rename q38_1			d101_1
rename q38_2			d101_2
rename q38_3			d101_3
rename q38_4			d101_4
rename q38_5			d101_5
rename q38_6			d101_6
rename q38_7			d101_7
rename q39_1			d102
rename q40  			d103
rename q41_1			d104_1
rename q41_2			d104_2
rename q41_3			d104_3
rename q41_4			d104_4
rename q41_5			d104_5
rename q41_6			d104_6
rename q41_7			d104_7
rename q41_8			d104_8
rename q41_9			d104_9
rename q42_1			d105_1
rename q42_2            d105_2
rename q42_3            d105_3
rename q42_4            d105_4
rename q42_5            d105_5
rename q43_1 			d106_1
rename q43_2            d106_2
rename q43_3            d106_3 
rename q43_4            d106_4
rename q43_5            d106_5
rename q43_6            d106_6
rename q43_7            d106_7
rename q43_8            d106_8
rename q100  			d111 
rename q101  			d112
rename q102  			d113
rename q45_1 			d121_1   
rename q45_2            d121_2
rename q45_3            d121_3
rename q45_4            d121_4
rename q45_5            d121_5
rename q45_6            d122_1
rename q45_7            d122_2
rename q45_8            d122_3
rename q45_9            d122_4
rename q45_10           d122_5
rename q45_11           d123_1
rename q45_12           d123_2
rename q45_13           d123_3
rename q45_14           d124_1
rename q45_15           d124_2
rename q45_16           d124_3
rename q45_17           d125_1
rename q45_18           d125_2
rename q45_19           d125_3
rename q46_1  			d131_1
rename q46_2            d131_2
rename q46_3            d131_3
rename q46_4            d131_4
rename q46_5            d131_5
rename q46_6            d131_6
rename q46_7            d131_7
rename q46_8            d131_8
rename q46_9            d131_9
rename q46_10           d131_10
rename q46_11           d131_11
rename q46_12           d131_12
rename q46_13           d131_13
rename q46_14           d131_14
rename q46_15           d131_15
rename q46_16           d131_16
rename q46_17           d131_17
rename q46_18           d131_18
rename q46_19           d131_19
rename q46_20 			d131_20
rename q46_21 			d131_21
rename q47_1  			d141_1
rename q47_2            d141_2
rename q47_3            d141_3
rename q47_4            d141_4
rename q47_5            d141_5
rename q47_6            d141_6
rename q47_7            d141_7
rename q47_8            d141_8
rename q47_9            d141_9
rename q47_10           d141_10
rename q47_11           d141_11
rename q47_12           d141_12
rename q47_13           d141_13
rename q47_14           d141_14
rename q47_15           d141_15
rename q47_16           d141_16
rename q47_17           d141_17
rename q47_18           d141_18
rename q47_19           d141_19
rename q47_20           d141_20
rename q47_21           d141_21
rename q50_1  			d151_1
rename q50_2            d152_1
rename q50_3            d153_1
rename q50_4            d154_1
rename q50_5            d155_1
rename q50_6            d151_2
rename q50_7            d152_2
rename q50_8            d153_2
rename q50_9            d154_2
rename q50_10           d155_2
rename q51_1  			d151_3
rename q51_2            d152_3
rename q51_3            d153_3
rename q51_4            d154_3
rename q51_5            d155_3
rename q51_6            d151_4
rename q51_7            d152_4
rename q51_8            d153_4
rename q51_9            d154_4
rename q51_10           d155_4
rename q52_1  			d151_5
rename q52_2            d152_5
rename q52_3            d153_5
rename q52_4            d154_5
rename q52_5            d155_5
rename q52_6            d151_6
rename q52_7            d152_6
rename q52_8            d153_6
rename q52_9            d154_6
rename q52_10           d155_6
rename q53_1  			d151_7
rename q53_2            d152_7
rename q53_3            d153_7
rename q53_4            d154_7
rename q53_5            d155_7
rename q53_6            d151_8
rename q53_7            d152_8
rename q53_8            d153_8
rename q53_9            d154_8
rename q53_10           d155_8
rename q54_1  			d151_9
rename q54_2            d152_9
rename q54_3            d153_9
rename q54_4            d154_9
rename q54_5            d155_9
rename q54_6            d151_10
rename q54_7            d152_10
rename q54_8            d153_10
rename q54_9            d154_10
rename q54_10           d155_10
rename q55_1			d151_11
rename q55_2            d152_11
rename q55_3            d153_11
rename q55_4            d154_11
rename q55_5            d155_11
rename q55_6            d151_12
rename q55_7            d152_12
rename q55_8            d153_12
rename q55_9            d154_12
rename q55_10           d155_12
rename q64				d161
rename q65				d162
rename q66				d163
rename q67				d164
rename q68				d166
rename q69				d167
rename q70				d168
rename q71				d169
rename q72				d1610
rename q73				d1611_1
rename q73_7_text		d1611_2
rename q74				d1612_1
rename q74_6_text		d1612_2
rename q75				d1613
	}
}

*------------------------------------------------------------------------------*
* Recover lost scores using numeric version of survey 
*------------------------------------------------------------------------------*
frame change main
drop d919 d99 
frame main_numeric {
	keep d11_3 d919 d99 
	tempfile data
	save `data'
}
merge 1:1 d11_3 using `data'
drop _merge 

frame change ud_re_offer
drop d919 d99 
frame ud_re_offer_numeric {
	keep d11_3 d919 d99 
	tempfile data
	save `data'
}
merge 1:1 d11_3 using `data'
drop _merge

*------------------------------------------------------------------------------*
* Recover the re-offer UD surveys and append 
*------------------------------------------------------------------------------*
frame change main
frame ud_re_offer {
	tempfile data
	save `data'
}
append using `data'
gen index = _n 
egen nobs = nvals(index) ,by(d11_3)
split startdate 
gen date = date(startdate1,"MDY")
sort d11_3 date 
bysort d11_3: gen index2 = _n
drop if index2 == 1 & nobs == 2
drop nobs index index2 date startdat*

* Drop unneeded dataframes from memory now that they have been merged in 
frame drop main_numeric ud_re_offer ud_re_offer_numeric

*------------------------------------------------------------------------------*
* Clean Item Responses and create sum scores 
*------------------------------------------------------------------------------*
*-----------------*
*   Content	      *
*-----------------*
foreach var of varlist d9* {
	tempvar `var'_2 
	encode `var' , gen(``var'_2')
	drop `var'
	rename ``var'_2' `var'
}
recode d91_1  (1 3 = 0) (2 = 1) 
recode d91_2  (1 3 = 0) (2 = 1) 
recode d91_3  (2 3 = 0) (1 = 1) 
recode d92    (1 2 4 5 = 0) (3 = 1) 
recode d93    (2 3 4 = 0) (1 = 1) 
recode d94    (1 3 4 = 0) (2 = 1) 
recode d95    (1 3 4 = 0) (2 = 1) 
recode d96_1  (1 3 4 = 0) (2 = 1) 
recode d96_2  (1 2 3 = 0) (4 = 1) 
recode d96_3  (1 3 4 = 0) (2 = 1) 
recode d96_4  (1 2 4 = 0) (3 = 1) 
recode d97    (1 3 4 = 0) (2 = 1) 
recode d98_1  (1 3  = 0) (2 = 1) 
recode d98_2  (1 3  = 0) (2 = 1) 
recode d98_3  (1 3  = 0) (2 = 1) 
recode d98_4  (1 2  = 0) (3 = 1) 
recode d99    (1 2 4 = 0) (3 = 1)
recode d910   (1 2 3 5 = 0) (4 = 1)
recode d911   (1 2 4 = 0) (3 = 1)
recode d912   (1 2 4 5 = 0) (3 = 1)
recode d913_1 (1 2  = 0) (3 = 1) 
recode d913_2 (2 3  = 0) (1 = 1) 
recode d913_3 (1 2  = 0) (3 = 1) 
recode d913_4 (2 3  = 0) (1 = 1) 
recode d914	(2 3 4  = 0) (1 = 1) 
recode d915	(1 2 3  = 0) (4 = 1) 
recode d916_1 (1 3  = 0) (2 = 1) 
recode d916_2 (1 3  = 0) (2 = 1) 
recode d916_3 (1 3  = 0) (2 = 1) 
recode d916_4 (1 2  = 0) (3 = 1)
recode d917 	(2 3 4 = 0) (1 = 1)
recode d918 	(2 3 4 = 0) (1 = 1)
recode d919   (1 2 4 = 0) (3 = 1)
recode d920_1 (1 2  = 0) (3 = 1)
recode d920_2 (1 2  = 0) (3 = 1)
recode d920_3 (1 2  = 0) (3 = 1)
recode d920_4 (2 3  = 0) (1 = 1)
egen d921 = rowmean(d9*)

*-----------------*
*Prior Experience *
*-----------------*
foreach var of varlist d10* {
	tempvar `var'_2 
	encode `var' , gen(``var'_2')
	drop `var'
	rename ``var'_2' `var'
}
label values d101_* exp
recode d105_* d106_* (2 = 0) (5 = 1) (4 = 2) (3 = 3) (1 = 4)

egen prior_scale_1 = rowmean(d101_*)
egen prior_scale_2 = rowmean(d104_*)
egen prior_scale_3 = rowmean(d105_* d106_*)
egen d107 = rowmean(prior_scale_1 prior_scale_2 prior_scale_3)

*-----------------*
* Efficacy *
*-----------------*
foreach var of varlist d121_* d122_* d123_* d124_* d125_*{
	tempvar `var'_2 
	gen ``var'_2' = substr(`var',2,1)
	drop `var'
	rename ``var'_2' `var'
	destring `var' , replace
}

egen d126_1 = rowmean(d121_1 d121_2 d121_3 d121_4 d121_5)
egen d126_2 = rowmean(d122_1 d122_2 d122_3 d122_4 d122_5)
egen d126_3 = rowmean(d123_1 d123_2 d123_3)
egen d126_4 = rowmean(d124_1 d124_2 d124_3)
egen d126_5 = rowmean(d125_1 d125_2 d125_3)
egen d126_6 = rowmean(d126_1 d126_2 d126_3 d126_4 d126_5)

*-----------------*
* Beliefs *
*-----------------*
foreach var of varlist d131* {
	tempvar `var'_2 
	encode `var' , gen(``var'_2')
	drop `var'
	rename ``var'_2' `var'
}

recode d131* (6 = 0) (5 = 5) (4 = 2) (3 = 3) (2 = 1) (1 = 4)
recode d131_7-d131_13 (0 = 5) (1 = 4) (2 = 3) (3 = 2) (4 = 1) (5 = 0)
egen d132  = rowmean(d131*)

*-----------------*
* mteb *
*-----------------*
foreach var of varlist d141* {
	tempvar `var'_2 
	encode `var' , gen(``var'_2')
	drop `var'
	rename ``var'_2' `var'
}

recode d141* (1 = 3) (2 = 1) (3 = 4) (4 = 0) (5 = 3) 
foreach x in 3 6 15 17 18 19 21 {
	recode d141_`x' (0 = 4) (1 = 3) (2 = 2) (3 = 1) (4 = 0) 
}
egen d142 = rowmean(d141*)

*-----------------*
* NEO *
*-----------------*
foreach var of varlist d15* {
	tempvar `var'_2 
	encode `var' , gen(``var'_2')
	drop `var'
	rename ``var'_2' `var'
}
recode d15* (5 = 0) (2 = 1) (3 = 2) (4 = 4) (1 = 3) 
label values d15* likert3

* ----- Recover UVA scores w/ TEPP Data 
frame uva_tepp {
	split studentname, gen(s)
	replace s1 = subinstr(s1,",","",.)
	rename s1 d11_2 
	rename s2 d11_1 
	egen dupes = tag(studentnumber)
	drop if dupes == 0 
	drop dupes 
	keep  neo* d11_2 d11_1 

	forvalues i = 1/9 {
		rename neo_0`i' neo_`i' 
	}
	forvalues n = 1(1)5 {
		local m = 55+`n'
		display "m="`m'  //check the indices (to be deleted after reviewing)
		local j = 1
		forvalues i = `n'(5)`m' {
			display "j="`j'  //check the indices
			display `i'  //check the indices
			rename neo_`i'  d15`n'_`j'_2
			local ++j	
		}
		local remove `j'
		local remove `m'
	}
	tempfile data
	save `data'
}
merge 1:1 d11_1 d11_2 using `data'
preserve
keep if _merge ==1
forvalues x = 1/12 {
	foreach var of varlist d151_`x' d152_`x' d153_`x' d154_`x' d155_`x' {
		drop `var'_2
	}
}
tempfile nontepp
save `nontepp'
restore
drop if _merge !=3  
destring d151_4_2, replace force 
destring d151_9_2, replace force
**# Bookmark #4: recover TEPP data
forvalues x = 1/12 {
	foreach var of varlist d151_`x' d152_`x' d153_`x' d154_`x' d155_`x' {
		replace `var' = `var'_2 if `var' == .  //`var'_2 are from TEPP data
		drop `var'_2
	}
}
recode d15* (1 = 0) (2 = 1) (3 = 2) (4 = 3) (5 = 4) if strpos(recipientemail,"virginia") > 0
append using `nontepp', force 
drop _merge
* end recover uva scores -----
local reverse_code d151_1 d153_1 d153_2 d154_2 d152_3 d154_3 d155_3 d151_4 ///
				   d153_4 d153_5 d154_5 d152_6 d154_6 d155_6 d151_7 d153_7 ///
				   d153_8 d154_8 d152_9 d154_9 d155_9 d151_10 d153_10 d154_11 ///
				   d155_11 d152_12 d154_12
foreach x in  `reverse_code' {
	recode `x' (0 = 4) (1 = 3) (2 = 2) (3 = 1) (4 = 0) 
}
*Neuroticism
egen d156_1 = rowmean(d151_*)
*Extraversion
egen d156_2 = rowmean(d152_*)
* Openness to Experience
egen d156_3 = rowmean(d153_*)
* Agreeableness
egen d156_4 = rowmean(d154_* )
* Conscientiousness
egen d156_5 = rowmean(d155_*)

*------------------------------------------------------------------------------*
* Demographics *
*------------------------------------------------------------------------------*
*Cleaning Up Strings 
*gender： d161
replace d161=lower(d161)
replace d161=strtrim(d161)
replace d161=subinstr(d161, "cisgender","",.)
replace d161=subinstr(d161, "cis","",.)
replace d161=subinstr(d161, "woman","female",.)
replace d161=subinstr(d161, "femalw","female",.)
replace d161=subinstr(d161, "(she/her)","",.)
replace d161=strtrim(d161)
label var d161 "Gender"
*age： d162 
replace d162=subinstr(d162, "`","",.)
replace d162=subinstr(d162, "years old","",.) 
replace d162=subinstr(d162, "yrs","",.)
replace d162=strtrim(d162)
destring d162, replace 
label var d162 "Age"
*encoding categorical 
local varlist d1611_1 d161 d166 d168 d169 d1610 d1612_1 d163
foreach var of varlist `varlist' {
	encode `var' , gen(`var'_2)
	drop `var'
	rename `var'_2 `var'
}
*destring numeric 
destring d162 d167 d164, replace force

*------------------------------------------------------------------------------*
* Pull in value and variable labels
*------------------------------------------------------------------------------*
* Value Labels
do "code/00_valuelabels_baseline_demographics_nsf.do"
label values d9* correctness 
label values d105_* d106_* exp2
label values d131* likert
label values d15* likert3
do "code/00_labelvar_baseline_demographics_nsf.do"
label_baseline_demographics_nsf
*------------------------------------------------------------------------------*
keep d*
drop durationinseconds distributionchannel

frame rename main baseline_demographics 
frame drop uva_tepp



