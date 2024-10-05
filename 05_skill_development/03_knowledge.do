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
include ${programs}/permutationsandcombinations.do


use "${root}/${data}/manova_data.dta", clear
rename (task rater coaching) (t r treat)
label values treat . 
keep if r != 3 & time == 1
drop x6 
mkf covs 
frame covs: use "${root}/${data}/simse_validity.dta", clear
frame covs: keep participantid site semester k1 k2 k3 k4 k5 k6 k7 m1 m2 m3 m5 m4
frame covs: tempfile data
frame covs: save `data'
merge m:1 site semester participantid using `data'
keep if _merge == 3 
drop _merge 
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester )
collapse x* k* m*, by(p treat block )
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)

sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x2)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x3)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x4)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x1*e.x5)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , cov(e.x3*e.x5)

sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) 
estimates store m1
sem (K -> k?) (F1 -> x1 x2@1 x5 x3 x4) 
estimates store m2
lrtest m1 m2 


sem (m2 <- t)

sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) , standardized



foreach v of varlist k? x? {
	tempvar temp 
	egen `temp' = std(`v')
	replace `v' = `temp'
}


sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) //, standardized


sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) (F1 x2 <- K) (F2 <- F1), var(e.x2@0) //, standardized



sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) (F1 <- K t) (F2 <- F1) //, standardized
estimates store m1 
sem (K -> k?) (F1 -> x1 x2@1 x5 x3 x4) (F1 <- K t)  //, standardized
estimates store m2 

lrtest m1 m2 

sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) (K F1 F2 -> m1), standardized
sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) (K F1 F2 -> m1), standardized
sem (K -> k?) (F1 -> x1 x2@1 x5 x3 x4) (K F1  -> m2), standardized





sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) (K F1 F2 -> m3), standardized


sem (K -> k?) (F1 -> x1 x2@1 x5) (F2 -> x3 x4) (K -> F1) (F1 -> F2) (K F1 F2 <- t), standardized


sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4) (F1 -> F2) , standardized




sem (K -> k?) (F2 -> x3 x4) (K -> F2) , standardized




corr x* , cov



combinations , n(4) k(2)
mat choices = r(combinations)
forvalues i = 1/5 {
	local list x1 x2 x3 x4 x5 
	local outcome x`i'
	local list: list list - outcome  
	forvalues i = 1/`:rowsof(choices)' {
		local a = choices[`i',1]
		local b = choices[`i',2]
		regress `outcome' `:word `a' of `list'' `:word `b' of `list''
	}
}



forvalues i = 1/5 {
	local list x1 x2 x3 x4 x5 
	local remove x`i'
	local list: list list - remove 
	regress x`i' `list' // if treat == 0
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


clear all
mata mata clear
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/05_skill_development/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "measurement/data"
global output   "skill_development/output"

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

keep x? p t
collapse x* , by(p t)
reshape wide x* , i(p) j(t)

sem (x1)








