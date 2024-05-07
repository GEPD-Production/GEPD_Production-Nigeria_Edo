/*******************************************************************************
Purpose: Cleaning all variables in raw data 

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

global date = c(current_date)
global username = c(username)

** File paths

* set up all globals
global base "C:\Users\wb589124\Downloads\GEPD_Production-Nigeria_Edo"
global data "${clone}\01_GEPD_raw_data\School"
global temp "$data\4_temp_data"
global code "${clone}\02_programs\School\Merge_Teacher_Modules" 
global final "$data\1_cleaned_input_data" 

/*Our goal is to clean all variables in all modules before our fuzzy match*/ 
* The following countries use the same variables
*Enter the 3 letter abbreviation of the country's data you want to clean here
*For example, Tchad is TCD


* Now, we start cleaning our datasets
/* Step 1: Start with roster data */
use "$data/teachers.dta", clear

* Dataset should be unique at teacher-id - school_code/interview_key level
ssc install unique 
unique TEACHERS__id interview__key												//Unique
replace m2saq2=lower(m2saq2)

* Run do file with all value labels
do "$code/z_value_labels.do"
 
* Sex - Recode sex variable as 1 for female and 0 for male
recode m2saq3 2=1 1=0
tab m2saq3
* label values
label define sex 0 "Male" 1 "Female", modify
label val m2saq3 sex 

* Contract status
tab m2saq5
tab m2saq5_other

* Full time status
* Recode part time to 0
recode m2saq6 2=0
label val m2saq6 fulltime

* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
cap la val urban_rural rural

* Save file
save "$final/teacher_absence.dta", replace
 
 ** NOT-RUN
 
/*/* Step 2: Clean pedagogy data */
use "$data/`cty'/`cty'_teacher_pedagogy.dta", clear
count
* Data should be unique at m4saq1_number school_code level

*Gender
if `i'==3|`i'==5 {
	di "No gender variable found"
	}
else{	
	tab m7saq10
	tab m7saq10, nol
	recode m7saq10 2=1 1=0
	la val m7saq10 sex
}
* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
la val urban_rural rural

* Label variables 
cap la var m4scq4_inpt "How many pupils are in the room?" 
cap la var m4scq4n_girls "How many of them are boys?"
cap la var m4scq5_inpt "How many total pupils have the textbook for class?"
cap la var m4scq6_inpt "How many pupils have pencil/pen?" 
cap la var m4scq7_inpt "How many pupils have an exercise book?"
cap la var m4scq11_inpt "How many pupils were not sitting on desks?"
cap la var m4scq12_inpt "How many students in class as per class list?"

* Save file
save "$final/`cty'/`cty'_teacher_pedagogy.dta", replace


*/



/* Step 3: m3(questionnaire) data */

use "$data/questionnaire_roster.dta", clear
* Teacher name is m3sb_troster and teacher id is m3sb_tnumber
* Data should be unique at m3sb_tnumber-school_code/interview_key level -- not unique (correcting manually for some ID errors)
unique interview__key m3sb_tnumber

sort interview__key m3sb_tnumber
quietly by interview__key m3sb_tnumber: gen dup = cond(_N==1,0,_n)
	tab dup
quietly by interview__key m3sb_tnumber: egen n_dup = max(dup)
	br if n_dup >0

log using "${clone}\02_programs\School\Raw_data_cleaning.smcl", replace
	//questionnaire_roster.dta
	//Correcting manually for some ID errors
replace m3sb_tnumber=13 if (m3sb_tnumber==8 & m3sb_troster=="Oduh Esther" & interview__key=="14-39-39-90")
replace m3sb_tnumber=11 if (m3sb_tnumber==9 & m3sb_troster=="Ifeku Veronica" & interview__key=="16-09-59-19")
replace m3sb_tnumber=4 if (m3sb_tnumber==3 & m3sb_troster=="Mrs Erhahor Idusogie" & interview__key=="20-03-75-20")
replace m3sb_tnumber=14 if (m3sb_tnumber==13 & m3sb_troster=="Edegba Mercy" & interview__key=="28-12-58-88")
replace m3sb_tnumber=4 if (m3sb_tnumber==5 & m3sb_troster=="Ugiovhe Philomena" & interview__key=="34-84-30-57")
replace m3sb_tnumber=5 if (m3sb_tnumber==4 & m3sb_troster=="AKINSOLA AZEEZ" & interview__key=="42-40-21-31")
replace m3sb_tnumber=8 if (m3sb_tnumber==5 & m3sb_troster=="Esezobor Eunice" & interview__key=="58-79-46-25")
replace m3sb_tnumber=4 if (m3sb_tnumber==7 & m3sb_troster=="Ehizogie Patience" & interview__key=="58-79-46-25")
replace m3sb_tnumber=16 if (m3sb_tnumber==19 & m3sb_troster=="ISHERHIENRHIEN MERCY I." & interview__key=="62-70-14-15")
replace m3sb_tnumber=5 if (m3sb_tnumber==4 & m3sb_troster=="AKINLADE RAYMON PHILIP" & interview__key=="64-88-17-13")
replace m3sb_tnumber=3 if (m3sb_tnumber==4 & m3sb_troster=="ISIBOR PATRICIA" & interview__key=="64-88-17-13")
replace m3sb_tnumber=4 if (m3sb_tnumber==3 & m3sb_troster=="OKOZI MARIA" & interview__key=="64-88-17-13")
replace m3sb_tnumber=6 if (m3sb_tnumber==5 & m3sb_troster=="SADIKU IDOWU THERESA" & interview__key=="64-88-17-13")
replace m3sb_tnumber=5 if (m3sb_tnumber==4 & m3sb_troster=="OTOHAN IKEKHUA" & interview__key=="65-54-74-59")
replace m3sb_tnumber=3 if (m3sb_tnumber==2 & m3sb_troster=="Balogun Dora Ehino" & interview__key=="66-25-52-85")
replace m3sb_tnumber=16 if (m3sb_tnumber==30 & m3sb_troster=="AIBANGBEE O.P" & interview__key=="84-68-24-20")
replace m3sb_tnumber=8 if (m3sb_tnumber==7 & m3sb_troster=="Comfort Iriogbe" & interview__key=="95-61-25-89")
	

log off
	
drop dup n_dup
unique interview__key m3sb_tnumber // unique




	//Different teachers (teacher name) but same id -- to be fixed by looking up teachers in roster file and replace with the correct ID


*Gender [Not-Run]
/*	tab m7saq10
	tab m7saq10, nol
	recode m7saq10 2=1 1=0
	la val m7saq10 sex
*/


*Age - differnt countries have different outliers
																	//NER
		* Has an outlier of 1974.
		sum m3saq6,d
		ssc install winsor
		winsor m3saq6, g( m3saq6_w) h(1) highonly
		drop m3saq6
		rename m3saq6_w m3saq6
	
		sum m3saq6
	
* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
cap la val urban_rural rural

* Save file
save "$final/teacher_questionnaire.dta", replace


/* Step 4: Merge in m5(assessment) data */
use "$data/teacher_assessment_answers.dta", clear

* Data should be unique at m5sb_troster/m5sb_tnumber - school_code/interview_key
unique interview__key m5sb_tnum // 12 duplicates

sort interview__key m5sb_tnum
quietly by interview__key m5sb_tnum: gen dup = cond(_N==1,0,_n)
	tab dup
quietly by interview__key m5sb_tnum: egen n_dup = max(dup)
	br if n_dup >0
	
log on
	//teacher_assessment_answers.dta
	//Correcting manually for some ID errors
	
replace m5sb_tnum=10 if (m5sb_tnum==13 & m5sb_troster=="JULIE IDONI" & interview__key=="05-30-95-22")
replace m5sb_tnum=8 if (m5sb_tnum==4 & m5sb_troster=="Efojie I. Mercy" & interview__key=="09-49-45-00")
replace m5sb_tnum=4 if (m5sb_tnum==1 & m5sb_troster=="Ehidiamen Rabietu Ehinor" & interview__key=="12-63-35-94")
replace m5sb_tnum=7 if (m5sb_tnum==1 & m5sb_troster=="Ehidiamen Iziegbe Priscilla" & interview__key=="12-63-35-94")
replace m5sb_tnum=5 if (m5sb_tnum==4 & m5sb_troster=="oshodin Fame" & interview__key=="12-63-35-94")
replace m5sb_tnum=7 if (m5sb_tnum==10 & m5sb_troster=="Ibrahim Aishat" & interview__key=="34-84-30-57")
replace m5sb_tnum=4 if (m5sb_tnum==3 & m5sb_troster=="REBECCA OKHILU" & interview__key=="35-55-29-72")
replace m5sb_tnum=5 if (m5sb_tnum==4 & m5sb_troster=="PATIENCE ITUAH" & interview__key=="35-55-29-72")
replace m5sb_tnum=6 if (m5sb_tnum==5 & m5sb_troster=="ESTHER AGBONYEMEN" & interview__key=="35-55-29-72")
replace m5sb_tnum=7 if (m5sb_tnum==6 & m5sb_troster=="GRACE IMOROA" & interview__key=="35-55-29-72")
replace m5sb_tnum=3 if (m5sb_tnum==1 & m5sb_troster=="Imoesi Felicia" & interview__key=="45-36-10-93")
replace m5sb_tnum=4 if (m5sb_tnum==3 & m5sb_troster=="Onuwabhagbe Lauretta Izehi" & interview__key=="58-79-07-25")
replace m5sb_tnum=3 if (m5sb_tnum==2 & m5sb_troster=="OGBEMUDIA CHRISTIANA CATHERINE" & interview__key=="59-61-99-94")
replace m5sb_tnum=6 if (m5sb_tnum==3 & m5sb_troster=="AJAGBE FOLASADE HANNAH" & interview__key=="59-61-99-94")
replace m5sb_tnum=10 if (m5sb_tnum==11 & m5sb_troster=="Mr Erhunmwunsee Ese Ephraim" & interview__key=="69-97-63-27")
replace m5sb_tnum=13 if (m5sb_tnum==10 & m5sb_troster=="Agadagodo Felicia" & interview__key=="76-69-80-98")
replace m5sb_tnum=5 if (m5sb_tnum==2 & m5sb_troster=="Mrs Okuke Roseline Oghogho" & interview__key=="80-27-29-67")
replace m5sb_tnum=14 if (m5sb_tnum==12 & m5sb_troster=="ABU SUSAN BISI" & interview__key=="87-31-19-81")
replace m5sb_tnum=6 if (m5sb_tnum==14 & m5sb_troster=="OSHOMAH MATILDA ANFANI" & interview__key=="87-31-19-81")


log off
log close

	drop dup n_dup
	
*Gender [Not-Run]
/*	tab m7saq10
	tab m7saq10, nol
	recode m7saq10 2=1 1=0
	la val m7saq10 sex
*/

* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
cap la val urban_rural rural

* Save file
save "$final/teacher_assessment.dta", replace


