//----------------------------------------------------------------------------//
// COSTI Cleaning File 
// Steffen Erickson 
// 08/25/23
// Run code blocks together 
	//-------------------------//
	
		*code {}
			
	
	
	//-------------------------//
//----------------------------------------------------------------------------//
mkf costi
frame costi {
import excel "outcome_data/COSTI-QCI Coding_March 19, 2024_07.15.xlsx", ///
sheet("Sheet0") firstrow case(lower) clear
keep finished q35-sc11
drop if length(q60) < 5 // drop the test files
replace q61 = "Two" if q60 == "01_F22_001_013_Placement.mp4"

//----------------------------------------------------------------------------//
// Rename Variables
//----------------------------------------------------------------------------//\

local i = 1 
foreach var of varlist q5-q10 {
	rename `var' q1_`i'
	local++i
}
local i = 1 
foreach var of varlist q39-q40 {
	rename `var' q2_`i'
	local++i
}

local i = 1 
foreach var of varlist q50-q51 {
	rename `var' q3_`i'
	local++i
}

forvalues x = 1/4 {
	forvalues i = 1/2 { 
		local a l`x'`i'
		local sub_domains: list sub_domains | a
	}
}

qui ds 
loc list1 `r(varlist)' 
foreach v of loc list1 {
	if strpos("`v'","q1_") > 0 		loc l11  : list l11  | v // counts 1 
	if strpos("`v'","q12_") > 0 	loc l12  : list l12  | v // quality 1
	if strpos("`v'","q2_") > 0 		loc l21  : list l21  | v // counts 2
	if strpos("`v'","q47_") > 0 	loc l22  : list l22  | v // quality 2
	if strpos("`v'","q3_") > 0 		loc l31  : list l31  | v // counts 3
	if strpos("`v'","q58_") > 0 	loc l32  : list l32  | v // quality 3
	if strpos("`v'","q10_") > 0 	loc l42  : list l42  | v // quality 4
}

tokenize `sub_domains'
local n: list sizeof local(sub_domains)
forvalues x = 1/`n' {
	local a = substr("``x''",3,1)
	local i = substr("``x''",2,1)
	local domain ``x''
	local j = 1
	foreach item of loc `domain' {
		rename `item' c`a'_`j'`i'
		local++j
	}
}

forvalues i = 1/2 {
	local a = `i' + 4
	rename c`i'_* c`a'_*
}

// segment codes 
local i = 1
foreach var of varlist sc* {
	rename `var' c7_`i'
	local++i
}

rename q60 c1_1 //filename
rename q35 c2_1 //rater
rename q61 c3_1 //dc
rename q86 c4_1 //small group/whole group

keep c*


forvalues i = 1/6 {
	gen c5_`i'4 = "" 
}

forvalues i = 1/6 {
	replace c5_`i'4 = c5_`i'1[1] in 1
}

//----------------------------------------------------------------------------//
// Label Variables
//----------------------------------------------------------------------------//

local remove1 "Select the level that you rate for each principle. - Principle"
local remove2 "Click to write the question text - Principle"
qui ds 
foreach v in `r(varlist)' {
	 replace `v' = subinstr(`v', "`remove1'", "",.)
	 replace `v' = subinstr(`v', "`remove2'", "",.)
}


qui ds 
foreach v in `r(varlist)' {
	loc a = `v'[1]
	label variable `v' "`a'"
	//loc b: list b | a
	
}
drop in 1
//----------------------------------------------------------------------------//
// Encode / Label Values
//----------------------------------------------------------------------------//

label define yesno 0 "No" 1 "Yes"
*label define Rater 1 "1- Chris" 2 "2 - Carol"

foreach var of varlist c6_* c2_1 c3_1 {
	tempvar `var'2
	encode  `var' , gen(`var'2)
	drop    `var'
	rename  `var'2 `var'
}

label define qci_levels 1 "level 1" 2 "level 2" 3 "level 3"
label values c6_* qci_levels

ds c5* c7*
loc vars1 `r(varlist)'
destring `vars1' , replace force

recode c2_1 (2 = 10) (3 = 11) (4 = 12) (5 = 13) (6 = 8) (7 = 9)

label define Rater ///
1 "Rater 1" 2 "Rater 2" 3 "Rater 3" 4 "Rater 4" 5 "Rater 5" 6 "Rater 6"  7 "Rater 7" ///
8 "Rater 8" 9 "Rater 9" 10 "Rater 10" 11 "Rater 11" 12 "Rater 12"  13 "Rater 13"
label values c2_1 Rater

tab c2_1
tab c2_1 , nolabel 

tab c2_1  c2_1 


//----------------------------------------------------------------------------//
// Split file name into site, semester, sectionn , id, type 
//----------------------------------------------------------------------------//
split c1_1, parse("_")
loc id_vars `r(varlist)'
local i = 1
forvalues x = 2/6 {
	rename `:word `i' of `id_vars'' c1_`x'
	local++i
}

label variable c1_2 "Site"
label variable c1_3 "Semester"
label variable c1_4 "Section"
label variable c1_5 "Participant ID"
label variable c1_6 "Setting"

//----------------------------------------------------------------------------//
// Reshape multiple segments to long 
//----------------------------------------------------------------------------//

egen tag = tag(c1_2 c1_3 c1_5 c2_1) 
drop if tag == 0
drop tag

drop c7_1-c7_11

global var_stubs c5_1 c5_2 c5_3 c5_4 c5_5 c5_6  ///
                 c6_1 c6_2 c6_3 c6_4 c6_5 c6_6  c6_7  c6_8

*save variable labels for segment codes 
foreach v of global var_stubs {
        local l`v' : variable label `v'1
		di "`l`v''"
}

reshape long $var_stubs, i(c1_2 c1_3 c1_5 c2_1) j(segment)

foreach v of global var_stubs {
        label var `v' "`l`v''"
 }

//----------------------------------------------------------------------------//
// More cleaning
//----------------------------------------------------------------------------//

tab c1_2
encode c1_2, gen(c1_2_2)
drop c1_2
rename c1_2_2 c1_2
label define sites 1 "UVA" 2 "UD" 3 "JMU"
label values c1_2 sites 

tab c1_2
encode c1_3, gen(c1_3_2)
drop c1_3
rename c1_3_2 c1_3
recode c1_3 (1=0) (2=1)
label define sems 0 "F22" 1 "S23"
label values c1_3 sems 

drop if c5_1 == .
 

/*
//----------------------------------------------------------------------------//
// Reshape multiple segments to long 
//----------------------------------------------------------------------------//

egen tag = tag(c1_2 c1_3 c1_5 c2_1) 
drop if tag == 0
drop tag

global var_stubs c5_1 c5_2 c5_3 c5_4 c5_5 c5_6  ///
                c6_1 c6_2 c6_3 c6_4 c6_5 c6_6  c6_7  c6_8

*save variable labels for segment codes 
foreach v of global var_stubs {
        local l`v' : variable label `v'1
		di "`l`v''"
}

reshape long $var_stubs , i(c1_2 c1_3 c1_5 c2_1) j(segment)

foreach v of global var_stubs {
        label var `v' "`l`v''"
 }

//----------------------------------------------------------------------------//
// More cleaning
//----------------------------------------------------------------------------//

tab c1_2
encode c1_2, gen(c1_2_2)
drop c1_2
rename c1_2_2 c1_2
label define sites 1 "UVA" 2 "UD" 3 "JMU"
label values c1_2 sites 

tab c1_2
encode c1_3, gen(c1_3_2)
drop c1_3
rename c1_3_2 c1_3
recode c1_3 (1=0) (2=1)
label define sems 0 "F22" 1 "S23"
label values c1_3 sems 

drop if c5_1 == .
*/
}
