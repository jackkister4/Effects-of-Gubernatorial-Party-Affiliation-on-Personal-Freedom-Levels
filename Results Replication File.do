//results

//set directory
cd "C:\Users\jackk\OneDrive\Desktop\Professional Project\Data\Data Process"

//use data set
use "gubernatorial_final_data_set.dta"

//install library
ssc install outreg2
ssc install rdrobust
ssc install rddensity
ssc install lpdensity

//drop missing values
drop if missing(dem_gov)

//generate descriptive statistics
preserve
keep personal_freedom gun_freedom cannabis_freedom tobacco_freedom dem_gov margin_of_victory
outreg2 using summary_stats.doc, word sum(log) replace
restore

//generate descriptive statistics for included bandwidth for primary regression
preserve
keep personal_freedom gun_freedom cannabis_freedom tobacco_freedom dem_gov margin_of_victory
drop if margin_of_victory < -9.037 | margin_of_victory > 9.037
outreg2 using summary_stats_primary.doc, word sum(log) replace
restore

//generate fixed effects
tab year, gen(yfe)
tab stateid, gen(sfe)



//regression for personal freedom

//optimal bandwidth selection given fixed effects
rdbwselect personal_freedom margin_of_victory, all covs(stateid year) kernel(uniform) vce(cluster stateid)
*9.037 

//rdd conditioned on year and state fixed effects at optimal bandwidth
reg personal_freedom c.margin_of_victory##dem_gov i.year i.stateid if margin_of_victory>= -9.037   & margin_of_victory<= 9.037 , cluster(stateid) 
*p-value = 0.337

//save to word doc
outreg2 using "results.doc", replace ctitle("Personal Freedom") addstat("N", e(N)) keep(1.dem_gov)



//regression for gun freedom

//optimal bandwidth selection given fixed effects
rdbwselect gun_freedom margin_of_victory, all covs(stateid year) kernel(uniform) vce(cluster stateid)
*10.426  

//rdd conditioned on year and state fixed effects at optimal bandwidth
reg gun_freedom c.margin_of_victory##dem_gov i.year i.stateid if margin_of_victory>= -10.426    & margin_of_victory<= 10.426  , cluster(stateid) 
*p-value = 0.808

//save to word doc
outreg2 using "results.doc", append ctitle("Gun Freedom") addstat("N", e(N)) keep(1.dem_gov)



//regression for cannabis freedom
rdbwselect cannabis_freedom margin_of_victory, all covs(stateid year) kernel(uniform) vce(cluster stateid)
*12.718 

//rdd conditioned on year and state fixed effects at optimal bandwidth
reg cannabis_freedom c.margin_of_victory##dem_gov i.year i.stateid if margin_of_victory>= -12.718     & margin_of_victory<= 12.718   , cluster(stateid) 
*p-value = 0.753

//save to word doc
outreg2 using "results.doc", append ctitle("Cannabis Freedom") addstat("N", e(N)) keep(1.dem_gov)



//regression for tobacco freedom
rdbwselect tobacco_freedom margin_of_victory, all covs(stateid year) kernel(uniform) vce(cluster stateid)
*14.375 

//rdd conditioned on year and state fixed effects at optimal bandwidth
reg tobacco_freedom c.margin_of_victory##dem_gov i.year i.stateid if margin_of_victory>= -14.375    & margin_of_victory<= 14.375  , cluster(stateid) 
*p-value = .271

//save to word doc
outreg2 using "results.doc", append ctitle("Tobacco Freedom") addstat("N", e(N)) keep(1.dem_gov)




//personal freedom
preserve
keep if margin_of_victory >= -9.037 & margin_of_victory <= 9.037
reg personal_freedom i.year i.stateid, cluster(stateid)
predict residuals_personal_freedom, residuals
rdplot residuals_personal_freedom margin_of_victory, p(1) kernel(uniform) h(9.037)
restore


//gun freedom
preserve
keep if margin_of_victory >= -10.426 & margin_of_victory <= 10.426
reg gun_freedom i.year i.stateid, cluster(stateid)
predict residuals_gun_freedom, residuals
rdplot residuals_gun_freedom margin_of_victory, p(1) kernel(uniform) h(10.426)
restore


//cannabis freedom
preserve
keep if margin_of_victory >= -12.718 & margin_of_victory <= 12.718
reg cannabis_freedom i.year i.stateid, cluster(stateid)
predict residuals_cannabis_freedom, residuals
rdplot residuals_cannabis_freedom margin_of_victory, p(1) kernel(uniform) h(12.718)
restore


//tobacco freedom
preserve
keep if margin_of_victory >= -14.375 & margin_of_victory <= 14.375
reg tobacco_freedom i.year i.stateid, cluster(stateid)
predict residuals_tobacco_freedom, residuals
rdplot residuals_tobacco_freedom margin_of_victory, p(1) kernel(uniform) h(14.375)
restore