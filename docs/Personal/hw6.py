import pandas as pd
import numpy as np
from glob import glob
import re
import shutil
import subprocess
import os

dirname = 'assignments/HW/data/'
os.system('tar zxvf '+dirname+' seerdata.tgz')
fnames = glob(dirname+'sect*.csv')
cancers =[]
for f in fnames:
  with open(f) as myfile:
    cancers.append(myfile.readlines()[1])

template = "Cancer of the ([A-Za-z]+)"
cancers2 = [re.findall(template, u)[0] for u in cancers]
for i in range(len(fnames)):
  shutil.copyfile(fnames[i], 'tmp.txt')
  os.system('head -n 48 tmp.txt > tmp2.txt')
  shutil.copyfile('tmp2.txt',dirname+cancers2[i]+'.csv')
os.system('rm -f sect*.csv')


