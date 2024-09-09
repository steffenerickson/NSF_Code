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

//----------------------------------------------------------------------------//
// Arbitrary distribution function (weighted least squares)
//----------------------------------------------------------------------------//
use "${root}/${data}/manova_data.dta", clear
rename (task rater coaching) (t r treat)
label values treat . 
keep if time == 1 & ( treat == 0 | treat == 1) & (r != 3) 
drop x6 
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
collapse x* , by(p treat block)
recode treat (0 = 1) (1 = 2)
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)

sem ( <- x1 x2 x3 x4 x5) , method(adf) 
estat framework, fitted
mat true = r(Sigma)[1..5,1..5]
sem ( <- x1 x2 x3 x4 x5) , group(treat) ginvariant(mcoef) //method(adf) 
mat mu0 = _b[/mean(x1)#1.treat],_b[/mean(x2)#1.treat],_b[/mean(x3)#1.treat],_b[/mean(x4)#1.treat],_b[/mean(x5)#1.treat]
mat mu1 = _b[/mean(x1)#2.treat],_b[/mean(x2)#2.treat],_b[/mean(x3)#2.treat],_b[/mean(x4)#2.treat],_b[/mean(x5)#2.treat]
mat observed = mu1 - mu0

/*
capture drop matrix res
foreach num of numlist 50(10)300 {
	clear
	ssd init x1 x2 x3 x4 x5
	ssd set obs `num'
	ssd set cov (stata) true
	ssd set means (stata) mu0
	ssd addgroup treat
	ssd set obs `num'
	ssd set cov (stata) true
	ssd set means (stata) mu1
	
	sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , group(treat) ginvariant(mcoef scoef) means(F1@0)	//method(adf) //standardized		 
	testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  ///
		((_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  ///
		((_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  ///
		((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat]))) 

	mat res = (nullmat(res)\ (`num',r(p)))		
}

preserve
svmat res 
scatter res2 res1 , yline(.05)
restore 
*/

capture matrix  drop res
foreach num of numlist 50(10)300 {
	clear
	ssd init x1 x2 x3 x4 x5
	ssd set obs `num'
	ssd set cov (stata) true
	ssd set means (stata) mu0
	ssd addgroup treat
	ssd set obs `num'
	ssd set cov (stata) true
	ssd set means (stata) mu1
	
	sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , group(treat) ginvariant(mcoef scoef) means(F1@0)	//method(adf) //standardized	
	
	testnl ((_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  ///
		   ((_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  
	local test1 = r(p)
	
	testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  ///
		   ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat]))) 
	local test2 = r(p)
	
	mat res = (nullmat(res) \ (`num'*2,`test1',`test2'))	
	
}

preserve
svmat res 
twoway (scatter res2 res1 , yline(.05, lpattern(dash) lcolor(black)) msymbol(Oh) mcolor(blue)) (scatter res3 res1 , yline(.05 , lpattern(dash) lcolor(black)) msymbol(Dh) mcolor(orange)),  	///
legend(order(1 "y1 = y4 = y5" 2 "y1 = y2 = y3") rows(1) pos(6)) ytitle("P value") xtitle("Sample Size") ///
title("Wald Test Over Hypothetical Sample Sizes") scheme(s1color)
graph export "${root}/${output}/hypotheticaltests.png" , replace
restore 














