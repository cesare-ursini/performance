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
		call symputx("NROWS",rows.numrows);
	run;
	quit;
	
	filename scrdata clear;

	%put Il numero di osservazioni nel dataset &NROWS.;
	%put Il limite massimo di osservazioni per il test &max_obs.;

	%if %sysevalf(&NROWS.>&max_obs.) %then %do;
		%put Le osservazioni del dataset superano il numero massimo consentito;
		%put Il dataset verrà filtrato;

		%let MODEL_TAB=MODEL;
        %let MODEL_NOBS=&max_obs.;

	    proc surveyselect   data=&CASLIB..&TAB. method=srs n=&MODEL_NOBS.
	                        out=&CASLIB..&MODEL_TAB. seed=55555 noprint;
	    run;
		
	    proc delete data=&CASLIB..&TAB.;
	    run;
	%end;
	%else %do;
		%put Le osservazioni del dataset non superano il numero massimo consentito;
		%put Tutte le osservazioni disponibili verranno utilizzate;

		%let MODEL_TAB=&TAB.;
        %let MODEL_NOBS=&NROWS.;
	%end;

    /*** GB ***/
    %let _sdtm=%sysfunc(datetime());

    proc gradboost data=&CASLIB..&MODEL_TAB. seed=55555 noprint;
        input S1 C1 S2 C2 S3 C3 S4 C4 S5 C5 / level = interval;
        target P / level=nominal;
    run;

    %let _edtm=%sysfunc(datetime());
    %let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
    %put %sysfunc(putn(&_sdtm, datetime20.)) - GB - Tempo esecuzione per &MODEL_NOBS. osservazioni: &_runtm secondi;
	
    /*** RF ***/
	%let _sdtm=%sysfunc(datetime());

    proc forest data=&CASLIB..&MODEL_TAB. seed=55555 noprint;
        input S1 C1 S2 C2 S3 C3 S4 C4 S5 C5 / level = interval;
        target P / level=nominal;
    run;

    %let _edtm=%sysfunc(datetime());
    %let _runtm=%sysfunc(putn(&_edtm - &_sdtm, 12.4));
    %put %sysfunc(putn(&_sdtm, datetime20.)) - RF - Tempo esecuzione per &MODEL_NOBS. osservazioni: &_runtm secondi;

    proc delete data=&CASLIB..&MODEL_TAB.;
    run;
%mend;
%model_perf;