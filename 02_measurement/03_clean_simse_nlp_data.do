clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement"
global datapull "/Users/steffenerickson/Documents/GitHub/NSF_Code/01_project_managment/_pull_data.do"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/02_measurement/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "data"
global output   "output"
global nlp      "nlp_scoring_data"

global dims Objective Unpacking Self-Instruction Self-Regulation Ending 
global type dev train test  
local filelist : dir . files "*.csv"
local i=1 
foreach file of local filelist {
	qui mkf fr`i'
    qui frame fr`i' : import delimited using "${root}/${nlp}/`file'"
	qui frame fr`i' : capture drop text 
	qui frame fr`i' : gen type = "`file'"
	*frame fr`i' : list in 1/10
	qui frame fr`i' : rename (*) (file rating prediction type)
	local++i
}
frame dir fr*
local framelist `r(frames)'
local n : list sizeof local(framelist)
frame copy fr1 full , replace
forvalues i = 2/`n' {
	frame fr`i' : tempfile data 
	frame fr`i' : save `data'
	frame full  : append using `data', force
}
frame drop fr*	
frame change full 

gen file_name = regexs(0) if regexm(file,"([0-9]*)_([a-zA-Z][0-9]*)_([0-9]*)_([0-9]*)_[a-zA-Z][0-9]")
drop file 
drop if file_name == ""
split type, parse(_)
drop type3 type
rename (type1 type2) (type dim)

drop if dim == "Accuracy & Clarity"
label define dims		1 "Objective" ///
						2 "Unpacking" ///
						3 "Self-Instruction" ///
						4 "Self-Regulation" ///
						5"Ending"
         
encode dim , gen(dim2) label(dims)
drop dim 
rename dim2 dim

collapse rating prediction, by(file_name type dim)
reshape wide rating prediction, i(file_name type)  j(dim)
drop rating?

rename (prediction*) (x1 x2 x3 x4 x5)


split file_name, parse(_)

drop file_name3 

rename (file_name1 file_name2 file_name4 file_name5) (site semester participantid task)


replace task = strlower(task)
encode task, gen(task2)
drop task 
rename task2 task 
gen time = (task > 3)
recode task (4=1)(5=2)(6=3) if time == 1

label define sites 1 "UVA" 2 "UD" 3 "JMU"
label define sems 0 "F22" 1 "S23"
encode semester, gen(semester2) label(sems)
encode site, gen(site2) 
drop site semester 
rename (site2 semester2) (site semester)

label values site sites


drop file_name 

collapse x?, by(participantid site semester time task)

reshape wide x? , i(participantid site semester time) j(task)

reshape wide x?? , i(participantid site semester) j(time)

ds x*
foreach x in `r(varlist)' {
	replace `x' = `x' + 1
}
rename x??? x???c
save "${root}/${data}/aidata.dta", replace


