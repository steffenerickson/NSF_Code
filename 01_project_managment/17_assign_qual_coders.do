//----------------------------------------------------------------------------//
// 
//
//----------------------------------------------------------------------------//
set seed 1234 
clear 
frame reset

//-----------------------------------------------------------------------------//
// Permin Program 
//-----------------------------------------------------------------------------//

cap prog drop permin_2
program define permin_2
version 17

syntax varlist(min=1 max=1) [if] [in] [, k(integer 5)]

capture count if `varlist' == .
capture count if `varlist' == "." | `varlist' ==""
	if r(N) != 0 {
            di as err "missing values in varlist"
            exit 198
	}
capture duplicates report `varlist'
if  r(N) !=r(unique_value) {
	di as err "duplicate values in varlist"
           exit 198
}
marksample touse
 if `k'< 2 {
	di in re "k must be greater than 2"
	exit 198
	}
qui describe `varlist'
 if `k'>r(N) {
	di in re "k must be less than or equal to N"
	exit 198
	}

* Generates k rows 
gen `varlist'_1=`varlist'
gen `varlist'_2=`varlist'
if `k' >= 3 {
	forvalues i = 3/`k' {
		gen `varlist'_`i'=`varlist'
		if `i' == 3 {
			global vars `varlist'_`i'
		}
		else {
			global vars ${vars} `varlist'_`i'
			di ${vars}
		}
	}
}
global vars `varlist'_1 `varlist'_2 ${vars}
keep ${vars}
qui describe ${vars}
scalar k=r(k)
scalar N=r(N)
scalar list k N

* Expands data
qui fillin ${vars}
qui drop _fillin

* Drops duplicate rows 
local j = `k' - 1
local first `1'
local i = 2
tokenize ${vars}
forvalues g = 1/`j' {
	forvalues x = 1/`g' {
		capture drop if ``x'' == ``i''
	}
	local++i	
}
order ${vars}
sort  ${vars}
qui describe ${vars}
display in yellow "Permutations Formed: " r(N)
scalar drop _all

end 

//----------------------------------------------------------------------------//
 * Rater assignments start here 
 * Steps 
	* Generates random sample of rater permutations
	* Randomly assigns rater permutations to participants
	* Drops assignments when participants are missing responses
//----------------------------------------------------------------------------//




//----------------------------------------------------------------------------//
// Create Rater permutations
//----------------------------------------------------------------------------//
mkf raters
frame change raters
clear 
matrix raters = (1,2,3,4,5,6,7,8)'
matrix colnames raters = "rater"
svmat raters , names(col)
permin_2 rater, k(8)
gen ordering = _n
gen randnum = runiform()
sort randnum
gen p = _n
keep if p <= 245

//----------------------------------------------------------------------------//
// Create dataset with participants observtions if there was no missing data
//----------------------------------------------------------------------------//

mkf participants 
frame change participants 
numlist "1(1)245"  
loc nlist `r(numlist)'
loc num : list sizeof local(nlist)
capture matrix drop M 
forvalues x = 1/`num' {
	matrix M = (nullmat(M) \ `:word `x' of `nlist'')
}
matrix double_code = (1,2)'
matrix time_points = (1,2,3,4)'
matrix raters_points = (1,2,3,4)'
matrix obs = M , (time_points \ J(241,1,.)) ,(double_code \ J(243,1,.))

matrix colnames obs = "p" "t" "d"
svmat obs , names(col)
fillin p t d
drop if t == . | d ==. 
drop _fillin 

gen index = _n
reshape wide index, i(p t) j(d)
reshape wide index1 index2, i(p) j(t)
rename index* response*

//----------------------------------------------------------------------------//
// Assign the raters to the participants 
//----------------------------------------------------------------------------//

frame raters {
	tempfile raters 
	save `raters'
}
merge 1:1 p using `raters'

ds, has(varl *index*)
local List `r(varlist)'
local i = 1 
foreach v of local List {
	replace `v' = rater_`i'
	local++i 
}

drop rater* randnum ordering _merge

corr response*

reshape long response1 response2, i(p) j(time)
reshape long response, i(p time) j(dc)
rename response rater 

forvalues x = 1/10 {
	table time rater if p == `x' , nototals
}


//----------------------------------------------------------------------------//
// Bring in obsevered data (observations missing) and match with fake full data 
//----------------------------------------------------------------------------//

mkf observed 
frame change observed
import delimited "/Users/steffenerickson/Desktop/KM_to_code.csv" , clear 
split unique_id , parse(-)
rename unique_id1 site 
rename unique_id2 semester
rename unique_id3 person
drop unique_id4

egen p = group(site semester person duplicates)
sum p
sort p 

label define t 1 "1" 2 "2" 3 "2a" 4 "3"
encode timepoint, gen(time) label(t)
drop site semester timepoint

tempfile data 
save `data' 
append using `data' , gen(dc)
label drop _append 
recode dc (0 = 1) (1 = 2)
sort p time dc


* Merge in assignmentsg
frame participants  {
	tempfile data
	save `data'
}
merge 1:1 p time dc using `data'

keep if _merge == 3
drop _merge 

forvalues x = 20/30 {
	table time rater if p == `x' , nototals
}

tab rater









