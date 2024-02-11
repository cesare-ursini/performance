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
		simple.numRows result=rows  table={caslib="&CASLIB.",name="&TAB." } ; 
		call symputx("nrows",rows.numrows);
	run;
	quit;
	
	filename scrdata clear;

	%put Il numero di osservazioni nel dataset &nrows.;
	%put Il limite massimo di osservazioni per il test &max_obs.;

	%if %sysevalf(&nrows.>&max_obs.) %then %do;
		%put Le osservazioni del dataset  superano il numero massimo consentito.
		%put Il dataset verrà filtrato.

		%let MODEL_TAB=MODEL;

	    proc surveyselect   data=&CASLIB..&TAB. method=srs n=&max_obs.
	                        out=&CASLIB..&MODEL_TAB. seed=55555 noprint;
	    run;
		
	    proc delete data=&CASLIB..&TAB.;
	    run;
	%end;
	%else %do;
		%put Le osservazioni del dataset non superano il numero massimo consentito.
		%put Tutte le osservazioni disponibili verranno utilizzate.

		%let MODEL_TAB=&TAB.;
	%end;

    /*** GB ***/
    %let _sdtm=%sysfunc(datetime());

    proc gradboost data=&CASLIB..&MODEL_TAB. seed=55555 noprint;
        input _numeric_ / level = interval;
        target state /level=nominal;
    run;

    %let _edtm=%sysfunc(datetime());
    %let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
    %put %sysfunc(putn(&_sdtm, datetime20.)) - Tempo esecuzione per &max_obs. osservazioni: &_runtm secondi;
	
    /*** RF ***/		
    /*** ... ***/

    proc delete data=&CASLIB..&MODEL_TAB.;
    run;

%mend;
%model_perf;