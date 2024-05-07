---
title: "Global Education Policy Dashboard - Nigeria - Edo 2023"
format: 
  pptx:
    fig_height: 8
    fig_width: 10
    keep-md: true
execute:
  warning: false
  error: false
  message: false
  echo: false
dpi: 400
knitr:
  opts_chunk:
    fig.path: "./figures/"
---


::: {.cell}

:::





# Introduction




- The Global Education Policy Dashboard  applies framework of WDR 2018 

- Create and collect a concise set of indicators that allow tracking of key determinants of learning.  

- The Dashboard tracks three levels, the three Ps:
  * Practice
  * Policies
  * Politics.

- The data is collected using three surveys: A school survey, an policy survey, and a survey of public officials

School Survey: The School Survey will collect data primarily on Practices (the quality of service delivery in schools), but also on some de facto Policy and school-level Politics indicators.  It will consist of streamlined versions of existing instruments—including SDI and SABER SD on teachers, 4th grade students, and inputs/infrastructure, TEACH on pedagogical practice, GECDD on school readiness of young children, and DWMS on management quality—together with new questions to fill gaps in those instruments.  Though the number of modules is similar to the full version of SDI, the number of items within each module is significantly lower. In each country, this survey will be administered in a nationally representative sample of 250 schools, selected through stratified  random sampling. As currently envisioned, the School Survey will include 8 short modules.
Expert Survey: The Expert Survey will collect information to feed into the policy indicators.  This survey will be filled out by key informants in each country, drawing on their knowledge to identify key elements of the policy framework (as in the SABER approach to policy-data collection that the Bank has used over the past 7 years).  The survey will have 4 modules with each including approximately ten questions.

Policy Survey:  The policy survey is conducted by an expert on the laws and regulations of a country.  The experts gather information on De Jure policies in the education system for that country.

Survey of Public Officials: The Survey of Public Officials will collect information about the capacity and orientation of the bureaucracy, as well as political factors affecting education outcomes. This survey will be a streamlined and education-focused version of the civil-servant surveys that the Bank’s Bureaucracy Lab has implemented recently in several countries, and the dashboard team is collaborating closely with DEC and Governance GP staff to develop this instrument.  As currently envisioned, the survey will be administered to a random sample of about 200 staff serving in the central education ministry and district education offices.  It will include questions about technical and leadership skills, work environment, stakeholder engagement, clientelism, and attitudes and behaviors.

Roadmap:  
- Below is a set of tables and charts containing findings for the Chad 2023 Global Education Policy Dashboard survey. - We will start with breakdowns of our Practice indicators  
- Then we will discuss findings of our Practice Indicators  
- Finally we will conclude with findings for our Bureaucracy Indicators.  









# 





::: {.cell}

:::




# Practice Indicators

- To begin, we will show a few results from our Practice, or Service Delivery, Indicators collected as part of the school survey.

# Overall Learning

- We begin with student learning on our assessment of 4th grade students.  
- We offer breakdowns by Urban/Rural and by Gender


::: {.cell}
::: {.cell-output-display}
![](./figures/learning-1.png)
:::
:::


# Overall Learning


::: {.cell}
::: {.cell-output .cell-output-stdout}

```
[1] "The mean percentage of students who could identify basic words is 76.5%"
[1] "The mean percentage of students who successfully answered 8+7 is 86.4%"
[1] "The mean percentage of students who successfully answered 7x8 is 70.3%"
[1] "The mean percentage of students who successfully answered 75/5 is 31.2%"
```


:::
:::


# Breakdowns for infrastructure

- We compare inputs and infrastructure for Urban/Rural schools 


::: {.cell}
::: {.cell-output-display}
![](./figures/urban_rural-1.png)
:::
:::


# Breakdown for Input by Urban/Rural


::: {.cell}
::: {.cell-output-display}
![](./figures/urban_rural_input-1.png)
:::
:::


# First Grade Assessment Score

- The following plots the school level average of the 4th grade assessment scores on the school level average 1st grade assessment score.  
- Note that the children assessed in 4th grade differ from the students assessed in 1st grade  
- The graph is meant to associate levels of student learning in 1st grade with 4th grade student learning.


::: {.cell fig_height='8' fig_width='9'}
::: {.cell-output-display}
![](./figures/1st_grade_plot-1.png)
:::

::: {.cell-output .cell-output-stdout}

```

Call:
lm(formula = student_knowledge ~ ecd_student_knowledge, data = df_reg)

Residuals:
    Min      1Q  Median      3Q     Max 
-29.928  -7.076  -0.067   6.538  44.194 

Coefficients:
                       Estimate Std. Error t value Pr(>|t|)    
(Intercept)           32.458879   0.464164   69.93   <2e-16 ***
ecd_student_knowledge  0.212027   0.006862   30.90   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 10.83 on 11744 degrees of freedom
  (1 observation deleted due to missingness)
Multiple R-squared:  0.07519,	Adjusted R-squared:  0.07511 
F-statistic: 954.8 on 1 and 11744 DF,  p-value: < 2.2e-16
```


:::
:::



# Teacher Pedagogical Skill
- One of the best predictors of 4th grade student achievement, along with the 1st grade scores, is the teacher's pedagogical score  
- The following plots the school level average of the 4th grade assessment scores on the teacher's pedagogical skill based on the Teach scale.  





# Teacher Content Knowledge

- Regions  differ in terms of their service delivery and learning outcomes.  
- This is particularly true for teacher effort and skill.  
- Below we plot teacher content knowledge by region to highlight some of these differences.  


::: {.cell}
::: {.cell-output-display}
![](./figures/content_knowledge_region-1.png)
:::

::: {.cell-output-display}
![](./figures/content_knowledge_region-2.png)
:::
:::




# Do principals know their schools?

- Adequate Textbooks:
  * Principals asked, "In the selected 4th grade classroom, how many of the pupils have the relevant textbooks?"
  * We can compare answer to average calculated in our school survey
  


::: {.cell}
::: {.cell-output-display}
![](./figures/unnamed-chunk-5-1.png)
:::
:::


# Discuss Results of Teacher Evaluation with Principal


::: {.cell}
::: {.cell-output-display}
![](./figures/discuss_results-1.png)
:::
:::




# Overall performance for Bureuacracy Indicators

- Moving to the Bureaucracy Indicators, below we show the averages by Office type for each of our indicators
- Public officials in the district offices tend to score lower than at the central level




::: {.cell}
::: {.cell-output-display}
![](./figures/overall-1.png)
:::
:::
