/*******************************************************************************
Purpose: Merging all teacher modules (roster, pedagogy, asssessment, and questionnaire)
for Tchad

Last modified on: 12/06/2024
By: Mohammed ElDesouky 
    
*******************************************************************************/
clear all

*set the paths
gl data_dir ${clone}/01_GEPD_raw_data


*Set working directory on your computer here
gl data "${data_dir}\\School\\"
gl temp "$data\4_temp_data\\"
gl code "${clone}\02_programs\School\Merge_Teacher_Modules\\" 


global date = c(current_date)
global username = c(username)


/*Our goal is to have a teacher level file that combines modules 1(roster/absence), 
3 (questionnaire), 4 (pedagogy), 5 (assessment).
The final data should be unique at the teacher_id - school_code/interview_key level.
*/ 

/* Step 1: Start with roster data */
frame create roster
frame change roster 
use "$data/1_cleaned_input_data/teacher_absence.dta", clear

* Dataset should be unique at teacher-id - school_code level
unique TEACHERS__id interview__key		//unique
replace m2saq2=lower(m2saq2)

replace m2saq2 = subinstr( m2saq2 , "mr.", "", .)
replace m2saq2 = subinstr( m2saq2 , "mr. ", "", .)
replace m2saq2 = subinstr( m2saq2 , "mrs.", "", .)
replace m2saq2 = subinstr( m2saq2 , "mrs. ", "", .)
replace m2saq2 = subinstr( m2saq2 , "ms.", "", .)
replace m2saq2 = subinstr( m2saq2 , "mrs ", "", .)
replace m2saq2 = subinstr( m2saq2 , "mr ", "", .)
replace m2saq2 = subinstr( m2saq2 , "ms", "", .)


gen teacher_name = m2saq2
split teacher_name

* There are 2572 teachers in the roster.

/* Step 4: Merge in pedagogy data */

* prep data for merge
frame create pedagogy
frame change pedagogy
use "$data/epdash.dta", clear
keep interview__key interview__id school_code_preload school_emis_preload school_info_correct m4saq1-s2_c9_3


replace interview__key="999999" if missing(interview__key)

* Teacher name is m4saq1 and teacher id is m4saq1_number
count if missing(m4saq1_number) 				//0 missing obs
count if m4saq1_number==0 						//1 to be corrected -- correct ID was checked and sent by Brian 
	br if m4saq1_number==0 
		replace m4saq1 ="Joy Aminu Bello" if m4saq1_number==0
		replace m4saq1_number=2 if m4saq1_number==0

** There are xx duplicates where the same teacher id was assigned to two different teachers in the same school

replace m4saq1 = lower( m4saq1 )
replace m4saq1 = subinstr( m4saq1 , "mr.", "", .)
replace m4saq1 = subinstr( m4saq1 , "mr. ", "", .)
replace m4saq1 = subinstr( m4saq1 , "mrs.", "", .)
replace m4saq1 = subinstr( m4saq1 , "mrs. ", "", .)
replace m4saq1 = subinstr( m4saq1 , "ms.", "", .)
replace m4saq1 = subinstr( m4saq1 , "mrs ", "", .)
replace m4saq1 = subinstr( m4saq1 , "mr ", "", .)
replace m4saq1 = subinstr( m4saq1 , "ms", "", .)


gen teacher_name = m4saq1
gen  TEACHERS__id = m4saq1_number
replace teacher_name=lower(teacher_name)
split teacher_name
replace teacher_name1="" if teacher_name1=="na"

* flag for obs in questionnaire data
gen in_pedagogy=1

* Save a temp file
save "$temp/teacher_pedagogy_c.dta", replace

/*
* Same as in pedadogy, we want to keep the obs with missing ID(m3sb_tnumber) in the master data
count if missing(m3sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m3sb_tnumber=9999 if missing(m3sb_tnumber)

*/

frame change roster
joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_pedagogy_c.dta", unmatched(both)

tab _merge       // 182/200 merged -- 18 did not merge (will try to re-merge them using teacher ID only). 

* we save data with only unmacthed and prep it
frame copy roster roster_un
frame change roster_un
keep if _merge==2

drop interview__id - questionnaireteachcode2

gen  TEACHERS__id = m4saq1_number

*correcting some ID mistakes by comparing the id number to this person to id number of same person in roster, and replace with correct ID

replace TEACHERS__id =3 if interview__key=="02-80-91-01" & m4saq1_number==12
replace TEACHERS__id =2 if interview__key=="11-47-65-17" & m4saq1_number==4
replace TEACHERS__id =3 if interview__key=="45-36-10-93" & m4saq1_number==2
replace TEACHERS__id =7 if interview__key=="47-61-21-41" & m4saq1_number==9
replace TEACHERS__id =4 if interview__key=="47-95-51-05" & m4saq1_number==3
replace TEACHERS__id =4 if interview__key=="85-01-02-94" & m4saq1_number==3
replace TEACHERS__id =2 if interview__key=="26-55-01-78" & m4saq1_number==0


replace m4saq1_number = TEACHERS__id //coping the changes to the module's ID var 
drop _merge

save "$temp/pedagogy_un.dta", replace


frame change roster
* we rematch based on teacher_id only 
drop if _merge==2
rename _merge merge_1
merge 1:1 interview__key TEACHERS__id using "$temp/pedagogy_un.dta", generate(newv) update
	tab newv 			//18/18 were matched 
	
unique interview__key m4saq1_number if !missing(m4saq1_number)		//200 observation from pedagogy modules were added (200 matched)
	br m4saq1 m2saq2 if !missing(in_pedagogy )  //verifying the matches case by case
	* confirm that 200 from pedagogy were matched to the correct teachers in roster
	drop newv

* replace back missing m3sbt_number
replace m4saq1_number=. if m4saq1_number==9999


/* Step 5: Merge in m3(questionnaire) data */

* prep data for merge
frame create quest
frame change quest
use "$data/1_cleaned_input_data/teacher_questionnaire.dta", clear

replace interview__key="999999" if missing(interview__key)

* Teacher name is m3sb_troster and teacher id is m3sb_tnumber
count if missing(m3sb_tnumber) 				//0 missing obs

** There are xx duplicates where the same teacher id was assigned to two different teachers in the same school

replace m3sb_troster = lower( m3sb_troster )
replace m3sb_troster = subinstr( m3sb_troster , "mr.", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mr. ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mrs.", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mrs. ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "ms.", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mrs ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mr ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "ms", "", .)


gen teacher_name = m3sb_troster
gen  TEACHERS__id = m3sb_tnumber
replace teacher_name=lower(teacher_name)
split teacher_name

* flag for obs in questionnaire data
gen in_questionnaire=1

* Save a temp file
save "$temp/teacher_questionnaire_c.dta", replace

/*
* Same as in pedadogy, we want to keep the obs with missing ID(m3sb_tnumber) in the master data
count if missing(m3sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m3sb_tnumber=9999 if missing(m3sb_tnumber)

*/

/* Master is not unique at teacher id/m2saq2 and school code/interview__key
Using is unique at teacher name - teacher id - school code level
Do a m:1 merge on those vars
*/
frame change roster
joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_questionnaire_c.dta", unmatched(both)

tab _merge       // 823/901 merged -- 78 did not merge (will try to re-merge them using teacher ID only). 

* we save data with only unmacthed and prep it
frame copy roster roster_un, replace
frame change roster_un
keep if _merge==2


drop interview__id - in_pedagogy

gen  TEACHERS__id = m3sb_tnumber
gen teacher_name = m3sb_troster
split teacher_name

drop _merge

save "$temp/questionnaire_un.dta", replace

* we rematch based on teacher_name  (since most issues are caused by giving wrong teacher id as m3_id)
frame change roster
drop if _merge==2
rename _merge merge_2
merge 1:1 interview__key teacher_name1 teacher_name2 using "$temp/questionnaire_un.dta", generate(newv) update
												//28/78 matched correctly -- 50 didnt match 
replace m3sb_tnumber=TEACHERS__id if newv==5    //correcting teachers id for those 28

frame copy roster roster_un_2
frame change roster_un_2

frame change roster_un
frlink 1:1 interview__key teacher_name1 teacher_name2 , frame(roster_un_2)
frget newv, from(roster_un_2)
tab newv
drop if newv==5  //dropping matched obs from unmatched dataset
drop newv
drop teacher_name teacher_name1 teacher_name2 teacher_name3 roster_un_2
save "$temp/questionnaire_un.dta", replace 


* we rematch based on teacher_id only in case first and second names are swapped in the questionnaire data
frame change roster
drop if newv==2
rename newv merge_3
merge 1:1 interview__key TEACHERS__id using "$temp/questionnaire_un.dta", generate(newv) update  //50 matched
	unique interview__key m3sb_tnumber if !missing(m3sb_tnumber)		//901 unique 
	br m2saq2 m3sb_troster if newv==4  // verification confirms that the 50 matched correctly to each teacher in roster. 
	drop newv


* replace back missing m3sbt_number
replace m3sb_tnumber=. if m3sb_tnumber==9999



/* Step 6: Merge in m5(assessment) data */
* prep data for merge
frame create assess
frame change assess
use "$data/1_cleaned_input_data/teacher_assessment.dta", clear

replace interview__key="999999" if missing(interview__key)

rename m5sb_tnum m5sb_tnumber
* Teacher name is m5sb_troster and teacher id is m5sb_tnumber
count if missing(m5sb_tnumber) 				//0 missing obs

** There are 26 duplicates where the same teacher id was assigned to two different teachers in the same school
* [Not-run] duplicates tag m5sb_tnumber school_code, g(flag_m5_dup_teach_id)
* [Not-run] replace flag_m5_dup_teach_id=1 if flag_m5_dup_teach_id!=0
* [Not-run] la var flag_m5_dup_teach_id "Flag m5: same teacher id, different teacher name"

* For now, drop obs with missing id. We want to keep all duplicates in master data.
replace m5sb_tnumber=9999 if missing(m5sb_tnumber)

replace m5sb_troster = lower( m5sb_troster )
replace m5sb_troster = subinstr( m5sb_troster , "mr.", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mr. ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mrs.", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mrs. ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "ms.", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mrs ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mr ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "ms", "", .)


gen teacher_name =  m5sb_troster
gen  TEACHERS__id = m5sb_tnumber
replace teacher_name=lower(teacher_name)
split teacher_name


* flag for obs in assessment data
gen in_assessment=1

* Save a temp file
save "$temp/teacher_assessment_c.dta", replace


/*
* Same as in pedadogy, we want to keep the obs with missing ID(m5sb_tnumber) in the master data
count if missing(m5sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m5sb_tnumber=9999 if missing(m5sb_tnumber)

/* Master is not unique at teacher id and school code
Using is unique at teacher name - teacher id - school code level
Do a m:1 merge on those vars
*/
*/

frame change roster
cap drop _merge

joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_assessment_c.dta", unmatched(both)

tab _merge       // 820/901 merged -- 81 did not merge (will try to re-merge them using teacher name only, then teacher ID only). 


* we save data with only unmacthed and prep it
frame copy roster roster_un, replace
frame change roster_un
keep if _merge==2

drop interview__id - in_questionnaire

gen TEACHERS__id = m5sb_tnumber
gen teacher_name = m5sb_troster
split teacher_name

drop _merge merge_3

save "$temp/assessment_un.dta", replace


* we rematch based on teacher_name  (since most issues are caused by giving wrong teacher id as m5_id)
frame change roster
drop if _merge==2
rename _merge merge_4
merge 1:1 interview__key teacher_name1 teacher_name2 using "$temp/assessment_un.dta", generate(newv) update
												//28/81 matched correctly -- 53 didnt match 
replace m5sb_tnumber=TEACHERS__id if newv==5    //correcting teachers id for those 28

frame copy roster roster_un_2, replace
frame change roster_un_2

frame change roster_un
frlink 1:1 interview__key teacher_name1 teacher_name2 , frame(roster_un_2)
frget newv, from(roster_un_2)
tab newv
drop if newv==5  //dropping matched obs from unmatched dataset
drop newv
drop teacher_name teacher_name1 teacher_name2 teacher_name3 roster_un_2
save "$temp/assessment_un.dta", replace 


* we rematch based on teacher_id only in case first and second names are swapped in the questionnaire data
frame change roster
drop if newv==2
rename newv merge_5
merge 1:1 interview__key TEACHERS__id using "$temp/assessment_un.dta", generate(newv) update  //53 matched
	unique interview__key m3sb_tnumber if !missing(m3sb_tnumber)		//901 unique 
	br m2saq2 m5sb_troster if newv==4  // verification confirms that the 50 matched correctly to each teacher in roster. 
	drop newv


* duplicates cleaning (dropping perfect duplicates - based on interview key and teacher id)
 unique TEACHERS__id interview__key // no duplicates to address
 

* replace back missing m5sb_tnumber
replace m5sb_tnumber=. if m5sb_tnumber==9999


* drop temp/unecessary vars 
loc drop dup n_dup merge_1 merge_2 merge_3 merge_4 merge_5
foreach var of local drop{
      capture drop `var'
      di in r "return code for: `var': " _rc
}


* label variables 
do "$code/zz_label_all_variables.do"

order interview__key TEACHERS__id
sort interview__key TEACHERS__id, stable

* Save final data
save "$data/Edo_teacher_level.dta", replace

clear
	clear all

/*******************************************************************************
Purpose: Merging all teacher modules (roster, pedagogy, asssessment, and questionnaire)
for Tchad

Last modified on: 
By: 
    
*******************************************************************************/
clear all

*set the paths
gl data_dir ${clone}/01_GEPD_raw_data


*Set working directory on your computer here
gl data "${data_dir}\\School\\"
gl temp "$data\4_temp_data\\"
gl code "${clone}\02_programs\School\Merge_Teacher_Modules\\" 


global date = c(current_date)
global username = c(username)


/*Our goal is to have a teacher level file that combines modules 1(roster/absence), 
3 (questionnaire), 4 (pedagogy), 5 (assessment).
The final data should be unique at the teacher_id - school_code/interview_key level.
*/ 

/* Step 1: Start with roster data */
frame create roster
frame change roster 
use "$data/1_cleaned_input_data/teacher_absence.dta", clear

* Dataset should be unique at teacher-id - school_code level
unique TEACHERS__id interview__key		//unique
replace m2saq2=lower(m2saq2)

replace m2saq2 = subinstr( m2saq2 , "mr.", "", .)
replace m2saq2 = subinstr( m2saq2 , "mr. ", "", .)
replace m2saq2 = subinstr( m2saq2 , "mrs.", "", .)
replace m2saq2 = subinstr( m2saq2 , "mrs. ", "", .)
replace m2saq2 = subinstr( m2saq2 , "ms.", "", .)
replace m2saq2 = subinstr( m2saq2 , "mrs ", "", .)
replace m2saq2 = subinstr( m2saq2 , "mr ", "", .)
replace m2saq2 = subinstr( m2saq2 , "ms", "", .)


gen teacher_name = m2saq2
split teacher_name

* There are 2572 teachers in the roster.

/* Step 4: Merge in pedagogy data */

* prep data for merge
frame create pedagogy
frame change pedagogy
use "$data/epdash.dta", clear
keep interview__key interview__id school_code_preload school_emis_preload school_info_correct m4saq1-s2_c9_3


replace interview__key="999999" if missing(interview__key)

* Teacher name is m4saq1 and teacher id is m4saq1_number
count if missing(m4saq1_number) 				//0 missing obs

** There are xx duplicates where the same teacher id was assigned to two different teachers in the same school

replace m4saq1 = lower( m4saq1 )
replace m4saq1 = subinstr( m4saq1 , "mr.", "", .)
replace m4saq1 = subinstr( m4saq1 , "mr. ", "", .)
replace m4saq1 = subinstr( m4saq1 , "mrs.", "", .)
replace m4saq1 = subinstr( m4saq1 , "mrs. ", "", .)
replace m4saq1 = subinstr( m4saq1 , "ms.", "", .)
replace m4saq1 = subinstr( m4saq1 , "mrs ", "", .)
replace m4saq1 = subinstr( m4saq1 , "mr ", "", .)
replace m4saq1 = subinstr( m4saq1 , "ms", "", .)


gen teacher_name = m4saq1
gen  TEACHERS__id = m4saq1_number
replace teacher_name=lower(teacher_name)
split teacher_name
replace teacher_name1="" if teacher_name1=="na"

* flag for obs in questionnaire data
gen in_pedagogy=1

* Save a temp file
save "$temp/teacher_pedagogy_c.dta", replace

/*
* Same as in pedadogy, we want to keep the obs with missing ID(m3sb_tnumber) in the master data
count if missing(m3sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m3sb_tnumber=9999 if missing(m3sb_tnumber)

*/

frame change roster
joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_pedagogy_c.dta", unmatched(both)

tab _merge       // 181/200 merged -- 19 did not merge (will try to re-merge them using teacher ID only). 

* we save data with only unmacthed and prep it
frame copy roster roster_un
frame change roster_un
keep if _merge==2

drop interview__id - questionnaireteachcode2

gen  TEACHERS__id = m4saq1_number

*correcting some ID mistakes by comparing the id number to this person to id number of same person in roster, and replace with correct ID

replace TEACHERS__id =3 if interview__key=="02-80-91-01" & m4saq1_number==12
replace TEACHERS__id =2 if interview__key=="11-47-65-17" & m4saq1_number==4
replace TEACHERS__id =3 if interview__key=="45-36-10-93" & m4saq1_number==2
replace TEACHERS__id =7 if interview__key=="47-61-21-41" & m4saq1_number==9
replace TEACHERS__id =4 if interview__key=="47-95-51-05" & m4saq1_number==3
replace TEACHERS__id =4 if interview__key=="85-01-02-94" & m4saq1_number==3
replace TEACHERS__id =2 if interview__key=="26-55-01-78" & m4saq1_number==0


replace m4saq1_number = TEACHERS__id //coping the changes to the module's ID var 
drop _merge

save "$temp/pedagogy_un.dta", replace


frame change roster
* we rematch based on teacher_id only 
drop if _merge==2
rename _merge merge_1
merge 1:1 interview__key TEACHERS__id using "$temp/pedagogy_un.dta", generate(newv) update
	tab newv 			//18/19 were matched and 1 was added as additional rows but did not match becuase of wrong teacher_id and name "m4saq1"
unique interview__key m4saq1_number if !missing(m4saq1_number)		//200 observation from pedagogy modules were added (199 matched)
	br m4saq1 m2saq2 if !missing(in_pedagogy )  //verifying the matches case by case
	* confirm that 199 from pedagogy were matched to the correct teachers in roster
	drop newv

* replace back missing m3sbt_number
replace m4saq1_number=. if m4saq1_number==9999


/* Step 5: Merge in m3(questionnaire) data */

* prep data for merge
frame create quest
frame change quest
use "$data/1_cleaned_input_data/teacher_questionnaire.dta", clear

replace interview__key="999999" if missing(interview__key)

* Teacher name is m3sb_troster and teacher id is m3sb_tnumber
count if missing(m3sb_tnumber) 				//0 missing obs

** There are xx duplicates where the same teacher id was assigned to two different teachers in the same school

replace m3sb_troster = lower( m3sb_troster )
replace m3sb_troster = subinstr( m3sb_troster , "mr.", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mr. ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mrs.", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mrs. ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "ms.", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mrs ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "mr ", "", .)
replace m3sb_troster = subinstr( m3sb_troster , "ms", "", .)


gen teacher_name = m3sb_troster
gen  TEACHERS__id = m3sb_tnumber
replace teacher_name=lower(teacher_name)
split teacher_name

* flag for obs in questionnaire data
gen in_questionnaire=1

* Save a temp file
save "$temp/teacher_questionnaire_c.dta", replace

/*
* Same as in pedadogy, we want to keep the obs with missing ID(m3sb_tnumber) in the master data
count if missing(m3sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m3sb_tnumber=9999 if missing(m3sb_tnumber)

*/

/* Master is not unique at teacher id/m2saq2 and school code/interview__key
Using is unique at teacher name - teacher id - school code level
Do a m:1 merge on those vars
*/
frame change roster
joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_questionnaire_c.dta", unmatched(both)

tab _merge       // 823/901 merged -- 78 did not merge (will try to re-merge them using teacher ID only). 

* we save data with only unmacthed and prep it
frame copy roster roster_un, replace
frame change roster_un
keep if _merge==2


drop interview__id - in_pedagogy

gen  TEACHERS__id = m3sb_tnumber
gen teacher_name = m3sb_troster
split teacher_name

drop _merge

save "$temp/questionnaire_un.dta", replace

* we rematch based on teacher_name  (since most issues are caused by giving wrong teacher id as m3_id)
frame change roster
drop if _merge==2
rename _merge merge_2
merge 1:1 interview__key teacher_name1 teacher_name2 using "$temp/questionnaire_un.dta", generate(newv) update
												//28/78 matched correctly -- 50 didnt match 
replace m3sb_tnumber=TEACHERS__id if newv==5    //correcting teachers id for those 28

frame copy roster roster_un_2
frame change roster_un_2

frame change roster_un
frlink 1:1 interview__key teacher_name1 teacher_name2 , frame(roster_un_2)
frget newv, from(roster_un_2)
tab newv
drop if newv==5  //dropping matched obs from unmatched dataset
drop newv
drop teacher_name teacher_name1 teacher_name2 teacher_name3 roster_un_2
save "$temp/questionnaire_un.dta", replace 


* we rematch based on teacher_id only in case first and second names are swapped in the questionnaire data
frame change roster
drop if newv==2
rename newv merge_3
merge 1:1 interview__key TEACHERS__id using "$temp/questionnaire_un.dta", generate(newv) update  //50 matched
	unique interview__key m3sb_tnumber if !missing(m3sb_tnumber)		//901 unique 
	br m2saq2 m3sb_troster if newv==4  // verification confirms that the 50 matched correctly to each teacher in roster. 
	drop newv


* replace back missing m3sbt_number
replace m3sb_tnumber=. if m3sb_tnumber==9999



/* Step 6: Merge in m5(assessment) data */
* prep data for merge
frame create assess
frame change assess
use "$data/1_cleaned_input_data/teacher_assessment.dta", clear

replace interview__key="999999" if missing(interview__key)

rename m5sb_tnum m5sb_tnumber
* Teacher name is m5sb_troster and teacher id is m5sb_tnumber
count if missing(m5sb_tnumber) 				//0 missing obs

** There are 26 duplicates where the same teacher id was assigned to two different teachers in the same school
* [Not-run] duplicates tag m5sb_tnumber school_code, g(flag_m5_dup_teach_id)
* [Not-run] replace flag_m5_dup_teach_id=1 if flag_m5_dup_teach_id!=0
* [Not-run] la var flag_m5_dup_teach_id "Flag m5: same teacher id, different teacher name"

* For now, drop obs with missing id. We want to keep all duplicates in master data.
replace m5sb_tnumber=9999 if missing(m5sb_tnumber)

replace m5sb_troster = lower( m5sb_troster )
replace m5sb_troster = subinstr( m5sb_troster , "mr.", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mr. ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mrs.", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mrs. ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "ms.", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mrs ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "mr ", "", .)
replace m5sb_troster = subinstr( m5sb_troster , "ms", "", .)


gen teacher_name =  m5sb_troster
gen  TEACHERS__id = m5sb_tnumber
replace teacher_name=lower(teacher_name)
split teacher_name


* flag for obs in assessment data
gen in_assessment=1

* Save a temp file
save "$temp/teacher_assessment_c.dta", replace


/*
* Same as in pedadogy, we want to keep the obs with missing ID(m5sb_tnumber) in the master data
count if missing(m5sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m5sb_tnumber=9999 if missing(m5sb_tnumber)

/* Master is not unique at teacher id and school code
Using is unique at teacher name - teacher id - school code level
Do a m:1 merge on those vars
*/
*/

frame change roster
cap drop _merge

joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_assessment_c.dta", unmatched(both)

tab _merge       // 820/901 merged -- 81 did not merge (will try to re-merge them using teacher name only, then teacher ID only). 


* we save data with only unmacthed and prep it
frame copy roster roster_un, replace
frame change roster_un
keep if _merge==2

drop interview__id - in_questionnaire

gen TEACHERS__id = m5sb_tnumber
gen teacher_name = m5sb_troster
split teacher_name

drop _merge merge_3

save "$temp/assessment_un.dta", replace


* we rematch based on teacher_name  (since most issues are caused by giving wrong teacher id as m5_id)
frame change roster
drop if _merge==2
rename _merge merge_4
merge 1:1 interview__key teacher_name1 teacher_name2 using "$temp/assessment_un.dta", generate(newv) update
												//28/81 matched correctly -- 53 didnt match 
replace m5sb_tnumber=TEACHERS__id if newv==5    //correcting teachers id for those 28

frame copy roster roster_un_2, replace
frame change roster_un_2

frame change roster_un
frlink 1:1 interview__key teacher_name1 teacher_name2 , frame(roster_un_2)
frget newv, from(roster_un_2)
tab newv
drop if newv==5  //dropping matched obs from unmatched dataset
drop newv
drop teacher_name teacher_name1 teacher_name2 teacher_name3 roster_un_2
save "$temp/assessment_un.dta", replace 


* we rematch based on teacher_id only in case first and second names are swapped in the questionnaire data
frame change roster
drop if newv==2
rename newv merge_5
merge 1:1 interview__key TEACHERS__id using "$temp/assessment_un.dta", generate(newv) update  //53 matched
	unique interview__key m3sb_tnumber if !missing(m3sb_tnumber)		//901 unique 
	br m2saq2 m5sb_troster if newv==4  // verification confirms that the 50 matched correctly to each teacher in roster. 
	drop newv


* duplicates cleaning (dropping perfect duplicates - based on interview key and teacher id)
 unique TEACHERS__id interview__key // no duplicates to address
 

* replace back missing m5sb_tnumber
replace m5sb_tnumber=. if m5sb_tnumber==9999


* drop temp/unecessary vars 
loc drop dup n_dup merge_1 merge_2 merge_3 merge_4 merge_5
foreach var of local drop{
      capture drop `var'
      di in r "return code for: `var': " _rc
}


* label variables 
do "$code/zz_label_all_variables.do"

order interview__key TEACHERS__id
sort interview__key TEACHERS__id, stable

* Save final data
save "$data/Edo_teacher_level.dta", replace

clear
	clear all

