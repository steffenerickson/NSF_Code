* permutations program
capture program drop permutations
program permutations, rclass 
	syntax,  N(integer) K(integer)
	tempname tempframe a v 
	mata st_matrix("`a'", J(1,`k',range(1,`n',1)))
	mkf `tempframe'
	frame `tempframe' {
		svmat `a' 
		fillin *
		drop _fillin
		qui ds
		tokenize `r(varlist)'
		local x = 2
		local k_1 = `k' - 1
		forvalues y = 1/`k_1' {
			forvalues z = 1/`y' {
				capture drop if ``z'' == ``x''
			}
			local++x	
		}
		mkmat *, matrix(`v') rowprefix(perm)
	}
	return matrix permutations = `v'
end 

* rater assignment 
clear
set seed 1234 
permutations, n(8) k(6)
mat x = r(permutations)
svmat x
gen randnum = runiform()
sort randnum
keep in 1/100 
drop randnum
rename (x*) (x_t1_r1 x_t1_r2 x_t2_r1 x_t2_r2 x_t3_r1 x_t3_r2)
gen p = _n
reshape long x_t1 x_t2 x_t3, i(p) j(r) string 
reshape long x, i(p r) j(t) string 
tab x 
version 16 : table p t r  if p < 6, c(mean x)

