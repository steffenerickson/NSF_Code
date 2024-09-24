clear all
mata mata clear
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/05_skill_development/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "measurement/data"
global output   "skill_development/output"
include "${programs}/mvgstudy.ado"

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

preserve
collapse x* , by(p treat block)
recode treat (0 = 1) (1 = 2)
sem ( <- x1 x2 x3 x4 x5) , group(treat) ginvariant(mcoef) //method(adf) 
mat mu0 = _b[/mean(x1)#1.treat],_b[/mean(x2)#1.treat],_b[/mean(x3)#1.treat],_b[/mean(x4)#1.treat],_b[/mean(x5)#1.treat]
mat mu1 = _b[/mean(x1)#2.treat],_b[/mean(x2)#2.treat],_b[/mean(x3)#2.treat],_b[/mean(x4)#2.treat],_b[/mean(x5)#2.treat]
mat observed = mu1 - mu0
restore

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


sem (X1 -> x11@1 x12@1 x13@1) 											///
    (X2 -> x21@1 x22@1 x23@1) 											///
	(X3 -> x31@1 x32@1 x33@1) 											///
	(X4 -> x41@1 x42@1 x43@1) 											///
	(X5 -> x51@1 x52@1 x53@1) 											///
	(C -> X2@1 X1 X5) (P -> X3@1 X4) (C -> P) , 						///
	var(e.X2@0 e.X3@0) 													///
	cov(e.x11*e.x21@c1  e.x12*e.x22@c1  e.x13*e.x23@c1 					///
		e.x11*e.x31@c2  e.x12*e.x32@c2  e.x13*e.x33@c2  				///
		e.x11*e.x41@c3  e.x12*e.x42@c3  e.x13*e.x43@c3 					///							
		e.x11*e.x51@c4  e.x12*e.x52@c4  e.x13*e.x53@c4 					///					
		e.x21*e.x31@c5  e.x22*e.x32@c5  e.x23*e.x33@c5  				///
		e.x21*e.x41@c6  e.x22*e.x42@c6  e.x23*e.x43@c6  				///
		e.x21*e.x51@c7  e.x22*e.x52@c7  e.x23*e.x53@c7  				///
		e.x31*e.x41@c8  e.x32*e.x42@c8  e.x33*e.x43@c8 					///	
		e.x31*e.x51@c9  e.x32*e.x52@c9  e.x33*e.x53@c9  				///												
		e.x41*e.x51@c10 e.x42*e.x52@c10 e.x43*e.x53@c10) 
		
estimates store m1


		
estat framework, fitted 
mat Sigma = r(Sigma)[16..20,16..20] 

		

sem (X1 -> x11@1 x12@1 x13@1) 											///
    (X2 -> x21@1 x22@1 x23@1) 											///
	(X3 -> x31@1 x32@1 x33@1) 											///
	(X4 -> x41@1 x42@1 x43@1) 											///
	(X5 -> x51@1 x52@1 x53@1) 											///
	(C -> X2@1 X1 X5) (P -> X3@1 X4) (C -> P) , 						///
	var(e.X2@0 e.X3@0 													///						
	e.x11@v1 e.x12@v1 e.x13@v1											///																										
	e.x21@v2 e.x22@v2 e.x23@v2											///																																							
	e.x31@v3 e.x32@v3 e.x33@v3											///																									
	e.x41@v4 e.x42@v4 e.x43@v4											///												
	e.x51@v5 e.x52@v5 e.x53@v5) 										///																										
	cov(e.x11*e.x21@c1  e.x12*e.x22@c1  e.x13*e.x23@c1 					///
		e.x11*e.x31@c2  e.x12*e.x32@c2  e.x13*e.x33@c2  				///
		e.x11*e.x41@c3  e.x12*e.x42@c3  e.x13*e.x43@c3 					///							
		e.x11*e.x51@c4  e.x12*e.x52@c4  e.x13*e.x53@c4 					///					
		e.x21*e.x31@c5  e.x22*e.x32@c5  e.x23*e.x33@c5  				///
		e.x21*e.x41@c6  e.x22*e.x42@c6  e.x23*e.x43@c6  				///
		e.x21*e.x51@c7  e.x22*e.x52@c7  e.x23*e.x53@c7  				///
		e.x31*e.x41@c8  e.x32*e.x42@c8  e.x33*e.x43@c8 					///	
		e.x31*e.x51@c9  e.x32*e.x52@c9  e.x33*e.x53@c9  				///												
		e.x41*e.x51@c10 e.x42*e.x52@c10 e.x43*e.x53@c10) 				
		

estimates store m2 

lrtest m1 m2 		

sem (X1 -> x11@1 x12@1 x13@1) 											///
    (X2 -> x21@1 x22@1 x23@1) 											///
	(X3 -> x31@1 x32@1 x33@1) 											///
	(X4 -> x41@1 x42@1 x43@1) 											///
	(X5 -> x51@1 x52@1 x53@1) 											///
	(C -> X2@1 X1 X5) (P -> X3@1 X4) (C -> P) , 						///
	var(e.X2@0 e.X3@0) 													

	
	
sem (X1 -> x11@1 x12 x13) 											///
    (X2 -> x21@1 x22 x23) 											///
	(X3 -> x31@1 x32 x33) 											///
	(X4 -> x41@1 x42 x43) 											///
	(X5 -> x51@1 x52 x53) 											///
	(C -> X2@1 X1 X5) (P -> X3@1 X4) (C -> P) , 						///
	var(e.X2@0 e.X3@0) 													///
	cov(e.x11*e.x21@c1  e.x12*e.x22@c1  e.x13*e.x23@c1 					///
		e.x11*e.x31@c2  e.x12*e.x32@c2  e.x13*e.x33@c2  				///
		e.x11*e.x41@c3  e.x12*e.x42@c3  e.x13*e.x43@c3 					///							
		e.x11*e.x51@c4  e.x12*e.x52@c4  e.x13*e.x53@c4 					///					
		e.x21*e.x31@c5  e.x22*e.x32@c5  e.x23*e.x33@c5  				///
		e.x21*e.x41@c6  e.x22*e.x42@c6  e.x23*e.x43@c6  				///
		e.x21*e.x51@c7  e.x22*e.x52@c7  e.x23*e.x53@c7  				///
		e.x31*e.x41@c8  e.x32*e.x42@c8  e.x33*e.x43@c8 					///	
		e.x31*e.x51@c9  e.x32*e.x52@c9  e.x33*e.x53@c9  				///												
		e.x41*e.x51@c10 e.x42*e.x52@c10 e.x43*e.x53@c10) 	
		



	
clear
ssd init x1 x2 x3 x4 x5
ssd set obs 1000 //71
ssd set cov (stata) Sigma
ssd set means (stata) mu0
ssd addgroup treat
ssd set obs  1000 // 75
ssd set cov (stata)Sigma
ssd set means (stata) mu1

sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , group(treat) ginvariant(mcoef scoef) means(F1@0)	//standardized	 
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  ///
       ((_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  ///
       ((_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  ///
       ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat]))) 
	   
	   
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  
testnl ((_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  
testnl ((_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  
testnl ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat])))
 


mat modelimplied = 	 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x2:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x5:2.treat#c.F1] 

mat adjusted  = 	 (_b[x1:2.treat]  -  _b[x1:1.treat]) /  _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) /  _b[x2:2.treat#c.F1], ///
					 (_b[x3:2.treat]  -  _b[x3:1.treat]) /  (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x4:2.treat]  -  _b[x4:1.treat]) /  (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x5:2.treat]  -  _b[x5:1.treat]) /  _b[x5:2.treat#c.F1] 
				 		
mata st_matrix("adjusted")					 
mata st_matrix("observed")
mata st_matrix("modelimplied")
mata: st_matrix("observed") - st_matrix("modelimplied")

