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
// Item Level Variance Components 
//----------------------------------------------------------------------------//

forvalues i = 1/5 {
	mvgstudy (x`i' = p t  p#t r|t p#r|t) if time == 0
	mata sigma_t  = st_matrix("r(covcomps1)")
	mata sigma_e1 = st_matrix("r(covcomps2)")
	mata sigma_e2 = st_matrix("r(covcomps3)")
	mata sigma_e3 = st_matrix("r(covcomps4)")
	mata sigma_e4 = st_matrix("r(covcomps5)")
	mata stacked = sigma_t \ sigma_e1 \ sigma_e2 \ sigma_e3 \ sigma_e4 
	mata CIs = satterthwaite(stacked,df,.80)
	mata prop = stacked :/ colsum(stacked)
	mata results = stacked, CIs, prop
	mata results = mm_cond(results :< 0, 0, results)
	mata results1`i' = round(results,.001)
}
mata results1 = results11\results12\results13\results14\results15


forvalues i = 1/5 {
	mvgstudy (x`i' = p t  p#t r|t p#r|t) if time == 1
	mata sigma_t  = st_matrix("r(covcomps1)")
	mata sigma_e1 = st_matrix("r(covcomps2)")
	mata sigma_e2 = st_matrix("r(covcomps3)")
	mata sigma_e3 = st_matrix("r(covcomps4)")
	mata sigma_e4 = st_matrix("r(covcomps5)")
	mata stacked = sigma_t \ sigma_e1 \ sigma_e2 \ sigma_e3 \ sigma_e4 
	mata CIs = satterthwaite(stacked,df,.80)
	mata prop = stacked :/ colsum(stacked)
	mata results = stacked, CIs, prop
	mata results = mm_cond(results :< 0, 0, results)
	mata results2`i' = round(results,.001)
}
mata results2 = results21\results22\results23\results24\results25


mata prepostresults = results1,results2
mata st_matrix("prepostresults",prepostresults)
mata st_matrix("prepostresults",prepostresults)
mat rownames prepostresults = 						  				 ///
"Setting an Objective (x1):p" "Setting an Objective (x1):t" "Setting an Objective (x1):p $\times$ t" "Setting an Objective (x1):r $|$ t" "Setting an Objective (x1):p $\times$ r $|$ t" ///
"Unpacking the Word Problem (x2):p" "Unpacking the Word Problem (x2):t" "Unpacking the Word Problem (x2):p $\times$ t" "Unpacking the Word Problem (x2):r $|$ t" "Unpacking the Word Problem (x2):p $\times$ r $|$ t" ///
"Self-Instruction (x3):p" "Self-Instruction (x3):t" "Self-Instruction (x3):p $\times$ t" "Self-Instruction (x3):r $|$ t" "Self-Instruction (x3):p $\times$ r $|$ t" ///
"Self-Regulation (x4):p" "Self-Regulation (x4):t" "Self-Regulation (x4):p $\times$ t" "Self-Regulation (x4):r $|$ t" "Self-Regulation (x4):p $\times$ r $|$ t" ///
"Ending the Model (x5):p" "Ending the Model (x5):t" "Ending the Model (x5):p $\times$ t" "Ending the Model (x5):r $|$ t" "Ending the Model (x5):p $\times$ r $|$ t"
frmttable using "${root}/${output}/itemlevelvarcomps.tex", ///
statmat(prepostresults) ///
sdec(3) ///
ctitles("","", "Pre Coursework","", "","","Post Coursework","","","" \ "","", "var","lci","uci","prop","var","lci","uci","prop" )  ///
/*title("Composite Score Variance Components ")*/ ///
multicol(1,3,4;1,7,4)  ///
coljust(c) ///
tex ///
fragment ///
replace

//----------------------------------------------------------------------------//
// Item Level Reliability Figures 
//----------------------------------------------------------------------------//

// Time 0 
capture matrix drop result
forvalues w = 1/5 {
	mvgstudy (x`w' = p t  p#t r|t p#r|t)  if time == 0
	mata sigma_t  = st_matrix("r(covcomps1)")
	mata sigma_e1 = st_matrix("r(covcomps2)")
	mata sigma_e2 = st_matrix("r(covcomps3)")
	mata sigma_e3 = st_matrix("r(covcomps4)")
	mata sigma_e4 = st_matrix("r(covcomps5)")
	forvalues i = 1/6 {
		forvalues j = 1/6 {

			mata g = sigma_t /  (sigma_t + (sigma_e2 / `i') + (sigma_e4 / (`i' * `j')))
			mata st_numscalar("g",g)
			mat result = (nullmat(result) \ (`w', `i',`j',g))
		}
	}
}

mkf comp_rel
frame comp_rel {
	svmat result 
	rename (result1 result2 result3 result4) (item task rater g)
	
	forvalues i = 1/5 {
		
		if `i' == 1 local name "x1: Setting an Objective"
		if `i' == 2 local name "x2: Unpacking the Word Problem"
		if `i' == 3 local name "x3: Self-Instruction"
		if `i' == 4 local name "x4: Self-Regulation"
		if `i' == 5 local name "x5: Ending the Model"
		
		twoway  (scatter g task if item == `i' & rater == 1 , connect(l)) ///
				(scatter g task if item == `i' & rater == 2 , connect(l)) ///
				(scatter g task if item == `i' & rater == 3 , connect(l)) ///
				(scatter g task if item == `i' & rater == 4 , connect(l)) ///
				(scatter g task if item == `i' & rater == 5 , connect(l)) ///
				(scatter g task if item == `i' & rater == 6 , connect(l)) , ///
				legend(order(1 "1 Rater" 2 "2 Raters" 3 "3 Raters" 4 "4 Raters" 5 "5 Raters" 6 "6 Raters")  pos(5) ring(0) rows(1) size(small)) ///
		xtitle("Tasks") ytitle("Generalizability Coefficient") yscale(range(.1(.1)1)) ylabel(.1(.1)1, nogrid) xlabel(,nogrid) ///
		title("`name'", size(small)) name(g`i' , replace) yline(.80)
		
	}
	
	grc1leg2 g1 g2 g3 g4 g5, legendfrom(g1) title("Item Level Reliabilities (Pre Coursework)" , size(medium)) rows(2) name(g1, replace) altshrink
	graph export "${root}/${output}/itemlevel_dstudy0.png" , replace
	graph export "${root}/${output}/itemlevel_dstudy0.jpg" , replace
}
frame drop comp_rel

// Time 1 
capture matrix drop result
forvalues w = 1/5 {
	mvgstudy (x`w' = p t  p#t r|t p#r|t)  if time == 1
	mata sigma_t  = st_matrix("r(covcomps1)")
	mata sigma_e1 = st_matrix("r(covcomps2)")
	mata sigma_e2 = st_matrix("r(covcomps3)")
	mata sigma_e3 = st_matrix("r(covcomps4)")
	mata sigma_e4 = st_matrix("r(covcomps5)")
	forvalues i = 1/6 {
		forvalues j = 1/6 {

			mata g = sigma_t /  (sigma_t + (sigma_e2 / `i') + (sigma_e4 / (`i' * `j')))
			mata st_numscalar("g",g)
			mat result = (nullmat(result) \ (`w', `i',`j',g))
		}
	}
}

mkf comp_rel
frame comp_rel {
	svmat result 
	rename (result1 result2 result3 result4) (item task rater g)
	
	forvalues i = 1/5 {
		
		if `i' == 1 local name "x1: Setting an Objective"
		if `i' == 2 local name "x2: Unpacking the Word Problem"
		if `i' == 3 local name "x3: Self-Instruction"
		if `i' == 4 local name "x4: Self-Regulation"
		if `i' == 5 local name "x5: Ending the Model"
		
		twoway  (scatter g task if item == `i' & rater == 1 , connect(l)) ///
				(scatter g task if item == `i' & rater == 2 , connect(l)) ///
				(scatter g task if item == `i' & rater == 3 , connect(l)) ///
				(scatter g task if item == `i' & rater == 4 , connect(l)) ///
				(scatter g task if item == `i' & rater == 5 , connect(l)) ///
				(scatter g task if item == `i' & rater == 6 , connect(l)) , ///
				legend(order(1 "1 Rater" 2 "2 Raters" 3 "3 Raters" 4 "4 Raters" 5 "5 Raters" 6 "6 Raters")  pos(5) ring(0) rows(1) size(small)) ///
		xtitle("Tasks") ytitle("Generalizability Coefficient") yscale(range(.1(.1)1)) ylabel(.1(.1)1, nogrid) xlabel(,nogrid) ///
		title("`name'", size(small)) name(g`i' , replace) yline(.80)
		
	}
	
	grc1leg2 g1 g2 g3 g4 g5, legendfrom(g1) title("Item Level Reliabilities (Post Coursework)" , size(medium)) rows(2) name(g1, replace) altshrink
	graph export "${root}/${output}/itemlevel_dstudy1.png" , replace
	graph export "${root}/${output}/itemlevel_dstudy1.jpg" , replace
}
frame drop comp_rel


//----------------------------------------------------------------------------//


mata rel_pre = J(0,1,.)
forvalues i = 1/5 {
	mvgstudy (x`i' = p t  p#t r|t p#r|t)  if time == 0
	mata sigma_t  = st_matrix("r(covcomps1)")
	mata sigma_e1 = st_matrix("r(covcomps2)")
	mata sigma_e2 = st_matrix("r(covcomps3)")
	mata sigma_e3 = st_matrix("r(covcomps4)")
	mata sigma_e4 = st_matrix("r(covcomps5)")
	mata rel_pre = rel_pre \ (sigma_t / (sigma_t + (sigma_e2/ 3) + (sigma_e4 / 6)))
}


mata rel_post = J(0,1,.)
forvalues i = 1/5 {
	mvgstudy (x`i' = p t  p#t r|t p#r|t)  if time == 1
	mata sigma_t  = st_matrix("r(covcomps1)")
	mata sigma_e1 = st_matrix("r(covcomps2)")
	mata sigma_e2 = st_matrix("r(covcomps3)")
	mata sigma_e3 = st_matrix("r(covcomps4)")
	mata sigma_e4 = st_matrix("r(covcomps5)")
	mata rel_post = rel_post \   (sigma_t / (sigma_t + (sigma_e2/ 3) + (sigma_e4 / 6)))
}




mata st_matrix("rel_pre",rel_pre)
mata st_matrix("rel_post",rel_post)



mata rel`i' = sigma_t / (sigma_t + (sigma_e2/ 3) + (sigma_e4 / 6))

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Extrapolation Inference 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//




//----------------------------------------------------------------------------//
// Pre Coursework 
//----------------------------------------------------------------------------//
use "${root}/${data}/simse_validity.dta" , clear

rename coaching t
keep if t == 0 | t == 1 
drop if xc21 == . & m2_1 == . 
save "${root}/${data}/extrapolation_sample.dta" , replace
egen block = group(site semester)
tab block , gen(b_)
egen k = rowmean(k?)
egen xC = rowmean(xc??)
egen x0 = rowmean(x??0)
egen q = rowmean(c6_?)
egen m = rowmean(m1 m2 m3 m4 m5)
egen s_xC = std(xC)
egen s_q  = std(q)
egen s_m  = std(m)
egen x1 = rowmean(x1?0r)
egen x2 = rowmean(x2?0r)
egen x3 = rowmean(x3?0r)
egen x4 = rowmean(x4?0r)
egen x5 = rowmean(x5?0r)

capture matrix drop results1 
foreach o in xC q m {
	capture matrix drop row
	forvalues i = 1/5 {
		local rel = rel_pre[`i',1]
		sem (X -> x`i') (`o' <- X), reliability(x`i' `rel') method(mlmv) standardized
		mat row = (nullmat(row),(e(b_std)[1,3], r(table)[5,3], r(table)[6,3]))
	}
	mat results1 = (nullmat(results1) \ row)
}

matrix rownames results1 = "Metacognitive Model" "QCI" "MQI"
matrix dcols = (0,0,1,0,0,1,0,0,1,0,0,1,0,0,1)
frmttable using "${root}/${output}/itemlevel_extrapolationpre.tex", ///
statmat(results1) ///
substat(1) ///
doubles(dcols) ///
ctitles("", "x1","x2","x3","x4","x5") ///
coljust(c) ///
tex ///
fragment ///
replace



//----------------------------------------------------------------------------//
// Post Coursework 
//----------------------------------------------------------------------------//
use "${root}/${data}/simse_validity.dta" , clear

rename coaching t
keep if t == 0 | t == 1 
drop if xc21 == . & m2_1 == . 
save "${root}/${data}/extrapolation_sample.dta" , replace
egen block = group(site semester)
tab block , gen(b_)
egen k = rowmean(k?)
egen xC = rowmean(xc??)
egen x0 = rowmean(x??0)
egen q = rowmean(c6_?)
egen m = rowmean(m1 m2 m3 m4 m5)
egen s_xC = std(xC)
egen s_q  = std(q)
egen s_m  = std(m)
egen x1 = rowmean(x1?1r)
egen x2 = rowmean(x2?1r)
egen x3 = rowmean(x3?1r)
egen x4 = rowmean(x4?1r)
egen x5 = rowmean(x5?1r)

capture matrix drop results2 
foreach o in xC q m {
	capture matrix drop row
	forvalues i = 1/5 {
		local rel = rel_post[`i',1]
		sem (X -> x`i') (`o' <- X), reliability(x`i' `rel') method(mlmv) standardized
		mat row = (nullmat(row),(e(b_std)[1,3], r(table)[5,3], r(table)[6,3]))
	}
	mat results2 = (nullmat(results2) \ row)
}

matrix rownames results2 = "Metacognitive Model" "QCI" "MQI"
matrix dcols = (0,0,1,0,0,1,0,0,1,0,0,1,0,0,1)
frmttable using "${root}/${output}/itemlevel_extrapolationpost.tex", ///
statmat(results2) ///
substat(1) ///
doubles(dcols) ///
ctitles("", "x1","x2","x3","x4","x5") ///
coljust(c) ///
tex ///
fragment ///
replace






