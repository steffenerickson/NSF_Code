* permutations program
capture program drop permutations
program permutations, rclass 
	syntax,  N(integer) K(integer)
	tempname tempframe a v
	local k_1 = `k' - 1
	mata st_matrix("`a'",range(1,`n',1))
	mkf `tempframe'
	frame `tempframe' {
		svmat `a', name(`v')
		forvalues i = 1/`k_1' {
			local j = `i' + 1
			gen `v'`j' = `v'`i'
		}
		fillin *
		drop _fillin
		qui ds
		tokenize `r(varlist)'
		local x = 2
		forvalues y = 1/`k_1' {
			forvalues z = 1/`y' {
				capture drop if ``z'' == ``x''
			}
			local++x	
		}
		mkmat * , matrix(`v') rowprefix(perm)
	}
	return matrix permutations = `v'
end 

* Rater Assignment 
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

