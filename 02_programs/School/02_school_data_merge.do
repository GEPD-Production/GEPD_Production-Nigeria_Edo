clear all

*set the paths
gl data_dir ${clone}/01_GEPD_raw_data/
gl processed_dir ${clone}/03_GEPD_processed_data/


*save some useful locals
local preamble_info_individual school_code 
local preamble_info_school school_code 
local not school_code
local not1 interview__id

***************
***************
* Append files from various questionnaires
***************
***************

gl dir_v7 "${data_dir}\\School\\School Survey - Version 7 - without 10 Revisited Schools\\"
gl dir_v8 "${data_dir}\\School\\School Survey - Version 8 - without 10 Revisited Schools\\"

* get the list of files
local files_v7: dir "${dir_v7}" files "*.dta"

di `files_v7'
* loop through the files and append into a single file saved in dir_saved
gl dir_saved "${data_dir}\\School\\"

foreach file of local files_v7 {
	di "`file'"
	use "${dir_v7}`file'", clear
	append using "${dir_v8}`file'", force
	save "${dir_saved}`file'", replace
}

***************
***************
* School File
***************
***************

********
*read in the raw school file
********
frame create school
frame change school

use "${data_dir}\\School\\epdash.dta" 

********
*read in the school weights
********

frame create weights
frame change weights
import delimited "${data_dir}\\Sampling\\${weights_file_name}"

* rename school code
rename ${school_code_name} school_code 


keep school_code ${strata} ${other_info} strata_prob ipw urban_rural

gen strata=" "
foreach var in $strata {
	replace strata=strata + `var' + " - "
}

destring school_code, replace force
destring ipw, replace force
duplicates drop school_code, force

******
* Merge the weights
*******
frame change school

gen school_code=school_code_preload
destring school_code, force replace

drop if missing(school_code)

frlink m:1 school_code, frame(weights)
frget ${strata} ${other_info} urban_rural strata_prob ipw strata, from(weights)


*create weight variable that is standardized
gen school_weight=1/strata_prob // school level weight

*fourth grade student level weight
egen g4_stud_count = mean(m4scq4_inpt), by(school_code)


*create collapsed school file as a temp
frame copy school school_collapse_temp
frame change school_collapse_temp

order school_code
sort school_code

* collapse to school level
ds, has(type numeric)
local numvars "`r(varlist)'"
local numvars : list numvars - not

ds, has(type string)
local stringvars "`r(varlist)'"
local stringvars : list stringvars- not

 foreach v of var * {
	local l`v' : variable label `v'
       if `"`l`v''"' == "" {
 	local l`v' "`v'"
 	}
 }

collapse (max) `numvars' (firstnm) `stringvars', by(school_code)

 foreach v of var * {
	label var `v' `"`l`v''"'
 }

***************
***************
* Teacher File
***************
***************

****
* Read in Teacher Pedagogy scores from Excel
****
frame create teacher_pedg
frame change teacher_pedg

import excel "${data_dir}\\School\\Teach_scores_formatted.xlsx", sheet("Scoring Sheet") firstrow clear


gl low_medium_high s_0_1_2 s_0_2_2 s_0_3_2 s_a2_1 s_a2_2 s_a2_3 s_b3_1 s_b3_2 s_b3_3 s_b3_4 s_b5_1 s_b5_2 s_b6_1 s_b6_2 s_b6_3 s_c7_1 s_c7_2 s_c7_3  s_c8_1 s_c8_2 s_c8_3 s_c9_1 s_c9_2 s_c9_3

gl low_medium_high_na s_a1_1 s_a1_2 s_a1_3 s_a1_4a s_a1_4b s_b4_2 s_b4_3

gl yes_no s_0_1_1 s_0_2_1 s_0_3_1

gl overall s_a1 s_a2 s_b3 s_b4 s_b5 s_b6 s_c7 s_c8 s_c9


** Verfying that the teach vars have observations
**# Bookmark #1

foreach var in $overall $yes_no $low_medium_high $low_medium_high_na {
sum `var'
}

** encoding the string responses into numeric -- Read below to understnad how the loop works 
	/*
	a- we define value lables to be used for encoding
	b- the loop first execute a test to confirm the varibales are coded as string:
		- if it is string (rc==0), the loop will execute and encode them into factor/numerical and labled vars
		- if it is numeric(rc==7), the loop will stop executing with an error -- already encoded into factor (do nothing more).

	*/

foreach var of global overall {
capture confirm string varibale `v'
if (_rc == 7) continue 
	*these aggregate vars must be numeric -- if they are, the loop would do nothing

	destring `var', replace
		tab `var'
}


** create sub-indicators from TEACH and calculating Teach score before collapsing

*  a- first, create an average score var of the sub-componenets  

egen classroom_culture = rowmean(s_a1 s_a2)
	
egen instruction = rowmean(s_b3 s_b4 s_b5 s_b6)

egen socio_emotional_skills = rowmean(s_c7 s_c8 s_c9)
			
egen teach_score=rowmean(classroom_culture instruction socio_emotional_skills)

*reshape subquestions from long to wide


frame copy teacher_pedg teacher_pedg_sub
frame change teacher_pedg_sub

keep Schoolcode $yes_no $low_medium_high $low_medium_high_na

bysort Schoolcode: gen clip=_n
tostring clip, replace
replace clip = "_" + clip

reshape wide $yes_no $low_medium_high $low_medium_high_na, i(Schoolcode) j(clip) string

*rename to be consistent with other files
foreach var in $yes_no $low_medium_high $low_medium_high_na {
	local cur_name1 = "`var'" + "_1"
	local cur_name2 = "`var'" + "_2"

	
	local new_name1=  subinstr("`var'", "s_","s1_",1)
	local new_name2=  subinstr("`var'", "s_","s2_",1)
	

	rename `cur_name1' `new_name1'
	rename `cur_name2' `new_name2'

}

frame change teacher_pedg

keep Schoolcode $overall classroom_culture instruction socio_emotional_skills teach_score
*collapse to teacher level
collapse $overall classroom_culture instruction socio_emotional_skills teach_score , by(Schoolcode)

frlink 1:1 Schoolcode, frame(teacher_pedg_sub)
frget *, from(teacher_pedg_sub)

rename Schoolcode school_code

drop teacher_pedg_sub



frame create teachers
frame change teachers
********
* Addtional Cleaning may be required here to link the various modules
* We are assuming the teacher level modules (Teacher roster, Questionnaire, Pedagogy, and Content Knowledge have already been linked here)
* See Merge_Teacher_Modules code folder for help in this task if needed
********
use "${data_dir}\\School\\Edo_teacher_level.dta" 

recode m2saq3 1=2 0=1


foreach var in $other_info {
	cap drop `var'
}
cap drop $strata

frlink m:1 interview__key, frame(school)
frget school_code ${strata} $other_info urban_rural strata school_weight numEligible numEligible4th, from(school)

*bring in the teacher pedagogy scores
frame copy teachers teacher_pedg_list
frame change teacher_pedg_list

keep if !missing(m4saq1)
keep school_code TEACHERS__id m4saq1 m4saq1_number

*join with teacher_pedg
frlink 1:1 school_code, frame(teacher_pedg) 
frget *, from(teacher_pedg)



frame change teachers
drop s1_0_1_1 - s2_c9_3

frlink 1:1 school_code TEACHERS__id , frame(teacher_pedg_list) 
frget s1_0_1_1 - s2_c9_3 classroom_culture instruction socio_emotional_skills teach_score , from(teacher_pedg_list)


*get number of 4th grade teachers for weights
egen g4_teacher_count=sum(m3saq2__4), by(school_code)
egen g1_teacher_count=sum(m3saq2__1), by(school_code)

order school_code
sort school_code

*weights
*teacher absense weights
*get number of teachers checked for absense
egen teacher_abs_count=count(m2sbq6_efft), by(school_code)
gen teacher_abs_weight=numEligible/teacher_abs_count
replace teacher_abs_weight=1 if missing(teacher_abs_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

*teacher questionnaire weights
*get number of teachers checked for absense
egen teacher_quest_count=count(m3s0q1), by(school_code)
gen teacher_questionnaire_weight=numEligible4th/teacher_quest_count
replace teacher_questionnaire_weight=1 if missing(teacher_questionnaire_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

*teacher content knowledge weights
*get number of teachers checked for absense
egen teacher_content_count=count(m3s0q1), by(school_code)
gen teacher_content_weight=numEligible4th/teacher_content_count
replace teacher_content_weight=1 if missing(teacher_content_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

*teacher pedagogy weights
gen teacher_pedagogy_weight=numEligible4th/1 // one teacher selected
replace teacher_pedagogy_weight=1 if missing(teacher_pedagogy_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

drop if missing(school_weight)

save "${processed_dir}\\School\\Confidential\\Merged\\teachers.dta" , replace



********
* Add some useful info back onto school frame for weighting
********

*collapse to school level
frame copy teachers teachers_school
frame change teachers_school

collapse g1_teacher_count g4_teacher_count, by(school_code)

frame change school
frlink m:1 school_code, frame(teachers_school)

frget g1_teacher_count g4_teacher_count, from(teachers_school)



***************
***************
* 1st Grade File
***************
***************

frame create first_grade
frame change first_grade
use "${data_dir}\\School\\ecd_assessment.dta" 



frlink m:1 interview__key interview__id, frame(school)
frget school_code ${strata} $other_info urban_rural strata school_weight m6_class_count g1_teacher_count, from(school)


order school_code
sort school_code

*weights
gen g1_class_weight=g1_teacher_count/1, // weight is the number of 1st grade streams divided by number selected (1)
replace g1_class_weight=1 if g1_class_weight<1 //fix issues where no g1 teachers listed. Can happen in very small schools

bysort school_code: gen g1_assess_count=_N
gen g1_student_weight_temp=m6_class_count/g1_assess_count // 3 students selected from the class

gen g1_stud_weight=g1_class_weight*g1_student_weight_temp

save "${processed_dir}\\School\\Confidential\\Merged\\first_grade_assessment.dta" , replace

***************
***************
* 4th Grade File
***************
***************

frame create fourth_grade
frame change fourth_grade
use "${data_dir}\\School\\fourth_grade_assessment.dta" 


frlink m:1 interview__key interview__id, frame(school)
frget school_code ${strata}  $other_info urban_rural strata school_weight m4scq4_inpt g4_teacher_count g4_stud_count, from(school)

order school_code
sort school_code

*weights
gen g4_class_weight=g4_teacher_count/1, // weight is the number of 4tg grade streams divided by number selected (1)
replace g4_class_weight=1 if g4_class_weight<1 //fix issues where no g4 teachers listed. Can happen in very small schools

bysort school_code: gen g4_assess_count=_N

gen g4_student_weight_temp=g4_stud_count/g4_assess_count // max of 25 students selected from the class

gen g4_stud_weight=g4_class_weight*g4_student_weight_temp


save "${processed_dir}\\School\\Confidential\\Merged\\fourth_grade_assessment.dta" , replace

***************
***************
* Collapse school data file to be unique at school_code level
***************
***************

frame change school

*******
* collapse to school level
*******

*drop some unneeded info
drop enumerators*

order school_code
sort school_code

* collapse to school level
ds, has(type numeric)
local numvars "`r(varlist)'"
local numvars : list numvars - not

ds, has(type string)
local stringvars "`r(varlist)'"
local stringvars : list stringvars- not

collapse (mean) `numvars' (firstnm) `stringvars', by(school_code)


save "${processed_dir}\\School\\Confidential\\Merged\\school.dta" , replace