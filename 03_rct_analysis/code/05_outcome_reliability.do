clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/rct"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/03_rct_analysis/code"
global data     "data"
global output   "output"
global output   "output"
include "/Users/steffenerickson/Documents/GitHub/stata_programs/mvgstudy.ado"

* Import files 
local filelist : dir "${root}/${output}/" files "*.dta"
if `:word count `filelist'' < 3 {
	do "{code}/02_data_set_up.do"
}
frame reset 
local filelist : dir "${root}/${output}/" files "*.dta"
local i = 1 
foreach file of local filelist {
	mkf fr`i'
	frame fr`i' : use "${root}/${output}/`file'" , clear
	local++i
}

// ---- Simse
frame change fr3 
preserve
keep if time ==1
keep id task simse task 
bysort id task: gen rater = _n
mvgstudy (simse = id task id#task rater|task id#rater|task)
scalar rel1 = r(covcomps1)[1,1] / (r(covcomps1)[1,1] + r(covcomps3)[1,1]/3 +  r(covcomps5)[1,1]/6)
restore
di rel1 

preserve
keep if time == 2
keep id model_num simse rater
collapse simse , by(id rater)
drop rater 
bysort id : gen rater = _n
mvgstudy (simse = id rater|id)
scalar rel2 = r(covcomps1)[1,1] / (r(covcomps1)[1,1] + r(covcomps2)[1,1]/2)
restore


// ---- QCI 
frame change fr1
preserve
keep qci rater segment id 
collapse qci , by(id rater)
drop rater 
bysort id : gen rater = _n
mvgstudy (qci = id rater|id)
scalar rel3 = r(covcomps1)[1,1] / (r(covcomps1)[1,1] + r(covcomps2)[1,1]/2)
restore
// ---- MQI
frame change fr2
preserve
keep mqi rater segment id 
collapse mqi , by(id rater)
drop rater 
bysort id : gen rater = _n
mvgstudy (mqi = id rater|id)
scalar rel4 = r(covcomps1)[1,1] / (r(covcomps1)[1,1] + r(covcomps2)[1,1]/2)
restore


mat rel = rel1 \ rel2 \ rel3 \ rel4
mat rownames rel = "Performance Task SIMSE" "Classroom SIMSE" "QCI" "MQI"
frmttable using "${root}/${output}/table5.rtf" , ///
statmat(rel) ///
ctitles("", "Reliability") ///
title("Outcome Reliability Coefficients") ///
coljust(c) ///
replace






