/*******************************************************************************
Purpose: Merging all teacher modules (roster, pedagogy, asssessment, and questionnaire)
for Tchad

Last modified on: 
By: 
    
*******************************************************************************/

clear all
set more off
macro drop _all
cap log close
program drop _all
matrix drop _all
*set trace on
*set tracedepth 1

* Install packages
ssc install matchit
ssc install freqindex

global date = c(current_date)
global username = c(username)

** File paths
* If you have one drive installed on your local machine, use this base
*global base "C:/Users/${username}/WBG/HEDGE Files - HEDGE Documents/GEPD-Confidential/General/LEGO_Teacher_Paper"

* set up all globals
global base "C:\Users\wb589124\Downloads\GEPD_Production-Nigeria_Edo"
global data "$base\01_GEPD_raw_data\School"
global temp "$data\4_temp_data"
global code "$base\02_programs\School\Merge_Teacher_Modules" 


/*Our goal is to have a teacher level file that combines modules 1(roster/absence), 
4 (questionnaire), 5 (assessment).
The final data should be unique at the teacher_id - school_code/interview_key level.
*/ 

/* Step 1: Start with roster data */
use "$data/1_cleaned_input_data/teacher_absence.dta", clear

* Dataset should be unique at teacher-id - school_code level
**# Bookmark #1
unique TEACHERS__id interview__key		//unique
* There are 6 obs with missing school code, no school level vars at all. Impute the 
* same school code for all 6 obs
*sum school_code
*replace school_code=999999 if missing(school_code)
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


/* [Not-run]
/* Step 2: Merge in modules key with roster */
/* Master is roster and is unique at teachers_id school code/interview_key level
   Using is the modules key data - not unique at teachers id and hashed_school_code
   Merge 1:m on teachers_id and hashed_school_code
*/

* Merge modules key and roster
merge 1:1 teachers_id hashed_school_code using "$data/`cty'/`cty'_teacher_modules_key.dta"
drop _merge
isid teachers_id school_code													//Only variable v1 is different. Safe to dedup

/* Step 4: Merge in pedagogy data */
preserve
use "$data/`cty'/`cty'_teacher_pedagogy.dta", clear

count if missing(m4saq1_number)
* replace missing with 9999, we will replace back to missing after the merge
replace m4saq1_number=9999 if missing(m4saq1_number)

* There are 6 obs with missing m4saq1_number
* Drop them here and we will add them as extra rows within the same school code
duplicates tag m4saq1_number m4saq1 hashed_school_code, g(test)
drop if test==1
*isid m4saq1_number school_code
count
di "There are `r(N)' teachers in the `cty' pedagogy data"
*468

* There are two variables containing teacher names: one for grade 2 and one for grade 4
* flag for obs in pedagogy data
gen in_pedagogy=1

* Save a temp file
save "$temp/`cty'/`cty'_teacher_pedagogy.dta", replace

restore

*Now save a copy with those dropped obs above
preserve
use "$data/`cty'/`cty'_teacher_pedagogy.dta", clear

count if missing(m4saq1_number)
* There are 6 obs with missing m4saq1_number
* Drop them here and we will add them as extra rows within the same school code
duplicates tag m4saq1_number m4saq1 hashed_school_code, g(test)
keep if test==1

* There are two variables containing teacher names: one for grade 2 and one for grade 4
* flag for obs in pedagogy data
gen in_pedagogy=1

* Save a temp file
save "$temp/`cty'/`cty'_teacher.dta", replace

restore

/* Merge pedagogy data
Master is not unique at teachers_id and school_code
Using is not unique at m4saq1_number and school_code
We want to merge pedagogy on the m4saq1_number and school_code from the modules key
*/

* Note that there are a lot of missing values for m4saq1_number in the master data
count if missing(m4saq1_number)
* replace missing with 9999, we will replace back to missing after the merge
replace m4saq1_number=9999 if missing(m4saq1_number)

merge m:1 m4saq1_number m4saq1 school_code using "$temp/`cty'/`cty'_teacher_pedagogy.dta"
*443 out of 462!

* There are some names from pedagogy that repeat themselves and look like duplicates
duplicates tag m4saq1, g(name_dup)
replace flag_dup_teacher_name=1 if name_dup!=0
* replace back missing m4saq1_number
replace m4saq1_number=. if m4saq1_number==9999

* there are 24 observations from pedagogy only: one is a missing teacher name and one seems to map to 
* teacher_id instead of m4saq1_number
preserve
keep if _merge==2
drop _merge teachers_id
gen m4_id=m4saq1_number
rename m4_id teachers_id
drop if missing(teachers_id)
isid teachers_id school_code
save "$temp/`cty'/`cty'_pedagogy_temp.dta", replace
restore

* merge on teachers_id and school code
drop if _merge==2 & !missing(teachers_id)
drop _merge
merge m:1 teachers_id school_code using "$temp/`cty'/`cty'_pedagogy_temp.dta", update
*Now we have 459 matches out of 462

* Now merge the ones that were dropped on teacher id - name school and grades
drop _merge
merge m:1 grade m4saq1_number m4saq1 school_code using "$temp/`cty'/`cty'_teacher.dta"
drop _merge
erase "$temp/`cty'/`cty'_teacher.dta"
*/



/* Step 5: Merge in m3(questionnaire) data */

* prep data for merge
preserve
use "$data/1_cleaned_input_data/teacher_questionnaire.dta", clear

replace interview__key="999999" if missing(interview__key)

* Teacher name is m3sb_troster and teacher id is m3sb_tnumber
count if missing(m3sb_tnumber) 				//0 missing obs

* [Not-run] duplicates tag m3sb_tnumber school_code, g(flag_m3_dup_teach_id)
* [Not-run] replace flag_m3_dup_teach_id=1 if flag_m3_dup_teach_id!=0
* [Not-run] la var flag_m3_dup_teach_id "Flag m3: same teacher id, different teacher name"
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
restore

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

joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_questionnaire_c.dta", unmatched(both)

tab _merge       // 823/901 merged -- 78 did not merge (will try to re-merge them using teacher ID only). 

* we save data with only unmacthed and prep it
preserve

keep if _merge==2

drop interview__id - questionnaireteachcode2

gen  TEACHERS__id = m3sb_tnumber


drop _merge

save "$temp/questionnaire_un.dta", replace

restore

* we rematch based on teacher_id only 
drop if _merge==2
rename _merge merge_1
merge 1:1 interview__key TEACHERS__id using "$temp/questionnaire_un.dta", generate(newv) update
	unique interview__key m3sb_tnumber if !missing(m3sb_tnumber)		//901 unique 
	drop newv

* [ran above instead] merge m:1 m3sb_troster interview__key using "$temp/teacher_questionnaire.dta"


* replace back missing m3sbt_number
replace m3sb_tnumber=. if m3sb_tnumber==9999

/* [Not-run]
/* there are 52 observations from questionnaire only. A quick check shows that the m3sb_tnumber is missing from modules key
while these teachers had m3sb_tnumber in questionnaire data. Save a temp data with observations with _merge==2
and merge on teachers_id - school_code instead
*/
preserve
keep if _merge==2
drop _merge teachers_id
gen m3_id=m3sb_tnumber
rename m3_id teachers_id
drop if missing(teachers_id)
isid teachers_id school_code
save "$temp/`cty'/`cty'_questionnaire_temp.dta", replace
restore

* merge on teachers_id and school code
drop if _merge==2 & !missing(m3sb_tnumber)
drop _merge
merge m:1 teachers_id school_code using "$temp/`cty'/`cty'_questionnaire_temp.dta", update

*/


/* Step 6: Merge in m5(assessment) data */
* prep data for merge
preserve
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
restore

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

cap drop _merge

joinby interview__key teacher_name1 TEACHERS__id using"$temp/teacher_assessment_c.dta", unmatched(both)

tab _merge       // 820/901 merged -- 81 did not merge (will try to re-merge them using teacher ID only). 


* we save data with only unmacthed and prep it
preserve

keep if _merge==2

drop interview__id - in_questionnaire

gen TEACHERS__id = m5sb_tnumber

drop _merge

save "$temp/assessment_un.dta", replace

restore

* we rematch based on teacher_id only 
drop if _merge==2
drop _merge
merge 1:1 interview__key TEACHERS__id using "$temp/assessment_un.dta", generate(newv) update  // obs from using were added which were not part of the roster

	unique interview__key m5sb_tnumber if !missing(m5sb_tnumber)		//901 unique 
	drop newv

* duplicates cleaning (dropping perfect duplicates - based on interview key and teacher id)
 unique TEACHERS__id interview__key // no duplicates to address
 
  /* not run

sort interview__key TEACHERS__id
quietly by interview__key TEACHERS__id: gen dup = cond(_N==1,0,_n)
	tab dup
quietly by interview__key TEACHERS__id: egen n_dup = max(dup)
	br if n_dup >0
	
	drop if dup==2

* duplicates cleaning (dropping perfect duplicates - based on interview key and teacher name)

drop dup n_dup
sort interview__key m2saq2
quietly by interview__key m2saq2: gen dup = cond(_N==1,0,_n)
	tab dup
quietly by interview__key m2saq2: egen n_dup = max(dup)
	br if n_dup >0
	
	drop if n_dup >0 // safe to drop all of them as they do not have observations

*merge m:1 m5sb_troster m5sb_tnumber school_code using "$temp/`cty'/`cty'_teacher_assessment.dta"

*/

* replace back missing m5sb_tnumber
replace m5sb_tnumber=. if m5sb_tnumber==9999

/* [not-run]
/* there are 50 observations from assessment only. A quick check shows that the 
m5sb_tnumber is missing from modules key while these teachers had m5sb_tnumber 
in assessment data.Save a temp data with observations 
with _merge==2 and merge on teachers_id - school_code instead
*/
preserve
keep if _merge==2
drop _merge teachers_id
gen m5_id=m5sb_tnumber
rename m5_id teachers_id
drop if m5sb_troster=="DJOUNOUMBI BASIL" & school_code==999999

isid teachers_id school_code

save "$temp/`cty'/`cty'_assessment_temp.dta", replace
restore

* merge on teachers_id and school code
drop if m5sb_troster=="DJOUNOUMBI BASIL" & school_code==999999 & _merge==2
drop if _merge==2
drop _merge
merge m:1 teachers_id school_code using "$temp/`cty'/`cty'_assessment_temp.dta", update


* Check on duplicates
duplicates tag teachers_id school_code, g(tag_dup_final)
tab tag_dup_final

/* There are 5 duplicated teacher id - school code combos because the same teachers
taught frade 2 and grade 4 in the same school. So we have a grade 2 obs and a grade 4 obs.
*/


*/


* drop temp/unecessary vars 
drop dup n_dup 

* label variables 
do "$code/zz_label_all_variables.do"


sort interview__key TEACHERS__id

* Save final data
save "$data/Edo_teacher_level.dta", replace

