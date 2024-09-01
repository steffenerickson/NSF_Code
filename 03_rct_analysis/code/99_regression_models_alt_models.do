clear all
global root     "/Users/steffenerickson/Desktop/summer2024/nsf/full_routine"
global code     "code"
global data     "data"
global output   "output"

* Import files 
local filelist : dir "${root}/${output}/" files "*.dta"
if `:word count `filelist'' < 3 {
	do ${root}/${code}/02_data_set_up.do
}
frame reset 
local filelist : dir "${root}/${output}/" files "*.dta"
local i = 1 
foreach file of local filelist {
	mkf fr`i'
	frame fr`i' : use ${root}/${output}/`file' , clear
	local++i
}

frame dir 

global covariates pre_simse d162 d167 d126_1 d126_2 d126_3 d126_4 d126_5 d132 ///
        d142 d156_1 d156_2 d156_3 d156_4 d156_5 d921 d107 

//----------------------------------------------------------------------------//
* Simse
//----------------------------------------------------------------------------//
frame change fr3 
* Performance Tasks 
regress simse_s i.t i.block i.task if time == 1, vce(cluster id)
regress simse_s i.t i.block i.task i.rater if time == 1, vce(cluster id)
regress simse_s i.t i.block i.task i.rater pre_simse *_im if time == 1, vce(cluster id)
regress simse_s i.t i.block i.task i.rater pre_simse $covariates *_im if time == 1, vce(cluster id)

* estimating within cells defined by factors 
anova simse_s i.block##i.rater##i.task t
regress simse_s i.t i.block##i.rater##i.task pre_simse $covariates *_im if time == 1, vce(cluster id)

* Student Teaching Placement 
regress simse_s i.t i.block i.rater i.model_num if time == 2, vce(cluster id)
regress simse_s i.t i.block i.rater i.model_num pre_simse *_im if time == 2, vce(cluster id)
regress simse_s i.t i.block i.rater i.model_num  pre_simse $covariates *_im if time == 2, vce(cluster id)
regress simse_s i.block simse1 i.rater i.model_num /*d921*/ if time == 2, vce(cluster id)


* estimating within cells defined by factors 
anova simse_s i.block##i.rater##i.model_num t
regress simse_s i.t i.block##i.rater##i.model_num pre_simse $covariates *_im if time == 2, vce(cluster id)

//----------------------------------------------------------------------------//
* QCI 
//----------------------------------------------------------------------------//
frame change fr1
regress qci_s i.t i.block , vce(cluster id)
regress qci_s i.t i.block i.rater i.segment, vce(cluster id)
regress qci_s i.t i.block i.rater i.segment pre_simse *_im , vce(cluster id)
regress qci_s i.t i.block i.rater i.segment pre_simse $covariates *_im , vce(cluster id)
regress qci_s i.t i.block i.segment pre_simse $covariates *_im , vce(cluster id)

regress qci_s i.block i.segment pre_simse i.rater /*$covariates *_im*/ , vce(cluster id)
regress qci_s i.block i.segment simse1 i.rater /*$covariates *_im*/ , vce(cluster id)



anova qci_s i.block##i.rater##i.segment t
regress qci_s i.t i.block##i.rater##i.segment pre_simse $covariates *_im , vce(cluster id)

//----------------------------------------------------------------------------//
* MQI
//----------------------------------------------------------------------------//
frame change fr2
regress mqi_s i.t i.block i.rater i.segment , vce(cluster id)
regress mqi_s i.t i.block i.rater i.segment pre_simse *_im , vce(cluster id)
regress mqi_s i.t i.block i.rater i.segment pre_simse $covariates *_im , vce(cluster id)

mixed mqi_s i.t i.block i.rater i.segment pre_simse $covariates *_im , vce(cluster id)


mixed mqi_s i.t i.block i.rater i.segment pre_simse $covariates *_im , vce(cluster id)


regress mqi_s i.block i.segment pre_simse i.rater /*$covariates *_im*/ , vce(cluster id)

regress mqi_s i.block i.segment simse1 i.rater $covariates *_im , vce(cluster id)

regress mqi_s i.block i.segment simse1  pre_simse i.rater , vce(cluster id)

egen simse1_s = std(simse1)
regress mqi_s i.block i.segment simse1_s i.rater , vce(cluster id)

regress mqi_s simse1_s //, vce(cluster id)

preserve
collapse mqi_s simse1_s, by(id block)
regress mqi_s i.block simse1_s 
restore

sum simse
gen simsek = .94*simse + (1-.94)*r(mean)
regress mqi_s i.block i.segment simsek i.rater /*d921*/ , vce(cluster id)
regress mqi_s i.block i.segment simse i.rater /*d921*/ , vce(cluster id)



* estimating within cells defined by factors 
anova mqi_s i.block##i.rater##i.segment t 
regress mqi_s i.t i.block i.rater##i.segment##i.block#i.segment pre_simse $covariates  *_im , vce(cluster id)

egen group2  = group(rater segment)
tab group2 t
egen group = b


// QCI rater downward bias explanation 
frame change fr1

sort id segment rater 
order id segment rater t  qci_s
list id segment rater  t qci_s if id == 1 |id == 15


tab t rater
tabstat qci_s ,by(rater)

regress qci_s i.t i.block i.rater i.segment pre_simse $covariates *_im , vce(cluster id)
regress qci_s i.t i.block i.segment pre_simse $covariates *_im , vce(cluster id)












