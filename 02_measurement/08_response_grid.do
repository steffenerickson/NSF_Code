// Config
clear all
frame reset
//mata mata clear
global root /Users/steffenerickson/Desktop/summer2024/simsemeasurment/full_routine
global code code
global data data
global results results 

// mvgstudy command 
include ${root}/${code}/00_mvgstudy.ado
use ${root}/${data}/manova_data.dta, clear

// Limit to balanced sample 
drop x6
rename (task rater coaching) (t r treat)
drop if (r == 3) | (treat == 2) | (x1 == . | x2 == . | x3 == . | x4 == . | x5 == .)
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
bysort p : gen n = _n 
egen c  = count(n) , by(p)
keep if c == 12
drop id  c n participantid dupes
reshape long x , i(r time t treat block p site semester) j(item)
*heatplot x i.item i.t, values(format(%9.0f)) /*legend(off)*/ aspectratio(1) colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(treat)


//collapse x , by(treat block item t site semester r )
//reshape wide x, i(t block item site semester r p) j(treat)
//gen tau = x1 - x0 
label define blocks 1 "Site 1"  2 "Site 2" 3 "Site 3" 4 "Site 4"
label define times  0 "BOY"  1 "EOY"
label values block blocks
label values time times
label variable t "Teaching Task"
label variable item "Teaching Skill"


heatplot x i.item i.t if treat == 1 , values(format(%9.2f)) legend(off) /*aspectratio(1)*/ colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(time block, legend(off) rows(2) note("")) ///
xlabel(1 "Addition" 2 "Fractions"  3 "Decimals") ///
ylabel(1 "Skill 1" 2 "Skill 2" 3 "Skill 3" 4 "Skill 4" 5 "Skill 5") 
graph export ${root}/${results}/effectgrid1.png , replace


forvalues i = 1/9 {
	local add `i' "Teacher `i'"
	local list : list list | add
}
heatplot x i.p i.r if treat == 1 & time == 1 & block == 1 & item == 2 & t == 2 , values(format(%9.2f)) legend(off) /*aspectratio(1)*/ colors(plasma, intensity(.6)) p(lc(black) lalign(center)) note("")  ///
xlabel(1 "Observation 1" 2 "Observation 2") ///
ylabel(`list') ytitle("")
graph export ${root}/${results}/effectgrid2.png , replace

preserve
keep if treat == 1
collapse x , by(item t block time)
gen xcheck = x 
regress x i.item##i.t##i.block##i.time
bysort block time item: gen randnum = runiform()
sort block time item randnum
by block time item: gen n = _n
replace x = . if n > 2

heatplot x i.item i.t , values(format(%9.2f)) legend(off) /*aspectratio(1)*/ colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(time block, legend(off) rows(2) note("")) ///
xlabel(1 "Addition" 2 "Fractions"  3 "Decimals") ///
ylabel(1 "Skill 1" 2 "Skill 2" 3 "Skill 3" 4 "Skill 4" 5 "Skill 5") 
graph export ${root}/${results}/effectgrid3.png , replace
restore






/*







/*
heatplot x i.item i.t if treat == 1 & time == 1, values(format(%9.2f)) legend(off) /*aspectratio(1)*/ colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(block , legend(off) note("")) ///
xlabel(1 "Fractions 1" 2 "Fractions 2"  3 "Decimals") ///
ylabel(1 "Skill 1" 2 "Skill 2" 3 "Skill 3" 4 "Skill 4" 5 "Skill 5") 

*/

/*
heatplot x i.item i.t , values(format(%9.2f)) legend(off) /*aspectratio(1)*/ colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(treat time block, legend(off) rows(4) note("")) ///
xlabel(1 "Fractions" 2 "Fractions "  3 "Decimals") ///
ylabel(1 "Skill 1" 2 "Skill 2" 3 "Skill 3" 4 "Skill 4" 5 "Skill 5") 
*/




regress x i.item##i.t##i.block##i.time
predict xp 

heatplot xp i.item i.t , values(format(%9.2f)) legend(off) /*aspectratio(1)*/ colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(time block, legend(off) rows(2) note("")) ///
xlabel(1 "Addition" 2 "Fractions"  3 "Decimals") ///
ylabel(1 "Skill 1" 2 "Skill 2" 3 "Skill 3" 4 "Skill 4" 5 "Skill 5") 

heatplot xcheck i.item i.t , values(format(%9.2f)) legend(off) /*aspectratio(1)*/ colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(time block, legend(off) rows(2) note("")) ///
xlabel(1 "Addition" 2 "Fractions"  3 "Decimals") ///
ylabel(1 "Skill 1" 2 "Skill 2" 3 "Skill 3" 4 "Skill 4" 5 "Skill 5") 






title("Variation in Instructional Quality over different Skills, Lessons, and Contexts")


heatplot tau i.item i.t, values(format(%9.3f)) legend(off) aspectratio(1) colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(site semester , legend(off) note(""))



heatplot x1 i.item i.t, values(format(%9.3f)) legend(off) aspectratio(1) colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(site semester , legend(off) note(""))







heatplot tau i.item i.t, values(format(%9.2f)) legend(off) aspectratio(1) colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(site , legend(off) note(""))

heatplot tau i.item i.t, values(format(%9.2f)) legend(off) aspectratio(1) colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(site semester, legend(off) note(""))


egen x = rowmean(x0 x1)
heatplot x i.item i.t, values(format(%9.2f)) legend(off) aspectratio(1) colors(plasma, intensity(.6)) p(lc(black) lalign(center)) by(site semester, legend(off) note(""))



regress tau i.item##i.block



collapse x , by(time treat block p item)


sort item t 

keep x item p 

heatplot x item p 



/*
capture matrix drop p item t 
qui regress x i.p i.t i.item 
contrasts g.p g.item g.t
mat C = r(table)[1,1..`:colsof(r(table))']'
local rownames : rowfullnames C
local i = 1
foreach rowname of local rownames {
	if strpos("`rowname'",".p") > 0 mat p = (nullmat(p)\C[`i',1])
	if strpos("`rowname'",".item") > 0 mat item = (nullmat(item)\C[`i',1])
	if strpos("`rowname'",".t") > 0 mat t = (nullmat(t)\C[`i',1])
	local++i 
}
mkf Contrasts 
frame change Contrasts 
svmat p 
gen n = _n
collapse n, by(p)
drop n 
svmat item 
svmat t 
rename *1 *

save ${root}/${results}/Contrasts.dta





