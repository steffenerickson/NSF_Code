//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Multivariate G Study for Balanced Designs 
// Author: Steffen Erickson
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Main Routine 
//----------------------------------------------------------------------------//

capture program drop mvgstudy 
program mvgstudy , rclass
	syntax varlist [if] [in], FACETS(varlist) FACETLEVELS(numlist)			 ///
							  EFFECTS(string) RESIDUAL(string)
	tempname tempframe 
	
	local lengthdepvars	   :  list sizeof local(varlist)
	local lengtheffectlist :  list sizeof local(effects)
	local n_facets         :  list sizeof local(facets)
	local n_facetlevels    :  list sizeof local(facetlevels)
	
	if `n_facets' != `n_facetlevels' {
		di "length(facets) must equal length(facetlevels)"
		exit 
	}
	local effects2 : list effects - residual
	
	* (1) Run manova
	frame put `varlist' `facets' `if' , into(`tempframe')
	frame `tempframe' {
		manova `varlist' = `effects2'
	}
	estimates store manova_estimates
	
	* (2) Collect 
	recovermanova , facets(`facets') facetlevels(`facetlevels') 			 ///
					effects(`effects') residual(`residual')
		matrix df = r(df)
		matrix flproducts = r(flproducts)
		forvalues i = 1/`lengtheffectlist' {
			matrix sscp`i' = r(sscp`i')
			local mat sscp`i'
			local matrixlist : list matrixlist | mat 
		}
		
	* (3) create P matrix (EMS equation matrix)
	createP, effects(`effects') flproducts(flproducts)
		matrix P = r(P)
	
	* (4) matrix procedures to estimate variance and covariance comps.
	emsmatrixproc, effects(`effects') df(df) p(p) matrixlist(`matrixlist')   ///
	               depvars(`lengthdepvars')			   
		forvalues i = 1/`lengtheffectlist' { 
			matrix covcomps`i' = r(covcomps`i')
		} 
		matrix ems = r(ems)
		matrix emcp = r(emcp)
		
	* display results 
	foreach x of local varlist {
		local name   "`x'"
		local names `" `names' "`name'" "'
	}
	forvalues i = 1/`lengtheffectlist' {
		matrix rownames covcomps`i' = `names'
		matrix colnames covcomps`i' = `names'
		matlist covcomps`i' , twidth(30) title("`:word `i' of `effects'' Component Covariance Matrix")
	}
	
	* return results 
	forvalues i = 1/`lengtheffectlist' { 
		return matrix covcomps`i' = covcomps`i'
	}
	return matrix P = P 
	return matrix df = df 
	return matrix flproducts = flproducts 		
	return matrix ems = ems
	return matrix emcp = emcp
end 

//----------------------------------------------------------------------------//
// stata sub-routines 
//----------------------------------------------------------------------------//
//---------- recover manova results  ----------//
capture program drop recovermanova
program recovermanova , rclass 
	syntax ,  FACETS(varlist) FACETLEVELS(numlist) EFFECTS(string) RESIDUAL(string)

	* recover manova results 
	local a = e(cmdline) 
	local check = strrpos("`a'","=")
	local newlist = substr("`a'",`check'+1,.)
	local length : list sizeof local(newlist)
	
	local j = `length' + 1
	forvalues i = 1/`j' {
		local name sscp`i'
		local sscp_tempmats : list sscp_tempmats | name
	}
	tempname tempmat df flproducts `sscp_tempmats'
	
	*degrees of freedom 
	forvalues i = 1/`length' {
		matrix `tempmat' = `e(df_`i')'
		matrix rownames `tempmat' = "`:word `i' of `effects''"
		matrix `df' = (nullmat(`df') \ `tempmat' )
		local++i
	}
	matrix `tempmat' = e(df_r)
	matrix rownames `tempmat' = "`residual'"
	matrix `df' = `df' \ `tempmat'
	
	*sums of squared cross product matrices 
	forvalues i = 1/`length' {
		matrix `sscp`i'' = e(H_`i')
		local++i
	}
	matrix `sscp`j'' = e(E)
	
	* Facet level products 
		* Rule π(α̇) = 
		* {1 if α = ω; and, otherwise, 
		* the product of the sample sizes for all indices in α̇}
	local i = 1
	foreach f of local facets {
		local `f' = `:word `i' of `facetlevels''
		local facet_level_list: list facet_level_list | f
		local++i 
	}
	
	foreach effect of local effects {
		local i = 1
		foreach f of local facet_level_list {
			local a = strpos("`effect'","`f'")
			if `a' == 0 local temp = ``f''
			else local temp = 1
			if `i' == 1 local x = `temp'
			else local x = `x' * `temp'
			local++i
		}
		matrix `tempmat' = `x'
		matrix rownames `tempmat' = "`effect'"
		matrix `flproducts' = (nullmat(`flproducts') \ `tempmat')
	}

	*return results 
	forvalues i = 1/`j' {
		return matrix sscp`i' = `sscp`i''
	}
	return matrix df = `df'
	return matrix flproducts = `flproducts'
end 

//---------- create p matrix  ----------//
capture program drop createP
program createP , rclass 
	syntax ,   EFFECTS(string) FLPRODUCTS(string)

	*fill p matrix 
	local n: list sizeof local(effects)
	mata: P =  uppertriangle(J(`n',`n',.))
	mata: st_matrix("P", P)

	foreach x of local effects {
		local name   "`x'"
		local names `" `names' "`name'" "'
	}
	matrix rownames P = `names'
	matrix colnames P = `names'
	
	local list1: rowfullnames P
	local i = 1
	foreach col of local list1 {
		local j = `i' 
		while (`j' >= 1) {
			matrix P[`j',`i'] = `flproducts'[`i',1]
			local--j
		}
		local++i
	}

	* Remove coefficients that are not in the EMS equations 
	local list1: colfullnames P
	foreach name of local list1 {
		local i = 1
		foreach cha in c. # ( ) | {
			if `i' == 1 local stubs : subinstr local name  "`cha'" "", all
			else 		local stubs : subinstr local stubs "`cha'" "", all
			local++i
		}
		local list2 : list list2 | stubs
	}
	
	local rows: list sizeof local(list2)
	local cols = `rows' - 1 
	forvalues x = 1/`rows' {
		forvalues y = 1/`cols' {
			local a = strpos("`:word `y' of `list2''","`:word `x' of `list2''")
			if `a' == 0  matrix P[`x', `y'] = 0 
		}
	}
	
	*return P matrix 
	return matrix P = P
	
end 

//---------- ems matrix procedures  ----------//
capture program drop emsmatrixproc
program emsmatrixproc, rclass 
	syntax, EFFECTS(string) DF(string) P(string) MATRIXLIST(string) 		 ///
	        DEPVARS(integer)
	local n: list sizeof local(effects)
	* compute mean squares
	forvalues i = 1/`n' {
		scalar a = df[`i',1]
		mata: df = st_numscalar("a")
		mata: temp = diagonal(st_matrix("sscp`i'"))
		mata: temp = temp :/df 
		if (`i' == 1) mata: ms = temp'
		else mata: ms = ms \ temp'
	}
	* compute mean cross products 
	forvalues i = 1/`n' {
		scalar a = df[`i',1]
		mata: df = st_numscalar("a")
		mata: temp = off_diag(st_matrix("sscp`i'"))
		mata: temp = temp:/df 
		if (`i' == 1) mata: mcp = temp'
		else mata: mcp = mcp \ temp'
	}
	
	* expected mean squares (variance components)
	mata: P = st_matrix("P")
	mata: ems = J(rows(ms),cols(ms),.)
	mata: for (i=1;i<=cols(ms);i++)  ems[1...,i] = luinv(P)*ms[1...,i] 
	mata: st_matrix("ems", ems)
	
	* expected mean cross products (covariance components)
	mata: P = st_matrix("P")
	mata: emcp = J(rows(mcp),cols(mcp),.)
	mata: for (i=1;i<=cols(mcp);i++) emcp[1...,i] = luinv(P)*mcp[1...,i]  
	mata: st_matrix("emcp", emcp)

	*rebuild matrices 
	forvalues i = 1/`n' {
		mata: temp`i' = makesymmetric(J(`depvars',`depvars',.))
		mata: covcomps`i' = rebuild_matrix(temp`i',emcp[`i',1...]',ems[`i',1...]') 
		mata: st_matrix("covcomps`i'",covcomps`i')
	}

	forvalues i = 1/`n' {
		return matrix covcomps`i' = covcomps`i'
	}
	return matrix ems = ems 
	return matrix emcp = emcp
end 

//----------------------------------------------------------------------------//
// mata sub-routines 
//----------------------------------------------------------------------------//

mata: mata clear 
mata
//---------- Return off diagonal from covariance matrix ----------//
real matrix off_diag(real matrix cov_mat)
{
	real scalar v, a, b, c, r, i, x
	real matrix res
	v = length(cov_mat[1...,1])
	a = v - 1
	b = 1
	for (i=a;i>=1;i--) {
		for (x=1;x<=i;x++) {
			c = v - i
			r = x + b
			if (b == 1 & x == 1) res = cov_mat[r,c]
			else res = (res \ cov_mat[r,c])
		}
		b++
	}
	return(res)	
}

//----- rebuild covariance matrix  -----//
real matrix rebuild_matrix(real matrix cov_mat, 
						    real matrix edited_covs,
					        real matrix variances)
{
	real matrix res 
	real scalar k, g, b, c, r1, r2 , i , x 
	
	res = J(rows(cov_mat),rows(cov_mat), . )
	k = 0
	g = 1
	
	for (i=(rows(cov_mat));i>=1;i--) {
		b = i - 1
		c = rows(cov_mat) - b 
		
		for (x=1; x <= b; x++) {
			r1 = x + k 
			r2 = x + g
			res[r2,c] = edited_covs[r1,1]
			if (res[r2,c] > 1) {
				res[r2,c] = 1
			}
		}
		k = k + b
		g++ 
	}
	_diag(res, variances)
	_makesymmetric(res)
	return(res)
} 

//----- Return key for off_diag vector -----//
string matrix off_diag_key(real matrix cov_mat)
{
	real   scalar v, a, b, c, r, i, x
	string matrix res
	string scalar str1, str2, str 
	
	v = length(cov_mat[1...,1])
	a = v - 1
	b = 1
	for (i=a;i>=1;i--) {
		for (x=1;x<=i;x++) {
			c = v - i
			r = x + b
			str1 = strofreal(r)
			str2 = strofreal(c)
			str = str2 + " " + str1
			if (b == 1 & x == 1) res = str
			else res = (res \ str)
		}
		b++
	}
	return(res)	
}

//------ satterthwaite confidence interval procedure ----- //
real scalar is_colvec(z) return(anyof(("colvector","scalar"),orgtype(z)))
void row_to_col(real vector v) 
{
    if (is_colvec(v) == 0) v = v'
	else v = v 
}
real matrix satterthwaite(real vector variances,
						  real vector df,
						  real scalar ci_level)
{
	real colvector r, lower, upper 
	real matrix res 

	row_to_col(variances)
	row_to_col(df)
	
	r = sqrt(df/2)
	upper = variances:* (2*r:^2:/invchi2(df,(1-ci_level)/2))
	lower = variances:* (2*r:^2:/invchi2(df,(1+ci_level)/2))
	
	res = lower , upper 
	return(res) 
}



end 
