//----------------------------------------------------------------------------//
// Method For Assigning Raters (Eliminating Rater Bias)
//----------------------------------------------------------------------------//

* permutations program
capture program drop permutations
program permutations, rclass 
	syntax,  N(integer) K(integer)
	tempname tempframe a perms
	if `k' > `n' {
		di "k must be less than or equal to n"
		exit 
	}
	forvalues i =  1/`n' {
		mat `a' = (nullmat(`a') \ `i')
	}
	mkf `tempframe'
	frame `tempframe' {
		svmat `a', name(`perms')
		local k_1 = `k' - 1
		forvalues i = 1/`k_1' {
			local j = `i' + 1
			gen `perms'`j' = `perms'`i'
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
		mkmat * , matrix(`perms') rowprefix(perm)
	}
	return matrix permutations = `perms'
end 

* Method 
clear
set seed 1234 
permutations, n(8) k(6)
mat x = r(permutations)
svmat x
gen randnum = runiform()
sort randnum
keep in 1/100 
drop randnum
rename x* (x_t1_r1 x_t1_r2 x_t2_r1 x_t2_r2 x_t3_r1 x_t3_r2)
gen p = _n
reshape long x_t1 x_t2 x_t3, i(p) j(r) string 
reshape long x , i(p r) j(t) string 
tab x 
version 16 : table p t r  if p < 6 , c(mean x)








