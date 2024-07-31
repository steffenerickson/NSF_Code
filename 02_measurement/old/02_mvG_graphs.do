//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Multivariate G Study Graphing Analysis File 

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------/

//----------------------------------------------------------------------------//
// Set Up 
//----------------------------------------------------------------------------//
clear all
cd "/Users/steffenerickson/Desktop/fall_2023/nsf/g_theory_work/full_routine"

* Pull Study Data  
do /Users/steffenerickson/Desktop/repos/collab_rep_lab/nsf_v2/_pull_data.do 

* Mult G Study Program 
include /Users/steffenerickson/Desktop/fall_2023/nsf/g_theory_work/programs/multivariateG.do


//----------------------------------------------------------------------------//
// Frame Prep
//----------------------------------------------------------------------------//

* Copy Performance task frame 
frame copy performancetask_and_baseline sim 

* Graphing Frames
mkf graphing_vars0 
mkf graphing_vars1
mkf graphing_vars2 

mkf graphing_covs0
mkf graphing_covs1 
mkf graphing_covs2

* Table Frames 

//----------------------------------------------------------------------------//
// Data Prep
//----------------------------------------------------------------------------//

* Performance task data 
frame sim {
	* create person identifier 
	encode participantid , gen(ID)
	tab ID , m
	sort ID site semester
	egen id = group (ID site semester)
	
	* Restrict to a balanced sample
	forvalues i = 1/6 {
		drop if x`i' == .
	}
	bysort id : gen n = _n if task != 7 & coaching != 2
	egen c  = count(n) if task != 7 & coaching != 2, by(id)
	tab c 
	keep if c == 12
	drop c
}

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

// Run Multivariate G Studies

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Pre and post G-Study
	* Used to decompose full design within each time point
	* item x [person x (rater|task)]
		* items are fixed 
		* persons raters and tasks are random 
		* persons raters and tasks are all linked with covariances 
//----------------------------------------------------------------------------//
frame sim {
	forvalues t = 0/1 {
		qui levelsof id if time == `t'
		local id_n = r(r)
	
		mvgstudy x* if time == `t', facets(id task rater) facetlevels(`id_n' 3 2) 	  ///
									effects(id task rater|task id#task id#rater|task) ///
									residual(id#rater|task) 
	
		forvalues i  = 1/5 {
			matrix covcomps`i'_`t' = r(covcomps`i')
		}
		matrix var_comps_`t'  = r(ems)			
		matrix covar_comps_`t' = r(emcp)
	}
}
//----------------------------------------------------------------------------//
// Connected time points G-Study 
	* Using this design to recover item covariances between time points
		* item x [person x task]
		* items are fixed 
		* persons and tasks are random 
		* persons and tasks are linked with covariances 
			* Valid when the tasks have been equated 
//----------------------------------------------------------------------------//
frame sim {
	preserve 
	
	recode task (4 = 1) (5 = 2) (6 = 3)
	keep x1-x6 dc task id time coaching rater
	reshape wide x1-x6 rater, i(id task dc coaching) j(time)
	egen rater = group(rater0 rater1)
	collapse x* , by(task id coaching)
	
	global if_statement 
	qui levelsof id 
	global id_n = r(r)
	
	mvgstudy x* , facets(id task) facetlevels($id_n 3 ) effects(id task id#task) residual(id#task) 
	
	forvalues i  = 1/3 {
		matrix covcomps`i'_2 = r(covcomps`i')
	}		
		matrix var_comps_2   = r(ems)			
		matrix covar_comps_2 = r(emcp)
		
	restore 
}
//----------------------------------------------------------------------------// 
//----------------------------------------------------------------------------// 

// Graphing color schemes 

//----------------------------------------------------------------------------// 
//----------------------------------------------------------------------------// 

//https://medium.com/the-stata-guide/stata-graphs-define-your-own-color-schemes-4320b16f7ef7

/*
*** Stata graph scheme
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots, perm
graph set window fontface "Arial Narrow"
*** Color palettes
 net install palettes, replace from("https://raw.githubusercontent.com/benjann/palettes/master/")
 net install colrspace, replace from("https://raw.githubusercontent.com/benjann/colrspace/master/")
*/

colorpalette LimeGreen YellowGreen Olivedrab SeaGreen Olive
colorpalette LimeGreen YellowGreen Olivedrab SeaGreen Olive, nograph
return list

//----------------------------------------------------------------------------// 
//----------------------------------------------------------------------------// 
//variance comps visuals 	
//----------------------------------------------------------------------------// 
//----------------------------------------------------------------------------// 


//----------------------------------------------------------------------------// 
// pre and post design
//----------------------------------------------------------------------------// 

// Pre
frame copy graphing_vars0 graphing_vars0e , replace
frame graphing_vars0e {
svmat var_comps_0
ds
local i = 1
foreach v in `r(varlist)' {
	rename `v' x`i'
	local++i
}

gen comp = _n
label define c 1 "person" 2 "task" 3 "rater|task" 4 "personxtask" 5 "personxrater|task"
label values comp c

reshape long x , i(comp) j(item)
reshape wide x , i(item) j(comp)
label define itm 1 "Objective" 2 "Unpacking" 3 "Self-Instruction" 4 "Self-Regulation" 5 "Ending Model" 6 "Accuracy"
label values item itm 

// Recode to 0 is variance component estimate is negative 
forvalues i = 1/5 {
	replace x`i' = 0 if x`i' < 0
}


graph hbar (sum) x* , over(item, label(labsize(small))) stack scheme(stcolor) ///
legend(order( 1 "person" 2 "task" 3 "rater|task" 4 "personxtask" 5 "personx(rater|task)" ) size(vsmall)  pos(6) ring(5) rows(1)) ///
ytitle("Variance") ///
title("Pre" , size(medium)) ///
bar(1, color("50 205 50")  fintensity(inten50)) ///
bar(2, color("154 205 50")  fintensity(inten50)) ///
bar(3, color("107 142 35") fintensity(inten50)) ////
bar(4, color("46 139 87") fintensity(inten50)) ///
bar(5, color("128 128 0") fintensity(inten50)) ///
name(g1, replace) yscale(range(0[.1].7)) ylabel(0[.1].7)
}


// Post 
frame copy graphing_vars1 graphing_vars1e , replace
frame graphing_vars1e {
svmat var_comps_1
ds
local i = 1
foreach v in `r(varlist)' {
	rename `v' x`i'
	local++i
}

gen comp = _n
label define c 1 "person" 2 "task" 3 "rater|task" 4 "personxtask" 5 "personxrater|task"
label values comp c

reshape long x , i(comp) j(item)
reshape wide x , i(item) j(comp)
label define itm 1 "Objective" 2 "Unpacking" 3 "Self-Instruction" 4 "Self-Regulation" 5 "Ending Model" 6 "Accuracy"
label values item itm 

// Recode to 0 is variance component estimate is negative 
forvalues i = 1/5 {
	replace x`i' = 0 if x`i' < 0
}


graph hbar (sum) x* , over(item, label(labsize(small))) stack scheme(stcolor) ///
legend(order( 1 "person" 2 "task" 3 "rater|task" 4 "personxtask" 5 "personx(rater|task)" ) size(vsmall)  pos(6) ring(5) rows(1)) ///
ytitle("Variance") ///
title("Post" , size(medium)) ///
bar(1, color("50 205 50")  fintensity(inten50)) ///
bar(2, color("154 205 50")  fintensity(inten50)) ///
bar(3, color("107 142 35") fintensity(inten50)) ////
bar(4, color("46 139 87") fintensity(inten50)) ///
bar(5, color("128 128 0") fintensity(inten50)) ///
name(g2, replace) yscale(range(0[.1].7)) ylabel(0[.1].7)
}

grc1leg g1 g2, rows(1) altshrink title("Decomposed Item Variances by Time")

//----------------------------------------------------------------------------// 
// Connected time point design 
//----------------------------------------------------------------------------// 
frame copy graphing_vars2 graphing_vars2e , replace
frame graphing_vars2e {
svmat var_comps_2
ds
local i = 1
foreach v in `r(varlist)' {
	rename `v' x`i'
	local++i
}

gen comp = _n
label define c 1 "person" 2 "task" 3 "person#task"
label values comp c

reshape long x , i(comp) j(item)
reshape wide x , i(item) j(comp)
label define itm 1 "1 Objective" 2 "1 Unpacking" 3 "1 Self-Instruction" ///
                 4 "1 Self-Regulation" 5 "1 Ending Model" 6 "1 Accuracy" ///
				 7 "2 Objective" 8 "2 Unpacking" 9 " 2 Self-Instruction" ///
				 10 "2 Self-Regulation" 11 "2 Ending Model" 12 "2 Accuracy" 
label values item itm 

forvalues i = 1/3 {
	replace x`i' = 0 if x`i' < 0
}

graph hbar (sum) x* , over(item, label(labsize(small))) stack scheme(stcolor) ///
legend(order( 1 "person" 2 "task" 3 "person#task" ) size(vsmall)  pos(6) ring(5) rows(1)) ///
ytitle("Variance") ///
title("Decomposed Item Variances by Time" , size(medium)) ///
bar(1, color("50 205 50")  fintensity(inten50)) ///
bar(2, color("154 205 50") fintensity(inten50)) ///
bar(2, color("46 139 87")   fintensity(inten50)) name(g1, replace) yscale(range(0[.1].7)) ylabel(0[.1].7)

}



//----------------------------------------------------------------------------// 
//----------------------------------------------------------------------------//
// Covariance Comps visuals 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------// 


//----------------------------------------------------------------------------// 
// pre and post design
//----------------------------------------------------------------------------// 



// Pre 
frame copy graphing_covs0 graphing_covs0e , replace
frame graphing_covs0e {
label define pairs	1  "Objective & Unpacking" 						///
					2  "Objective & Instruction" 					///
					3  "Objective & Regulation" 					///
					4  "Objective & Ending " 						///
					5  "Objective & Accuracy" 						///
					6  "Unpacking & Instruction" 					///
					7  "Unpacking & Regulation" 					///
					8  "Unpacking & Ending " 						///
					9  "Unpacking & Accuracy" 						///
					10 "Instruction & Regulation"		    		///
					11 "Instruction & Ending" 						///
					12 "Instruction & Accuracy" 					///
					13 "Regulation & Ending" 						///
					14 "Regulation & Accuracy" 						///
					15 "Ending & Accuracy" 			, replace	
	
	
mata: a = off_diag_key(st_matrix("covcomps1_0"))
getmata a 
split a, parse(" ")
drop a 
destring a1 a2, replace
rename (a1 a2) (item1 item2)
matrix covar_comps_0 = covar_comps_0'
svmat covar_comps_0
ds
local j = 1
forvalues i = 3/7 {
	rename `:word `i' of `r(varlist)'' x`j'
	local++j
}

egen pair = group(item1 item2)
label values pair pairs 
tab pair

graph hbar (sum) x1 x2 x3 x4 x5, over(pair, label(labsize(tiny))) stack scheme(stcolor) ///
legend(order(1 "person" 2 "task" 3 "rater|task" 4 "personxtask" 5 "personx(rater|task)") ///
size(vsmall) rows(1) pos(6) ring(10)) ///
ytitle("Covariance") title("Pre" , size(medium)) ///
bar(1, color("50 205 50")  fintensity(inten50)) ///
bar(2, color("154 205 50")  fintensity(inten50)) ///
bar(3, color("107 142 35") fintensity(inten50)) ////
bar(4, color("46 139 87") fintensity(inten50)) ///
bar(5, color("128 128 0") fintensity(inten50)) ///
name(g1, replace) yscale(range(-.05[.05].25)) ylabel(-.05[.05].25)
}


// Post 
frame copy graphing_covs1 graphing_covs1e , replace
frame graphing_covs1e {
label define pairs	1  "Objective & Unpacking" 						///
					2  "Objective & Instruction" 					///
					3  "Objective & Regulation" 					///
					4  "Objective & Ending " 						///
					5  "Objective & Accuracy" 						///
					6  "Unpacking & Instruction" 					///
					7  "Unpacking & Regulation" 					///
					8  "Unpacking & Ending " 						///
					9  "Unpacking & Accuracy" 						///
					10 "Instruction & Regulation"		    		///
					11 "Instruction & Ending" 						///
					12 "Instruction & Accuracy" 					///
					13 "Regulation & Ending" 						///
					14 "Regulation & Accuracy" 						///
					15 "Ending & Accuracy" 			, replace		
mata: a = off_diag_key(st_matrix("covcomps1_1"))
getmata a 
split a, parse(" ")
drop a 
destring a1 a2, replace
rename (a1 a2) (item1 item2)
matrix covar_comps_1 = covar_comps_1'
svmat covar_comps_1
ds
local j = 1
forvalues i = 3/7 {
	rename `:word `i' of `r(varlist)'' x`j'
	local++j
}

egen pair = group(item1 item2)
label values pair pairs 
tab pair

graph hbar (sum) x1 x2 x3 x4 x5, over(pair, label(labsize(tiny))) stack scheme(stcolor) ///
legend(order(1 "person" 2 "task" 3 "rater|task" 4 "personxtask" 5 "personx(rater|task)") ///
size(vsmall) rows(1) pos(6) ring(10)) ///
ytitle("Covariance") title("post" , size(medium)) ///
bar(1, color("50 205 50")  fintensity(inten50)) ///
bar(2, color("154 205 50")  fintensity(inten50)) ///
bar(3, color("107 142 35") fintensity(inten50)) ////
bar(4, color("46 139 87") fintensity(inten50)) ///
bar(5, color("128 128 0") fintensity(inten50)) ///
name(g2, replace) yscale(range(-.05[.05].25)) ylabel(-.05[.05].25)
}


grc1leg g1 g2, rows(1) altshrink title("Decomposed Within Time Pairwise Item Covariances")
   
//----------------------------------------------------------------------------// 
// Connected time point design 
//----------------------------------------------------------------------------// 

frame copy graphing_covs2 graphing_covs2e , replace
frame graphing_covs2e {
mata: a = off_diag_key(st_matrix("covcomps1_2"))
getmata a 
split a, parse(" ")
drop a 
destring a1 a2, replace
rename (a1 a2) (item1 item2)
matrix covar_comps_2 = covar_comps_2'
svmat covar_comps_2
ds
local j = 1
forvalues i = 3/5 {
	rename `:word `i' of `r(varlist)'' x`j'
	local++j
}

label define itms       ///
1  "1 Objective " 		///
2  "1 Unpacking" 		///
3  "1 Instruction" 		///
4  "1 Regulation" 		///
5  "1 Ending " 			///
6  "1 Accuracy" 		///
7  "2 Objective " 		///
8  "2 Unpacking" 		///
9  "2 Instruction" 		///
10 "2 Regulation" 		///
11 "2 Ending " 			///
12 "2 Accuracy" 		

label values item* itms

decode item1, gen(string_item1)
decode item2, gen(string_item2)
gen pair = string_item1 + " " + string_item2

gen t1 = substr(string_item1,1,1)
gen t2 = substr(string_item2,1,1)
destring t1 , replace
destring t2 , replace
gsort + t1 t2
sort t1 t2 item1 item2 
gen n = _n

labmask n, values(pair)

graph hbar (sum) x1 x2 x3 if t1 == t2, over(n, label(labsize(tiny))) stack scheme(stcolor) ///
legend(order( 1   "person" 	2   "task"	3   "personxtask" )  ///
size(vsmall) rows(1) pos(2) ring(0)) ///
ytitle("Covariance") title("Within" , size(medium)) ///
bar(1, color("50 205 50")  fintensity(inten50)) ///
bar(2, color("154 205 50")  fintensity(inten50)) ///
bar(2, color("46 139 87")  fintensity(inten50)) name(g1, replace) yscale(range(-.05[.05].25)) ylabel(-.05[.05].25)
		   
graph hbar (sum) x1 x2 x3 if t1 != t2, over(n, label(labsize(tiny))) stack scheme(stcolor) ///
legend(order(1   "person" 2   "task" 3   "personxtask" )  size(vsmall) rows(1) pos(2) ring(0)) ///
ytitle("Covariance") title("Between" , size(medium))	///	
bar(1, color("50 205 50")  fintensity(inten50)) ///
bar(2, color("154 205 50") fintensity(inten50)) ///
bar(2, color("46 139 87")   fintensity(inten50)) name(g2,replace) yscale(range(-.05[.05].25)) ylabel(-.05[.05].25)
		   
		   
grc1leg g1 g2, rows(1) altshrink title("Decomposed Within and Between Time Pairwise Item Covariances")
}


  