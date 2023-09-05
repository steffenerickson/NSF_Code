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
import excel "outcome_data/COSTI-QCI Coding_August 25, 2023_11.43.xlsx", sheet("Sheet0") firstrow case(lower) clear
keep finished q35-q12_8 sc*
drop if length(q60) < 5

//----------------------------------------------------------------------------//
// Rename Variables
//----------------------------------------------------------------------------//\


rename q60 c11_1 
rename q35 c12_1 //rater
rename q61 c13_1 //dc
rename q86 c14_1 //small group/whole group

local sub_domains l1 l2 l3 
foreach f of local sub_domains {
	loc `f' ""
	}
	
qui ds 
loc list1 `r(varlist)' 
foreach v of loc list1 {
	if strpos("`v'","q") > 0  & length("`v'") < 4 loc l1  : list l1  | v 
	if strpos("`v'","q12_") > 0 				  loc l2  : list l2  | v 
	if strpos("`v'","sc") > 0 					  loc l3  : list l3  | v 

}
loc i = 5
foreach domain of loc sub_domains {
	loc j = 1
	foreach item of loc `domain' {
		rename `item' c1`i'_`j'
		loc++j
	}
	loc++i
}

//----------------------------------------------------------------------------//
// Label Variables
//----------------------------------------------------------------------------//


foreach var of varlist c16* {
	replace `var' = subinstr(`var',"Select the level that you rate for each principle. - ","",.) in 1 
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
label define likert 0 "Level 1" 1 "Level 2" 2 "Level 3" 
label define Rater 8 "Coder 8" 9 "Coder 9" 10 "Coder 10"

qui ds, has(varl *Principle*)  
loc vars1 `r(varlist)'
foreach i of loc vars1 {
	encode `i' , gen(`i'_2) label(likert)
	drop `i'
	rename `i'_2 `i'
} 

destring c17* , replace
destring c15* , replace  

encode c12_1 , gen(c12_1_2) label(Rater)
drop c12_1
rename c12_1_2 c12_1

encode c13_1 , gen(c13_1_2) 
drop c13_1
rename c13_1_2 c13_1

encode c14_1 , gen(c14_1_2) 
drop c14_1
rename c14_1_2 c14_1

//-------------------

//----------------------------------------------------------------------------//
// Split file name into site, semester, sectionn , id, type 
//----------------------------------------------------------------------------//
split c11_1, parse("_")
loc id_vars `r(varlist)'
local i = 1
forvalues x = 2/6 {
	rename `:word `i' of `id_vars'' c11_`x'
	local++i
}

label variable c11_2 "Site"
label variable c11_3 "Semester"
label variable c11_4 "Section"
label variable c11_5 "Participant ID"
label variable c11_6 "Setting"

//----------------------------------------------------------------------------//
// More cleaning
//----------------------------------------------------------------------------//

tab c11_2
encode c11_2, gen(c11_2_2)
drop c11_2
rename c11_2_2 c11_2
label define sites 1 "UVA" 2 "UD" 3 "JMU"
label values c11_2 sites 

tab c11_2
encode c11_3, gen(c11_3_2)
drop c11_3
rename c11_3_2 c11_3
recode c11_3 (1=0) (2=1)
label define sems 0 "F22" 1 "S23"
label values c11_3 sems 


}
