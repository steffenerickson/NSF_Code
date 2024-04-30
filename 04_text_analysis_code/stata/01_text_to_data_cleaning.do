//----------------------------------------------------------------------------//
// Purpose: Routine to store text data from observation transcripts in Stata 
// Author : Steffen Erickson 
// Date   : April 11, 2024 
//----------------------------------------------------------------------------//


//----------------------------------------------------------------------------//
// Converts a directory of word documents to a directory of .txt files
//----------------------------------------------------------------------------//

* python script word_to_txt.py


//----------------------------------------------------------------------------//
// Converts transcripts into a free-format text file that can be read as tabular data 
//----------------------------------------------------------------------------//
clear all 
* Set up directories 
global root 	/Users/steffenerickson/Desktop/spring2024/qpp/text/
global code 	text_analysis_code/stata 
global data 	txt_files
global output 	data

* Text processing function 
include ${root}/${code}/import_text_files_mata_function.do

*Info to pass into text processing function 
global sites	uva ud jmu 
global obstype	performancetasks placement 
global semester	fall spring
mata: regexvec = "[0-9][0-9]_","[A-Z][a-z][a-z],\s[A-Z][a-z][a-z]" ,"SUMMARY KEYWORDS"
	 	 
* Run text processing function through directory 
forvalues i = 1/`:word count $sites'{
	forvalues j = 1/`:word count $obstype'{
		forvalues k = 1/`:word count $semester'{
			
			local site 		`:word `i' of ${sites}'
			local obstype   `:word `j' of ${obstype}'
			local semester  `:word `k' of ${semester}'
			
			if "`site'" == "jmu" & "`obstype'" == "placement" continue 
			cd ${root}/${data}/`site'/`obstype'/`semester'
			capture erase "${root}/${output}/`site'_`obstype'_`semester'_outputfile.txt"
			mata: driver("*.txt","${root}/${output}/`site'_`obstype'_`semester'_outputfile.txt" ,regexvec) // text processing function 
		}
	}
}

//----------------------------------------------------------------------------//
// Reads text data back into Stata
//----------------------------------------------------------------------------//
clear
cd ${root}/${output}
mata: filenames = sort(dir(".", "files", "*.txt"),1)
mata:  st_local("filelist",invtokens(filenames'))
forvalues  i = 1/`:word count `filelist'' {
	mkf f`i'
	frame f`i': infile strL filename strL title strL metadata strL text using `:word `i' of `filelist''
}

frame copy f1 full, replace 
forvalues  i = 1/`:word count `filelist'' {
	frame f`i' : tempfile data
	frame f`i' : save `data'
	frame full : append using `data'
}

//----------------------------------------------------------------------------//
// Clean the File 
//----------------------------------------------------------------------------//
frame change full
drop filename 
replace title = regexreplaceall(title,"\([0-9]\)","")
replace title = "02_F22_003_037_Placement" if title == "02_F22_003_037_Placement2" 
split title , parse(_)
replace title5 = "P6"  if title5 == "6"
replace title1 = "UVA" if title1 == "01"
replace title1 = "UD"  if title1 == "02"
replace title1 = "JMU" if title1 == "03"

rename (title title1 title2 title4 title5) (id site course person task)
gen personid = site + "_" + course + "_" + person
keep  id metadata text site course person personid task 
order id metadata site course person personid task text 
//----------------------------------------------------------------------------//
// Export File 
//----------------------------------------------------------------------------//

export delimited using "${root}/${output}/metamodeltranscripttextdata.csv", delimiter(tab) quote replace
save metamodeltranscripttextdata.dta , replace 






