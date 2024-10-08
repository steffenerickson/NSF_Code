//----------------------------------------------------------------------------//
// Balanced Multivariate G-Study (reduces to univariate with one outcome)
// for calculating variance components 
//----------------------------------------------------------------------------//
mata
mata clear 
//------------ Structures -----------------//
struct myproblem {
	string rowvector		depvars 
	string rowvector 		effects
	string rowvector 		facets 
	real matrix 			DATA
	struct derived_objects 	scalar dobj
}

struct derived_objects {
	real rowvector			fls					// levels of each facet 
	real rowvector 			df 					// effects degrees of freedom
	real rowvector 			flps 		   		// facet level products
	real matrix 			P					// facet level prducts matrix for matrix procedure to create EMS matrices 
	struct TOTALstruct 		scalar tscp 		// total squares and cross products
	struct decomplist		scalar decomplist 	// string vector of effects used in decomposition for a particular effect
	struct SSCPstruct 		scalar sscp 		// sums of squares and cross products
	struct MSCPstruct		scalar mscp     	// mean squares and cross products
	struct EMSstruct		scalar ems			// expected mean squares and cross products
	struct SEstruct 		scalar se			// standard errors for ems matrices 
}

//------------ Main Routine -----------------//
void command(string scalar equation,real matrix DATA)
{
	struct myproblem 		scalar pr
	
	initialize_objects(pr.dobj)
	pr.depvars  = tokens(ustrsplit(equation, "=")[1])
	pr.effects  = tokens(ustrsplit(equation, "=")[2])
	pr.DATA 	= DATA
	pr.facets 	= find_unique_strings(tokens(subinstr(subinstr(invtokens(pr.effects),"|"," "), "#"," ")))
	manovaroutine(pr)
}
void initialize_objects(struct derived_objects scalar dobj)
{
	dobj.fls 		 = J(0,0,.)
	dobj.df 		 = J(0,0,.)
	dobj.flps 		 = J(0,0,.)
	dobj.P 			 = J(0,0,.)
	dobj.decomplist  = asarray_create() 
	dobj.tscp 		 = asarray_create()  
	dobj.sscp 		 = asarray_create()  
	dobj.mscp 		 = asarray_create()  
	dobj.ems 		 = asarray_create()  
	dobj.se 		 = asarray_create()  
}
void manovaroutine(struct myproblem scalar pr)
{
	get_facetlevels(pr) //complete
	get_df(pr) //complete 
	get_facetlevelproducts(pr) //complete
	get_totalproducts(pr) // complete 
	get_decomplist(pr) // complete 
	get_sscp(pr)
	get_mscp(pr)
	get_p(pr)
	get_ems(pr)
	get_se(pr)
}

//------------ Manova Sub routines -----------------//
// get_facetlevels()
void get_facetlevels(struct myproblem scalar pr)
{
	real scalar 	i, col_index
	
	pr.dobj.fls = J(1,length(pr.facets),.)
	for(i=1;i<=length(pr.facets);i++) {
		col_index = i + length(pr.depvars) // facets are at the end of the matrix following dependent variables 
		pr.dobj.fls[i] = rows(panelsetup(sort(pr.DATA,col_index),col_index)) // counts rows in panelsetup matrix to get number of fact levels 
	}
}

// get_df()
void get_df(struct myproblem scalar pr)
{
	pr.dobj.df = J(1,length(pr.effects),.)
	for(i=1;i<=length(pr.effects);i++ ) {
		if (strmatch(pr.effects[i],"*#*") == 0 & strmatch(pr.effects[i],"*|*") == 0) pr.dobj.df[i] = df_maineffect(pr.dobj.fls,pr.facets,pr.effects[i])
		else if (strmatch(pr.effects[i],"*#*") == 1 & strmatch(pr.effects[i],"*|*") == 0) pr.dobj.df[i] = df_interaction(pr.dobj.fls,pr.facets,pr.effects[i])
		else if (strmatch(pr.effects[i],"*#*") == 0 & strmatch(pr.effects[i],"*|*") == 1) pr.dobj.df[i] = df_nested(pr.dobj.fls,pr.facets,pr.effects[i])
		else if (strmatch(pr.effects[i],"*#*") == 1 & strmatch(pr.effects[i],"*|*") == 1) pr.dobj.df[i] = df_nested_interaction(pr.dobj.fls,pr.facets,pr.effects[i])
		// else if need a way to spit out an error if invalid symbols are used 
	}
}

// get_facetlevelproducts()
void get_facetlevelproducts(struct myproblem scalar pr)
{
	real scalar 		flp,x,i,j
	
	pr.dobj.flps = J(1,length(pr.effects),.)
	for(i=1;i<=length(pr.effects);i++) {
		flp = 1 
		for(j=1;j<=length(pr.facets);j++) {
			if (strpos(pr.effects[i],pr.facets[j]) == 0) x = pr.dobj.fls[j]
			else x = 1
			flp = flp * x 
		}
		pr.dobj.flps[i] = flp 
	}
}

// get_totalproducts()
void get_totalproducts(struct myproblem scalar pr)
{
	
	string rowvector 		effect_split
	string colvector 		cols_concat
	real rowvector			col_index
	real matrix 			DATAtemp,info,Means,TSCP
	real scalar 			i,j,k,x,totals_multiplier_u
	
	DATAtemp = pr.DATA
	for(i=1;i<=length(pr.effects);i++) {
		// determines what column contains the factor variable(s)
		effect_split = ustrsplit(pr.effects[i], "[|#]")
		s = J(1,length(pr.facets),1)
		for(j=1;j<=length(effect_split);j++) s = s :* indexnot(effect_split[j],pr.facets)
		col_index  = select((1..length(pr.facets)),s :== 0) :+ length(pr.depvars)
		_sort(DATAtemp,col_index)
		
		// additional work for interaction or nesting 
		if (length(col_index) > 1 ) {
			for(k=1;k<=length(col_index);k++) {
				if (k == 1) cols_concat = strofreal(DATAtemp[.,col_index[k]]) 
				else cols_concat = cols_concat + strofreal(DATAtemp[.,col_index[k]])
			}
			DATAtemp = DATAtemp, strtoreal(cols_concat)	
			col_index = cols(DATAtemp) // turn col_index back to scalar indicating the column
		}
		
		//creates the tscp matrix and stores in associative array 
		info = panelsetup(DATAtemp,col_index)
		Means = J(0,length(pr.depvars),.)
		for(x=1; x<=rows(info); x++) Means = Means \ mean(panelsubmatrix(DATAtemp,x,info)[1...,1..length(pr.depvars)])
		TSCP = Means' * Means * totals_multiplier(pr.effects[i],pr.facets,pr.dobj.fls) // totals_multiplier is user written
		asarray(pr.dobj.tscp, pr.effects[i], TSCP) // store matrix in the associative array 
	}
	
	//grand means 
	totals_multiplier_u = 1 
	for(i=1;i<=length(pr.dobj.fls);i++) totals_multiplier_u = totals_multiplier_u *pr.dobj.fls[i]
	TSCP = mean(DATAtemp[1...,1..length(pr.depvars)]) * totals_multiplier_u
	asarray(pr.dobj.tscp, "u", TSCP)
}

// get_decomplist()
void get_decomplist(struct myproblem scalar pr)
{
	
	string rowvector 		vec,temp_vec,result,splits
	string scalar 			nesting_index
	real scalar 			check,i,j,x
	
	vec = sort_desc_length(pr.effects), "u" // add u representing the grand mean to the end of the vector 
	for(i=1;i<=length(vec)-1;i++) {
		temp_vec = vec[i..length(vec)]
		result = temp_vec[1]
		splits = ustrsplit(temp_vec[1],"[|#]")
		nesting_index = splits[length(splits)]
		for(j=2;j<=length(temp_vec);j++) {
			check = 0 
			for(x=1;x<=length(splits);x++) {
				check = check + strpos(temp_vec[j],splits[x])
			}
			if (strmatch(temp_vec[1],"*|*|*") == 1 & strmatch(temp_vec[1],"*#*") == 0) { // multiple levels of nesting (e.g.,-> i|h|p )
				if (check > 0 & ///
				length(ustrsplit(temp_vec[j],"[#|]")) == length(ustrsplit(temp_vec[1],"[#|]")) - 1) ///
				result = result,temp_vec[j]
			}
			else if (strmatch(temp_vec[1],"*|*#*") == 1) { // items nested within levels defined by two or more blocks (e.g., -> i | (p # h))
				if (check > 0 & ///
				length(ustrsplit(temp_vec[j],"[#]")) == length(ustrsplit(temp_vec[1],"[#]"))) ///
				result = result,temp_vec[j]
			}
			else if (strpos(temp_vec[1],"|") != 0) { //  nested within facets (e.g.,-> p # (i:h))
				if (check > 0 & strpos(temp_vec[j],nesting_index) > 0 ///
				& length(ustrsplit(temp_vec[j],"[#|]")) < length(ustrsplit(temp_vec[1],"[#|]"))) ///
				result = result,temp_vec[j]
			}
			else { // crossed or main effects
				if ((check > 0  ///
				& length(ustrsplit(temp_vec[j],"[#|]")) < length(ustrsplit(temp_vec[1],"[#|]"))) ///
				| temp_vec[j] == "u" ) ///
				result = result,temp_vec[j]
			}
		}
		asarray(pr.dobj.decomplist, temp_vec[1], result)
	}
}
// get_sscp()

// get_mscp()

// get_p()

void get_p(struct myproblem scalar pr)
{
	string rowvector 	effects_stripped
	real scalar 		row, col 
	
	effects_stripped = tokens(subinstr(subinstr(invtokens(pr.effects),"|",""), "#",""))
	pr.dobj.P  = J(length(effects_stripped),length(effects_stripped),0)
	for(col=1;col<=length(effects_stripped);col++){
		row = col
		while (row >= 1) {
			pr.dobj.P[row, col] = pr.dobj.flps[col]
			--row
		}
	}
	for(row=1;row<=length(effects_stripped);row++) {
		for(col=1;col<=length(effects_stripped)-1;col++) {
			if (strpos(effects_stripped[col],effects_stripped[row])== 0) pr.dobj.P[row,col] = 0 
		}
	}
	return(P)
}

// get_ems()

//stacked = mscp_p  \  mscp_t   \ mscp_pt  \ mscp_tr  \ mscp_ptr 
//skip = cols(p)
//rangemat = range(0,rows(stacked),skip)
//Start = rangemat[1..(rows(rangemat)-1)]:+1
//End = rangemat[2..rows(rangemat)]
//inv_p = luinv(p)
//for(i=1;i<=cols(p);i++){
//	res = J(rows(p),cols(p),0)
//	for(j=1;j<=cols(p);j++) {
//		temp = stacked[Start[j]..End[j],1..cols(p)]
//		res = res + (temp * inv_p[i,j])
//	}
//	res
//}


// get_se()

/*
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
*/

//------------  Sub-Sub rountines (helper functions) -----------------//

// find_unique_strings()
string rowvector find_unique_strings(string rowvector strings)
{
	string rowvector 	uniquestrings
	real scalar 		i 
	
	uniquestrings = J(1,length(strings),"")
	for (i=1;i<=length(strings);i++){
		if (indexnot(strings[i],uniquestrings) == J(1,length(strings),1)) uniquestrings[i] = strings[i]
	}
	return(select(uniquestrings,uniquestrings:!=""))
}

// sort_desc_length() sort and insert algorithm
string matrix sort_desc_length(string matrix M)
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

// get_df() sub-routines //

// main effects 
real scalar df_maineffect(real rowvector n_facets, 
						   string rowvector facets,
						   string scalar effect) 
{
	return(select((strpos(facets,effect):*n_facets),(strpos(facets,effect):*n_facets):>0) - 1) 
}

// interactions 
real scalar df_interaction(real rowvector n_facets, 
						   string rowvector facets,
						   string scalar effect) 
{
	real scalar 		result
	string rowvector 	effect_split 
	
	result = 1 
	effect_split = ustrsplit(effect, "[#]")
	for(i=1;i<=length(effect_split);i++) result = result * (select((strpos(facets,effect_split[i]):*n_facets),(strpos(facets,effect_split[i]):*n_facets):>0) - 1) 
	return(result)
}

// nesting
real scalar df_nested(real rowvector n_facets, 
					  string rowvector facets,
					  string scalar effect) 
{
	real scalar 		result
	string rowvector 	effect_split 
	
	result = 1 
	effect_split = ustrsplit(effect, "[|]")
	for(i=1;i<=length(effect_split);i++) {
		if (i == 1) result = result * (select((strpos(facets,effect_split[i]):*n_facets),(strpos(facets,effect_split[i]):*n_facets):>0) - 1) // nested indices are subtracted by. 1
		else result = result * (select((strpos(facets,effect_split[i]):*n_facets),(strpos(facets,effect_split[i]):*n_facets):>0)) 	 // nesting indices are not subtracted by 1 
	}
	return(result)
}

// interactions and nesting
real scalar df_nested_interaction(real rowvector n_facets, 
								  string rowvector facets,
								  string scalar effect) 
{
	real scalar 		result
	real scalar 		start_nesting
	string rowvector 	effect_split 
	
	result = 1 
	start_nesting = strpos(subinstr(effect, "#",""),"|") // find the position where the nesting indices start 
	effect_split = ustrsplit(effect, "[|#]")
	for(i=1;i<=length(effect_split);i++) {
		if (i == start_nesting) result = result * (select((strpos(facets,effect_split[i]):*n_facets),(strpos(facets,effect_split[i]):*n_facets):>0) )  // nesting indices are not subtracted by 1 
		else result = result * (select((strpos(facets,effect_split[i]):*n_facets),(strpos(facets,effect_split[i]):*n_facets):>0)-1) // nested indices are subtracted by 1
	}
	return(result)
}

// get total squares and cross products multiplier 
real scalar totals_multiplier(string scalar effect,
							  string rowvector facets, 
							  real rowvector n_facets)
{
	string rowvector 	effect_split
	real rowvector 	 	n_facets_notindex,n_facets_notvalues
	real scalar 		i, result 
	
	effect_split = ustrsplit(effect, "[|#]")
	n_facets_notindex = J(1,length(facets),1)
	for(i=1;i<=length(effect_split);i++) n_facets_notindex = n_facets_notindex :* indexnot(effect_split[i],facets)
	n_facets_notvalues = select((n_facets_notindex :* n_facets),(n_facets_notindex :* n_facets) :!= 0)
	result = 1
	for(i=1;i<=length(n_facets_notvalues);i++) result = result * n_facets_notvalues[i]
	return(result)
}

//Return off diagonal from covariance matrix
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

//rebuild covariance matrix
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

// Return key for off_diag vector
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




