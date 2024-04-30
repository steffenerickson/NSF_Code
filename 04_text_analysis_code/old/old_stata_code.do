


//----------------------------------------------------------------------------//

// 

mata 
mata clear 

//--------------------------------------//
// Define Structures to Hold Variables
//-------------------------------------//
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


//------------------------------------------------------------------//
// Creates a record and outputs proccessed text to the output file 
//------------------------------------------------------------------//

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
	fput(pr.output_fh, sprintf(`""%s" "%s" "%s" "%s" "%s""',
	pr.fr.id,
	pr.fr.textvec[1], pr.fr.textvec[2], pr.fr.textvec[3], pr.fr.textvec[4]))
}

//---------------------------------------------------//
// Reads in Text and Processes
//---------------------------------------------------//

void process_file(string scalar filename, string scalar output_filename, string rowvector wheretosplit)
{
	struct myproblem scalar 		pr
	
	pr.output_fh = fopen(output_filename, "w")
	initialize_record(pr.fr)
	//pr.output_fh = output_fh
	pr.regexvec = wheretosplit
	pr.fr.id = filename
	text_to_vec(pr)
	output_record(pr)
	fclose(pr.output_fh)
}

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
				store = store + " \n " + pr.line 
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
		if (i == rows(pr.fr.cutmat)) {
			pr.fr.textvec[1,i] = invtokens(pr.fr.textmat[1,pr.fr.cutmat[i]..length(pr.fr.textmat)])
		}			
		if (pr.fr.cutmat[i] == pr.fr.cutmat[j] - 1) {
			pr.fr.textvec[1,i] = pr.fr.textmat[1,i]
		}
		if (pr.fr.cutmat[i]  < pr.fr.cutmat[j] - 1) {
			pr.fr.textvec[1,i] = invtokens(pr.fr.textmat[1,pr.fr.cutmat[i]..pr.fr.cutmat[j]-1])
		}
	}
}

end






cd "/Users/steffenerickson/Desktop/spring2024/qpp/practice"
mata: regexvec = "[0-9][0-9]_", "[0-9][0-9]:[0-9][0-9][AaPp][Mm]" , "SUMMARY KEYWORDS" , "\s[0][0]:[0][0-9]\s"
mata: process_file("01_S23_001_003_P3 copy.txt","outputfile.txt",regexvec)

clear 
infile strL filename strL title strL metadata strL keywords strL text using outputfile.txt





//----------------------------------------------------------------------------//








/*
mata 
void process_file(string scalar filename, real scalar output_fh)
{
	struct myproblem scalar pr
	real scalar input_fh
	initialize_record(pr.t)
	pr.output_fh = output_fh
	input_fh = fopen(filename, "r")
	while ( (pr.line=fget(input_fh)) != J(0,0,"") ) {
		process_line(pr)
	}
	output_record(pr)
	fclose(input_fh)
}
end 

mata 
mata clear
string rowvector text_to_vec(string scalar filename, string rowvector regexvec)
{
	string rowvector 		textmat,textvec
	real   colvector 		cutmat  
	
	textmat = storetext(filename)
	cutmat  = findcuts(textmat,regexvec)
	textvec = vectorizecuts(textmat,cutmat)
	
	return(textvec)
}

string rowvector storetext(string scalar filename) 
{
	real   scalar			fh
	string scalar			store 
	string matrix			result, resulttrimmed
	
	store = ""
	fh = fopen(filename , "r")
		while ((line=fget(fh))!=J(0,0,"")) {
				store = store + " \n " + line 
			}
	fclose(fh)
	result     	  = ustrsplit(store, "\\n")
	resulttrimmed = select(result, ustrlen(ustrtrim(result)):!=0)
	
	return(resulttrimmed)
}

real colvector findcuts(string rowvector textmat, string rowvector regexvec) 
{
	real matrix			temp, check, indices, cutmat

	temp = J(length(regexvec),length(textmat),.)
	for(i=1;i<=length(regexvec);i++){
		temp[i,1..length(textmat)] = regexm(textmat, regexvec[i])
	}
	check 	= colsum(temp)
	indices = range(1,cols(check),1)
	cutmat 	= select((check' :* indices), (check' :* indices):!=0)
	
	return(cutmat)
}

string rowvector vectorizecuts(string rowvector textmat, real matrix cutmat) 
{
	string rowvector			textvec 
	
	textvec = J(1,length(cutmat),"")
	for(i=1;i<=rows(cutmat);i++){
		if (i < rows(cutmat)) j = i + 1 
		if (i == rows(cutmat)) 			textvec[1,i] = invtokens(textmat[1,cutmat[i]..length(textmat)])
		if (cutmat[i] == cutmat[j] - 1) textvec[1,i] = textmat[1,i]
		if (cutmat[i]  < cutmat[j] - 1) textvec[1,i] = invtokens(textmat[1,cutmat[i]..cutmat[j]-1])
	}
	
	return(textvec)
}
end


cd "/Users/steffenerickson/Desktop/spring2024/qpp/txt_files/uva/placement/spring"
mata: regexvec = "[0-9][0-9]_", "[0-9][0-9]:[0-9][0-9][AaPp][Mm]" , "SUMMARY KEYWORDS" , "\s[0][0]:[0][0-9]\s"
mata: vec = text_to_vec("01_S23_001_002_Placement.txt",regexvec)
mata: vec[1..2]
