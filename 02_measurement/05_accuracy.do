clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/02_measurement/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "data"
global output   "output"

import excel "${root}/${data}/SimSE Calibration Activities.xls", sheet("SimSE Calibration Activities co") clear
keep A D H J L N P 
rename (A D H J L N P) (date rater x1 x2 x3 x4 x5)
drop in 1 
foreach v of varlist x* {
	encode `v' , gen(`v'2)
	tab `v' `v'2
	drop `v'
	rename `v'2 `v' 
}

label values x* .
recode x* (1 = 0) (2 =1)
encode rater, gen(Rater)
drop rater 
rename Rater rater 
replace date = substr(date,1,10)
gen session_date = date(date, "YMD")
format session_date %td
sort rater session_date
by rater: gen session = _n

reshape long x , i(rater session) j(item)
anova x i.item i.rater i.session

xtmixed x i.item || rater: || session: 
lincom _b[_cons]
lincom _b[_cons] + _b[1.item]
lincom _b[_cons] + _b[2.item]
lincom _b[_cons] + _b[3.item]
lincom _b[_cons] + _b[4.item]
lincom _b[_cons] + _b[5.item]


regress x i.item i.rater i.session
contrasts gw.item
