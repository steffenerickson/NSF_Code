*------------------------------------------------------------------------------*  
/*
Title: Permin Program 
Authors: Steffen Erikson
Date: 12/5/22
Purpose: genrerate permuations from a set. P(n,k) = the number of ways 
to choose k items from n distinct items, where the order of the items matters. 

*/ 

*------------------------------------------------------------------------------*  

*------------------------------------------------------------------------------*
* Permin Program 
*------------------------------------------------------------------------------*

cap prog drop permin
set more off
program define permin
version 17

*Program Syntax *

syntax varlist(min=1 max=1) [if] [in] [, k(integer 5)]

* REQUIRED                 
* 	varlist(min=1 max=1) - set that permuations are generated from 
*   k - the ordered arrangements of k distinct elements selected from the set    

*varlist must have all unique values       

*---------------------------------------------------*
* Controls 
*---------------------------------------------------*

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
*---------------------------------------------------*
* Code Body
*---------------------------------------------------*

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

