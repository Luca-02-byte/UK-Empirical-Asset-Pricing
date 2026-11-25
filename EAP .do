version 19
clear all

cd "path/to/your/working/folder"

import excel Dati.xlsx, firstrow clear

save Dati_2, replace

forvalues i = 1/10 {
    generate XS`i' = S`i' - rf
    label var XS`i' "Excess return of S`i'"
}

graph box XS1

* Winsorization
ssc install winsor2
winsor2 XS1 XS2 XS3 XS4 XS5 XS6 XS7 XS8 XS9 XS10 rmrf smb hml umd
graph box XS1_w

winsor2 XS1 XS2 XS3 XS4 XS5 XS6 XS7 XS8 XS9 XS10 rmrf smb hml umd, cuts (2 98) suffix(_z)
graph box XS1_z

* Summary statistics
tabstat XS1 XS2 XS3 XS4 XS5 XS6 XS7 XS8 XS9 XS10, statistics(mean)
summ XS1 XS2 XS3 XS4 XS5 XS6 XS7 XS8 XS9 XS10, detail

tabstat XS1_z XS2_z XS3_z XS4_z XS5_z XS6_z XS7_z XS8_z XS9_z XS10_z, statistics(mean)
summ XS1_z XS2_z XS3_z XS4_z XS5_z XS6_z XS7_z XS8_z XS9_z XS10_z, detail

*Correlation
cor rmrf smb hml umd
cor rmrf_z smb_z hml_z umd_z

* Time-series Regression 
postfile handle port str10 model r2_a alpha b_rmrf b_smb b_hml b_umd using "model_results.dta", replace

forvalues i = 1/10 {
    * CAPM Model
    regress XS`i'_z rmrf_z
    estimates store capm_`i'
    post handle (`i') ("CAPM") (e(r2_a)) (_b[_cons]) (_b[rmrf_z]) (.) (.) (.)

    * FF3
    regress XS`i'_z rmrf_z smb_z hml_z
    estimates store ff3_`i'
    post handle (`i') ("FF3") (e(r2_a)) (_b[_cons]) (_b[rmrf_z]) (_b[smb_z]) (_b[hml_z]) (.)

    * Carhart 4F
    regress XS`i'_z rmrf_z smb_z hml_z umd_z
    estimates store carhart_`i'
    post handle (`i') ("Carhart4") (e(r2_a)) (_b[_cons]) (_b[rmrf_z]) (_b[smb_z]) (_b[hml_z]) (_b[umd_z])
}
postclose handle


* GRS test
ssc install grstest2

matrix GRS_table = J(3, 2, .)
matrix colnames GRS_table = "GRS_F_Stat" "P_Value_F"
matrix rownames GRS_table = "CAPM" "FF3" "Carhart4"

*1. CAPM
quietly grstest2 XS1_z XS2_z XS3_z XS4_z XS5_z XS6_z XS7_z XS8_z XS9_z XS10_z, flist(rmrf_z)
matrix GRS_table[1,1] = R[2,2]   
matrix GRS_table[1,2] = R[2,3]   

* 2. FF3
quietly grstest2 XS1_z XS2_z XS3_z XS4_z XS5_z XS6_z XS7_z XS8_z XS9_z XS10_z, flist(rmrf_z smb_z hml_z)
matrix GRS_table[2,1] = R[2,2]
matrix GRS_table[2,2] = R[2,3]

* 3. Carhart 4F
quietly grstest2 XS1_z XS2_z XS3_z XS4_z XS5_z XS6_z XS7_z XS8_z XS9_z XS10_z, flist(rmrf_z smb_z hml_z umd_z)
matrix GRS_table[3,1] = R[2,2]
matrix GRS_table[3,2] = R[2,3]
display _n "========================================================================="
display "             TABELLA SINTETICA GRS (STATISTICA F E P-VALUE)             "
display "========================================================================="
matrix list GRS_table, format(%9.4f)



use "model_results.dta", clear

gen model_id = 1 if model == "CAPM"
replace model_id = 2 if model == "FF3"
replace model_id = 3 if model == "Carhart4"
label define mid 1 "CAPM" 2 "FF3" 3 "Carhart4"
label values model_id mid

* Adjusted R2
twoway (connected r2_a port if model_id==1, lpattern(dash) msymbol(O) msize(medium)) ///
       (connected r2_a port if model_id==2, lpattern(solid) msymbol(D) msize(medium)) ///
       (connected r2_a port if model_id==3, lpattern(shortdash) msymbol(T) msize(medium)), ///
       title("Adjusted R-squared Comparison Across Models") ///
       xtitle("Portfolio") ///
       ytitle("Adjusted R²") ///
       xlabel(1(1)10) ///
       ylabel(, angle(0) format(%4.2f)) ///
       legend(order(1 "CAPM" 2 "Fama-French 3F" 3 "Carhart 4F"))

* Pricing errors
twoway (connected alpha port if model_id==1, lpattern(dash) msize(medium)) ///
       (connected alpha port if model_id==2, lpattern(solid) msize(medium)) ///
       (connected alpha port if model_id==3, lpattern(shortdash) msize(medium)), ///
       yline(0, lcolor(red) lpattern(dot)) ///
       title("Pricing Errors (Alpha) Across Models") ///
       subtitle("Values closer to zero indicate superior factor pricing") ///
       xtitle("Portfolio") ytitle("Alpha (Intercept)") ///
       xlabel(1(1)10) ///
       legend(order(1 "CAPM" 2 "Fama-French 3F" 3 "Carhart 4F"))

	   
	  


save Dati_corretti, replace

import excel risultati_corretti.xlsx, firstrow clear

gen id=_n
label define id_lbl 1 "XS1" 2 "XS2" 3 "XS3" 4 "XS4" 5 "XS5" ///
                    6 "XS6" 7 "XS7" 8 "XS8" 9 "XS9" 10 "XS10"
label values id id_lbl

graph bar b_rmrf b_smb b_hml b_umd, over(id) ylabel(#10) title("Slopes of Portfolio") legend(label(1 "rmrf") label(2 "smb") label(3 "hml") label(4 "umd"))

* Cross-section regression

regress mean b_rmrf b_smb, vce(robust)
vif
regress mean b_rmrf b_hml, vce(robust)
vif
regress mean b_rmrf b_umd, vce(robust)
vif

save dati_regression_2, replace
