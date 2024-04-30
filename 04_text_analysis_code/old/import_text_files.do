
//cd "/Users/steffenerickson/Desktop/spring2024/qpp/txt_files/uva/performancetasks/spring"

//cd "/Users/steffenerickson/Desktop/spring2024/qpp/txt_files/uva/placement/spring"

// ---------------------

//Driver 


mata:
void driver(string scalar filespec, string scalar output_filename)
{
	string colvector filenames
	real scalar i
	real scalar output_fh
	filenames = sort(dir(".", "files", filespec),1)
	output_fh = fopen(output_filename, "w")
	for (i=1; i<=length(filenames); i++) {
		process_file(filenames[i], output_fh)
	}
	fclose(output_fh)
}




// process file function 


mata 





mata 
	//filename = "01_S23_001_002_P1.txt"
	filename = "01_S23_001_002_Placement.txt"
	store = ""
	fh = fopen(filename , "r")
	while ((line=fget(fh))!=J(0,0,"")) {
			store = store + " \n " + line 
		}
	fclose(fh)
	result     = ustrsplit(store, "\\n")
	resulttrimmed = select(result, ustrlen(ustrtrim(result)):!=0)
end 


mata 
regexvec = "[0-9][0-9]_", "[0-9][0-9]:[0-9][0-9][AaPp][Mm]" , "SUMMARY KEYWORDS" , "\s[0][0]:[0][0-9]\s"
temp = J(length(regexvec),length(resulttrim),.)
for(i=1;i<=length(regexvec);i++){
	temp[i,1..length(resulttrim)] = regexm(resulttrim, regexvec[i])
}
check = colsum(temp)
indices = range(1,cols(check),1)
cutmat = select((check' :* indices), (check' :* indices):!=0)
end 

mata 
S = J(1,length(cutmat),"")
for(i=1;i<=rows(cutmat);i++){
	if (i < rows(cutmat)) j = i + 1 
	if (i == rows(cutmat)) S[1,i] = invtokens(resulttrim[1,cutmat[i]..length(resulttrim)])
	if (cutmat[i] == cutmat[j] - 1) S[1,i] = resulttrim[1,i]
	if (cutmat[i]  < cutmat[j] - 1) S[1,i] = invtokens(resulttrim[1,cutmat[i]..cutmat[j]-1])
}
end 

mata: S

//----------------------------------------------------------------------------//
// Copy 
//----------------------------------------------------------------------------//

cscript
set matastrict on
mata:
void driver(string scalar filespec, string scalar output_filename)
{
	string colvector filenames
	real scalar i
	real scalar output_fh
	filenames = sort(dir(".", "files", filespec),1)
	output_fh = fopen(output_filename, "w")
	for (i=1; i<=length(filenames); i++) {
		process_file(filenames[i], output_fh)
	}
	fclose(output_fh)
}

struct transcripts {
	real   scalar has_data /* Boolean */
	string scalar filename
	string scalar metadata
	string scalar keywords
	string scalar text
}

struct myproblem {
	struct transcripts scalar t
	string scalar line
	real scalar output_fh
}

void initialize_record(struct transcripts scalar t)
{
	t.filename = ""
	reinitialize_record(t)
}

void reinitialize_record(struct transcripts scalar t)
{
	t.has_data = 0
	t.filename = ""
	t.metadata = ""
	t.keywords = ""
	t.text     = ""
}

void output_record(struct myproblem scalar pr)
{
	if (pr.t.has_data == 0) return
	fput(pr.output_fh, sprintf(""%s" "%s" "%s" "%s"",
	pr.t.filename,
	pr.t.metadata, 
	pr.t.keywords,
	pr.t.text))
}

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

void process_line(struct myproblem scalar pr)
{
	if (process_line_filename(pr)) return
	if (process_line_metadata(pr)) return
	if (process_line_keywords(pr)) return
	if (process_line_text(pr)) return
	/* otherwise, we ignore the line */
}

mata : sprintf(`""%s" "%s" "%s" "%s""', "apple", "pear","banana", "grape")

mata : strvec = "love", "to", "eat", "apples"

mata : sprintf(`""%s" "%s" "%s" "%s""', strvec[1], strvec[2], strvec[3], strvec[4])


forvalues i = 1/4 {
	local temp `",strvec[`i']"'
	local store : list store | temp
}
di "`store'"

/*

mata 
	//filename = "01_S23_001_002_P1.txt"
	filename = "01_S23_001_002_Placement.txt"
	store = ""
	fh = fopen(filename , "r")
	while ((line=fget(fh))!=J(0,0,"")) {
			store = store + " \n " + line 
		}
	fclose(fh)
	result     = ustrsplit(store, "\\n")
	resulttrim = select(result, ustrlen(ustrtrim(result)):!=0)
end 



mata: c1 = regexm(resulttrim, "[0-9][0-9]_")
mata: c2 = regexm(resulttrim, "[0-9][0-9]:[0-9][0-9][AaPp][Mm]")
mata: c3 = regexm(resulttrim, "SUMMARY KEYWORDS")
mata: c4 = regexm(resulttrim, "\s[0-9][0-9]:[0-9][0-9]\s?$")
mata: check = c1 \ c2 \ c3 \ c4
mata: check5 = colsum(check)
mata: check5

mata: (check5:!= 0)









mata: S

mata : a[(cutmat[1])..(cutmat[6] - 1),1]

printf("%s\n","cond 3") //
mata : a[1,(cutmat[i])..(indices[j] - 1)]

 mata: invtokens(resulttrim[1,cutmat[3]..length(check5)])

 

mata 
for(i=1;i<=rows(indices);i++){
	j = i + 1
	col = 1
	while indices[i] < indices[j] {
		
	}
	col++
}

mata: indices1[2] < indices1[3] 

end 





// Loop based for now 

store = J

mata
for (i=1;i<=rows(check5);i++) {
	if (check5[i] != 0) printf(a[i])
}
end



mata: substr(a,.,1)


// Rework this code --------------------
mata
// Define a function to split the matrix
void split_matrix(matrix A, pointer matrix splits[])
{
    int rows = rows(A)
    matrix current_split
    int count = 1
    
    // Initialize the first split as an empty matrix
    splits[count] = J(0, cols(A), .)
    
    for (i = 1; i <= rows; i++) {
        // Check if the row contains a 1 and start a new split if needed
        if (A[i,1] == 1 && rows(splits[count]) > 0) {
            count++
            splits[count] = J(0, cols(A), .)
        }
        
        // Append the current row to the current split
        splits[count] = splits[count] \ A[i,..]
    }
}

// Example usage:
matrix A = (0,0,0 \ 1,0,0 \ 0,0,0 \ 0,0,0 \ 1,0,0 \ 0,0,0)
pointer matrix splits[]
split_matrix(A, &splits)

// Display the results
for (i = 1; i <= length(splits); i++) {
    printf("Split %d:\n", i)
    print(splits[i])
}
end 
*-----------------------


mata: check1 = regexm(a, "[0-9][0-9]:")
mata: check1 = regexm(a, "[0-9][0-9]:")

mata: strpos(string, "[0-9][0-9]")







mata: subresult = resulttrim[20...,1]

mata: invtokens(result[1,20..47])



mata 
filename = "01_F22_001_002_P1.txt"
store = ""
fh = fopen(filename , "r")
while ((line=fget(fh))!=J(0,0,"")) {
		if (line == "") del = " \n "
		else del = " "
		store = store + del + line 
	}
fclose(fh)
//store 
parts = ustrsplit(store, "\\n")
result = parts
select(result, ustrlen(ustrtrim(result)):!=0)
//parts
end 


mata 
myText = "This is the first line. \n This is the second line. \n This is the third line."
ustrsplit(myText, "\\n")
end 

[*%\n]

mata: ustrsplit("$12.31 €6.75", "[$€]") 




mata 
filename = "01_F22_001_001_P1.txt"
fh = fopen(filename , "r")
doc = fget(fh)
doc 
end 


mata 
filename = "01_F22_001_001_P1.txt"
fh = fopen(filename , "r")
while ((line=fget(fh))!=J(0,0,"")) {
        printf("%s\n",line) 
}
fclose(fh)
end 



cd "/Users/steffenerickson/Desktop/spring2024/qpp/txt_files/uva/performancetasks/fall"


mata 
struct myproblem {
	string scalar line
}
end 


mata 
struct output {
	string scalar line
}
end 

mata 
void process_line(struct myproblem scalar pr)
{
	if (process_text(pr)) return
	//if (process_line_metadata(pr)) return
	//if (process_line_keywords(pr)) return
	//if (process_line_text(pr)) return
	/* otherwise, we ignore the line */
}
end 

mata 

real scalar process_text(struct myproblem scalar pr)
{
	string scalar piece, store 
	
	piece = pr.line
	store = ""
	while ((line=fget(fh))!=J(0,0,"")) {
		store = store + "" + piece
	}
	
}

end 






if (line == "00:01") {
		while ((line=fget(fh))!=J(0,0,"")) {
				store = store + "" + line
}

mata 

// Create a string with line breaks
myText = "This is the first line.\nThis is the second line.\nThis is the third line."

// Print the string
printf("%s\n", myText)

end 




if (line == "") del = "\n"
else del = " "












mata 
filename = "01_F22_001_001_P1.txt"
store = ""
fh = fopen(filename , "r")
	while ((line=fget(fh))!=J(0,0,"")) {
			//printf("%s\n", line) 
			if (line == "00:01") {
				while ((line=fget(fh))!=J(0,0,"")) {
					if (line == "") printf("Happy")
					store = store + " \n " + line 
				}
			}
	}
fclose(fh)
//store 
printf("%s\n", store )
end 

if (line == "00:01") {
		while ((line=fget(fh))!=J(0,0,"")) {
				store = store + "" + line
}




*/


//
