mata mata clear 
qui include multivariateG.ado
capture program drop remove_last
program remove_last, rclass
syntax varlist 
foreach name of local varlist  {
local pos = strrpos("`name'","_")
local stub = substr("`name'",1,`pos'-1)
local stubs : list stubs | stub
return local stubs `stubs'
}
end 

clear
forvalues i = 1/2 {
forvalues j = 1/3 {
forvalues k = 1/2 {
local name x`i'_t`j'_r`k'
local list: list list | name 
}
}
}
input `list'
1 3 3 1 3 2 1 2 2 2 2 1 1
2 2 1 1 1 1 1 1 1 1 1 1 1
3 1 2 2 2 1 1 1 1 2 2 1 1
4 1 2 2 2 1 1 1 2 2 2 2 1
end  

gen p = _n
remove_last x*
greshape long `r(stubs)', i(p) j(r) string
remove_last x*
greshape long `r(stubs)' , i(p r) j(t) string 
foreach facet in t r {
tempname temp
encode `facet' , gen(`temp')
drop `facet'
rename `temp' `facet'
}

version 16: table p r t, c(mean x1 mean x2)

mvgstudy (x* = p t p#t r|t p#r|t)



