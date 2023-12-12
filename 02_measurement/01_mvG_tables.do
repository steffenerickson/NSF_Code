//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Multivariate G Study Tables Analysis File 
	* Variance and covariance comps and their standard errors 
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
* Table Frames 
mkf table0
mkf table1
mkf table2

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
		matrix df_`t' = r(df)
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
		matrix df_2 = r(df)
		
	restore 
}

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

// Variance Components tables 

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// pre and post 
//----------------------------------------------------------------------------//



forvalues t = 0/1 {
	frame copy table`t' table`t'e , replace
	frame table`t'e {
		
		* set negative estimates to 0 
		local r = rowsof(var_comps_`t')
		local c = colsof(var_comps_`t')
		forvalues i = 1/`r' {
			forvalues j = 1/`c' {
				if var_comps_`t'[`i', `j'] < 0  matrix var_comps_`t'[`i', `j'] = 0 
			}
		}
		
		* Place variance components in dataframe 
		local names 
		local effects person task rater|task personxtask personx(rater|task)
		foreach x of local effects {
			local name   "`x'"
			local names `" `names' "`name'" "'
		}
		capture matrix drop stacked
		forvalues i = 1/`c' {
			tempname temp 
			matrix `temp' = var_comps_`t'[1...,`i'],J(rowsof(var_comps_`t'),1,`i'),df_`t'
			matrix rownames `temp' = `names'
			matrix stacked = (nullmat(stacked) \ `temp')
		}
		
		local rownames: rowfullnames stacked
		svmat stacked 
		gen comp = " "
		qui desc 
		forvalues i = 1/`r(N)' {
			replace comp = "`:word `i' of `rownames''" in `i'
		}
		
		rename (stacked1 stacked2 stacked3) (var item df)
		
		*proportion of total variance 
		egen total = total(var) , by(item)
		gen prop = var / total
		
		*confidence intervals 
		mata: y = satterthwaite(st_data(., "var"),st_data(.,  "df"),.80)
		getmata  (var_low var_up) = y
		mata: mata drop y
		
		*formatting 
		label define itm 1 "Objective" 2 "Unpacking" 3 "Self-Instruction" /// 
						4 "Self-Regulation" 5 "Ending Model" 6 "Accuracy"
		label values item itm 
		decode item, gen(item2)
		gen n = _n 
		gen label = item2 + ":" + comp
		
		order label df var var_low var_up prop total
		keep label  df var var_low var_up prop total n
		
		foreach var of  varlist var-total {
			replace `var' = round(`var',.001)
			rename `var' `var'`t'
		}
		sort n
	}
}


frame copy table0e merged_table , replace 
frame merged_table {
	frame table1e : tempfile data
	frame table1e : save `data'
	merge 1:1 label n using `data'
	drop _merge
}


//----------------------------------------------------------------------------//
// linear combination of pre and post 
//----------------------------------------------------------------------------//

frame copy table2 table2e , replace
	frame table2e {
	
	*variance of the difference 
	*var(X - Y) = var(X) + var(Y) - 2*cov(X,Y)
	local names person task personxtask 
	capture matrix drop stacked 
	forvalues x = 1/3 {
		capture matrix drop diff_scores`x'
		forvalues i = 1/6 {
			local j = `i' + 6
			local val = covcomps`x'_2[`i',`i'] + covcomps`x'_2[`j',`j'] - 2*covcomps`x'_2[`j',`i']
			mat temp = (`val' ,`i', df_2[`x',1]) 
			mat rowname temp = "`:word `x' of `names''"
			matrix diff_scores`x' = (nullmat(diff_scores`x') \ temp )
		} 
		matrix stacked = (nullmat(stacked) \ diff_scores`x')
	}
	
	mat list stacked 
	
	local r = rowsof(stacked)
	forvalues i = 1/`r' {
		if stacked[`i', 1] < 0  matrix stacked[`i', 1] = 0 
	}
	
		
	local rownames: rowfullnames stacked
	svmat stacked 
	gen comp = " "
	qui desc 
	forvalues i = 1/`r(N)' {
		replace comp = "`:word `i' of `rownames''" in `i'
	}
	
	rename (stacked1 stacked2 stacked3) (var item df)
	
	*proportion of total variance 
	egen total = total(var) , by(item)
	gen prop = var / total
	
	*confidence intervals 
	mata: y = satterthwaite(st_data(., "var"),st_data(.,  "df"),.80)
	getmata  (var_low var_up) = y
	mata: mata drop y
	
	*formatting 
	label define itm 1 "Objective" 2 "Unpacking" 3 "Self-Instruction" /// 
					4 "Self-Regulation" 5 "Ending Model" 6 "Accuracy"
	label values item itm 
	//gen len_comp = strlen(comp)
	//sort item len_comp
	
	decode item, gen(item2)
	gen label = item2 + ":" + comp
	order label df var var_low var_up prop total
	keep label var var_low var_up prop total 
	foreach var of  varlist var-total {
		replace `var' = round(`var',.001)
		rename `var' `var'1_0
	}

}

frame merged_table {
	frame table2e: tempfile data 
	frame table2e: save `data'
	merge 1:1 label using `data'
	sort n
	drop n  _merge
	list
	qui ds 
	local list `r(varlist)'
	local remove label
	local list2 : list list - remove
	mkmat `list2', matrix(g_table) rownames(label)
}



esttab matrix(g_table) , ///
mtitle("") ///
title("Variance Components by Rubric Item: Pre Coursework (0), Post Coursework (1), & Post Coursework - Pre Coursework (1 - 0)") ///
























