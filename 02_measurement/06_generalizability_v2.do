clear all 
version 18

//----------------------------------------------------------------------------//
// Set Up 
//----------------------------------------------------------------------------//
* Set up directories 
local office 1 
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
	global programs "Users/steffenerickson/Documents/GitHub/stata_programs"
	global data     "data"
	global output   "output"
}
// mvgstudy command 
include ${programs}/mvgstudy.ado
use "${root}/${data}/manova_data.dta", clear

// Limit to balanced sample 
drop x6
rename (task rater coaching) (t r treat)
drop if (r == 3) | (treat == 2) | (x1 == . | x2 == . | x3 == . | x4 == . | x5 == .)
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
bysort p : gen n = _n 
egen c  = count(n) , by(p)
keep if c == 12
drop id site semester c n participantid dupes

//----------------------------------------------------------------------------//
// Variance Components Tables 
//----------------------------------------------------------------------------//

//--------------------- Pre Post Results -------------------------------------//

// Pre
mvgstudy (x* = p t  p#t r|t p#r|t) if time == 0
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
mata total_error0 = e1 + e2 + e3 + e4
mata true0 = t
mata df = st_matrix("r(df)")
mata w  = (.2,.2,.2,.2,.2)'
mata sigma_t  = w'*t*w
mata sigma_e1 = w'*e1*w
mata sigma_e2 = w'*e2*w
mata sigma_e3 = w'*e3*w
mata sigma_e4 = w'*e4*w
mata stacked = sigma_t \ sigma_e1 \ sigma_e2 \ sigma_e3 \ sigma_e4 
mata CIs = satterthwaite(stacked,df,.80)
mata prop = stacked :/ colsum(stacked)
mata results = stacked, CIs, prop
mata results = mm_cond(results :< 0, 0, results)
mata results1 = round(results,.001)


// Post 
mvgstudy (x* = p t  p#t r|t p#r|t) if time == 1
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
mata total_error1 = e1 + e2 + e3 + e4
mata true1 = t
mata df = st_matrix("r(df)")
mata w  = (.2,.2,.2,.2,.2)'
mata sigma_t  = w'*t*w
mata sigma_e1 = w'*e1*w
mata sigma_e2 = w'*e2*w
mata sigma_e3 = w'*e3*w
mata sigma_e4 = w'*e4*w
mata stacked = sigma_t \ sigma_e1 \ sigma_e2 \ sigma_e3 \ sigma_e4 
mata CIs = satterthwaite(stacked,df,.80)
mata prop = stacked :/ colsum(stacked)
mata results = stacked, CIs, prop
mata results = mm_cond(results :< 0, 0, results)
mata results2 = round(results,.001)

// Pre Post Table 
mata prepostresults = results1,results2
mata st_matrix("prepostresults",prepostresults)
mat rownames prepostresults = "p" "t" "p $\times$ t" "r $|$ t" "p $\times$ r $|$ t"
frmttable using "${root}/${output}/resultstable2.tex", ///
statmat(prepostresults) ///
sdec(3) ///
ctitles("", "Pre Coursework","", "","","Post Coursework","","","" \ "", "var","lci","uci","prop","var","lci","uci","prop" )  ///
/*title("Composite Score Variance Components ")*/ ///
multicol(1,2,4;1,6,4)  ///
coljust(c) ///
tex ///
fragment ///
replace

//------------------ Covariance Component Matrices ---------------------------//
mata st_matrix("true0",true0)
mata st_matrix("total_error0",total_error0)
mata st_matrix("true1",true1)
mata st_matrix("total_error1",total_error1)
foreach m in true0 true1 total_error0 total_error1 {
	mat rownames `m' = "x1" "x2" "x3" "x4" "x5"
	mat colnames `m' = "x1" "x2" "x3" "x4" "x5"
}

outtable using  "${root}/${output}/appendixcovcomps1.tex", mat(true0) replace
outtable using  "${root}/${output}/appendixcovcomps2.tex", mat(true1) replace
outtable using  "${root}/${output}/appendixcovcomps3.tex", mat(total_error0) replace 
outtable using  "${root}/${output}/appendixcovcomps4.tex", mat(total_error1) replace 

// -------------------- different weighting strategies -----------------------//
// time 0 
mvgstudy (x* = p t  p#t r|t p#r|t) if time == 0
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
mata df = st_matrix("r(df)")
//equal weights
mat w1  = (.2,.2,.2,.2,.2)'
// Weight by utterance type frequency 
mata usefreq = (.0371616, .4255967, .1539324, .0096108, .0387634)'
mata w2 = usefreq :/ colsum(usefreq)
mata st_matrix("w2",w2) 
mat list w1
mat list w2
forvalues i = 1/2 {
	mata w = st_matrix("w`i'")
	mata sigma_t  = w'*t*w
	mata sigma_e1 = w'*e1*w
	mata sigma_e2 = w'*e2*w
	mata sigma_e3 = w'*e3*w
    mata sigma_e4 = w'*e4*w
	mata stacked = sigma_t \ sigma_e1 \ sigma_e2 \ sigma_e3 \ sigma_e4 
	mata CIs = satterthwaite(stacked,df,.80)
	mata prop = stacked :/ colsum(stacked)
	mata results = stacked, CIs, prop
	mata results = mm_cond(results :< 0, 0, results)
	mata results = round(results,.001)
	mata st_matrix("results`i'",results)
	mata rel`i' = sigma_t / (sigma_t + (sigma_e2/ 3) + (sigma_e4 / 6))
}
mata rel1 
mata rel2 
matrix weightresults = results1 , results2 
mat rownames weightresults = "p" "t" "p $\times$ t" "r $|$ t" "p $\times$ r $|$ t"
frmttable using  "${root}/${output}/resultstable3.tex", ///
statmat(weightresults) ///
sdec(3) ///
ctitles("", "Equal","", "","","Utterance Frequency","","","" \ "", "var","lci","uci","prop","var","lci","uci","prop" )  ///
/*title("Composite Score Variance Components by Weighting Strategy")*/ ///
multicol(1,2,4;1,6,4) ///
coljust(c) ///
tex ///
fragment ///
replace

// time 1 
mvgstudy (x* = p t  p#t r|t p#r|t) if time == 1
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")               
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
mata df = st_matrix("r(df)")
//equal weights
mat w1  = (.2,.2,.2,.2,.2)'
// Weight by utterance type frequency 
mata usefreq = (.0371616, .4255967, .1539324, .0096108, .0387634)'
mata w2 = usefreq :/ colsum(usefreq)
mata st_matrix("w2",w2) 

mat list w1
mat list w2
forvalues i = 1/2 {
	mata w = st_matrix("w`i'")
	mata sigma_t  = w'*t*w
	mata sigma_e1 = w'*e1*w
	mata sigma_e2 = w'*e2*w
	mata sigma_e3 = w'*e3*w
    mata sigma_e4 = w'*e4*w
	mata stacked = sigma_t \ sigma_e1 \ sigma_e2 \ sigma_e3 \ sigma_e4 
	mata CIs = satterthwaite(stacked,df,.80)
	mata prop = stacked :/ colsum(stacked)
	mata results = stacked, CIs, prop
	mata results = mm_cond(results :< 0, 0, results)
	mata results = round(results,.001)
	mata st_matrix("results`i'",results)
	mata rel`i' = sigma_t / (sigma_t + (sigma_e2/ 3) + (sigma_e4 / 6))
}
mata rel1 
mata rel2 
matrix weightresults = results1 , results2 
mat rownames weightresults = "p" "t" "p $\times$ t" "r $|$ t" "p $\times$ r $|$ t"
frmttable using  "${root}/${output}/resultstable4.tex", ///
statmat(weightresults) ///
sdec(3) ///
ctitles("", "Equal","", "","","Utterance Frequency","","","" \ "", "var","lci","uci","prop","var","lci","uci","prop" )  ///
/*title("Composite Score Variance Components by Weighting Strategy")*/ ///
multicol(1,2,4;1,6,4) ///
coljust(c) ///
tex ///
fragment ///
replace

//----------------------------------------------------------------------------//
// Reliability Figures for weighting strategies
//----------------------------------------------------------------------------//

// Time 0 
mvgstudy (x* = p t  p#t r|t p#r|t)  if time == 0
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
capture matrix drop result
forvalues w = 1/2 {
	forvalues i = 1/6 {
		forvalues j = 1/6 {
			mata w = st_matrix("w`w'")
			mata sigma_t  = w'*t*w
			mata sigma_e1 = w'*e1*w
			mata sigma_e2 = w'*e2*w
			mata sigma_e3 = w'*e3*w
			mata sigma_e4 = w'*e4*w
			mata g = sigma_t /  (sigma_t + (sigma_e2 / `i') + (sigma_e4 / (`i' * `j')))
			mata st_numscalar("g",g)
			mat result = (nullmat(result) \ (`w', `i',`j',g))
		}
	}
}

mkf comp_rel
frame comp_rel {
	svmat result 
	rename (result1 result2 result3 result4) (weight task rater g)
	
	forvalues i = 1/2 {
		
		if `i' == 1 local name "Equal Weights"
		if `i' == 2 local name "Utterance Frequency"
		
		twoway  (scatter g task if weight == `i' & rater == 1 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 2 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 3 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 4 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 5 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 6 , connect(l)) , ///
				legend(order(1 "1 Rater" 2 "2 Raters" 3 "3 Raters" 4 "4 Raters" 5 "5 Raters" 6 "6 Raters")  pos(5) ring(0) rows(1) size(small)) ///
		xtitle("Tasks") ytitle("Generalizability Coefficient") yscale(range(.1(.1)1)) ylabel(.1(.1)1) ///
		title("`name'", size(small)) name(g`i' , replace)
		
	}
	
	grc1leg g1 g2, legendfrom(g1) title("Reliability Under Different Measurement Procedures by Weighting Strategy (Pre)" , size(medium)) rows(1) name(g1, replace) altshrink
	graph export "${root}/${output}/dstudy0.png" , replace
}
frame drop comp_rel

// Time 1 
mvgstudy (x* = p t  p#t r|t p#r|t)  if time == 1
mata t  = st_matrix("r(covcomps1)")  
mata e1 = st_matrix("r(covcomps2)")
mata e2 = st_matrix("r(covcomps3)")
mata e3 = st_matrix("r(covcomps4)")
mata e4 = st_matrix("r(covcomps5)")
capture matrix drop result
forvalues w = 1/2 {
	forvalues i = 1/6 {
		forvalues j = 1/6 {
			mata w = st_matrix("w`w'")
			mata sigma_t  = w'*t*w
			mata sigma_e1 = w'*e1*w
			mata sigma_e2 = w'*e2*w
			mata sigma_e3 = w'*e3*w
			mata sigma_e4 = w'*e4*w
			mata g = sigma_t /  (sigma_t + (sigma_e2 / `i') + (sigma_e4 / (`i' * `j')))
			mata st_numscalar("g",g)
			mat result = (nullmat(result) \ (`w', `i',`j',g))
		}
	}
}

mkf comp_rel
frame comp_rel {
	svmat result 
	rename (result1 result2 result3 result4) (weight task rater g)
	
	forvalues i = 1/2 {
		
		if `i' == 1 local name "Equal Weights"
		if `i' == 2 local name "Utterance Frequency"
		
		twoway  (scatter g task if weight == `i' & rater == 1 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 2 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 3 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 4 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 5 , connect(l)) ///
				(scatter g task if weight == `i' & rater == 6 , connect(l)) , ///
				legend(order(1 "1 Rater" 2 "2 Raters" 3 "3 Raters" 4 "4 Raters" 5 "5 Raters" 6 "6 Raters")  pos(5) ring(0) rows(1) size(small)) ///
		xtitle("Tasks") ytitle("Generalizability Coefficient") yscale(range(.1(.1)1)) ylabel(.1(.1)1) ///
		title("`name'", size(small)) name(g`i' , replace)
		
	}
	
	grc1leg g1 g2, legendfrom(g1) title("Reliability Under Different Measurement Procedures by Weighting Strategy (Post)" , size(medium)) rows(1) name(g1, replace) altshrink
	graph export "${root}/${output}/dstudy1.png" , replace
}
frame drop comp_rel


