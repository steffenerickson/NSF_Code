clear all 
version 18

* Set up directories 
local office 1 
if `office' == 1 {
	global root 	"C:/Users/cns8vg"
	global code 	"GitHub/NSF_Code/02_measurement"  
	global programs "GitHub/stata_programs"
	global data     "Box Sync/NSF_DR_K12/measurement/data"
	global output 	"Box Sync/NSF_DR_K12/measurement/data/output"
}
if `office' == 0 {
	global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement"
	global code     "Users/steffenerickson/Documents/GitHub/NSF_Code/02_measurement/code"
	global programs "Users/steffenerickson/Documents/GitHub/stata_programs"
	global data     "data"
	global output   "output"
}

//----------------------------------------------------------------------------//
// Pre Coursework 
//----------------------------------------------------------------------------//
use "${root}/${data}/simse_validity.dta" , clear
mat w1 = (.2,.2,.2,.2,.2)
mat w2 = (.18434257,.33474212,.15967268,.08754351,.23369913)
mat w3 = (.05587665,.63993258,.2314547,.01445092,.05828514)
global rel1 =  .7079341654
global rel2 =  .65
global rel3 = .4718875922

rename coaching t
keep if t == 0 | t == 1 
drop if xc21 == . & m2_1 == . 
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

forvalues i = 1/3 {
	gen xp_w`i' = w`i'[1,1]*x1 + w`i'[1,2]*x2 + w`i'[1,3]*x3 + w`i'[1,4]*x4 + w`i'[1,5]*x5 
	//sum xp_w`i'
	//gen mup_w`i' = rel`i'*xp_w`i' + (1 - rel`i')*r(mean)
}
capture matrix drop results 
foreach o in xC q m {
	capture matrix drop row
	foreach i in 1 2 3 {
		sem (X -> xp_w`i') (`o' <- X), reliability(xp_w`i' ${rel`i'}) method(mlmv) standardized
		mat row = (nullmat(row),(e(b_std)[1,3], r(table)[5,3], r(table)[6,3]))
	}
	mat results = (nullmat(results) \ row)
}

matrix rownames results = "Metacognitive Model" "QCI" "MQI"
matrix dcols = (0,0,1,0,0,1,0,0,1)
frmttable using "${root}/${output}/resultstable4.tex", ///
statmat(results) ///
substat(1) ///
doubles(dcols) ///
ctitles("", "Equal","Factor Loadings","Utterance Frequency",) ///
coljust(c) ///
tex ///
fragment ///
replace

//----------------------------------------------------------------------------//
// Post Coursework 
//----------------------------------------------------------------------------//

use "${root}/${data}/simse_validity.dta" , clear
mat w1 = (.2,.2,.2,.2,.2)
mat w2 = (.18434257,.33474212,.15967268,.08754351,.23369913)
mat w3 = (.05587665,.63993258,.2314547,.01445092,.05828514)
global rel1 = .9102957791
global rel2 = .9013609282
global rel3 = .7777348137

rename coaching t
keep if t == 0 | t == 1 
drop if xc21 == . & m2_1 == . 
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

forvalues i = 1/3 {
	gen xp_w`i' = w`i'[1,1]*x1 + w`i'[1,2]*x2 + w`i'[1,3]*x3 + w`i'[1,4]*x4 + w`i'[1,5]*x5 
	//sum xp_w`i'
	//gen mup_w`i' = rel`i'*xp_w`i' + (1 - rel`i')*r(mean)
}

capture matrix drop results 
foreach o in xC q m {
	capture matrix drop row
	foreach i in 1 2 3 {
		sem (X -> xp_w`i') (`o' <- X), reliability(xp_w`i' ${rel`i'}) method(mlmv) standardized
		mat row = (nullmat(row),(e(b_std)[1,3], r(table)[5,3], r(table)[6,3]))
	}
	mat results = (nullmat(results) \ row)
}

matrix rownames results = "Metacognitive Model" "QCI" "MQI"
matrix dcols = (0,0,1,0,0,1,0,0,1)
frmttable using "${root}/${output}/resultstable5.tex", ///
statmat(results) ///
substat(1) ///
doubles(dcols) ///
ctitles("", "Equal","Factor Loadings","Utterance Frequency",) ///
coljust(c) ///
tex ///
fragment ///
replace



