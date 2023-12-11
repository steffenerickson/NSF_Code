
clear all 
cd "/Users/steffenerickson/Desktop/fall_2023/nsf/knowledge_measures"

import excel "Knowledge Measures Scoring Survey_November 24, 2023_08.45.xlsx", sheet("Sheet0") firstrow case(lower) clear

keep q31-q42_3


split q9,parse(-)

destring q31, gen(rater) force 
rename q9 file_name
rename (q42_1 q42_2 q42_3) (k1 k2 k3)
encode q93 ,gen(participantid)
encode q47, gen(dc)

drop in 1 
drop if file_name == "test"

encode  q91 , gen(site)           
encode  q92 , gen(semester)      


label define si 1 "UVA" 2 "UD" 3 "JMU"
label define sem 0 "fall" 1 "spring"

label values site si
label values semester sem


encode  q94 , gen(time) 
tab time q94
recode time (4 = 3) (3 = 4)
label define ti 1 "Baseline" 2 "End of Module" 3  "Final" 4"Control Section 3" 
label values time ti

egen id = group(participantid site semester)

drop q*


forvalues i = 1/3 {
	encode k`i' , gen(k`i'2)
	drop k`i'
	rename k`i'2 k`i'
}

label variable k1 "Knowledge of Students with Mathematics Disabilities and Difficulties"
label variable k2 "Knowledge of Word Problems"
label variable k3 "Knowledge of Metacognitive Modeling"


xtreg k1 i.time i.rater , i(id)
xtreg k2 i.time i.rater , i(id)
xtreg k3 i.time i.rater , i(id)



collapse k1 k2 k3 , by(id participantid site semester)









table time, statistic(mean k1) statistic(mean k2) statistic(mean k3)
anova k1 time id rater id#time id#rater

egen tag = tag(id) if time == 4
gsort id - tag
by id: replace tag = tag[1]
drop if tag == 1

areg k1 i.time i.rater if time != 4, absorb(id) 
areg k2 i.time i.rater if time != 4, absorb(id)
areg k3 i.time i.rater if time != 4, absorb(id)


xtreg k1 i.time , i(id) 
xtreg k2 i.time , i(id)
xtreg k3 i.time , i(id)






tab id if time == 4 , matcell(id_list)


