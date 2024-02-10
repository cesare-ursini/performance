import saspy
#import pandas as pd

############################ VARIABILI - INIZIO ############################

#URL del source code SAS per il test
source_url="https://raw.githubusercontent.com/cesare-ursini/performance/main/performance.sas"

#URL del dataset CSV da utilizzare per il test
csv_url="https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/creditscores.csv"

#Numero massimo di osservazioni da utilzzare per il test
max_obs=1000

############################ VARIABILI - FINE ############################

#Creazione della sessione SAS
sas = saspy.SASsession(cfgfile='sascfg_personal.py', verify=False)

#Creazione macro variabili SAS a partire dalle variabili Python
sas.symput("source_url", source_url)
sas.symput("csv_url", csv_url)
sas.symput("max_obs", max_obs)

#Submit del codice principale
sub = sas.submitLOG('''
filename infile URL "&source_url.";
%include infile / source2;
''')

#Chiusura sessione SAS
sas.endsas()