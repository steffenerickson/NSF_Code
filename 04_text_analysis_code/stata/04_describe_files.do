clear all 
cd "/Users/steffenerickson/Desktop/spring2024/qpp/text/output/00_final_tables"
local filelist : dir . files "*.csv"
foreach file of local filelist {
	qui mkf tempframe 
	frame tempframe {
		di "`file'"
		qui import delimited  `file'
		describe,  short  
	}
	qui frame drop tempframe 
}

//store all tables in frames 
clear all 
cd "/Users/steffenerickson/Desktop/spring2024/qpp/text/output/00_final_tables"
local filelist : dir . files "*.csv"
foreach file of local filelist {
	local name : subinstr local file ".csv" "" , all
	mkf `name'
	frame `name' : qui import delimited  `file'
}

// Library Content 
frame change LIB
local wordlist
foreach var of var * {
	local word  "``var'`,"
	local wordlist : list wordlist | word
}
di "`wordlist'"

// Average length of transcript 
mkf raw 
frame raw {
	use "/Users/steffenerickson/Desktop/spring2024/qpp/text/data/metamodeltranscripttextdata.dta"
	mata {
		x = st_sdata(.,"text")
		text_lengths = J(rows(x),1,.)
		for (i=1;i <=rows(x);i++) text_lengths[i] = strlen(x[i])
		mean(text_lengths)
	} 
}


// Corpus Content
frame dir 

// Vocab content 
frame change VOCAB
local wordlist
foreach var of var * {
	local word  "``var'`,"
	local wordlist : list wordlist | word
}
di "`wordlist'"

* Top 20 words 
gsort - dfidf 
local wordlist
forvalues i = 1/20 {
	local word = term_str[`i']
	local wordformatted  "``word'`,"
	local wordlist : list wordlist | wordformatted
	
}
di "`wordlist'"

// BOW 
frame change BOW

local wordlist
foreach var of var * {
	local word  "``var'`,"
	local wordlist : list wordlist | word
}
di "`wordlist'"

frame change DTM


frame dir 

//  TFIDF_L2
frame change TFIDF_L2 


// PCA 



// LDA

local rawlist1 problem number right stickers word line numbers
local rawlist2 problem word number numbers sense right answer 
local rawlist3 problem minutes right time hours times word
local rawlist4 problem numbers right pennies way money tiles 
local rawlist5 problem candy pieces answer right story equals 
forvalues i = 1/5 {
	quietly {
	local wordlist
	foreach var of local rawlist`i' {
		local word  "``var'`,"
		local wordlist : list wordlist | word
	}
	}
	di "`wordlist'"
}




eighths brown white older cups	





