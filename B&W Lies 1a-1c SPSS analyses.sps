*filter so only White Ps and Ps who passed attnchecks

USE ALL.
FILTER BY filter_$.
EXECUTE.

* Reverse code IMS item

RECODE IMS2 (1=9) (2=8) (3=7) (4=6) (5=5) (6=4) (7=3) (8=2) (9=1) INTO IMS2R.
EXECUTE.

*Chronbachs IMS

RELIABILITY
  /VARIABLES=IMS1 IMS3 IMS4 IMS5 IMS2R
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

*Chronbachs EMS

RELIABILITY
  /VARIABLES=EMS1 EMS2 EMS3 EMS4 EMS5
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

*Chronbachs Black contact

RELIABILITY
  /VARIABLES=elemB middB highB converB knowB
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

*Chronbachs White contact

RELIABILITY
  /VARIABLES=elemW middW highW converW knowW
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

 *create composite IMS,EMS, and contact variables

COMPUTE IMS=Mean(IMS1,IMS3,IMS4,IMS5,IMS2R).
EXECUTE.

COMPUTE EMS=Mean(EMS1,EMS3,EMS4,EMS5, EMS2).
EXECUTE.

COMPUTE Blackcontact=Mean(elemB,middB,highB,converB,knowB).
EXECUTE.

COMPUTE Whitecontact=Mean(elemW,middW,highW,converW,knowW).
EXECUTE.

*center variables

COMPUTE IMS_cent=IMS-[insert M value].
COMPUTE EMS_cent=EMS-[instert M value]
COMPUTE Blackcontact_cent=Blackcontact-[insert M value].
COMPUTE Whitecontact_cent=Whitecontact- [M value].

*IMS x EMS interaction terms

COMPUTE IMSXEMS_cent=IMS_cent*EMS_cent.

*low and high EMS and interaction terms for simple slopes

COMPUTE EMS_low=EMS_cent+ [insert SD value].
COMPUTE EMS_high=EMS_cent- [instert SD value].
COMPUTE IMSXEMS_low=IMS_cent*EMS_low.
COMPUTE IMSXEMS_high=IMS_cent*EMS_high.


*t-test Black-White criterion

T-TEST PAIRS=Bcrit WITH Wcrit (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

*IMSxEMS on Bcrit controlling for Wcrit

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Bcrit
  /METHOD=ENTER Wcrit IMS_cent EMS_cent IMSXEMS_cent.

*At low EMS

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Bcrit
  /METHOD=ENTER Wcrit IMS_cent EMS_low IMSXEMS_low.

*At high EMS

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Bcrit
  /METHOD=ENTER Wcrit IMS_cent EMS_high IMSXEMS_high.

*SOI senistivity analysis

T-TEST PAIRS=Bdprime WITH Wdprime (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.
