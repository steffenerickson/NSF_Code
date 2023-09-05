//-----------------------------------------------------------------------------//
/*
Title: Classroom Observation Assignment  
Authors: Steffen Erikson
Date: 02/20/23
Purpose: This Do-File randomly assigns coders to classroom obsevation videos  

*/ 
//-----------------------------------------------------------------------------//

* Set Up
frame reset 
mkf full 
mkf coders 
mkf inventory_1
mkf inventory_2

//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
// Observation tool 1 
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//

//-----------------------------------------------------------------------------//
// Randomly assign videos to first
//-----------------------------------------------------------------------------//
frame change inventory_1
${classroom_task_data}

replace Lengthofvideominssec = "5:04" if Lengthofvideominssec == "3:49 + 1:15"
gen time = clock(Lengthofvideominssec, " m s")
format time  %tc
xtile t = time, nquantiles(3)
replace t = 4 if t == . 

forvalues x = 1/4 {
	preserve
		if `x' == 1 | `x' == 3 {
			loc lim limit(7)
		}	
		if `x' == 4 {
			loc lim limit(2)
		}
		else {
			loc lim
		}
		randomize coder if t == `x', id(Videofile) seed(1234) arms(3) `lim'
		tempfile data`x'
		save `data`x''
	restore 
} 

use `data1' , clear
append using `data2' `data3' `data4'
drop if coder == . 
drop randomization_dt 
qui tab coder t

//-----------------------------------------------------------------------------//
// Randomly assign videos 2nd coder
//-----------------------------------------------------------------------------//

randomize t1_coder_2, id(Videofile) seed(1234) by(t coder)
drop randomization_dt strata 

rename coder t1_coder_1
recode t1_coder_1 (0 = 1) (1 = 2) (2 = 3)
recode t1_coder_2 (0 = 2)(1 = 3) if t1_coder_1 == 1 
recode t1_coder_2 (0 = 3)(1 = 1) if t1_coder_1 == 2
recode t1_coder_2 (0 = 1)(1 = 2) if t1_coder_1 == 3

tab t1_coder_1 t1_coder_2

//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
// Observation tool 2
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
randomize t2_coder_1, id(Videofile) seed(1234) by(t)
drop randomization_dt strata 

gen t2_coder_2 = 1 if t2_coder_1 == 0
replace t2_coder_2 = 0 if t2_coder_1 == 1
recode t2_coder_1 t2_coder_2 (0 = 1) (1 = 2)


tab t1_coder_1 t1_coder_2

tab t2_coder_1 t2_coder_2

//-----------------------------------------------------------------------------//
// Export
//-----------------------------------------------------------------------------//
rename t length 
lab define len 1 "short" 2 "medium" 3 "long" 4 "no time"
lab values length len 

export excel ${clean_data}/classroom_observation.xlsx , replace firstrow(variables)

//-----------------------------------------------------------------------------//
// Second tool 
//-----------------------------------------------------------------------------//

frame change inventory_2
${classroom_task_data_2}

set seed 1239

keep Original_Filename Site
drop if Original_Filename == ""

label define coder 0 "Elise" 1 "Lucy"

preserve 
gen coder = 0 
label values coder coder
gen rannum = runiform() 
sort rannum 
drop rannum
export excel ${clean_data}/classroom_observation_elise.xlsx, replace firstrow(variables)
restore 

preserve 
gen coder = 1
label values coder coder
gen rannum = runiform() 
sort rannum 
drop rannum
export excel ${clean_data}/classroom_observation_lucy.xlsx , replace firstrow(variables)
restore 

 


















