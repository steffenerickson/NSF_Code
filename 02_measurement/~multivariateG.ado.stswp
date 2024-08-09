//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Multivariate G Study for Balanced Designs 
// Author: Steffen Erickson
// Date: 7/28/2024
// Version 2
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Main Routine 
//----------------------------------------------------------------------------//
capture program drop mvgstudy 
program mvgstudy , rclass
	syntax anything [if] [in] 
	
	marksample touse 
	tempname tempframe 
	// Set up ----------
	* Parse syntax expression
	parse_equation `anything'
	local tempvarlist `r(vars)'
	local effects `r(effects)'
	foreach var of varlist `tempvarlist' {
		local varlist : list varlist | var
	}
	* Lengths for Loops
	local lengthdepvars	   :  list sizeof local(varlist)
	local lengtheffectlist :  list sizeof local(effects)
	* Find Facets
	mata facets = uniqrows(tokens(subinstr(subinstr(invtokens(st_local("effects")),"|"," "), "#"," "))')
	mata facets = invtokens(facets')
	mata st_local("facets",facets)
	* Find Facet Levels
	capture matrix drop facetlevels 
	foreach facet of local facets {
		qui levelsof `facet' if `touse' == 1
		matrix facetlevels = (nullmat(facetlevels) \ `r(r)')
	}
	* Find Residual 
	mata residual = sort_desc_length(tokens(st_local("effects")))[1]
	mata st_local("residual",residual)
	local effects2 : list effects - residual
	// Main Routine ----------
	* (1) Run manova
	frame put `varlist' `facets' if `touse' == 1, into(`tempframe')
	frame `tempframe' {
		qui manova `varlist' = `effects2'
	}
	estimates store manova_estimates
	* (2) Collect 
	recovermanova, facets(`facets') facetlevels(facetlevels) effects(`effects') residual(`residual')
	matrix df = r(df)
	matrix flproducts = r(flproducts)
	forvalues i = 1/`lengtheffectlist' {
		matrix sscp`i' = r(sscp`i')
		local mat sscp`i'
		local matrixlist : list matrixlist | mat 
	}	
	* (3) Create P matrix (EMCP equation matrix)
	createP, effects(`effects') flproducts(flproducts)
	matrix P = r(P)
	* (4) Expected Mean Cross Products (covariance components)
	emcpmatrixprocedure, df(df) p(P) 		   
	forvalues i = 1/`lengtheffectlist' { 
		matrix covcomps`i' = r(comp`i')
	}
	// Display Results ----------
	foreach x of local varlist {
		local name   "`x'"
		local names `" `names' "`name'" "'
	}
	forvalues i = 1/`lengtheffectlist' {
		matrix rownames covcomps`i' = `names'
		matrix colnames covcomps`i' = `names'
		matlist covcomps`i' , twidth(30) title("`:word `i' of `effects'' Component Covariance Matrix")
	}
	// Return results ----------
	forvalues i = 1/`lengtheffectlist' { 
		return matrix covcomps`i' = covcomps`i'
	}
	return matrix P = P 
	return matrix df = df 
	return matrix flproducts = flproducts 		
end 

//----------------------------------------------------------------------------//
// Stata sub-routines 
//----------------------------------------------------------------------------//
capture program drop recovermanova
program recovermanova, rclass 
	syntax,  FACETS(string) FACETLEVELS(string) EFFECTS(string) RESIDUAL(string)
	
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
	*facet level products
	mata st_matrix("flproducts",get_facetlevelproducts(tokens(st_local("effects")),tokens(st_local("facets")),st_matrix("`facetlevels'")))
	foreach x of local effects {
		local name   "`x'"
		local names `" `names' "`name'" "'
	}
	matrix rownames flproducts = `names'
	*return results 
	forvalues i = 1/`j' {
		return matrix sscp`i' = `sscp`i''
	}
	return matrix df = `df'
	return matrix flproducts = flproducts
end 

capture program drop createP
program createP, rclass 
	syntax,   EFFECTS(string) FLPRODUCTS(string)
	
	mata st_matrix("P",get_p(tokens(st_local("effects")),st_matrix("`flproducts'")))
	foreach x of local effects {
		local name   "`x'"
		local names `" `names' "`name'" "'
	}
	matrix rownames P = `names'
	matrix colnames P = `names'
	return matrix P = P
end 

capture program drop emcpmatrixprocedure
program emcpmatrixprocedure, rclass 
	syntax,  DF(string) P(string) 
	
	capture matrix drop stacked
	forvalues i = 1/`:colsof(`p')' {
		scalar a = df[`i',1]
		mata df = st_numscalar("a")
		mata temp = st_matrix("sscp`i'")
		mata mscp`i' = temp :/df
		mata st_matrix("mscp`i'",mscp`i')
		matrix stacked = (nullmat(stacked) \ mscp`i')
		local emcpname emcp`i'
		local emcpnames : list emcpnames | emcpname
	}
	if `:colsof(stacked)' == 1 {
		mata ems = luinv(st_matrix("`p'")) * st_matrix("stacked") 
		mata st_matrix("ems",ems)
		forvalues i = 1/`:colsof(`p')'{
			matrix comp`i' = ems[`i',1]
			return matrix comp`i' = comp`i'
		}
	}
	else {
		mata A = emcpmatrixprocedure(st_matrix("stacked"),st_matrix("`p'"),tokens(st_local("emcpnames")))	
		mata for (loc=asarray_first(A); loc!=NULL; loc=asarray_next(A, loc)) st_matrix(asarray_key(A, loc),asarray_contents(A, loc))
		forvalues i = 1/`:colsof(`p')'{
			return matrix comp`i' = emcp`i'
		}
	}
end 

cap prog drop parse_equation
program parse_equation, rclass
	syntax anything 
	
	tempname str pos i 
	mata `str' = st_local("anything")
	mata `str' = tokens(subinstr(subinstr(`str',"(",""),")",""))
	mata `pos' = strpos(`str',"=")
	mata `i' = 1
	mata while (`pos'[`i'] < 1) ++`i'
	mata st_local("vars", invtokens(`str'[1,1..`i' - 1]))
	mata st_local("effects",invtokens(`str'[1,`i' + 1..cols(`str')]))
	return local vars `vars' 
	return local effects `effects'
end

	
//----------------------------------------------------------------------------//
// mata sub-routines 
//----------------------------------------------------------------------------//
mata
string matrix sort_desc_length(string vector M)
{
	real   scalar 		i,j
	string scalar		temp 
	string matrix 		res
	
	res = M 
	for (i=2;i<=length(M);i++){
		temp = res[i]
		j = i - 1
		while (j >= 1 & strlen(temp) > strlen(res[j])) {
			res[j + 1] = res[j]
			j--
			if (j < 1) break 
		}
		res[j+1] = temp 
	}
	return(res)
}

// Rule π(α̇) = {1 if α = ω; and, otherwise, the product of the sample sizes for all indices in α̇}
real vector get_facetlevelproducts(string vector effects, string vector facets, real vector fls)
{
	real scalar 		flp,x,i,j
	real vector         flps
	
	flps = J(1,length(effects),.)
	for(i=1;i<=length(effects);i++) {
		flp = 1 
		for(j=1;j<=length(facets);j++) {
			if (strpos(effects[i],facets[j]) == 0) x = fls[j]
			else x = 1
			flp = flp * x 
		}
		flps[i] = flp 
	}
	flps = flps'
	return(flps)
	flps
}

real matrix get_p(string vector effects, real vector flproducts)
{
	string rowvector 	effects_stripped
	real scalar 		row, col 
	real matrix 		P
	
	effects_stripped = tokens(subinstr(subinstr(invtokens(effects),"|",""), "#",""))
	P = J(length(effects_stripped),length(effects_stripped),0)
	for(col=1;col<=length(effects_stripped);col++){
		row = col
		while (row >= 1) {
			P[row, col] = flproducts[col]
			--row
		}
	}
	for(row=1;row<=length(effects_stripped);row++) {
		for(col=1;col<=length(effects_stripped)-1;col++) {
			if (strpos(effects_stripped[col],effects_stripped[row])== 0) P[row,col] = 0 
		}
	}
	return(P)
}

transmorphic matrix emcpmatrixprocedure(real matrix stacked, real matrix p, string matrix names)
{
	transmorphic matrix 	emcp
	real scalar 			skip 
	real matrix 			rangemat, starting, ending, inv_p,temp,res
	real scalar 			i, j
	
	emcp = asarray_create()   
	skip = cols(stacked)
	rangemat = range(0,rows(stacked),skip)
	starting = rangemat[1..(rows(rangemat)-1)]:+1
	ending = rangemat[2..rows(rangemat)]
	inv_p = luinv(p)
	for(i=1;i<=cols(p);i++){
		res = J(cols(stacked),cols(stacked),0)
		for(j=1;j<=cols(p);j++) {
			temp = stacked[starting[j]..ending[j],1..cols(stacked)]
			res = res + (temp * inv_p[i,j])
		}
		asarray(emcp,names[i],res)
	}
	return(emcp)
}

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
		}
		k = k + b
		g++ 
	}
	_diag(res, variances)
	_makesymmetric(res)
	return(res)
} 

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
end 
