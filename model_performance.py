import saspy
import pandas as pd

sas = saspy.SASsession(cfgfile='sascfg_personal.py', verify=False)

c = sas.submitLST("""

""")