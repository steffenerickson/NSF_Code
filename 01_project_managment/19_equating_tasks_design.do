

clear all 

cd /Users/steffenerickson/Desktop/fall_2023/nsf/equating_tasks

global seed 1234

//randomize_program
include 00_randomize_program.do


//-----------------------//
// Combinations 
//-----------------------//
capture program drop combn
program combn, rclass 
	syntax , MATNAME(string) N(integer) K(integer)
	tempname tempframe a
	
	if `k' > `n' {
		di "k must be less than or equal to n"
		exit
	}
	
	forvalues i =  1/`n' {
		mat `a' = (nullmat(`a') \ `i')
	}
	mkf `tempframe'
	frame `tempframe' {
		svmat `a', name(`matname')
		local k_1 = `k' - 1
		forvalues i = 1/`k_1' {
			local j = `i' + 1
			gen `matname'`j' = `matname'`i'
		}
		fillin *
		drop _fillin
		qui ds 
		local vars `r(varlist)'
		tokenize `vars'
		local n: list sizeof local(vars)
		local i = 1
		local j = 1
		while (`j' < `n') {
			local j = `i' + 1
			drop if ``i'' >= ``j''
			local++i
		}
		mkmat * , matrix(`matname') rowprefix(comb)
	}
	return matrix `matname' = `matname'
end 

//-----------------------//
// Permutations 
//-----------------------//

capture program drop permin
program permin, rclass 
	syntax , MATNAME(string) N(integer) K(integer)
	tempname tempframe a
	
	
	if `k' > `n' {
		di "k must be less than or equal to n"
		exit 
	}
	
	forvalues i =  1/`n' {
		mat `a' = (nullmat(`a') \ `i')
	}
	mkf `tempframe'
	frame `tempframe' {
		svmat `a', name(`matname')
		local k_1 = `k' - 1
		forvalues i = 1/`k_1' {
			local j = `i' + 1
			gen `matname'`j' = `matname'`i'
		}
		fillin *
		drop _fillin
		qui ds 
		local vars `r(varlist)'
		tokenize `vars'
		local i = 2
		local j = `k' - 1
		forvalues g = 1/`j' {
			forvalues x = 1/`g' {
				capture drop if ``x'' == ``i''
			}
			local++i	
		}
		mkmat * , matrix(`matname') rowprefix(perm)
	}
	return matrix `matname' = `matname'
end 
	
permin , matname(task) n(5) k(5)
matrix list r(task)
	
	
	
//----------------------------------------------------------------------------//
// routine 
//----------------------------------------------------------------------------//


//Task conditions 

mkf task_conditions
frame task_conditions {
	
	combn , matname(task) n(3) k(2)
	matrix list r(task)
	matrix task1 = r(task)
	
	combn , matname(task) n(3) k(2)
	matrix list r(task)
	matrix task2 = r(task)
	
	svmat task1
	svmat task2
	
	recode task21 task22 (1 = 4) (2 = 5) (3 = 6)
	
	gen delim = ","
	egen pre = concat(task11 delim task12)
	egen post = concat(task21 delim task22)
	
	drop task* delim 
	
	fillin pre post
	drop _fillin 
	
	split pre,  generate(task1) parse(",")
	split post, generate(task2) parse(",")
	drop pre post 
	destring task* , replace 
	
	gen condition = _n

}

//rater assigmnents

mkf rater_assignments 
frame rater_assignments {
	permin , matname(rater) n(8) k(8)
	mat rater = r(rater)
	svmat rater
	set seed ${seed}
	gen randnum = runiform()
	sort randnum 
	gen participant = _n
	keep in 1/100
	drop randnum
}

// Randomize participants to task conditions and randomly assign raters

mkf randomize 
frame randomize {

	set obs 100
	gen participant = _n
	randomize condition , arms(9) id(participant) seed(${seed})
	replace  condition  =  condition + 1
	drop randomization_dt

	frame task_conditions: tempfile data
	frame task_conditions: save `data'
	merge m:1 condition using `data'
	drop _merge 
	
	frame rater_assignments : tempfile data
	frame rater_assignments : save `data'
	merge 1:1 participant using `data'
	drop _merge 
	
}


frame change randomize
rename (rater1 rater2 rater3 rater4 rater5 rater6 rater7 rater8) ///
       (rater11_1 rater12_1 rater21_1 rater22_1 rater11_2 rater12_2 rater21_2 rater22_2)  
reshape long rater11_ rater12_ rater21_ rater22_ , i(participant condition) j(dc)
rename rater*_ rater*
local i = 1
foreach x in 11 12 21 22 {
	rename task`x' task`i'
	rename rater`x' rater`i'
	local++i
}
reshape long task rater, i(participant condition dc) j(obs)
reshape wide rater, i(participant condition task obs) j(dc)

label define t 1 "task 1" 2 "task 2" 3 "task 3" 4 "task 4" 5 "task 5" 6 "task 6"
label values task t



tab condition task
tab task rater1
tab task rater2

tab participant task


export excel task_equating_design.xlsx , replace firstrow(variables)




