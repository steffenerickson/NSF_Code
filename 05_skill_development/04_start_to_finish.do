//----------------------------------------------------------------------------//
// Investigating the Structural Assumption Implied by a Latent Variable Model 
// Author: Steffen Erickson
// Date  : 9/2/24
// Note : Need to start a mata code base because the functions are starting to 
// sse the same sub functions. Code breaks when the function is called when it 
// is already in memory 
//----------------------------------------------------------------------------//


clear all
mata mata clear
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/05_skill_development/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "measurement/data"
global output   "skill_development/output"
include ${programs}/mvgstudy.ado
include ${programs}/semgenerate.do

// Cleaning and imputing missing values 
use "${root}/${data}/manova_data.dta", clear
rename (task rater coaching) (t r treat)
label values treat . 
keep if time == 1 & ( treat == 0 | treat == 1) & r != 3
drop x6
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)
fillin t r p 
forvalues i = 1/5 {
	tempvar temp
	regress x`i' i.p i.t i.r i.p#i.t i.p#i.r i.t#i.r
	predict `temp'
	replace x`i' = `temp' if x`i' == . 
}

// Covariance Components from factorial decomposition
sort p t r 
by p : gen n = _n
mvgstudy (x1 x2 x3 x4 x5 = p n|p)
mat true   = r(covcomps1)
mat error    = r(covcomps2)  
mat tot = true + error 
clear
ssd init x1 x2 x3 x4 x5
ssd set obs 146
ssd set cov (stata) tot
sem (F1 -> x2 x1 x5) (F2 -> x3 x4), standardized 





clear
ssd init x1 x2 x3 x4 x5
ssd set obs 146
ssd set cov (stata) true
sem (F1 -> x2 x1 x5) (F2 -> x3 x4), standardized 










/*
keep p k?
alpha k?
reshape long k , i(p) j(i)
mvgstudy (k = p i#p)
di .013858 / (.013858 + .0714598/7)
*/








