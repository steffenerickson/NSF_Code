clear all
global root "/Users/steffenerickson/Desktop/spring2024/qpp/text"

capture prog drop import_folder_of_excel
prog import_folder_of_excel
	syntax , Folder(string) Stub(string)
	quietly {
	cd "`folder'"
	local filelist : dir . files "`stub'"
	local i=1 
	foreach file of local filelist {
	    local id = substr("`file'",1,17)
		mkf fr`i'
		frame fr`i' {
			import excel using "`file'", firstrow case(lower) clear
			gen id = "`id'"
			gen index = _n
			sum index if transcriptiondetails == "Transcription results:"
			local row = r(mean) + 1
			drop in 1/`row'
			drop index
		}
		local++i
	}
	frame dir fr*
	local remove default 
	local temp `r(frames)'
	local framelist : list temp  - remove 
	local n : list sizeof local(framelist)
	frame copy fr1 full , replace
	forvalues i = 2/`n' {
		frame fr`i' : tempfile data 
		frame fr`i' : save `data'
		frame full  : append using `data', force
	}
	frame drop fr*	
	}
end 

forvalues i = 1/6 {
	local folder "${root}/AI Transcript Work/Task `i'/Annotated Transcripts Task `i'"
	import_folder_of_excel, folder(`folder') stub(0*.xl*)
	frame rename full task`i'
}

frame copy task1 full, replace
forvalues i = 2/6 {
	frame task`i' : tempfile data 
	frame task`i' : save `data'
	frame full    : append using `data', force
}

frame change full
drop j overall accuracyclarity

rename (transcriptiondetails b) (time sent_str)

foreach var of varlist objective-ending {
	replace `var' = strlower(`var')
}

foreach var of varlist objective-ending {
	replace `var' = "0" if `var' == "" | `var' == "n/a"  | `var' == "e = 2"
}

destring objective-ending, replace 

rename id title 
replace title = regexreplaceall(title,"\([0-9]\)","")
replace title = "02_F22_003_037_Placement" if title == "02_F22_003_037_Placement2" 
split title , parse(_)
replace title5 = "P6"  if title5 == "6"
replace title1 = "UVA" if title1 == "01"
replace title1 = "UD"  if title1 == "02"
replace title1 = "JMU" if title1 == "03"

rename (title title1 title2 title4 title5) (id site course person task)
gen personid = site + "_" + course + "_" + person
keep  id site course person personid task objective unpacking selfinstruction selfregulation ending
order id site course person personid task objective unpacking selfinstruction selfregulation ending

save /Users/steffenerickson/Desktop/spring2024/qpp/text/data/sentence_labels.dta, replace 

