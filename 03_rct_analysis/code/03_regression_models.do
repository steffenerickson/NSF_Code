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

global covariates pre_simse d162 d167 d126_1 d126_2 d126_3 d126_4 d126_5 d132 d142 d156_1 d156_2 d156_3 d156_4 d156_5 d921 d107 white male parentnotteach parentcollege 

* Models
// ---- Simse
frame change fr3 
* Performance Tasks 
regress simse_s i.t i.block i.task i.rater $covariates *_im if time == 1, vce(cluster id)

* Student Teaching Placement 
regress simse_s i.t i.block i.rater i.model_num $covariates *_im if time == 2, vce(cluster id)

// ---- QCI 
frame change fr1
regress qci_s i.t i.block i.rater i.segment $covariates *_im, vce(cluster id)

// ---- MQI
frame change fr2
regress mqi_s i.t i.block i.rater i.segment $covariates *_im, vce(cluster id)








