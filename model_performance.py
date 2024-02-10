import saspy
import pandas as pd

sas = saspy.SASsession(cfgfile='sascfg_personal.py', verify=False)

c = sas.submit('''
filename infile URL "https://raw.githubusercontent.com/cesare-ursini/performance/main/performance.sas";
%include infile / source2;
''')
print(sas.lastlog())
sas.endsas()