clear all 
version 18

//----------------------------------------------------------------------------//
// Set Up 
//----------------------------------------------------------------------------//
* Set up directories 
local office 0
if `office' == 1 {
	global root 	"C:/Users/cns8vg"
	global code 	"GitHub/NSF_Code/02_measurement"  
	global programs "GitHub/stata_programs"
	global data     "Box Sync/NSF_DR_K12/measurement/data"
	global output 	"Box Sync/NSF_DR_K12/measurement/output"
}
if `office' == 0 {
	global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement"
	global code     "Users/steffenerickson/Documents/GitHub/NSF_Code/02_measurement/code"
	global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
	global data     "data"
	global output   "output"
}
// mvgstudy command 
include "${programs}/mvgstudy.ado"
use "${root}/${data}/manova_data.dta", clear

// Limit to balanced sample 
drop x6
rename (task rater coaching) (t r treat)
drop if (r == 3) | (treat == 2) | (x1 == . | x2 == . | x3 == . | x4 == . | x5 == .) | time == 2
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
bysort p : gen n = _n 
egen c  = count(n) , by(p)
keep if c == 12
save "${root}/${data}/gstudy_sample.dta" , replace
drop id site semester c n participantid dupes




//----------------------------------------------------------------------------//
// Reliability Figures for weighting strategies
//----------------------------------------------------------------------------//

// Time 0 


mat w1  = (.2,.2,.2,.2,.2)'


mvgstudy (x* = p t  p#t r|t p#r|t)  if time == 0
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
capture matrix drop result
forvalues i = 1/6 {
	forvalues j = 1/6 {
		mata w = st_matrix("w1")
		mata sigma_t  = w'*t*w
		mata sigma_e1 = w'*e1*w
		mata sigma_e2 = w'*e2*w
		mata sigma_e3 = w'*e3*w
		mata sigma_e4 = w'*e4*w
		mata g = sigma_t /  (sigma_t + (sigma_e2 / `i') + (sigma_e4 / (`i' * `j')))
		mata st_numscalar("g",g)
		mat result = (nullmat(result) \ (1, `i',`j',g))
	}
}

mkf comp_rel
frame comp_rel {
	clear
	svmat result 
	rename (result1 result2 result3 result4) (weight task rater g)
	
	twoway  (scatter g task  if rater == 1 , connect(l)) ///
			(scatter g task  if rater == 2 , connect(l)) ///
			(scatter g task  if rater == 3 , connect(l)) ///
			(scatter g task  if rater == 4 , connect(l)) ///
			(scatter g task  if rater == 5 , connect(l)) ///
			(scatter g task  if rater == 6 , connect(l)) , ///
			legend(order(1 "1 Rater" 2 "2 Raters" 3 "3 Raters" 4 "4 Raters" 5 "5 Raters" 6 "6 Raters")  pos(5) ring(0) rows(1) size(small)) ///
			xtitle("Tasks") ytitle("Generalizability Coefficient") yscale(range(.1(.1)1)) ylabel(.1(.1)1, nogrid) xlabel(,nogrid) ///
			title("Diagnostic", size(small)) name(g1 , replace) yline(.80)
		
}

mvgstudy (x* = p t  p#t r|t p#r|t)  if time == 1
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
capture matrix drop result
forvalues i = 1/6 {
	forvalues j = 1/6 {
		mata w = st_matrix("w1")
		mata sigma_t  = w'*t*w
		mata sigma_e1 = w'*e1*w
		mata sigma_e2 = w'*e2*w
		mata sigma_e3 = w'*e3*w
		mata sigma_e4 = w'*e4*w
		mata g = sigma_t /  (sigma_t + (sigma_e2 / `i') + (sigma_e4 / (`i' * `j')))
		mata st_numscalar("g",g)
		mat result = (nullmat(result) \ (1, `i',`j',g))
	}
}

frame comp_rel {
	clear 
	svmat result 
	rename (result1 result2 result3 result4) (weight task rater g)
	
	twoway  (scatter g task if  rater == 1 , connect(l)) ///
			(scatter g task if  rater == 2 , connect(l)) ///
			(scatter g task if  rater == 3 , connect(l)) ///
			(scatter g task if  rater == 4 , connect(l)) ///
			(scatter g task if  rater == 5 , connect(l)) ///
			(scatter g task if  rater == 6 , connect(l)) , ///
			legend(order(1 "1 Rater" 2 "2 Raters" 3 "3 Raters" 4 "4 Raters" 5 "5 Raters" 6 "6 Raters")  pos(5) ring(0) rows(1) size(small)) ///
			xtitle("Tasks") ytitle("Generalizability Coefficient") yscale(range(.1(.1)1)) ylabel(.1(.1)1, nogrid) xlabel(,nogrid) ///
			title("Formative", size(small)) name(g2 , replace) yline(.80)
		
	}

frame drop comp_rel


grc1leg2 g1 g2, legendfrom(g1) title("Reliability of Performance Tasks by Use", size(medium)) rows(1) name(g1, replace) altshrink

graph export "${root}/${output}/dstudy_aefp.png" , replace




