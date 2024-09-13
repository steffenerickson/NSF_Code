//----------------------------------------------------------------------------//
// Investigating the Structural Assumption Implied by a Latent Variable Model 
// Author: Steffen Erickson
// Date  : 9/2/24
//----------------------------------------------------------------------------//
clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/05_skill_development/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "measurement/data"
global output   "skill_development/output"
include ${programs}/mvgstudy.ado

use "${root}/${data}/manova_data.dta", clear
rename (task rater coaching) (t r treat)
label values treat . 
keep if r != 3 & time == 1
drop x6 
mkf covs 
frame covs: use "${root}/${data}/simse_validity.dta", clear
frame covs: keep participantid site semester k1 k2 k3 k4 k5 k6 k7
frame covs: tempfile data
frame covs: save `data'
merge m:1 site semester participantid using `data'
keep if _merge == 3 
drop _merge 
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester )
collapse x* k*, by(p treat block )
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)

sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x2)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x3)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x4)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x5)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x3*e.x5)

corr x* , cov

regress x4 x3 x1
regress x4 x2 x5
regress x4 x2 x1

forvalues i = 1/5 {
	local list x1 x2 x3 x4 x5 
	local remove x`i'
	local list: list list - remove 
	regress x`i' `list'
}



sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (K -> k?) (F2 <- F1) (F1 <- K) 

sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (K -> k?) (F2 <- F1) (F1 F2 <- K t) 


egen k = rowmean(k?)
egen eta1 = rowmean(x1 x2 x5)
egen eta2 = rowmean(x3 x4)


egen groups = cut(k), group(3)
regress eta1 i.groups 

forvalues i = 2/7 {
	gsem (k1 k2 k3 k4 k5 k6 k7 <- _cons), lclass(C `i')
	estimates store c`i'inv
}
estimates stats c2inv c3inv c4inv c5inv c6inv c7inv











