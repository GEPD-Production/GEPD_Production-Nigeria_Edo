*paths
gl teach_path "C:\Users\WB469649\WBG\HEDGE Files - HEDGE Documents\GEPD-Confidential\General\Country_Data\GEPD_Production-Chad\03_GEPD_processed_data\School\Confidential\Cleaned\teachers_Stata.dta"
gl attendance_path "C:\Users\WB469649\WBG\HEDGE Files - HEDGE Documents\GEPD-Confidential\General\Country_Data\GEPD_Production-Chad\03_GEPD_processed_data\School\Confidential\Cleaned\school_Stata.dta"


*Teacher Pedagogy
use "$teach_path" , replace
keep if grade==4
svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)  || teacher_unique_id, weight(teacher_pedagogy_weight)
 
 
replace teach_prof=100*(teach_score>=3)
*For overall TEACH Scores
foreach var in teach_score teach_prof  {
svy: mean `var' 
}

*For male teachers
foreach var in teach_score teach_prof  {
svy: mean `var' if m2saq3 == 0 
} 
 
*For female teachers
foreach var in teach_score teach_prof   {
svy: mean `var' if m2saq3 == 1
}
 
*For rural teachers
foreach var in teach_score teach_prof  {
svy: mean `var' if urban_rural == "Rural" 
}
 
foreach var in teach_score teach_prof  {
svy: mean `var' if urban_rural == "Urban" 
}

*student attendance
use "$attendance_path" , replace

svyset school_code [pw=school_weight], strata($strata) singleunit(scaled) 
svy: mean student_attendance_male

svyset school_code [pw=school_weight], strata($strata) singleunit(scaled) 
svy: mean student_attendance_female

*Principal Management
svyset school_code, strata($strata) singleunit(scaled) weight(school_weight)
svy: mean principal_management if m7saq10 ==2
 
*And for problem solving:
svy: mean problem_solving if m7saq10==2
svy: mean problem_solving if m7saq10==1