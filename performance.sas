%let CASLIB=CASUSER;
%let TAB=MODEL_TAB;


%macro model_perf;

	filename scrdata temp;
	
	%put Downloading dataset ...;
	
	proc http
	   url='https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/creditscores.csv'
	   out=scrdata;                                     
	run;
	
	%put Dataset Downloaded;
	
	proc cas;
	   upload
	      path="%sysfunc(pathname(scrdata))"
	      casOut={caslib="&CASLIB.", name="&TAB.", replace=TRUE}
	      importOptions="csv";
	run;
	quit;
	
	filename scrdata clear;

	%let max_iter=3;
	/* limite n osservazioni con print n obs in dataset e un unico ciclo*/
	%do _i=1 %to &max_iter.;
	
		%let n_obs=%sysevalf(10**&_i.);
	
		proc surveyselect data=&CASLIB..&TAB. method=srs n=&n_obs.
		                  out=&CASLIB..GB seed=55555;
		run;
	
		%let _sdtm=%sysfunc(datetime());
	
		/*** GB ***/
		proc gradboost data=&CASLIB..GB seed=55555 noprint;
		   input Age Credit_Score Income Number_of_Open_Credit_Cards Payment_History Region_FIPS State_FIPS Total_Debt Zipcode / level = interval;
		   target state /level=nominal;
		   output out=&CASLIB..score_at_runtime;
		run;

		/*** RF ***/		
		/*** ... ***/

		%let _edtm=%sysfunc(datetime());
		%let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
		%put %sysfunc(putn(&_sdtm, datetime20.)) - Tempo esecuzione per &n_obs. osservazioni: &_runtm secondi;
	
		proc delete data=&CASLIB..GB;
		run;
	
	%end;

%mend;
%model_perf;