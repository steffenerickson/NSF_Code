

//----------------------------------------------------------------------------//
//			Missing Data Imputation Programs 								  //
//----------------------------------------------------------------------------//

//--------------------------//
//Check Binary Subroutine 
//--------------------------//


cap program drop check_binary 
program check_binary, rclass

	syntax varlist(max = 1)
	
	su `varlist', mean
	if (`varlist' == r(min) | `varlist' == r(max) | `varlist' >= . ) & r(min) != r(max) {
		scalar b = 1
	}
	else {
		scalar b = 0
	}
	
	return scalar binary = b

end 

//--------------------------//
//Imputation 
//--------------------------//

// Imputes mean for missing covariates. Creates a dummy variable to indicate 
// that the observation has an imputed value for the variable. If the block
// option is used, the imputed mean is the block mean 
// If the variable is dichotomous, 0 is imputed 

cap program drop impute_mean
program impute_mean, nclass 

	syntax varlist(max=1) [if] [,BLOCK(varlist) TREATMENT(varlist) CONDITION(real 0)]
	
	if "`treatment'" != "" {
		if "`block'" != "" {
			local if_in_condition & `treatment' == `condition'
		}
		else {
			local if_in_condition if `treatment' == `condition'
		}
	}
	
	if "`block'" != "" {
		capture confirm string `block'
		qui levelsof `block' , local(levels)
		local i = 1
		foreach l of local levels {
			gen `varlist'_im_`i' = (`varlist' == .)
			if !_rc {
				check_binary `varlist'
				if r(binary) == 1 {
					local mu = 0
				}
				else {
					qui sum `varlist' if `block' == `"`l'"' `if_in_condition' 
					local mu = r(mean)
				}
				replace `varlist' = `mu' if `varlist' == . & `block' == `"`l'"'
			}
			else {
				check_binary `varlist'
				if r(binary) == 1 {
					local mu = 0
				}
				else {
					qui sum `varlist' if `block' == `l' `if_in_condition' 
					local mu = r(mean)
				}
				replace `varlist' = `mu' if `varlist' == . & `block' == `l'
			}
			local++i
		}
		egen `varlist'_im = rowmax(`varlist'_im_*) 
		drop `varlist'_im_*
	}
	else {
		gen `varlist'_im = (`varlist' == .)
		check_binary `varlist'
		if r(binary) == 1 {
			local mu = 0
		}
		else {
			qui sum `varlist' 
			local mu = r(mean) `if_in_condition' 
		}
		replace `varlist' = `mu' if `varlist' == . 
	}

end 

