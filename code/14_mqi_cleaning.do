//----------------------------------------------------------------------------//
// MQI Cleaning File 
// Steffen Erickson 
// 06/13/23
// Run code blocks together 
	//-------------------------//
	
		*code {}
			
	
	
	//-------------------------//
//----------------------------------------------------------------------------//

mkf mqi
frame mqi {
import excel "outcome_data/NSF+MQI+Coding_June+7,+2023_09.03.xls", sheet("NSF+MQI+Coding_June+7,+2023_09.") firstrow case(lower) clear

keep q2-q40 q10* q11_1
drop in 2

//----------------------------------------------------------------------------//
// Rename Variables
//----------------------------------------------------------------------------//
local sub_domains l1 l2 l3 l4 l5
foreach f of local sub_domains {
	loc `f' ""
	}
	
qui ds 
loc list1 `r(varlist)' 
foreach v of loc list1 {
	if strpos("`v'","q5") > 0 loc l1  : list l1  | v //richness 
	if strpos("`v'","q6") > 0 loc l2  : list l2  | v //working w/ students 
	if strpos("`v'","q7") > 0 loc l3  : list l3  | v //errors
	if strpos("`v'","q8") > 0 loc l4  : list l4  | v //common core
	if strpos("`v'","q10") > 0 | strpos("`v'","q11") > 0 loc l5  : list l5  | v //whole lesson codes 
}

loc i = 5
foreach domain of loc sub_domains {
	loc j = 1
	foreach item of loc `domain' {
		rename `item' m1`i'_`j'
		loc++j
	}
	loc++i
}

rename q1  m11_1  // file name 
rename q2  m12_1  // rater 
rename q3  m14_1  // work connected to math?
rename q40 m13_1  // notes 
order m11_1 m12_1 m13_1 m14_1

//----------------------------------------------------------------------------//
// Label Variables
//----------------------------------------------------------------------------//
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
label define likert 0 "Not Present" 1 "Low" 2 "Mid" 3 "High"
label define yesno 0 "No" 1 "Yes"
label define Rater 1 "1- Chris" 2 "2 - Carol"

qui ds, has(varl *WHOLE*)  
loc vars1 `r(varlist)'
local remove m11_1 m12_1 m13_1 m14_1 `vars1'
qui ds 
loc vars2 `r(varlist)'
loc items : list vars2 - remove

di "`items'"
foreach i of loc items {
	encode `i' , gen(`i'_2) label(likert)
	drop `i'
	rename `i'_2 `i'
} 

destring `vars1' , replace 

encode m14_1 , gen(m14_1_2) label(yesno)
drop m14_1
rename m14_1_2 m14_1

encode m12_1 , gen(m12_1_2) label(Rater)
drop m12_1
rename m12_1_2 m12_1

//----------------------------------------------------------------------------//
// Split file name into site, semester, sectionn , id, type 
//----------------------------------------------------------------------------//
split m11_1, parse("_")
loc id_vars `r(varlist)'
local i = 1
forvalues x = 2/6 {
	rename `:word `i' of `id_vars'' m11_`x'
	local++i
}

label variable m11_2 "Site"
label variable m11_3 "Semester"
label variable m11_4 "Section"
label variable m11_5 "Participant ID"
label variable m11_6 "Setting"


//----------------------------------------------------------------------------//
// mean Domain scores 
//----------------------------------------------------------------------------//

egen m15_8 = rowmean(m15*)
label variable m15_8 "Richness of Mathematics - Mean Score"

egen m16_4 = rowmean(m16*)
label variable m16_4 "Working with Students and Mathematics - Mean Score"

egen m17_5 = rowmean(m17*)
label variable m17_5 "Errors and Imprecision - Mean Score"

egen m18_7 = rowmean(m18*)
label variable m18_7 "Common_Core Aligned Student Practices (CCASP) - Mean Score"

//----------------------------------------------------------------------------//
// More cleaning
//----------------------------------------------------------------------------//

tab m11_2
encode m11_2, gen(m11_2_2)
drop m11_2
rename m11_2_2 m11_2
label define sites 1 "UVA" 2 "UD" 3 "JMU"
label values m11_2 sites 

tab m11_2
encode m11_3, gen(m11_3_2)
drop m11_3
rename m11_3_2 m11_3
recode m11_3 (1=0) (2=1)
label define sems 0 "F22" 1 "S23"
label values m11_3 sems 


}
