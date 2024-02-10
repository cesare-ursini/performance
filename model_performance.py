import saspy
import pandas as pd

sas = saspy.SASsession(cfgfile='sascfg_personal.py', verify=False)

c = sas.submitLST("""
filename infile URL "https://raw.githubusercontent.com/cesare-ursini/performance/main/performance.sas?token=GHSAT0AAAAAACOCCOSOYLHLOGM7LSW62TSUZOITTJA";
%%include infile / source2;
""")

sas.endsas()