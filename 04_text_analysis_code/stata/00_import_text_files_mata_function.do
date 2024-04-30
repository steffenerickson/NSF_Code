
//----------------------------------------------------------------------------//
// TEXT TO DATA V2
// Purpose: Routine to take individual text files and places them in one 
//			free format text file that can be read as tabular data 
// Author : Steffen Erickson 
// 			Adapted from The Stata Journal (2009) 9, Number 4, pp. 599–620, Mata Matters: File processing by William Gould
// Date   : April 11, 2024 
//----------------------------------------------------------------------------//

mata 
mata clear 
// Driver function - loops though directory 
void driver(string scalar filespec, string scalar output_filename, string rowvector wheretosplit)
{
	string colvector filenames
	real scalar i
	real scalar output_fh
	filenames = sort(dir(".", "files", filespec),1)
	output_fh = fopen(output_filename, "w")
	for (i=1; i<=length(filenames); i++) {
		process_file(filenames[i], output_fh, wheretosplit)
	}
	fclose(output_fh)
}

// Defines structures to hold variables
struct file_record {
	real scalar   		has_data /* Boolean */
	string scalar 		id 
	string rowvector 	textvec
	string rowvector 	textmat
	real matrix			cutmat
}
struct myproblem {
	struct file_record scalar 		fr
	string scalar 			  		line
	string rowvector		  		regexvec
	real scalar 			 		output_fh
}
// Creates a record and outputs proccessed text to the output file 
void initialize_record(struct file_record scalar fr)
{
	fr.id = ""
	reinitialize_record(fr)
}
void reinitialize_record(struct file_record scalar fr)
{
	//fr.has_data = 0
	fr.id = ""
	fr.textvec  = J(0,0,"") 
	fr.textmat = J(0,0,"") 
	fr.cutmat  = J(0,0,.) 
}
void output_record(struct myproblem scalar pr)
{
	//if (pr.fr.has_data == 0) return
	if (length(pr.fr.textvec) >= 3) {
		fput(pr.output_fh, sprintf(`""%s" "%s" "%s" "%s""', pr.fr.id,pr.fr.textvec[1],pr.fr.textvec[2],pr.fr.textvec[3]))
	}
}

// Controls text processing 
void process_file(string scalar filename, real scalar output_fh, string rowvector wheretosplit)
{
	struct myproblem scalar   pr
	
	initialize_record(pr.fr)
	
	pr.output_fh = output_fh
	pr.regexvec  = wheretosplit
	pr.fr.id     = filename
	
	text_to_vec(pr)
	output_record(pr)
}
// Functions to split and process text
void text_to_vec(struct myproblem scalar pr)
{
	 storetext(pr)
	 findcuts(pr)
	 vectorizecuts(pr)
}
void storetext(struct myproblem scalar pr) 
{
	real   scalar			fh
	string scalar			store 
	
	store = ""
	fh = fopen(pr.fr.id, "r")
		while ((pr.line=fget(fh))!=J(0,0,"")) {
				store = store + "\n" + pr.line 
			}
	fclose(fh)
	pr.fr.textmat = select(ustrsplit(store, "\\n"), ustrlen(ustrtrim(ustrsplit(store, "\\n"))):!=0)
}
void findcuts(struct myproblem scalar pr) 
{
	real matrix			temp, check, indices

	temp = J(length(pr.regexvec),length(pr.fr.textmat),.)
	for(i=1;i<=length(pr.regexvec);i++){
		temp[i,1..length(pr.fr.textmat)] = regexm(pr.fr.textmat, pr.regexvec[i])
	}
	check 	= colsum(temp)
	indices = range(1,cols(check),1)
	pr.fr.cutmat = select((check' :* indices), (check' :* indices):!=0)
}
void vectorizecuts(struct myproblem scalar pr) 
{
	pr.fr.textvec = J(1,length(pr.fr.cutmat),"")
	for(i=1;i<=rows(pr.fr.cutmat);i++){
		if (i < rows(pr.fr.cutmat)) j = i + 1 
		if (i == rows(pr.fr.cutmat)) {	// last condition - stores from the last line indexed by the cutmat to the end 
			pr.fr.textvec[1,i] = invtokens(pr.fr.textmat[1,pr.fr.cutmat[i]..length(pr.fr.textmat)])
		}			
		if (pr.fr.cutmat[i] == pr.fr.cutmat[j] - 1) { // stores a single line 
			pr.fr.textvec[1,i] = pr.fr.textmat[1,i]
		}
		if (pr.fr.cutmat[i]  < pr.fr.cutmat[j] - 1) { // stores from a line indexed by cutmat to the next line indexed by the cutmat 
			pr.fr.textvec[1,i] = invtokens(pr.fr.textmat[1,pr.fr.cutmat[i]..pr.fr.cutmat[j]-1])
		}
	}
}
end

*cd "/Users/steffenerickson/Desktop/spring2024/qpp/txt_files/ud/placement/fall"
*mata: regexvec = "[0-9][0-9]_", "[A-Z][a-z][a-z],\s[A-Z][a-z][a-z]" , "SUMMARY KEYWORDS"
*mata: driver("*.txt","/Users/steffenerickson/Desktop/spring2024/qpp/outputfile.txt",regexvec)
*clear 
*cd "/Users/steffenerickson/Desktop/spring2024/qpp"
*infile strL filename strL title strL metadata strL text using outputfile.raw


