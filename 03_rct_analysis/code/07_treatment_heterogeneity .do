clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/rct"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/03_rct_analysis/code"
global data     "data"
global output   "output"
global output   "output"

* Import files 
local filelist : dir "${root}/${output}/" files "*.dta"
if `:word count `filelist'' < 3 {
	do "{code}/02_data_set_up.do"
}
frame reset 
local filelist : dir "${root}/${output}/" files "*.dta"
local i = 1 
foreach file of local filelist {
	mkf fr`i'
	frame fr`i' : use "${root}/${output}/`file'" , clear
	local++i
}

global covariates pre_simse d162 d167 d126_1 d126_2 d126_3 d126_4 d126_5 d132 d142 d156_1 d156_2 d156_3 d156_4 d156_5 d921 d107 white male 

* Models
// ---- Simse
frame change fr3 

drop if time == 0 
regress simse_s i.t i.block i.task i.rater $covariates *_im if time == 1, vce(cluster id)


//----------------------------------------------------------------------------//
// Simse Site Dependent Treatment Heterogeneity 
//----------------------------------------------------------------------------//

regress simse_s i.t  i.task i.rater $covariates *_im if time == 1, vce(cluster id)
regress simse_s i.t  i.model_num i.rater $covariates *_im if time == 2, vce(cluster id)

regress simse_s i.block##i.t i.task i.rater $covariates *_im if time == 1, vce(cluster id)
contrasts g.block#j.t

mat a = r(table)'
mat li a
mat coefs = (r(table)[1,1...] + J(1,colsof(r(table)),.95)) \ (r(table)[5,1...] + J(1,colsof(r(table)),.95)) \(r(table)[6,1...] + J(1,colsof(r(table)),.95))

mat colnames coefs  = "Site 1 Fall" "Site 1 Spring" "Site 2 Fall" "Site 2 Spring"
coefplot matrix(coefs), ci((2 3)) horizontal ///
msymbol(circle) msize(medium) mcolor(eltgreen) mlcolor(black) ///
ciopts(lcolor(ebblue)) ///
xtitle("Contrast from Average Effect", size(medium)) ///
xline(.95) ylabel(,nogrid) xscale(range(-.4(.2)2)) xlabel(-.4(0.2)2,nogrid) ///
title("Performance Task") ///
name(g1, replace) ylabel(, angle(45))


regress simse_s i.block##i.t i.model_num i.rater $covariates *_im if time == 2, vce(cluster id)
contrasts g.block#j.t

mat a = r(table)'
mat li a
mat coefs = (r(table)[1,1...] + J(1,colsof(r(table)),.76)) \ (r(table)[5,1...] + J(1,colsof(r(table)),.76)) \(r(table)[6,1...] + J(1,colsof(r(table)),.76))

mat colnames coefs  = "Site 1 Fall" "Site 1 Spring" "Site 2 Fall" "Site 2 Spring"
coefplot matrix(coefs), ci((2 3)) horizontal ///
msymbol(circle) msize(medium) mcolor(eltgreen) mlcolor(black) ///
ciopts(lcolor(ebblue)) ///
xtitle("Contrast from Average Effect", size(medium)) ///
xline(.76) ylabel(,nogrid) xscale(range(-.4(.2)2)) xlabel(-.4(0.2)2 ,nogrid) ///
title("Classroom Task") ///
name(g2, replace) ylabel(, angle(45))


graph combine g1 g2, altshrink xcommon rows(1) title("Site/Semester Dependent Treatment Heterogeneity")


//----------------------------------------------------------------------------//
// Simse Item Dependent Treatment Heterogeneity 
//----------------------------------------------------------------------------//

preserve
collapse $covariates *_im , by(block id)
keep block id $covariates *_im 
tempfile data 
save `data'
restore

keep x* t block task rater time id model_num
reshape long x ,  i(t block task rater time id model_num) j(item)
merge m:1 id block using `data'
egen stdx = std(x)



regress stdx i.t i.block i.task i.rater $covariates *_im if time == 1, vce(cluster id)

regress stdx i.t i.block i.model_num i.rater $covariates *_im if time == 2, vce(cluster id)

regress stdx i.item##i.t i.block i.task i.rater $covariates *_im if time == 1, vce(cluster id)
contrasts g.item#j.t

mat a = r(table)'
mat li a
mat coefs = (r(table)[1,1...] + J(1,colsof(r(table)),.49)) \ (r(table)[5,1...] + J(1,colsof(r(table)),.49)) \(r(table)[6,1...] + J(1,colsof(r(table)),.49))

mat colnames coefs  = "Objective" "Unpacking" "Self-instruction" "Self-regulation" "Ending" "Accuracy"
coefplot matrix(coefs), ci((2 3)) horizontal ///
msymbol(circle) msize(medium) mcolor(eltgreen) mlcolor(black) ///
ciopts(lcolor(ebblue)) ///
xtitle("Contrast from Average Effect", size(medium)) ///
xline(.49) ylabel(,nogrid) xscale(range(-.4(.2)1.2)) xlabel(-.4(0.2)1.2,nogrid) ///
title("Performance Task") ///
name(g1, replace) ylabel(, angle(45))


regress stdx i.item##i.t i.block i.model_num i.rater $covariates *_im if time == 2, vce(cluster id)
contrasts g.item#j.t

mat a = r(table)'
mat li a
mat coefs = (r(table)[1,1...] + J(1,colsof(r(table)),.39)) \ (r(table)[5,1...] + J(1,colsof(r(table)),.39)) \(r(table)[6,1...] + J(1,colsof(r(table)),.39))

mat colnames coefs  = "Objective" "Unpacking" "Self-instruction" "Self-regulation" "Ending" "Accuracy"
coefplot matrix(coefs), ci((2 3)) horizontal ///
msymbol(circle) msize(medium) mcolor(eltgreen) mlcolor(black) ///
ciopts(lcolor(ebblue)) ///
xtitle("Contrast from Average Effect", size(medium)) ///
xline(.39) ylabel(,nogrid) xscale(range(-.4(.2)1.2)) xlabel(-0.4(0.2)1.2 ,nogrid) ///
title("Classroom Task") ///
name(g2, replace) ylabel(, angle(45))


graph combine g1 g2, altshrink xcommon rows(1) title("Item Dependent Treatment Heterogeneity")




preserve

drop if item == 6
collapse stdx $covariates *_im , by(id task item block t)

regress stdx i.item##i.t i.task /*  $covariates *_im*/, vce(cluster id)
contrasts g.item#j.t

mat a = r(table)'
mat li a
mat coefs = (r(table)[1,1...] + J(1,colsof(r(table)),.39)) \ (r(table)[5,1...] + J(1,colsof(r(table)),.39)) \(r(table)[6,1...] + J(1,colsof(r(table)),.39))

mat colnames coefs  = "Objective" "Unpacking" "Self-instruction" "Self-regulation" "Ending" 
coefplot matrix(coefs), ci((2 3)) horizontal ///
msymbol(circle) msize(medium) mcolor(eltgreen) mlcolor(black) mlabel mlabformat(%9.3f) ///
ciopts(lcolor(ebblue)) ///
xtitle("Effect Estimates", size(medium)) ///
xline(.39) ylabel(,nogrid) xscale(range(-.4(.2)1.2)) xlabel(-0.4(0.2)1.2 ,nogrid) ///
title("Item Dependent Treatment Heterogeneity") ///
name(g2, replace) ylabel(, angle(45))


restore














