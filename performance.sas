%let CASLIB=CASUSER;
%let TAB=INPUT_TAB;

%macro model_perf;

    cas;
    caslib _all_ assign;

	filename scrdata temp;
	
	%put Downloading dataset ...;
	
	proc http
	   url="&csv_url."
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

    %put Vengono selezionate massimo &max_obs. osservazioni.;

    proc surveyselect   data=&CASLIB..&TAB. method=srs n=&max_obs.
                        out=&CASLIB..MODEL seed=55555;
    run;

    proc delete data=&CASLIB..&TAB.;
    run;

    /*** GB ***/
    %let _sdtm=%sysfunc(datetime());

    proc gradboost data=&CASLIB..MODEL seed=55555 noprint;
        input Age Credit_Score Income Number_of_Open_Credit_Cards Payment_History Region_FIPS State_FIPS Total_Debt Zipcode / level = interval;
        target state /level=nominal;
        /*output out=&CASLIB..score_at_runtime;*/
    run;

    %let _edtm=%sysfunc(datetime());
    %let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
    %put %sysfunc(putn(&_sdtm, datetime20.)) - Tempo esecuzione per &max_obs. osservazioni: &_runtm secondi;
	
    /*** RF ***/		
    /*** ... ***/

    proc delete data=&CASLIB..MODEL;
    run;

%mend;
%model_perf;