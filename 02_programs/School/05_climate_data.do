
clear all 


do "C:\Users\wb589124\WBG\HEDGE Files - HEDGE Documents\GEPD-Confidential\General\Country_Data\GEPD_Production-Nigeria_Edo\profile_GEPD.do"

gl data_dir ${clone}/01_GEPD_raw_data/


* loading climate data
use "${data_dir}/School/climatebeliefs.dta"

*basic tabulatuion to extract the labels 
codebook climatebeliefs__id

* dropping unnecessary vars
drop interview__id

unique interview__key questionnaire_roster__id  // dataset to be unique on those levels - for now not unique 
unique interview__key questionnaire_roster__id climatebeliefs__id


* reshaping data wide
reshape wide m3_clim_q1, i(interview__key questionnaire_roster__id) j(climatebeliefs__id) 

la var m3_clim_q11 "Evidence shows that climate change is happening"
la var m3_clim_q12 "Human activity is the primary cause of climate change"
la var m3_clim_q13 "Climate change is not increasing natural disaster threats like flooding, drought, and extreme temperatures"
la var m3_clim_q14 "Burning of fossil fuel like oil and coal contributes to climate change"
la var m3_clim_q15 "Deforestation is one of the causes of climate change"
la var m3_clim_q16 "Agricultural activities such as animal and plant production contribute to climate change"


unique interview__key questionnaire_roster__id  // -unique 

*generating stats

foreach var in m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16  {
	tab `var', nol
	
}

gen clim3 = m3_clim_q13
tab m3_clim_q13
replace m3_clim_q13= 1 if clim3==0
replace m3_clim_q13=0 if clim3==1
tab m3_clim_q13

drop clim3 

egen counter = rowtotal(m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16)

sum counter, d
tab counter, m


gen atleast_one_wrong =. 
replace atleast_one_wrong=1 if counter <6
sum atleast_one_wrong






*********************** Repeat for Chad 

clear all 


do "C:\Users\wb589124\WBG\HEDGE Files - HEDGE Documents\GEPD-Confidential\General\Country_Data\GEPD_Production-Chad\profile_GEPD.do"

gl data_dir ${clone}/01_GEPD_raw_data/


* loading climate data
use "${data_dir}/School/climatebeliefs.dta"

*basic tabulatuion to extract the labels 
codebook climatebeliefs__id

* dropping unnecessary vars
drop interview__id

unique interview__key questionnaire_roster__id  // dataset to be unique on those levels - for now not unique 
unique interview__key questionnaire_roster__id climatebeliefs__id


* reshaping data wide
reshape wide m3_clim_q1, i(interview__key questionnaire_roster__id) j(climatebeliefs__id) 

la var m3_clim_q11 "Evidence shows that climate change is happening"
la var m3_clim_q12 "Human activity is the primary cause of climate change"
la var m3_clim_q13 "Climate change is not increasing natural disaster threats like flooding, drought, and extreme temperatures"
la var m3_clim_q14 "Burning of fossil fuel like oil and coal contributes to climate change"
la var m3_clim_q15 "Deforestation is one of the causes of climate change"
la var m3_clim_q16 "Agricultural activities such as animal and plant production contribute to climate change"


unique interview__key questionnaire_roster__id  // -unique 

*generating stats

foreach var in m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16  {
	tab `var', nol
	
}

gen clim3 = m3_clim_q13
tab m3_clim_q13
replace m3_clim_q13= 1 if clim3==0
replace m3_clim_q13=0 if clim3==1
tab m3_clim_q13

drop clim3 

egen counter = rowtotal(m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16)

sum counter, d
tab counter, m


gen atleast_one_wrong =. 
replace atleast_one_wrong=1 if counter <6
sum atleast_one_wrong


*********************** Repeat for Gabon

clear all 


do "C:\Users\wb589124\WBG\HEDGE Files - HEDGE Documents\GEPD-Confidential\General\Country_Data\GEPD_Production-Gabon\profile_GEPD.do"

gl data_dir ${clone}/01_GEPD_raw_data/


* loading climate data
use "${data_dir}/School/climatebeliefs.dta"

*basic tabulatuion to extract the labels 
codebook climatebeliefs__id

* dropping unnecessary vars
drop interview__id

unique interview__key questionnaire_roster__id  // dataset to be unique on those levels - for now not unique 
unique interview__key questionnaire_roster__id climatebeliefs__id


* reshaping data wide
reshape wide m3_clim_q1, i(interview__key questionnaire_roster__id) j(climatebeliefs__id) 

la var m3_clim_q11 "Evidence shows that climate change is happening"
la var m3_clim_q12 "Human activity is the primary cause of climate change"
la var m3_clim_q13 "Climate change is not increasing natural disaster threats like flooding, drought, and extreme temperatures"
la var m3_clim_q14 "Burning of fossil fuel like oil and coal contributes to climate change"
la var m3_clim_q15 "Deforestation is one of the causes of climate change"
la var m3_clim_q16 "Agricultural activities such as animal and plant production contribute to climate change"


unique interview__key questionnaire_roster__id  // -unique 

*generating stats

foreach var in m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16  {
	tab `var', nol
	
}

gen clim3 = m3_clim_q13
tab m3_clim_q13
replace m3_clim_q13= 1 if clim3==0
replace m3_clim_q13=0 if clim3==1
tab m3_clim_q13

drop clim3 

egen counter = rowtotal(m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16)

sum counter, d
tab counter, m


gen atleast_one_wrong =. 
replace atleast_one_wrong=1 if counter <6
sum atleast_one_wrong


*********************** Repeat for Jordan 13

clear all 


do "C:\Users\wb589124\WBG\HEDGE Files - HEDGE Documents\GEPD-Confidential\General\Country_Data\GEPD_Production-Jordan_2023\profile_GEPD.do"

gl data_dir ${clone}/01_GEPD_raw_data/


* loading climate data
use "${data_dir}/School/climatebeliefs.dta"

*basic tabulatuion to extract the labels 
codebook climatebeliefs__id

* dropping unnecessary vars
drop interview__id

unique interview__key questionnaire_roster__id  // dataset to be unique on those levels - for now not unique 
unique interview__key questionnaire_roster__id climatebeliefs__id


* reshaping data wide
reshape wide m3_clim_q1, i(interview__key questionnaire_roster__id) j(climatebeliefs__id) 

la var m3_clim_q11 "Evidence shows that climate change is happening"
la var m3_clim_q12 "Human activity is the primary cause of climate change"
la var m3_clim_q13 "Climate change is not increasing natural disaster threats like flooding, drought, and extreme temperatures"
la var m3_clim_q14 "Burning of fossil fuel like oil and coal contributes to climate change"
la var m3_clim_q15 "Deforestation is one of the causes of climate change"
la var m3_clim_q16 "Agricultural activities such as animal and plant production contribute to climate change"


unique interview__key questionnaire_roster__id  // -unique 

*generating stats

foreach var in m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16  {
	tab `var', nol
	
}

gen clim3 = m3_clim_q13
tab m3_clim_q13
replace m3_clim_q13= 1 if clim3==0
replace m3_clim_q13=0 if clim3==1
tab m3_clim_q13

drop clim3 

egen counter = rowtotal(m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16)

sum counter, d
tab counter, m


gen atleast_one_wrong =. 
replace atleast_one_wrong=1 if counter <6
sum atleast_one_wrong



*********************** Repeat for Pakistan KP

clear all 


do "C:\Users\wb589124\WBG\HEDGE Files - HEDGE Documents\GEPD-Confidential\General\Country_Data\GEPD_Production-Pakistan_KP\profile_GEPD.do"

gl data_dir ${clone}/01_GEPD_raw_data/


* loading climate data
use "${data_dir}/School/version8/climatebeliefs.dta"

*basic tabulatuion to extract the labels 
codebook climatebeliefs__id

* dropping unnecessary vars
drop interview__id

unique interview__key questionnaire_roster__id  // dataset to be unique on those levels - for now not unique 
unique interview__key questionnaire_roster__id climatebeliefs__id


* reshaping data wide
reshape wide m3_clim_q1, i(interview__key questionnaire_roster__id) j(climatebeliefs__id) 

la var m3_clim_q11 "Evidence shows that climate change is happening"
la var m3_clim_q12 "Human activity is the primary cause of climate change"
la var m3_clim_q13 "Climate change is not increasing natural disaster threats like flooding, drought, and extreme temperatures"
la var m3_clim_q14 "Burning of fossil fuel like oil and coal contributes to climate change"
la var m3_clim_q15 "Deforestation is one of the causes of climate change"
la var m3_clim_q16 "Agricultural activities such as animal and plant production contribute to climate change"


unique interview__key questionnaire_roster__id  // -unique 

*generating stats

foreach var in m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16  {
	tab `var', nol
	
}

gen clim3 = m3_clim_q13
tab m3_clim_q13
replace m3_clim_q13= 1 if clim3==0
replace m3_clim_q13=0 if clim3==1
tab m3_clim_q13

drop clim3 

egen counter = rowtotal(m3_clim_q11 m3_clim_q12 m3_clim_q13 m3_clim_q14 m3_clim_q15 m3_clim_q16)

sum counter, d
tab counter, m


gen atleast_one_wrong =. 
replace atleast_one_wrong=1 if counter <6
sum atleast_one_wrong




