
clear all
set more off

set matsize 2000

use "...\data.dta"

keep if bankindex ==1




/* Genrating variables defined in Williams and Bush*/

/*generating advances using net and gross NPAs*/
/* var56 = gnpa ratio */
/* var58 = nnpa ratio */ 

gen advancennpa=(net_npa/ var58)*100

gen advancegnpa= (gross_npa/ var56)*100

gen ladvancegnpa=ln(advancegnpa)

/* Generating year*/

gen year_n= year(date)
keep if year_n>2001
/* creating lag loans*/

sort bankid date 

by bankid: gen lagloan= advancegnpa[_n-1]

by bankid: gen loaninc= advancegnpa-lagloan

by bankid: gen lagloaninc= loaninc[_n-1]

by bankid: gen gnpainc= gross_npa-gross_npa[_n-1]

gen nparatio= gnpainc/lagloaninc

by bankid: gen nparationext= nparatio[_n+1]

by bankid: gen gnpaincnext= gnpainc[_n+1]

/*Prov to lagloan ratio*/

gen LLP= provisions_and_contingencies

gen LLPtolagloan= provisions_and_contingencies/lagloaninc

/*Prov to loan ratio*/

gen LLPtoloan= provisions_and_contingencies/loaninc

/*gen profit before provision*/

gen profit= net_profit+provisions_and_contingencies

gen profitratio= profit/lagloaninc

gen netprofitratio= net_profit/lagloaninc

replace profittosales = profit/net_sales
gen netprofittosales= net_profit/net_sales

/*generate Assets using ROA and Net profit*/

gen Assets= (net_profit/ROA)*100

/* control variables for regressions*/
/*generate capital adaequacy ratio*/
by bankid: gen CAR= capital_adequacy_ratio[_n-1]
by bankid : gen lassets= Assets[_n-1]


/*interaction Terms*/

gen npachair= nparatio*newchair
 gen npanextchair= nparationext*newchair
gen incomechair= profitratio*newchair





/*scaling by net sales*/

gen LLPtosales= provisions_and_contingencies/net_sales

replace npatosales= gnpainc/net_sales

by bankid: gen npatosalesnext= npatosales[_n+1]

replace profittosales= profit/net_sales

by bankid: gen lagprofittosales= profittosales[_n-1]
gen logloan=ln(advancegnpa)

*Definition of nrechair*/
/*joined before end of the quarter*/

by bankid: gen newchairend=1 if join_date> date[_n-1] & join_date<=date
replace newchairend=0 if newchairend==. 

gen cutoff= date-45

by bankid: gen newchair45=1 if join_date<= cutoff & join_date>cutoff[_n-1]
replace newchair45=0 if newchair45==. 



/*Adding next four quarter*/





/*Interaction terms scaled by sales*/

gen chairnpatosalesnext= newchair*npatosalesnext
gen chairprofitsales=  profittosales*newchair

gen chair1npatosalesnext= newchair45*npatosalesnext
gen chair1profitsales=  profittosales*newchair45



/*unscaled interaction terms*/

gen chairnpanext= newchair*gnpaincnext
gen chairprofit= newchair*profit

/*loan growth*/

by bankid: gen loangrowth= advancegnpa/lagloan

xtset bankid
xtreg  LLPtosales newchair profittosales  chairprofitsales nparationext npanextchair nparatio   i.date i.bankid, cluster(bankid)

xtreg  LLPtosales newchair profittosales  chair1profitsales npatosalesnext chair1npatosalesnext npatosales lagloan CAR  i.date i.bankid, cluster(bankid)

/*xtreg  LLPtosales newchair profittosales  chair2profitsales npatosalesnext chair2npatosalesnext npatosales  i.date i.bankid, cluster(bankid)*/

/*unscaled regressions*/

xtreg  LLP newchair profit  chairprofit gnpaincnext chairnpanext gnpainc lagloan CAR  i.date i.bankid, cluster(bankid)

xtreg  LLPtosales newchair  npatosalesnext chairnpatosalesnext npatosales   i.date i.bankid, cluster(bankid)

xtreg  LLPtosales newchair   i.date i.bankid, cluster(bankid)

xtreg  loangrowth newchair  npatosales Assets i.date i.bankid, cluster(bankid)



/*Definition of nrechair*/
/*joined before end of the quarter*/

/*by bankid: gen newchairqtrend=1 if join_date<= date[_n-1] & join_date<=date
replace newchairqtrend=0 if newchairqtrend==. 

gen cutoff= date-45

by bankid: gen newchair45=1 if join_date<= cutoff & join_date>cutoff[_n-1]
replace newchair45=0 if newchair45==. */





gen cutoff30= date-30

by bankid: gen newchair30=1 if join_date<= cutoff30 & join_date>cutoff30[_n-1]
replace newchair30=0 if newchair30==. 
/* tes Regression scaled by loans*/

by bankid: gen newchairnext= newchair[_n-1]

by bankid: gen newchairnext1= newchair[_n-2]

by bankid: gen newchairnext2= newchair[_n-3]

by bankid: gen newchairnext3= newchair[_n-4]

by bankid: gen lagnewchair= newchair[_n-1]

gen newchair_year= newchairnext+newchairnext1+newchairnext2+newchair


by bankid: gen newchairendnext= newchairend[_n-1]

by bankid: gen newchairendnext1= newchairend[_n-2]

by bankid: gen newchairendnext2= newchairend[_n-3]

by bankid: gen newchairendnext3= newchairend[_n-4]


by bankid: gen newchairendlag= newchairend[_n+1]

by bankid: gen newchairendlag1= newchairend[_n+2]

by bankid: gen newchairendlag2= newchairend[_n+3]

by bankid: gen newchairendlag3= newchairend[_n+4]



gen normal=.
replace normal=0 if newchairend==1
replace normal=1 if newchairendnext==1
replace normal=2 if newchairendnext1==1
replace normal=3 if newchairendnext2==1
replace normal=-1 if newchairendlag==1
replace normal=-2 if newchairendlag1==1
replace normal=-3 if newchairendlag2==1



gen newchair_yearendnew= newchairend+newchairendnext+newchairendnext1+newchairendnext2

xtreg  LLPtolagloan newchair CAR lagprofittosales lagloan i.date i.bankid, cluster(bankid)



xtreg LLPtosales newchairend   i.date i.bankid, cluster(bankid)

xtreg advancegnpa newchair45   i.date i.bankid, cluster(bankid)

xtreg advancegnpa newchairend  i.date i.bankid, cluster(bankid) robust

xtreg advancennpa newchair_yearendnew i.date i.bankid, cluster(bankid) robust

xtreg advancennpa newchairend newchairendnext newchairendnext1 newchairendnext2  i.date i.bankid, cluster(bankid) robust


xtreg loangrowth newchair45   i.date i.bankid, cluster(bankid)

xtreg advancegnpa  newchair_yearendnew  i.date i.bankid, cluster(bankid)

xtreg loaninc  newchair_yearendnew  i.date i.bankid, cluster(bankid)

xtreg loaninc  newchairend  i.date i.bankid, cluster(bankid)

xtreg calc_advance newchair45   i.date i.bankid, cluster(bankid)

xtreg calc_advance newchair45   i.date i.bankid, cluster(bankid)

xtreg calc_advance newchair45   i.date i.bankid, cluster(bankid)

xtreg calc_advance newchair45   i.date i.bankid, cluster(bankid)

xtreg calc_advance newchair45   i.date i.bankid, cluster(bankid)

/*xtreg LLPtolagloan newchairqtrend   i.date i.bankid, cluster(bankid)*/




xtreg LLPtolagloan  newchair profitratio nparatio nparationext npanextchair incomechair npachair i.date i.bankid, cluster(bankid)

xtreg  loaninc newchair i.date if (join_date!=.& bankindex==1), cluster(bankid) fe


/*interaction Terms newchairend*/

gen npachairend= nparatio*newchairend
 gen npanextchairend= nparationext*newchairend
gen incomechairend= profitratio*newchairend
gen chairendprofittosales=profittosales*newchairend
gen chairendprofitratio= newchairend * profitratio

xtreg  LLPtolagloan newchairend profitratio nparationext nparatio npanextchairend incomechairend i.date i.bankid, cluster(bankid)
xtreg  LLPtosales newchairend profittosales  nparationext nparatio  npanextchairend chairendprofittosales   i.date i.bankid, cluster(bankid)
xtreg  LLPtolagloan newchairend  i.date i.bankid, cluster(bankid)
xtreg  LLPtoloan newchairend  i.date i.bankid, cluster(bankid)
xtreg  LLPtosales newchairend  i.date i.bankid, cluster(bankid)
xtreg  LLPtosales newchair  i.date i.bankid, cluster(bankid)














xtreg LLPtosales newchair  CAR gdp  inflation gsec  i.bankid, cluster(bankid) 


xtreg netprofittosales  newchair  CAR gdp  inflation gsec    i.bankid, cluster(bankid) 


xtreg LLPtolagloan npanextchairend chairendprofitratio newchairend  profitratio nparatio nparationext CAR gdp  inflation gsec i.bankid, cluster(bankid)



/*Final Tables*/

/*Table 3- LLP To Sales*/
/*LLP to sales*/
** column 1 **
xtreg LLPtosales newchair  i.date i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table3.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket replace

** column 2 **
xtreg LLPtosales newchair  CAR  gdp  inflation gsec  i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table3.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

** column 3 **
xtreg LLPtosales newchairend  i.date i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table3.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

** column 4 **
xtreg LLPtosales newchairend  CAR gdp  inflation gsec    i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table3.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append


/*Table 4*/
/* Profit and Profit before provisions*/
** column 1 **
xtreg profittosales newchair  i.date i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket replace
** column 2 **
xtreg profittosales  newchair  CAR gdp  inflation gsec   i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append
** column 3 **
xtreg profittosales newchairend  i.date i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append
** column 4 **
xtreg profittosales  newchairend  CAR gdp  inflation gsec  i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append
** column 5 **
xtreg netprofittosales  newchair  i.date i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append
** column 6 **
xtreg netprofittosales  newchair  CAR gdp  inflation gsec   i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append
** column 7 **
xtreg netprofittosales newchairend  i.date i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append
** column 8 **
xtreg netprofittosales  newchairend  CAR gdp  inflation gsec   i.bankid, cluster(bankid) 
outreg2 using "...\Tables\table4.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append


/*Table 5*/
/* Relationship between Provision and NPAS- Bushman and Williams*/

xtreg LLPtolagloan  nparatio nparationext i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket replace

xtreg LLPtolagloan profitratio nparatio nparationext i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg LLPtolagloan npanextchairend newchairend  profitratio nparatio nparationext i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg LLPtolagloan npanextchairend chairendprofitratio newchairend  profitratio nparatio nparationext i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg LLPtolagloan npanextchairend chairendprofitratio newchairend  profitratio nparatio nparationext CAR gdp  inflation gsec  i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append


/* with LLPtosales*/

xtreg  LLPtosales nparationext nparatio    i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg  LLPtosales  profittosales  nparationext nparatio    i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg  LLPtosales npanextchairend newchairend profittosales  nparationext nparatio     i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg  LLPtosales npanextchairend chairendprofittosales newchairend profittosales  nparationext nparatio     i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg  LLPtosales npanextchairend chairendprofittosales newchairend profittosales  nparationext nparatio  CAR gdp  inflation gsec   i.date i.bankid, cluster(bankid)
outreg2 using "...\Tables\table5.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append


/*Table 6- Lending Result*/



xtreg advancegnpa newchair_yearend i.bankid i.date, cluster(bankid)
outreg2 using "...\Tables\table6.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket replace

xtreg advancegnpa newchair_yearend  CAR gdp  inflation gsec   i.bankid, cluster(bankid)
outreg2 using "...\Tables\table6.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg advancegnpa newchair  i.bankid i.date, cluster(bankid)
outreg2 using "...\Tables\table6.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append

xtreg advancegnpa newchair i.date  i.bankid, cluster(bankid)
outreg2 using "...\Tables\table6.xls",  addstat(Adjusted R-squared, e(r2_o))  dec(3) tstat coefastr bracket append





xtreg advancegnpa newchair_yearend gdp  inflation gsec  i.bankid i.date, cluster(bankid)



xtreg LLPtosales newchair  CAR Assets  interest_expenses  i.date i.bankid, cluster(bankid) 


xtreg LLPtosales newchairend  i.date i.bankid, cluster(bankid) 


xtreg LLPtosales newchairend  CAR Assets  interest_expenses  i.date i.bankid, cluster(bankid) 





xtreg profittosales newchair i.date i.bankid, cluster(bankid) 

xtreg profittosales newchair CAR Assets  interest_expenses  i.date i.bankid, cluster(bankid) 



xtreg netprofittosales newchair  i.date i.bankid, cluster(bankid) 

xtreg netprofittosales newchair CAR Assets  interest_expenses   i.date i.bankid, cluster(bankid) 
