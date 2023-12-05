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
import excel "outcome_data/NSF+MQI+Coding_June+7,+2023_09.03.xls", ///
sheet("NSF+MQI+Coding_June+7,+2023_09.") firstrow case(lower) clear

//keep q2-q40 q10* q11_1
drop in 2

//----------------------------------------------------------------------------//
// Rename Variables
//----------------------------------------------------------------------------//
forvalues x = 1/4 {
	forvalues i = 1/4 { 
		local a l`x'`i'
		local sub_domains: list sub_domains | a
	}
}
local sub_domains `sub_domains' l5
foreach f of local sub_domains {
	loc `f' ""
}
	
qui ds 
loc list1 `r(varlist)' 
foreach v of loc list1 {
	if strpos("`v'","q5") > 0 	loc l11  : list l11  | v //richness1 
	if strpos("`v'","q6") > 0 	loc l12  : list l12  | v //working w/ students1
	if strpos("`v'","q7") > 0 	loc l13  : list l13  | v //errors1
	if strpos("`v'","q8") > 0 	loc l14  : list l14  | v //common core1
	if strpos("`v'","q16") > 0 	loc l21  : list l21  | v //richness2
	if strpos("`v'","q17") > 0 	loc l22  : list l22  | v //working w/ students2 
	if strpos("`v'","q18") > 0 	loc l23  : list l23  | v //errors2
	if strpos("`v'","q19") > 0 	loc l24  : list l24  | v //common core2
	if strpos("`v'","q22") > 0 	loc l31  : list l31  | v //richness3
	if strpos("`v'","q23") > 0 	loc l32  : list l32  | v //working w/ students3
	if strpos("`v'","q24") > 0 	loc l33  : list l33  | v //errors3
	if strpos("`v'","q25") > 0 	loc l34  : list l34  | v //common core3
	if strpos("`v'","q28") > 0 	loc l41  : list l41  | v //richness4
	if strpos("`v'","q29") > 0 	loc l42  : list l42  | v //working w/ students4
	if strpos("`v'","q30") > 0 	loc l43  : list l43  | v //errors4
	if strpos("`v'","q31") > 0 	loc l44  : list l44  | v //common core4
	if strpos("`v'","q10") > 0 | strpos("`v'","q11") > 0 loc l5  : list l5  | v //whole lesson codes 
}

tokenize `sub_domains'
local n: list sizeof local(sub_domains)
forvalues x = 1/`n' {
	local a = substr("``x''",3,1)
	local i = substr("``x''",2,1)
	local domain ``x''
	local j = 1
	foreach item of loc `domain' {
		if "`i'" == "5" rename `item' m`i'_`j'
		else rename `item' m`a'_`j'`i'
		local++j
	}
}

rename  m5_* m9_*
rename  m4_* m8_* 
rename  m3_* m7_* 
rename  m2_* m6_* 
rename  m1_* m5_* 



rename q1  m1_1  // file name 
rename q2  m2_1  // rater 
rename q3  m4_1  // work connected to math?
rename q40 m3_1  // notes 
order m1_1 m2_1 m3_1 m4_1

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
local remove m1_1 m2_1 m3_1 m4_1 `vars1'
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

encode m4_1 , gen(m4_1_2) label(yesno)
drop m4_1
rename m4_1_2 m4_1

encode m2_1 , gen(m2_1_2) label(Rater)
drop m2_1
rename m2_1_2 m2_1

//----------------------------------------------------------------------------//
// Split file name into site, semester, sectionn , id, type 
//----------------------------------------------------------------------------//
split m1_1, parse("_")
loc id_vars `r(varlist)'
local i = 1
forvalues x = 2/6 {
	rename `:word `i' of `id_vars'' m1_`x'
	local++i
}

label variable m1_2 "Site"
label variable m1_3 "Semester"
label variable m1_4 "Section"
label variable m1_5 "Participant ID"
label variable m1_6 "Setting"



//----------------------------------------------------------------------------//
// Reshape multiple segments to long 
//----------------------------------------------------------------------------//


egen tag = tag(m1_2 m1_3 m1_5 m2_1) 
drop if tag == 0
drop tag



local var_stubs m5_1 m5_2 m5_3 m5_4 m5_5 m5_6 m5_7 m6_1 m6_2 m6_3 m7_1 ///
m7_2 m7_3 m7_4 m8_1 m8_2 m8_3 m8_4 m8_5 m8_6 

*save variable labels for segment codes 
foreach v of local var_stubs {
        local l`v' : variable label `v'1
 }
 
reshape long `var_stubs' , i(m1_2 m1_3 m1_5 m2_1) j(segment)

foreach v of local var_stubs {
        label var `v' "`l`v''"
 }

 label values m9_* 

*/

//----------------------------------------------------------------------------//
// mean Domain scores 
//----------------------------------------------------------------------------//

egen m5_8 = rowmean(m5*)
label variable m5_8 "Richness of Mathematics - Mean Score"

egen m6_4 = rowmean(m6*)
label variable m6_4 "Working with Students and Mathematics - Mean Score"

egen m7_5 = rowmean(m7*)
label variable m7_5 "Errors and Imprecision - Mean Score"

egen m8_7 = rowmean(m8*)
label variable m8_7 "Common_Core Aligned Student Practices (CCASP) - Mean Score"

//----------------------------------------------------------------------------//
// More cleaning
//----------------------------------------------------------------------------//

*remove missing segments 
drop if m5_8 == .
tab m1_2
encode m1_2, gen(m1_2_2)
drop m1_2
rename m1_2_2 m1_2
label define sites 1 "UVA" 2 "UD" 3 "JMU"
label values m1_2 sites 

tab m1_2
encode m1_3, gen(m1_3_2)
drop m1_3
rename m1_3_2 m1_3
recode m1_3 (1=0) (2=1)
label define sems 0 "F22" 1 "S23"
label values m1_3 sems 


}
